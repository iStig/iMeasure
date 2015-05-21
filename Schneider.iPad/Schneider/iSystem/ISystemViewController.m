//
//  ISystemViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ISystemViewController.h"
#import "SystemDeviceView.h"
#import "SystemManager.h"
#import <QuartzCore/QuartzCore.h>
#import "SubDeviceView.h"
#import "ObjectiveLibModbus.h"
#import "ModbusAuxiliary.h"
#import "AudoView.h"

#define Left_Margin              220.0f
#define Device_View_Size         CGSizeMake(100.0f, 100.0f)

#define MCCB_VIDEO_TAG 11229
#define ACB_VIDEO_TAG  11228

@interface ISystemViewController ()
{
    UIButton            *_btnSave;
    UIButton            *_btn_mccb_video;
    UIButton            *_btn_acb_video;
    UIButton            *_btnSetIp;
    UIButton            *_btnRefresh;
    UIButton            *_btnDefault;
    
    UIImageView         *_set_ip_bg;
    UIButton            *_confirm_ip_btn;
    UITextField         *_txt_set_ip;
    
    UIScrollView        *_vSrollDeviceList;
    AudoView            *_audoView;
    UIView              *_audoBgView;

    UIImageView         *_vImgSystemBg;
    NSMutableArray      *_marrayDeviceFrame;
    NSMutableArray      *_marrayPositionInfo;
    NSMutableArray      *_marrayDevices;
    
    SystemManager       *_systemManager;
    DeviceManagerView   *_deviceManagerView;
    CommunicationManager *_comManager;
    
    ///devices communication
    NSInteger           _device_id;
    NSMutableArray      *_marray_devices_rqt;
    ObjectiveLibModbus  *_modbus_object;
    NSMutableDictionary *_mdict_device_model;
   
}
@end

@implementation ISystemViewController

