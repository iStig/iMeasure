//
//  IControlViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-15.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "IControlViewController.h"
#import "CustomObjectModbus.h"
#import "SystemManager.h"

typedef enum {
    NonState = 0,
    OldPwdState,
    NewPwdState,
}ChangePwdState;

@interface IControlViewController ()
{
    CustomObjectModbus *_obj;
    
    ///read on step 2,and use on setp 3 & 6
    NSInteger          _control_content;
    ///control type open or close
    BOOL               _is_open;
    
    SwitchView          *_switch_view;
    int                 _device_index;
    NSMutableArray      *_marray_device_state;
    NSMutableArray      *_array_devices_state;
    
    ControlSpecialStruct *_vSystemStruct;
    NSMutableArray       *_marray_modbusObjs;
    SystemManager        *_systemManager;
    
    ///change password
    UIImageView         *_set_ip_bg;
    UIButton            *_confirm_ip_btn;
    UITextField         *_txt_set_ip;
    
    ChangePwdState      _change_pwd_state;

    int                 _command_number;
    int                 _operating_index;
    int                 _operating_type;
    int                 _flag;
    
    
    UIView              *_view_password_bg;
    UIImageView         *_vImg_password;
    UITextField         *_txt_password;
    UITextField         *_txt_password_other;
}

@property (nonatomic, retain) CustomObjectModbus *obj;
@property (nonatomic, retain) NSMutableArray *array_devices_state;

@end

@implementation IControlViewController
@synthesize obj = _obj;

- (void)dealloc
{
    [_obj release];
    [_set_ip_bg release];
    [_vImg_password release];
    [_view_password_bg release];
    [_array_devices_state release];
    [_txt_password release];
    [_confirm_ip_btn release];
    [_txt_set_ip release];
    [_vSystemStruct release];
    [_marray_modbusObjs release];
    [_marray_device_state release];
    [_switch_view release];
    [_txt_password_other release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _marray_device_state = [[NSMutableArray alloc] init];
        _systemManager = [SystemManager shareManager];
    }
    return self;
}

- (void)loadSystemStruct
{
    ///1.system struct user interface
    UIImageView *imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 14, 957, 629)];
    imageBg.image = [UIImage imageNamed:@"struct_bg.png"];
    imageBg.userInteractionEnabled = YES;
    [_contentView addSubview:imageBg];
    [imageBg release];
    
    _vSystemStruct = [[ControlSpecialStruct alloc] initWithFrame:CGRectMake(82, 27, 0, 0)];
    [_contentView addSubview:_vSystemStruct];
    _marray_modbusObjs = [[NSMutableArray alloc] init];
    ///2.device modbus objects
}

- (void)changePasswordButtonClicked:(UIButton *)btn
{
    _txt_set_ip.text = @"";
    _change_pwd_state = OldPwdState;
    _set_ip_bg.image = [UIImage imageNamed:@"old_change_pwd_bg.png"];
    _set_ip_bg.hidden = !_set_ip_bg.hidden;
}

