//
//  ISettingViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-23.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ISettingViewController.h"
#import "ProtectionViewController.h"
#import "PorpertyViewController.h"
#import "ProtectionViewController.h"

typedef enum {
    NoneType = 0,
    CancelType,
    ProtectionType,
    DrawDiagramType,
}SettingType;

NSString *const kProductSettingKey = @"product_setting";
///system_type_settings
NSString *const kSystemTypeSettingKey = @"system_type_settings";
NSString *const kSettingDescKey = @"description";
NSString *const kSettingValue = @"value";

#define Protection_Sel_Tag 89111

@interface ISettingViewController ()
{
    CustomObjectModbus *_obj;
    NSDictionary       *_dict_setting;
    UIButton           *_btn_protection;
    
    SettingType        _setting_type;
}
@end

@implementation ISettingViewController

- (void)dealloc
{
    [_btn_protection release];
    [_dict_setting release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadISettingData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Isetting" ofType:@"plist"];
    _dict_setting = [[NSDictionary alloc] initWithContentsOfFile:path];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleImage:@"isetting_title.png"];
	// Do any additional setup after loading the view.
    
    _btn_protection = [[UIButton alloc] initWithFrame:CGRectMake(789, 7, 205, 48)];
    [_btn_protection setBackgroundImage:[UIImage imageNamed:@"protection_setting_btn.png"] forState:UIControlStateNormal];
    [_btn_protection setTitleColor:colorWithHexString(@"666666") forState:UIControlStateNormal];
    [_btn_protection setTitle:@"Protection Setting" forState:UIControlStateNormal];
    [_btn_protection addTarget:self action:@selector(protectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:_btn_protection];

    [self loadISettingData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)protectionButtonClicked:(UIButton *)btn
{
    if (!_setting_type) {
        _setting_type = CancelType;
        [btn setTitle:@"Cancel" forState:UIControlStateNormal];
        ProtectionSelView *selView = [[ProtectionSelView alloc] initWithFrame:_contentView.bounds];
        selView.delegate = self;
        selView.tag = Protection_Sel_Tag;
        [_contentView addSubview:selView];
        [selView release];
    } else if (_setting_type == CancelType) {
        _setting_type = NoneType;
        ProtectionSelView *selView = (ProtectionSelView *)[_contentView viewWithTag:Protection_Sel_Tag];
        if (selView) {
            selView.delegate = nil;
            [selView removeFromSuperview];
        }
        [btn setTitle:@"Protection Setting" forState:UIControlStateNormal];
    } else if (_setting_type == DrawDiagramType) {
        ProtectionSelView *selView = (ProtectionSelView *)[_contentView viewWithTag:Protection_Sel_Tag];
        NSMutableArray *marray_sel_modbus = [[NSMutableArray alloc] init];

        for (int i = 0; i < [[selView marraySelectedDevices] count]; i ++) {
            int index = [[[selView marraySelectedDevices] objectAtIndex:i] intValue];
            if (index) {
                ObjectiveLibModbus *obj = [_marray_modbusObjs objectAtIndex:i];
                if (obj) {
                    NSDictionary *dict = [[_systemManger deviceInfomationOfPosition:i] objectForKey:kDeviceInfoKey];
                    NSString *str_device_name = [NSString stringWithFormat:@"%@_%.1f %d",
                                                 [dict objectForKey:kDeviceModelKey],
                                                 [[dict objectForKey:kDeviceVersionKey] floatValue],
                                                 [[dict objectForKey:kDeviceIdKey] intValue]];
                    NSDictionary *dic_obj = [[NSDictionary alloc] initWithObjectsAndKeys:[_marray_modbusObjs objectAtIndex:i],@"modbus",str_device_name, @"name", nil];
                    
                    [marray_sel_modbus addObject:dic_obj];
                    [dic_obj release];
                }
            }
        }
        ProtectionViewController *protection = [[ProtectionViewController alloc] init];
        protection.array_obj_modbus = marray_sel_modbus;
        [self.navigationController pushViewController:protection animated:YES];
        [marray_sel_modbus release];
        [protection release];
    }
}

#pragma mark - protection delegate method - 
- (void)selectedDeviceButtonClicked:(NSArray *)array_sel
{
    int sel_count = 0;
    for (NSNumber *num in array_sel) {
        if ([num intValue]) {
            sel_count ++;
        }
    }
    if (!sel_count) {
        _setting_type = CancelType;
        [_btn_protection setTitle:@"Cancel" forState:UIControlStateNormal];
    } else {
        _setting_type = DrawDiagramType;
        [_btn_protection setTitle:@"Trip Curve " forState:UIControlStateNormal];
    }
}

- (NSArray *)asc:(int)intResp
{
    ///dec - > asc
    char *buf = &intResp;
    buf ++;
    char c[2];
    for(int i=0;i < 2;i++){
        c[i] = *buf;
        buf--;
    }
    
    return [NSArray arrayWithObjects:[NSNumber numberWithChar:c[0]],
     [NSNumber numberWithChar:c[1]], nil];
}

#pragma mark - product setting -
- (NSString *)descriptionOfValue:(int)value
{
    NSString *strResult = nil;
    NSArray *arraySystemType = [[_dict_setting objectForKey:kProductSettingKey] objectForKey:kSystemTypeSettingKey];
    for (NSDictionary *dict in arraySystemType) {
        if ([[dict objectForKey:kSettingValue] intValue] == value) {
            strResult = [dict objectForKey:kSettingDescKey];
        }
    }
    return strResult;
}

- (void)getProductSetting
{
    ///system type setting
    [_obj readRegistersFrom:system_type_setting().start_address
                      count:system_type_setting().register_count
                    success:^(NSArray *array) {
                        NSLog(@"%@",[self descriptionOfValue:[[array lastObject] intValue]]);
                        [self getM2CSettings];
                    }
                    failure:^(NSError *error){
                        errorMessageAlert(@"system type setting failed", error.description);
                    }];
}

- (void)handleTargetFrameClickedEvent:(NSInteger)target_index
{
    _obj = [_marray_modbusObjs objectAtIndex:target_index];
    if (_obj) {
        PorpertyViewController *property = [[PorpertyViewController alloc] initWithModbusObject:_obj];
        property.int_device_position = target_index;
        [self.navigationController pushViewController:property animated:YES];
        [property release];
    }
}

@end