- (void)dealloc
{
    [_set_ip_bg release];
    [_txt_set_ip release];
    [_confirm_ip_btn release];
    [_btnSetIp release];
    [_btnRefresh release];
    [_audoBgView release];
    [_audoView release];
    [_btn_mccb_video release];
    [_btn_acb_video release];
    [_modbus_object release];
    [_marray_devices_rqt release];
    [_marrayDevices release];
    [_btnSave release];
    [_vImgSystemBg release];
    [_vSrollDeviceList release];
    [_deviceManagerView release];
    [_marrayDeviceFrame release];
    [_marrayPositionInfo release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _systemManager = [SystemManager shareManager];
        _comManager = [CommunicationManager commManager];
        _comManager.connect_delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load device view method -
- (void)loadDeviceFrame
{    
    CGRect lt = CGRectMake(285, 83, 190, 216);                                          ///left top
    CGRect mt = CGRectMake(lt.origin.x + lt.size.width + 10, lt.origin.y, 222, 216);    ///middle top
    CGRect rt = CGRectMake(mt.origin.x + mt.size.width + 10, lt.origin.y, 211, 216);    ///right top
    CGRect lb = CGRectMake(lt.origin.x, lt.origin.y + lt.size.height + 30, 170, 219);   ///left bottom
    CGRect mb = CGRectMake(lb.origin.x + lb.size.width + 10, lb.origin.y, 224, 219);    ///middle bottom
    CGRect rb = CGRectMake(mb.origin.x + mb.size.width + 10, lb.origin.y, 227, 219);    ///right bottom
    
    _marrayDeviceFrame = [[NSMutableArray alloc] initWithObjects:
                          [NSValue valueWithCGRect:lt],
                          [NSValue valueWithCGRect:mt],
                          [NSValue valueWithCGRect:rt],
                          [NSValue valueWithCGRect:lb],
                          [NSValue valueWithCGRect:mb],
                          [NSValue valueWithCGRect:rb], nil];
}

- (void)refreshDeviceManagerView
{
    ///first load target frame array
    NSArray *deviceKey = [_mdict_device_model allKeys];
    ///device views array
    NSMutableArray *marrayFreeViews = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [deviceKey count]; i ++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[_mdict_device_model objectForKey:[deviceKey objectAtIndex:i]]];
        [dict setValue:[NSNumber numberWithInt:[[deviceKey objectAtIndex:i] intValue]] forKey:kDeviceIdKey];
        [dict setValue:@"isystem_middle.png" forKey:kNorImageKey];
        [dict setValue:@"isystem_middle_sel.png" forKey:kSelImageKey];
        CGRect startFrame = CGRectZero;
        startFrame = CGRectMake(0, 58 * i, 238, 58);
        SystemDeviceView *device = [[SystemDeviceView alloc] initWithStartFrame:startFrame targetFrame:_marrayDeviceFrame modbusIp:[NSString stringWithFormat:Device_IP_Empty] port:Device_Port device_id:i + 1];
        device.device_information = dict;
        [_vSrollDeviceList addSubview:device];
        [marrayFreeViews addObject:device];
        [device release];
        [dict release];
    }
    _vSrollDeviceList.contentSize = CGSizeMake(200, 58 * [deviceKey count]);

    ///selected history
    SystemDeviceView *emptyDevice = [[SystemDeviceView alloc] initWithStartFrame:CGRectZero targetFrame:nil modbusIp:Device_IP_Empty port:Device_Port device_id:999];
    
    ///find selected view
    ///第一步，先把本次没有获取的设备去掉
    ///load last devices struct
    NSArray *arrayOriginHistoryStruct = [_systemManager devicePositionInfo];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrayOriginHistoryStruct count]; i ++) {
        NSDictionary *selected = [arrayOriginHistoryStruct objectAtIndex:i];
        BOOL remove_device = YES;
        for (NSString *strDevice_id in [_mdict_device_model allKeys]) {
            if ([strDevice_id intValue] ==
                [[selected objectForKey:kDeviceIdKey] intValue]) {
                remove_device = NO;
                break;
            }
        }
        if (!remove_device) {
            [marray addObject:selected];
        } else {
            [marray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES],@"device_empty", nil]];
        }
    }
    [_systemManager setMarrayDevicePositionInfo:marray];
    [_systemManager save];
    [marray release];
    
    ///处理后的
    NSArray *arrayHistoryStruct = [_systemManager devicePositionInfo];
    NSMutableArray *marraySelectedViews = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [arrayHistoryStruct count] ;i ++) {
        NSDictionary *selected = [arrayHistoryStruct objectAtIndex:i];
        ///position is not empty
        if (![[selected objectForKey:kPositionEmptyKey] boolValue]) {
            ///positon is not empty
            for (SystemDeviceView *systemDevice in marrayFreeViews) {
                if ([systemDevice device_id] == [[selected objectForKey:kDeviceIdKey] intValue]) {
                    [marraySelectedViews addObject:systemDevice];
                }
            }
        } else {
            [marraySelectedViews addObject:emptyDevice];
        }
    }
    ///device manager view
    _deviceManagerView = [[DeviceManagerView alloc] initWithFrame:CGRectMake(10, 26, 978, 628)
                                                    fangxiang:kVerticalDirection
                                                      deviceFrame:CGRectMake(5, 5, 190, 190)
                                                      targetFrame:_marrayDeviceFrame
                                                      freeDevices:marrayFreeViews
                                                  selectedDevices:marraySelectedViews
                                                       scrollview:_vSrollDeviceList
                                                        superView:_contentView
                                                        delegate:self];
    _deviceManagerView.layer.cornerRadius = 8.0f;
    [marraySelectedViews release];
    [marrayFreeViews release];
    [_contentView addSubview:_deviceManagerView];
    [self.view bringSubviewToFront:_btn_acb_video];
    [self.view bringSubviewToFront:_btn_mccb_video];
    [_contentView bringSubviewToFront:_audoView];
}

- (void)loadDeviceSubViews
{
    _marrayDevices = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_marrayDeviceFrame count]; i++) {
        SubDeviceView *subView = [[SubDeviceView alloc] init];
        if (i == 1) {
            subView.device_type = B_Device_Type;
        } else if (i == 2) {
            subView.device_type = L_Device_Type;
        } else if (i == 5) {
            subView.device_type = R_Device_Nsx_Type;
        } else {
            subView.device_type = R_Device_Type;
        }
        subView.rect = [[_marrayDeviceFrame objectAtIndex:i] CGRectValue];
        CGPoint center = subView.center;
        ///_device manger view offset
        center.x += 10;
        center.y += 26;
        subView.center = center;
        [_contentView addSubview:subView];
        [_marrayDevices addObject:subView];
        [subView release];
    }
}