- (void)confirmButtonClicked:(UIButton *)btn
{
    if (_change_pwd_state == OldPwdState) {
        if ([getUIObjectForKey(Control_User_Pwd) isEqualToString:_txt_set_ip.text]) {
            _change_pwd_state = NewPwdState;
            _set_ip_bg.image = [UIImage imageNamed:@"change_pwd_bg.png"];
            _txt_set_ip.text = @"";
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The old password is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    } else if (_change_pwd_state == NewPwdState) {
        if (![_txt_set_ip.text length]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"New password can't be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            [_txt_set_ip resignFirstResponder];
        } else {
            saveUDObject(_txt_set_ip.text, Control_User_Pwd);
            _txt_set_ip.text = @"";
            _change_pwd_state = OldPwdState;
            _set_ip_bg.hidden = !_set_ip_bg.hidden;
            [_txt_set_ip resignFirstResponder];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Change password successed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitleImage:@"icontrol_title.png"];

    [self loadSystemStruct];
    UIButton *btn_passwd = [[UIButton alloc] initWithFrame:CGRectMake(940, 7, 48, 48)];
    [btn_passwd setImage:[UIImage imageNamed:@"passwd_btn.png"] forState:UIControlStateNormal];
    [btn_passwd addTarget:self action:@selector(changePasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:btn_passwd];

    _set_ip_bg = [[UIImageView alloc] initWithFrame:CGRectMake(442, 4, 491, 56)];
    _set_ip_bg.image = [UIImage imageNamed:@"old_change_pwd_bg.png"];
    _set_ip_bg.userInteractionEnabled = YES;
    [self.navBar addSubview:_set_ip_bg];
    
    _confirm_ip_btn = [[UIButton alloc] initWithFrame:CGRectMake(341, 9, 118, 40)];
    [_confirm_ip_btn setImage:[UIImage imageNamed:@"confirm_btn.png"] forState:UIControlStateNormal];
    [_confirm_ip_btn addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_set_ip_bg addSubview:_confirm_ip_btn];
    
    _txt_set_ip = [[UITextField alloc] initWithFrame:CGRectMake(162, 18, 156, 26)];
    _txt_set_ip.backgroundColor = [UIColor clearColor];
    _txt_set_ip.font = [UIFont boldSystemFontOfSize:16.0f];
    _txt_set_ip.textColor = colorWithHexString(@"4fa600");
    _txt_set_ip.keyboardType = UIKeyboardTypeNumberPad;
    [_set_ip_bg addSubview:_txt_set_ip];
    _set_ip_bg.hidden = YES;

	// Do any additional setup after loading the view.
    _switch_view = [[SwitchView alloc] initWithFrame:_contentView.bounds];
    _switch_view.backgroundColor = [UIColor clearColor];
    _switch_view.delegate = self;
    [_contentView addSubview:_switch_view];
    
    [self creatPasswordView];
}

- (void)creatPasswordView
{
    _view_password_bg = [[UIView alloc] initWithFrame:self.view.bounds];
    _view_password_bg.backgroundColor = [UIColor clearColor];
    UIView *view_cover = [[UIView alloc] initWithFrame:_view_password_bg.bounds];
    view_cover.backgroundColor = [UIColor blackColor];
    view_cover.alpha = 0.5;
    [_view_password_bg addSubview:view_cover];
    [view_cover release];
    [self.view addSubview:_view_password_bg];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHidePasswordView)];
    [_view_password_bg addGestureRecognizer:tap];
    [tap release];
    
//    _vImg_password = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_password.png"]];
    _vImg_password=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 350, 120)];
    [_vImg_password setImage:[[UIImage imageNamed:@"input_password.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    _vImg_password.center=self.view.center;
    
    _vImg_password.userInteractionEnabled = YES;
    [_view_password_bg addSubview:_vImg_password];
    
    _vImg_password.center = CGPointMake(self.view.frame.size.width / 2, 300);
    
    _txt_password = [[UITextField alloc] initWithFrame:
                     CGRectMake(10, 15, _vImg_password.frame.size.width - 50, 30)];
    _txt_password.font = [UIFont boldSystemFontOfSize:24.0f];
    _txt_password.textColor = [UIColor blackColor];
    _txt_password.secureTextEntry = YES;
    _txt_password.textAlignment = UITextAlignmentCenter;
    _txt_password.backgroundColor = [UIColor clearColor];
    _txt_password.placeholder = @"Operator Password";
    [_vImg_password addSubview:_txt_password];
    
    
    _txt_password_other = [[UITextField alloc] initWithFrame:CGRectMake(10, 75, _vImg_password.frame.size.width - 50, 30)];
    _txt_password_other.font = [UIFont boldSystemFontOfSize:24.0f];
    _txt_password_other.textColor = [UIColor blackColor];
    _txt_password_other.secureTextEntry = YES;
    _txt_password_other.textAlignment = UITextAlignmentCenter;
    _txt_password_other.backgroundColor=[UIColor clearColor];
    _txt_password_other.placeholder=@"Security Password";
    [_vImg_password addSubview:_txt_password_other];
    
    
    
    UIButton *confirm_btn = [[UIButton alloc] initWithFrame:
                             CGRectMake(_txt_password.frame.size.width , 0, 50, 60)];
    [confirm_btn setImage:[UIImage imageNamed:@"sel_box.png"] forState:UIControlStateNormal];
    [confirm_btn addTarget:self action:@selector(passwordConfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_vImg_password addSubview:confirm_btn];
    [confirm_btn release];
    
    
    UIButton *confirm_btn_other = [[UIButton alloc] initWithFrame:
                             CGRectMake(_txt_password_other.frame.size.width , 60, 50, 60)];
    [confirm_btn_other setImage:[UIImage imageNamed:@"sel_box.png"] forState:UIControlStateNormal];
    [confirm_btn_other addTarget:self action:@selector(passwordConfirmOtherButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_vImg_password addSubview:confirm_btn_other];
    [confirm_btn_other release];
    
    _view_password_bg.hidden = YES;
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDeviceStructView];
    [self selectFunctionButton:3];
    
    _device_index = 0;
    [_marray_device_state removeAllObjects];
    //[self checkDeviceState];
    [self checkDeviceStateCycle];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkDeviceState) object:nil];
}

- (void)tapHidePasswordView
{
    _view_password_bg.hidden = YES;
    [_txt_password resignFirstResponder];
    [_txt_password_other resignFirstResponder];
    _txt_password.text = @"";
    _txt_password_other.text = @"";
}

- (void)refreshDeviceStructView
{
    [_vSystemStruct refreshDeviceStructView];
    [_marray_modbusObjs removeAllObjects];
    for (int i = 0; i < [[_systemManager devicePositionInfo] count]; i ++) {
        NSDictionary *deviceInfo = [[[_systemManager devicePositionInfo] objectAtIndex:i] objectForKey:kDeviceInfoKey];
        NSString *strIP = getUIObjectForKey(Device_IP_Key);
        CustomObjectModbus *modbusObj = [[CustomObjectModbus alloc] initWithTCP:strIP port:Device_Port device:[[deviceInfo objectForKey:kDeviceIdKey] intValue] device_info:deviceInfo];
        [_marray_modbusObjs addObject:modbusObj];
        [modbusObj release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)passwordConfirmOtherButtonClicked:(UIButton *)btn
{
     _view_password_bg.hidden = YES;
    [_txt_password_other resignFirstResponder];
    if ([_txt_password_other.text isEqualToString:getUIObjectForKey(Control_Admin_Pwd)] ||
        [_txt_password_other.text isEqualToString:getUIObjectForKey(Control_User_Pwd)]) {
        
        [self sharedModeControl];

    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"your Security Password entered incorrectly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    _txt_password.text = @"";
    _txt_password_other.text = @"";
    
}

- (void)passwordConfirmButtonClicked:(UIButton *)btn
{
    //_view_password_bg.hidden = YES;
    [_txt_password resignFirstResponder];
    if ([_txt_password.text isEqualToString:getUIObjectForKey(Control_Admin_Pwd)] ||
        [_txt_password.text isEqualToString:getUIObjectForKey(Control_User_Pwd)]) {
        //[self sharedModeControl];
        [_txt_password_other becomeFirstResponder];
    } else {
        _txt_password.text = @"";
        [_txt_password becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"your Operator Password entered incorrectly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
   
}

#pragma mark - UITextfiled delegate method -

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{

}          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField{

}           // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called


#pragma mark - Switch view delegate method -
- (void)device:(int)index switchIsChanged:(BOOL)close
{
    //yes 闭合开关，打开设备
    ///no
    self.obj = [_marray_modbusObjs objectAtIndex:index];
    if ([self.obj device_id]) {
        _view_password_bg.hidden = NO;
        [_txt_password becomeFirstResponder];
        _operating_index = index;
        _operating_type = close;
        _is_open = !close;
    
}
}

#pragma mark - step method -

- (void)checkDeviceStateCycle
{
    _device_index = 0;
    [_marray_device_state removeAllObjects];
    [self checkDeviceState];
}

- (void)appendDeviceState:(int)state
{
    ///0 open
    ///1 close
    [_marray_device_state addObject:[NSNumber numberWithInt:state]];
    _device_index ++;
    if (_device_index < [_marray_modbusObjs count]) {
        [self checkDeviceState];
    } else {
        self.array_devices_state = _marray_device_state;
        [_switch_view setMarray_switch_state:self.array_devices_state];
        [self performSelector:@selector(checkDeviceStateCycle) withObject:nil afterDelay:1.5];
    }
}

- (void)checkDeviceState
{
    CustomObjectModbus *obj = [_marray_modbusObjs objectAtIndex:_device_index];
    int address;
    NSMutableArray *marray_sel_modbus = [[NSMutableArray alloc] init];
    if (obj) {
        NSDictionary *dict = [[_systemManager deviceInfomationOfPosition:_device_index] objectForKey:kDeviceInfoKey];
        NSString *str_device_name = [NSString stringWithFormat:@"%@_%.1f %d",
                                     [dict objectForKey:kDeviceModelKey],
                                     [[dict objectForKey:kDeviceVersionKey] floatValue],
                                     [[dict objectForKey:kDeviceIdKey] intValue]];
        NSDictionary *dic_obj = [[NSDictionary alloc] initWithObjectsAndKeys:[_marray_modbusObjs objectAtIndex:_device_index],@"modbus",str_device_name, @"name", nil];
        
        [marray_sel_modbus addObject:dic_obj];
        [dic_obj release];
    }

    
    NSString *str_name = [[marray_sel_modbus objectAtIndex:0] objectForKey:@"name"];
    NSArray *arrayinfo = [str_name componentsSeparatedByString:@" "];
    arrayinfo = [[arrayinfo objectAtIndex:0] componentsSeparatedByString:@"_"];

    NSString *str_version = [arrayinfo objectAtIndex:1];
    NSArray *array_sub = [str_version componentsSeparatedByString:@"."];
    str_version = [array_sub objectAtIndex:1];
    if (![str_version isEqualToString:@"0"]) {
        address = 12000;
    } else {
        address = 660;
    }
    if (obj.device_id) {
        [obj readRegistersFrom:address
                          count:1
                        success:^(NSArray *array){
                            
                            int state = [[array lastObject] intValue] & 1;
                               NSLog(@"%d",state);
                            [self appendDeviceState:state];
                        } failure:^(NSError *error){
                            [self appendDeviceState:0];
                            //errorMessageAlert(@"", error.description);
                        }];
    } else {
        [self appendDeviceState:0];
    }
}

- (void)sharedModeControl
{
    NSArray *values = nil;
    BOOL _is_new_command = NO;
    NSDictionary *dict_device_info = [_obj device_information];
    if (dict_device_info) {
        NSString *str_version = [dict_device_info objectForKey:kDeviceVersionKey];
        NSArray *array_version = [str_version componentsSeparatedByString:@"."];
        if ([array_version count] == 2) {
            if ([[array_version lastObject] intValue] != 0) {
                _is_new_command = YES;
            }
        }
    }
    
    if (!_is_new_command) {
        if (_is_open) {
            values = [NSArray arrayWithObjects:[NSNumber numberWithInt:57400],
                      [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                      [NSNumber numberWithInt:1],[NSNumber numberWithInt:0] ,nil];
        } else {
            values = [NSArray arrayWithObjects:[NSNumber numberWithInt:57400],
                      [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                      [NSNumber numberWithInt:0],[NSNumber numberWithInt:0] ,nil];
        }
        [_obj writeRegistersFromAndOn:7699
                             toValues:values
                              success:^(NSArray *array){
                                  if (_is_open) {
                                      [self closeCommandStates];
                                  } else {
                                      [self openCommandStates];
                                  }
                                  NSLog(@"1");
                              } failure:^(NSError *error){
                                  NSLog(@"2");
                              }];
    } else {
        if (_is_open) {
            values = [NSArray arrayWithObjects:[NSNumber numberWithInt:904],
                      [NSNumber numberWithInt:10],[NSNumber numberWithInt:4353],
                      [NSNumber numberWithInt:1],[NSNumber numberWithInt:13107],
                      [NSNumber numberWithInt:13107], nil];
        } else {
            values = [NSArray arrayWithObjects:[NSNumber numberWithInt:905],
                      [NSNumber numberWithInt:10],[NSNumber numberWithInt:4353],
                      [NSNumber numberWithInt:1],[NSNumber numberWithInt:13107],
                      [NSNumber numberWithInt:13107], nil];
        }
        [_obj writeRegistersFromAndOn:7999
                             toValues:values
                              success:^(NSArray *array){
                                  [self newCommandStates];
                                  NSLog(@"1");
                              } failure:^(NSError *error){
                                  NSLog(@"2");
                              }];
    }
}

- (void)newCommandStates
{
    [_obj readRegistersFrom:8020
                      count:1
                    success:^(NSArray *array){
                        int state = [[array lastObject] intValue];
                        NSString *str_error_desc = nil;
                        switch (state) {
                            case 0:
                                break;
                            case 4363:
                                str_error_desc = @"BSCM is out of order";
                                break;
                            case 4503:
                                str_error_desc = @"Circuit breaker is tripped";
                                break;
                            case 4504:
                                str_error_desc = @"Circuit is already closed";
                                break;
                            case 4505:
                                str_error_desc = @"Circuit is already opened";
                                break;
                            case 4506:
                                str_error_desc = @"Circuit is already reset";
                                break;
                            case 4507:
                                str_error_desc = @"Actuator is in manual mode";
                                break;
                            case 4508:
                                str_error_desc = @"Actuator is not present";
                                break;
                            case 4510:
                                str_error_desc = @"A previous command is still in progress";
                                break;
                            case 4511:
                                str_error_desc = @"Reset command is forbidden";
                                break;
                            default:
                                break;
                        }
                        if ([str_error_desc length]) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str_error_desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                            [alert release];
                        }
                    } failure:^(NSError *error){
                        
                    }];
}

- (void)openCommandStates
{
    [_obj readRegistersFrom:801
                      count:1
                    success:^(NSArray *array){
                        int state = [[array lastObject] intValue];
                        NSString *str_error_desc = nil;
                        switch (state) {
                            case 1:
                                break;
                            case 2:
                                str_error_desc = @"Incorrect number of parameters";
                                break;
                            case 3:
                                str_error_desc = @"Incorrect coilValue";
                                break;
                            case 4:
                                str_error_desc = @"Incorrect password";
                                break;
                            case 5:
                                str_error_desc = @"Register 670 in MANU mode";
                                break;
                            default:
                                break;
                        }
                        if ([str_error_desc length]) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str_error_desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                            [alert release];
                        }
                    } failure:^(NSError *error){
                    
                    }];
}

- (void)closeCommandStates
{
    [_obj readRegistersFrom:802
                      count:1
                    success:^(NSArray *array){
                        int state = [[array lastObject] intValue];
                        NSString *str_error_desc = nil;
                        switch (state) {
                            case 1:
                                break;
                            case 2:
                                str_error_desc = @"Incorrect number of parameters";
                                break;
                            case 3:
                                str_error_desc = @"Incorrect coilValue";
                                break;
                            case 4:
                                str_error_desc = @"Incorrect password";
                                break;
                            case 5:
                                str_error_desc = @"Register 670 in MANU mode";
                                break;
                            default:
                                break;
                        }
                        if ([str_error_desc length]) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str_error_desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                            [alert release];
                        }
                    } failure:^(NSError *error){
                        
                    }];
}


///12.release
- (void)twelveStep
{
    
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:59492],
                  [NSNumber numberWithInt:3],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_flag],nil];

    [_obj writeRegistersFromAndOn:step_9().start_address
                         toValues:values
                          success:^(NSArray *array){
                              NSLog(@"successed step 12");
                              //[_switch_view animation:_operating_index close:_operating_type];
                              //[self recheckDeviceOpenState];
                          } failure:^(NSError *error){
                              NSLog(@"control failed on step 12");
                          }];
}

///11.check result code
- (void)eleventhStep
{
    [_obj readRegistersFrom:step_11().start_address
                      count:step_11().register_count
                    success:^(NSArray *array){
                        if (![[array lastObject] intValue]) {
                            [self twelveStep];
                        } else {
                            [self eleventhStep];
                        }
                        NSLog(@"successed step 11 %d",[[array objectAtIndex:0] intValue]);
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 11");
                    }];
}

///10.wait for the command being executed
- (void)tenthStep
{
    [_obj readRegistersFrom:step_10().start_address
                      count:step_10().register_count
                    success:^(NSArray *array){
                        if (![[array objectAtIndex:0] intValue] &&
                            [[array objectAtIndex:1] intValue] == _command_number) {
                            NSLog(@"successed step 10 ,command number %d",[[array objectAtIndex:1] intValue]);
                            [self eleventhStep];
                        } else {
                            [self tenthStep];
                        }
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 10");
                    }];
}

///9.disable activation of the MX coil
- (void)ninethStep
{
    NSArray *values = nil;
    if (_is_open) {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58771],
                  [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:10],nil];
    } else {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58771],
                  [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:12],nil];
    }
    _command_number = 58771;
    [_obj writeRegistersFromAndOn:step_9().start_address
                         toValues:values
                          success:^(NSArray *array){
                              NSLog(@"successed step 9");
                              [self tenthStep];
                          } failure:^(NSError *error){
                              NSLog(@"control failed on step 9");
                          }];
}

///8.check result code
- (void)eighthStep
{
    [_obj readRegistersFrom:step_8().start_address
                      count:step_8().register_count
                    success:^(NSArray *array){
//                        if (![[array lastObject] intValue]) {
                            [self ninethStep];
//                        } else {
//                            [self eighthStep];
//                        }
                        NSLog(@"successed step 8 %d",[[array objectAtIndex:0] intValue]);
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 8");
                    }];
}

///7.wait for the command being executed
- (void)seventhStep
{
    [_obj readRegistersFrom:step_7().start_address
                      count:step_7().register_count
                    success:^(NSArray *array){
                        if (![[array objectAtIndex:0] intValue] &&
                            ([[array objectAtIndex:1] intValue] == _command_number)) {
                            NSLog(@"successed step 7 ,command number %d",[[array objectAtIndex:1] intValue]);
                            [self eighthStep];
                        } else {
                            [self seventhStep];
                        }
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 7");
                    }];
}

///6.open the circuit-breaker
- (void)sixthStep
{
    NSArray *values = nil;
    if (_is_open) {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58769],
                           [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:1],nil];
        _command_number = 58769;
    } else {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58770],
                  [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:1],nil];
        _command_number = 58770;
    }
    [_obj writeRegistersFromAndOn:step_6().start_address
                         toValues:values
                          success:^(NSArray *array){
                              NSLog(@"successed step 6");
                              [self seventhStep];
                          } failure:^(NSError *error){
                              NSLog(@"control failed on step 6");
                          }];
}