- (void)refreshDeviceList
{
    _device_id = 1;
    
    for (UIView *view in [_vSrollDeviceList subviews]) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < [[_systemManager marrayDevicePositionInfo] count]; i ++) {
        SubDeviceView *subView = (SubDeviceView *)[_marrayDevices objectAtIndex:i];
        if (subView) {
            [subView unSelect];
        }
    }
    
    [_mdict_device_model removeAllObjects];
    [_deviceManagerView removeFromSuperview];
    [_deviceManagerView release];
    _deviceManagerView = nil;
    [self devicesCommunication];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    
    saveUDObject(@"否", Default_Device);
    NSLog(@"%@",getUIObjectForKey(Default_Device));
    
    [self setTitleImage:@"isystem_title.png"];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    
    //System background
    _vImgSystemBg = [[UIImageView alloc] initWithFrame:CGRectMake(265, 26, 723, 629)];
    _vImgSystemBg.image = [UIImage imageNamed:@"isystem_struct.png"];
    [_contentView addSubview:_vImgSystemBg];
    [self loadDeviceFrame];
    [self loadDeviceSubViews];
        
    //Device list
    _vSrollDeviceList = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 238, 628)];
    _vSrollDeviceList.backgroundColor = colorWithHexString(@"b5b5b5");
    _vSrollDeviceList.delegate = self;
    _vSrollDeviceList.clipsToBounds = NO;
    
    
    //default device system button
    _btnDefault = [[UIButton alloc] initWithFrame:CGRectMake(940, 7, 48, 48)];
    [_btnDefault setImage:[UIImage imageNamed:@"demo_style.png"] forState:UIControlStateNormal];
    [_btnDefault addTarget:self action:@selector(defaultButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:_btnDefault];
    
    //Save device system button
    _btnSave = [[UIButton alloc] initWithFrame:CGRectMake(880, 7, 48, 48)];
    [_btnSave setImage:[UIImage imageNamed:@"isystem_save_btn.png"] forState:UIControlStateNormal];
    [_btnSave addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:_btnSave];
    
    _btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(820, 7, 48, 48)];
    [_btnRefresh setImage:[UIImage imageNamed:@"isystem_refresh_btn.png"] forState:UIControlStateNormal];
    [_btnRefresh addTarget:self action:@selector(refreshButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([getUIObjectForKey(Default_Login) isEqualToString:@"normal"]) {
        _btnRefresh.hidden = YES;
    }
    
    [self.navBar addSubview:_btnRefresh];

    ///set ip button
    _btnSetIp = [[UIButton alloc] initWithFrame:CGRectMake(760, 7, 48, 48)];
    [_btnSetIp setImage:[UIImage imageNamed:@"set_ip_btn.png"] forState:UIControlStateNormal];
    [_btnSetIp addTarget:self action:@selector(setIpAddressButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([getUIObjectForKey(Default_Login) isEqualToString:@"normal"]) {
        _btnSetIp.hidden = YES;
    }
    
    [self.navBar addSubview:_btnSetIp];
    
    _set_ip_bg = [[UIImageView alloc] initWithFrame:CGRectMake(265, 4, 491, 56)];
    _set_ip_bg.image = [UIImage imageNamed:@"isystem_set_ip_bg.png"];
    _set_ip_bg.userInteractionEnabled = YES;
    [self.navBar addSubview:_set_ip_bg];
    
    _confirm_ip_btn = [[UIButton alloc] initWithFrame:CGRectMake(341, 9, 118, 40)];
    [_confirm_ip_btn setImage:[UIImage imageNamed:@"confirm_btn.png"] forState:UIControlStateNormal];
    [_confirm_ip_btn addTarget:self action:@selector(confirmIpAddressButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_set_ip_bg addSubview:_confirm_ip_btn];
    
    _txt_set_ip = [[UITextField alloc] initWithFrame:CGRectMake(69, 15, 252, 26)];
    _txt_set_ip.backgroundColor = [UIColor clearColor];
    _txt_set_ip.font = [UIFont boldSystemFontOfSize:16.0f];
    _txt_set_ip.textColor = colorWithHexString(@"4fa600");
    _txt_set_ip.keyboardType = UIKeyboardTypeNumberPad;
    [_set_ip_bg addSubview:_txt_set_ip];
    _set_ip_bg.hidden = YES;
    _txt_set_ip.text = getUIObjectForKey(Device_IP_Key);
    
    _mdict_device_model = [[NSMutableDictionary alloc] init];
    
    [self refreshDeviceList];
    
    _btn_mccb_video = [[UIButton alloc] initWithFrame:CGRectMake(915, 52 + _contentView.frame.origin.y, 50, 50)];
    _btn_mccb_video.tag = MCCB_VIDEO_TAG;
    [_btn_mccb_video setImage:[UIImage imageNamed:@"mccb_video_btn.png"] forState:UIControlStateNormal];
    [_btn_mccb_video addTarget:self action:@selector(playVideoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_mccb_video];
    
    _btn_acb_video = [[UIButton alloc] initWithFrame:CGRectMake(840, 52 + _contentView.frame.origin.y, 50, 50)];
    _btn_acb_video.tag =ACB_VIDEO_TAG;
    [_btn_acb_video setImage:[UIImage imageNamed:@"acb_video_btn.png"] forState:UIControlStateNormal];
    [_btn_acb_video addTarget:self action:@selector(playVideoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_acb_video];
    
    _audoBgView = [[UIView alloc] initWithFrame:_contentView.bounds];
    [self.view addSubview:_audoBgView];
    _audoView = [[AudoView alloc] initWithFrame:CGRectMake(0, 0, 397, 263)];
    _audoView.backgroundColor = [UIColor clearColor];
    [_audoBgView addSubview:_audoView];
    _audoBgView.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAudoView:)];
    [_audoBgView addGestureRecognizer:tap];
    [tap release];
}

- (void)hideAudoView:(UIGestureRecognizer *)gest
{
    _audoBgView.hidden = YES;
    [_audoView stopPlay];
}

- (void)playVideoButtonClicked:(UIButton *)btn
{
    [self.view bringSubviewToFront:_audoBgView];
    if (btn.tag == MCCB_VIDEO_TAG) {
        _audoView.frame = CGRectMake(515, 112, 397, 263);
        [self.view bringSubviewToFront:_btn_mccb_video];
        [_audoView playFile:@"MCCBvideo.mp4"];
    } else  {
        _audoView.frame = CGRectMake(440, 112, 397, 263);
        [self.view bringSubviewToFront:_btn_acb_video];
        [self.view bringSubviewToFront:_btn_mccb_video];
        [_audoView playFile:@"E53376B.mp4"];
    }
    
    _audoBgView.hidden = NO;
}

- (void)backButtonClicke:(UIButton *)btn
{
    [self xhDismissViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:0]; //左侧导航栏按钮状态 当前为isystem
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
#pragma mark - -
- (void)saveButtonClicked:(UIButton *)btn
{
    [_systemManager saveSystemStruct:_deviceManagerView.marraySelectedDeviceView];
    [self showInforAlert:@"Save device struct successed"];
}


- (void)defaultButtonClicked:(UIButton *)btn
{

    if (btn.selected) {
        // [self showInforAlert:@"device"];
        saveUDObject(@"否", Default_Device);
         [self refreshDeviceList];
    }
    else{
         [self showInforAlert:@"demo"];
        saveUDObject(@"是", Default_Device);
         [self refreshDeviceList];
      
    }
      btn.selected = !btn.selected;
   NSLog(@"%@",getUIObjectForKey(Default_Device));
    
}
- (void)refreshButtonClicked:(UIButton *)btn
{
    [self refreshDeviceList];
}

- (void)setIpAddressButtonClicked:(UIButton *)btn
{
    _set_ip_bg.hidden = !_set_ip_bg.hidden;
}

- (void)confirmIpAddressButtonClicked:(UIButton *)btn
{
    //if (isCorrenctIP(_txt_set_ip.text)) {
    if ([_txt_set_ip.text length]) {
        saveUDObject(_txt_set_ip.text, Device_IP_Key);
        _set_ip_bg.hidden = YES;
        [_txt_set_ip resignFirstResponder];
        [self refreshDeviceList];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Input Ip Adress is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - device commonent delegate method -
- (void)unSelectedTargetFrame:(int)target_index device:(DeviceView *)deviceView
{
    SubDeviceView *subView = (SubDeviceView *)[_marrayDevices objectAtIndex:target_index];
    if (subView) {
        [(SystemDeviceView *)deviceView showDeviceInformation];
        [subView unSelect];
    }
}

- (void)targetFrame:(int)target_index selectedBy:(DeviceView *)deviceView
{
    SubDeviceView *subView = (SubDeviceView *)[_marrayDevices objectAtIndex:target_index];
    if (subView) {
        [(SystemDeviceView *)deviceView hideDeviceInformation];
        [subView selectByDeviceInfo:deviceView.device_information];
    }
}

#pragma mark - isystem communication -
- (void)devicesCommunication
{
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
      
        NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
        [mdict setValue:@"5.0" forKey:kDeviceVersionKey];
        [mdict setValue:@"E" forKey:kDeviceModelKey];
        [mdict setValue:@"N/A" forKey:kDeviceBreakerNameKey];
        [mdict setValue:[NSNumber numberWithInt:31] forKey:kDeviceSystemTypeSettingKey];
        [_mdict_device_model setValue:mdict forKey:[NSString stringWithFormat:@"%d",18]];
        [self refreshDeviceManagerView];
    }
    else{
    
    NSString *ip = getUIObjectForKey(Device_IP_Key);
    if (_modbus_object) {
        [_modbus_object release];
        _modbus_object = nil;
    }
    _modbus_object = [[ObjectiveLibModbus alloc] initWithTCP:ip port:Device_Port device:_device_id];
    [_modbus_object connect:^{
        NSLog(@"connect is successed");
     
        [self showLoadingView:YES];
        [self getDeviceModel];
    } failure:^(NSError *error) {
        NSLog(@"connect is failed");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Connect Failed, Pls make sure your ip address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
        }];
    }
  }

- (void)getDeviceModel
{
    ///device is connect
    if (_device_id <= Device_Count) {
        [self progressLoadingView:@"Scanning" index:_device_id count:Device_Count];
        NSString *ip = getUIObjectForKey(Device_IP_Key);
        [_modbus_object setupTCP:ip port:Device_Port device:_device_id];
        register_str regist = device_model();
        [_modbus_object readRegistersFrom:regist.start_address
                                    count:regist.register_count
                                  success:^(NSArray *array) {
                                      NSLog(@"device successed %d \n%@",_device_id,array);
                                      [_marray_devices_rqt addObject:[NSNumber numberWithInt:_device_id]];
                                      [self parseModelRespond:array];
                                      ///system type setting
                                      //[self getSystemTypeSetting];
                                      [self getBreakerName];
                                  }
                                  failure:^(NSError *error){
                                      NSLog(@"get device %d model failed ",_device_id);
                                      NSLog(@"%@",error.description);
                                      _device_id ++;
                                      //[self performSelector:@selector(getDeviceModel) withObject:nil afterDelay:2.0];
                                     [self getDeviceModel];
                                  }];
    } else {
        [_modbus_object disconnect];
        [_modbus_object release];
        _modbus_object = nil;
        
        [self refreshDeviceManagerView];
        [self showLoadingView:NO];
    }
}

- (void)parseModelRespond:(NSArray *)modelRespond
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    NSArray *arrayModel = parseAsc(modelRespond);
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [arrayModel count]; i ++) {
        if (!i) {
            NSString *str_version = [NSString stringWithFormat:@"%c.%c",
                                     [[[arrayModel objectAtIndex:i] objectAtIndex:0] charValue],
                                     [[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
            [mdict setValue:str_version forKey:kDeviceVersionKey];
            [mstr appendString:str_version];
        } else if (i == 1) {
            NSString *strModel = [NSString stringWithFormat:@"%c",
                                  [[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
            [mdict setValue:strModel forKey:kDeviceModelKey];
            [mstr appendString:strModel];
        }
    }
    [_mdict_device_model setValue:mdict forKey:[NSString stringWithFormat:@"%d",_device_id]];
    [mdict release];
    [mstr release];
}

- (void)getBreakerName
{
    [_modbus_object readRegistersFrom:9845
                             count:8
                           success:^(NSArray *array){
                               NSMutableString *mstr_break_name = [[NSMutableString alloc] init];
                               NSArray *array_asc = parseAsc([array subarrayWithRange:NSMakeRange(2, 6)]);
                               for (int i = 0; i < [array_asc count]; i ++) {
                                   if ([[array objectAtIndex:0] intValue] == Undisplay_num) {
                                       [mstr_break_name appendFormat:@"N/A"];
                                       break;
                                   }
                                   NSArray *sub_value = [array_asc objectAtIndex:i];
                                   [mstr_break_name appendFormat:@"%c%c",
                                    [[sub_value objectAtIndex:0] charValue],
                                    [[sub_value objectAtIndex:1] charValue]];
                               }
                               
                               NSMutableDictionary *mdict = [_mdict_device_model objectForKey:
                                                             [NSString stringWithFormat:@"%d",_device_id]];
                               [mdict setValue:mstr_break_name forKey:kDeviceBreakerNameKey];
                               [mstr_break_name release];
                               
                               [self getSystemTypeSetting];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

- (void)getSystemTypeSetting
{
    [_modbus_object readRegistersFrom:system_type_setting().start_address
                            count:system_type_setting().register_count
                          success:^(NSArray *array){
                              NSMutableDictionary *mdict = [_mdict_device_model objectForKey:
                                                            [NSString stringWithFormat:@"%d",_device_id]];
                              [mdict setValue:[NSNumber numberWithInt:
                                               [[array lastObject] intValue]] forKey:kDeviceSystemTypeSettingKey];
                              _device_id ++;
                              //[self performSelector:@selector(getDeviceModel) withObject:nil afterDelay:2.0];
                              [self getDeviceModel];
                          } failure:^(NSError *error){
                              _device_id ++;
                              [self getDeviceModel];
                              //[self performSelector:@selector(getDeviceModel) withObject:nil afterDelay:2.0];
                          }];
}
@end