///5.check result code
- (void)fifthStep
{
    [_obj readRegistersFrom:step_5().start_address
                      count:step_5().register_count
                    success:^(NSArray *array){
                        NSLog(@"successed step 5 %d",[[array objectAtIndex:0] intValue]);
                        if (![[array lastObject] intValue]) {
                            [self sixthStep];
                        } else {
                            [self firstStep];
                        }
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 5");
                    }];
}

///4.wait for the command being executed
- (void)fourthStep
{
    [_obj readRegistersFrom:step_4().start_address
                      count:step_4().register_count
                    success:^(NSArray *array){
                        if (![[array objectAtIndex:0] intValue] &&
                            ([[array objectAtIndex:1] intValue] == _command_number)) {
                            NSLog(@"successed step 4 ,command number %d",[[array objectAtIndex:1] intValue]);
                            [self fifthStep];
                        } else {
                            [self fourthStep];
                        }
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 4");
                    }];
}

///3.enable activation of the MX coil
- (void)thirdStep
{
    NSArray *values = nil;
    if (_is_open) {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58771],
                           [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:10],nil];
    } else {
        values = [NSArray arrayWithObjects:[NSNumber numberWithInt:58771],
                  [NSNumber numberWithInt:4],[NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:_control_content],[NSNumber numberWithInt:12],nil];
    }
    
    _command_number = 58771;
    [_obj writeRegistersFromAndOn:step_3().start_address
                         toValues:values
                          success:^(NSArray *array){
                              if (_is_open) {
                                  NSLog(@"open successed step 3");
                              } else {
                                  NSLog(@"close successed step 3");
                              }
                              [self fourthStep];
                          } failure:^(NSError *error){
                              if (_is_open) {
                                  NSLog(@"open control failed on step 3");
                              } else {
                                  NSLog(@"close control failed on step 3");
                              }
                          }];
}

///2.get control word
- (void)secondStep
{
    ///read the control word in register 553 of the circuit-breaker manager
    [_obj readRegistersFrom:step_2().start_address
                      count:step_2().register_count
                    success:^(NSArray *array){
                        _control_content = [[array lastObject] intValue];
                        NSLog(@"successed step 2");
                        [self thirdStep];
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 2");
                    }];
}

///1.request the flag
- (void)firstStep
{
    ///7715 flag must be different than 0 to go on the next step
    [_obj readRegistersFrom:step_1().start_address
                      count:step_1().register_count
                    success:^(NSArray *array){
                        _flag = [[array lastObject] intValue];
                        if (!_flag) {
                            NSLog(@"another supervisor on a multi-supervisor system is already in configuration mode");
                        } else {
                            NSLog(@"successed step 1");
                            [self secondStep];
                        }
                    } failure:^(NSError *error){
                        NSLog(@"control failed on step 1");
                    }];
}
@end
