//
//  ProtectionViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-28.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ProtectionViewController.h"
#import "ModbusAuxiliary.h"
#import "ProtectionGraphView.h"
#import "SystemManager.h"
#import "DrawDiagram.h"
#import "ObjectiveLibModbus.h"

#define Chart_Model_Device_Tag 88879

@interface ProtectionViewController ()
{
    NSDictionary        *_dict_proetction;
    SystemManager       *_system_manager;
    CGFloat             _float_version;
    
    NSMutableDictionary *_mdict_modbus_values;
    NSInteger           _modbus_index;
    
    ///Chart view
    UIImageView         *_chart_bg;
    UIImageView         *_chart_coordinate;
    
    UIImageView         *_vimg_device;
    NSMutableArray      *_marray_chart_views;
    CGFloat             _current_in;
    NSInteger           _is_on;
    UIButton            *_btnRefresh;
    
    NSString            *_str_version;
    NSString            *_str_model;
}
@end

@implementation ProtectionViewController
@synthesize array_obj_modbus = _array_obj_modbus;

- (void)dealloc
{
    [_chart_bg release];
    [_vimg_device release];
    [_marray_chart_views release];
    [_chart_coordinate release];
    [_mdict_modbus_values release];
    [_dict_proetction release];
    [_btnRefresh release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Isetting.plist" ofType:nil];
        NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
        _dict_proetction = [[NSDictionary alloc] initWithDictionary:[rootDict objectForKey:@"protection_setting"]];
        _mdict_modbus_values = [[NSMutableDictionary alloc] init];
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleImage:@"isetting_title.png"];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    ///cover view
    //[self getProtectionSetting];
    
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
        
        NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
        [mdict setValue:[NSNumber numberWithFloat:0.4] forKey:kIrKey];
        [mdict setValue:[NSNumber numberWithFloat:0.5] forKey:kTrKey];
        [mdict setValue:[NSNumber numberWithFloat:8]   forKey:kIsdKey];
        [mdict setValue:[NSNumber numberWithFloat:0.4] forKey:kTsdKey];
        [mdict setValue:[NSNumber numberWithFloat:8]   forKey:kIiKey];
        [mdict setValue:[NSNumber numberWithFloat:100] forKey:kInKey];
        [_mdict_modbus_values setValue:mdict forKey:[[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"]];
        [mdict release];
         [self initChartView];
    
    }else{
       [self getIn];
    
    }
 
    //[self initChartView];
    
    
    //refresh Button 
    _btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(880, 7, 48, 48)];
    [_btnRefresh setImage:[UIImage imageNamed:@"isystem_refresh_btn.png"] forState:UIControlStateNormal];
    [_btnRefresh addTarget:self action:@selector(refreshDrawViewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:_btnRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)refreshDrawViewBtnClicked:(UIButton*)sender{

    NSLog(@"REFRESH");
    _modbus_index = 0;

  [self getIn];

}

#pragma mark - get protection -
- (NSNumber *)asc:(int)intResp
{
    ///dec - > asc
    char *buf = &intResp;
    buf ++;
    char c[2];
    for(int i=0;i < 2;i++){
        c[i] = *buf;
        buf--;
    }
    
    return [NSNumber numberWithChar:c[0]];
}

/*
 (NSMutableDictionary *) $2 = 0x09852f70 {
 "A_2.0 1" =     {
 Ir = "0.4";
 Isd = "1.5";
 Tr = "0.5";
 };
 "E_5.0 19" =     {
 Ii = 8;
 Ir = 1;
 Isd = 4;
 Tr = 8;
 Tsd = "0.04";
 }
 */

- (void)initChartView
{
    _chart_bg = [[UIImageView alloc] initWithFrame:CGRectMake(28, 36, 959, 599)];
    _chart_bg.image = [UIImage imageNamed:@"chart_bg.png"];
    _chart_bg.userInteractionEnabled = YES;
    [_contentView addSubview:_chart_bg];
    
    _chart_coordinate = [[UIImageView alloc] initWithFrame:CGRectMake(80, 26, 677, 515)];
    _chart_coordinate.image = [UIImage imageNamed:@"coordinates.png"];
    [_chart_bg addSubview:_chart_coordinate];
    
    _marray_chart_views = [[NSMutableArray alloc] init];
    for (int i = 0 ;i < [[_mdict_modbus_values allKeys] count]; i ++) {
        
        NSDictionary *dict = [_mdict_modbus_values objectForKey:[[_mdict_modbus_values allKeys] objectAtIndex:i]];
        NSArray *array_color = nil;
        if (!i) {
            array_color = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0],
                                    [NSNumber numberWithFloat:204/255.0],
                                    [NSNumber numberWithFloat:1],nil];
        } else {
            array_color = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:1],
                           [NSNumber numberWithFloat:0],
                           [NSNumber numberWithFloat:0],nil];
        }
        
  
        CGRect rect = _chart_bg.bounds;
        rect.size.width -= 200;
        rect.origin.y = 26.0f;
        rect.size.height -= 26.0f;
        DrawDiagram *_view_chart = [[DrawDiagram alloc] initWithFrame:rect
                                                           chart_info:dict
                                                              version:[[_mdict_modbus_values allKeys] objectAtIndex:i]
                                  color:array_color];

        _view_chart.backgroundColor = [UIColor clearColor];
        
        [_chart_bg addSubview:_view_chart];
        [_marray_chart_views addObject:_view_chart];
        [_view_chart release];
        
        ///device model
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(740, 38 + 50 * i, 50, 10)];
        imgView.backgroundColor = [UIColor colorWithRed:[[array_color objectAtIndex:0] floatValue]
                                                  green:[[array_color objectAtIndex:1] floatValue]
                                                   blue:[[array_color objectAtIndex:2] floatValue] alpha:1];
        [_chart_bg addSubview:imgView];
        [imgView release];
    
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(800, 28 + 50 * i, 130, 30)];
        btn.tag = Chart_Model_Device_Tag + i;
        [btn addTarget:self action:@selector(chartDeviceModelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"protection_setting_btn.png"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [btn setTitleColor:colorWithHexString(@"999999") forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"Mic %@",[[_mdict_modbus_values allKeys] objectAtIndex:i]] forState:UIControlStateNormal];
        [_chart_bg addSubview:btn];
        [btn release];
    }
    
    _vimg_device = [[UIImageView alloc] initWithFrame:CGRectMake(800, 120, 128, 442)];
    _vimg_device.backgroundColor = [UIColor grayColor];
    [_chart_bg addSubview:_vimg_device];
    
    [self performSelector:@selector(chartDeviceModelButtonClicked:)
               withObject:(UIButton *)[_chart_bg viewWithTag:Chart_Model_Device_Tag] afterDelay:0];
}

- (void)chartDeviceModelButtonClicked:(UIButton *)btn
{
    NSString *str_title = [btn titleForState:UIControlStateNormal];
    NSArray *array = [str_title componentsSeparatedByString:@" "];
    if ([array count] > 1) {
        NSString *str_img = [array objectAtIndex:1];
        _vimg_device.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",str_img]];
    }
    
    int index = btn.tag - Chart_Model_Device_Tag;
    DrawDiagram *show_chart_view = nil;
    DrawDiagram *hide_chart_view = nil;

    if ([_marray_chart_views count] == 2) {
        if (!index) {
            show_chart_view = (DrawDiagram *)[_marray_chart_views objectAtIndex:0];
            hide_chart_view = (DrawDiagram *)[_marray_chart_views objectAtIndex:1];
        } else {
            show_chart_view = (DrawDiagram *)[_marray_chart_views objectAtIndex:1];
            hide_chart_view = (DrawDiagram *)[_marray_chart_views objectAtIndex:0];
        }
        [show_chart_view showTitle:YES];
        [hide_chart_view showTitle:NO];

    }
}

#pragma mark - modebus method -
- (void)parseSettingInfo:(NSArray *)array
{
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    NSArray *arrayKeys = [[NSArray alloc] initWithObjects:kIrKey,kTrKey,kIsdKey,kTsdKey,kIiKey, nil];
    for (int i = 0; i < [self protection_setting].register_count; i ++) {
        if (i % 2) {
            NSNumber *num = [self asc:[[array objectAtIndex:i] intValue]];
            NSString *key = [arrayKeys objectAtIndex:i / 2];
            NSArray  *values = [_dict_proetction objectForKey:key];
            [mdict setObject:[values objectAtIndex:([num  intValue] - 1)] forKey:key];
        }
    }
    
    [mdict setValue:[NSNumber numberWithFloat:_current_in] forKey:kInKey];
    [_mdict_modbus_values setValue:mdict forKey:[[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"]];
    [mdict release];
}

- (void)parseModeASettingInfo:(NSArray *)array
{
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    
    CGFloat Ir = ([[array objectAtIndex:3] intValue] * 10000 + [[array objectAtIndex:2] intValue]) / _current_in;
    [mdict setValue:[NSNumber numberWithFloat:Ir] forKey:kIrKey];
    
    CGFloat tr = [[array objectAtIndex:4] intValue] / 1000.0f;
    [mdict setValue:[NSNumber numberWithFloat:tr] forKey:kTrKey];
    
    CGFloat Isd = ([[array objectAtIndex:13] intValue] * 10000 + [[array objectAtIndex:12] intValue]) / _current_in / Ir;
    [mdict setValue:[NSNumber numberWithFloat:Isd] forKey:kIsdKey];
    
    [mdict setValue:[NSNumber numberWithFloat:_current_in] forKey:kInKey];
    
    NSString *str_name = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"];
    NSArray *array_name = [str_name componentsSeparatedByString:@" "];
    array_name = [[array_name objectAtIndex:0] componentsSeparatedByString:@"_"];
    NSString *str_version = [array_name objectAtIndex:1];
    
    if ([str_version floatValue] != 2.0) {
        CGFloat tsd = [[array objectAtIndex:14] intValue] / 1000.0f;
        
        NSString *str_name = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"];
        NSArray *arrayinfo = [str_name componentsSeparatedByString:@" "];
        arrayinfo = [[arrayinfo objectAtIndex:0] componentsSeparatedByString:@"_"];
        NSString *str_model = [arrayinfo objectAtIndex:0];
        if ([str_model isEqualToString:@"P"]) {
            if (_is_on) {
                tsd /= 10;
            }
        }
        [mdict setValue:[NSNumber numberWithFloat:tsd] forKey:kTsdKey];
        
        CGFloat Ii = [[array objectAtIndex:23] intValue] * 10000 + [[array objectAtIndex:22] intValue] / _current_in;
        [mdict setValue:[NSNumber numberWithFloat:Ii] forKey:kIiKey];
    }
    
    [_mdict_modbus_values setValue:mdict forKey:[[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"]];
    [mdict release];
}

- (void)parse52SettingInfo:(NSArray *)array
{
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    [mdict setValue:[NSNumber numberWithFloat:_current_in] forKey:kInKey];

    CGFloat Ir = [[array objectAtIndex:2] intValue] / _current_in;
    //([[array objectAtIndex:1] intValue] * 10000 + [[array objectAtIndex:0] intValue]) / _current_in;
    [mdict setValue:[NSNumber numberWithFloat:Ir] forKey:kIrKey];
    
    CGFloat tr = [[array objectAtIndex:4] intValue] / 1000.0f;
    [mdict setValue:[NSNumber numberWithFloat:tr] forKey:kTrKey];
    
    CGFloat Isd = [[array objectAtIndex:12] intValue] / 10.0f;
    //([[array objectAtIndex:4] intValue] * 10000 + [[array objectAtIndex:3] intValue]) / _current_in / Ir;
    [mdict setValue:[NSNumber numberWithFloat:Isd] forKey:kIsdKey];
        
    CGFloat Tsd = [[array objectAtIndex:14] intValue];
    [mdict setValue:[NSNumber numberWithFloat:Tsd / 1000] forKey:kTsdKey];
    
    CGFloat Ii = [[array objectAtIndex:22] intValue]/10.0f;
    [mdict setValue:[NSNumber numberWithFloat:Ii] forKey:kIiKey];
    
    [_mdict_modbus_values setValue:mdict forKey:[[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"]];
    [mdict release];
}

- (register_str)protection_setting
{
    
    register_str protection_setting;
    
    NSString *str_name = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"];
    NSArray *arrayinfo = [str_name componentsSeparatedByString:@" "];
    arrayinfo = [[arrayinfo objectAtIndex:0] componentsSeparatedByString:@"_"];
    NSString *str_model = [arrayinfo objectAtIndex:0];
    NSString *str_version = [arrayinfo objectAtIndex:1];
    NSArray *array_sub = [str_version componentsSeparatedByString:@"."];
    str_version = [array_sub objectAtIndex:1];

//    if ([str_model isEqualToString:@"A"] || [str_model isEqualToString:@"P"]) {
//        protection_setting.start_address = 12179;
//    } else {
//        protection_setting.start_address = 30005;
//    }
//    protection_setting.register_count = 10;
//
//    if (![str_version isEqualToString:@"0"]) {
//        protection_setting.start_address = 8753;
//        protection_setting.register_count = 50;
//    }
    protection_setting.start_address = 8753;
    protection_setting.register_count = 40;
    return protection_setting;
}

- (void)getIn
{
    if (_modbus_index < [_array_obj_modbus count]) {
        ObjectiveLibModbus *obj = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"modbus"];
        [obj readRegistersFrom:8749
                         count:1
                       success:^(NSArray *array){
                           _current_in = [[array objectAtIndex:0] floatValue];
                           //_is_on = [[array objectAtIndex:15] intValue];
                           
                           [self getProtectionSetting];
                       } failure:^(NSError *error){
                           _modbus_index ++;
                           [self getProtectionSetting];
                       }];
    } else {
        NSLog(@"finished get data");
        [self initChartView];
    }

}

- (void)getProtectionSetting
{
    if (_modbus_index < [_array_obj_modbus count]) {
        ObjectiveLibModbus *obj = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"modbus"];
        [obj readRegistersFrom:[self protection_setting].start_address
                                 count:[self protection_setting].register_count
                               success:^(NSArray *array){
                                   NSString *str_name = [[_array_obj_modbus objectAtIndex:_modbus_index] objectForKey:@"name"];
                                   NSArray *arrayinfo = [str_name componentsSeparatedByString:@" "];
                                   arrayinfo = [[arrayinfo objectAtIndex:0] componentsSeparatedByString:@"_"];
                                   NSString *str_model = [arrayinfo objectAtIndex:0];
                                   NSString *str_version = [arrayinfo objectAtIndex:1];
                                   NSArray *array_sub = [str_version componentsSeparatedByString:@"."];
                                   str_version = [array_sub objectAtIndex:1];
                                   if (![str_version isEqualToString:@"0"]) {
                                       [self parse52SettingInfo:array];
                                   } else {
//                                       if ([str_model isEqualToString:@"A"] || [str_model isEqualToString:@"P"]) {
//                                           [self parseModeASettingInfo:array];
//                                       } else {
//                                           [self parseSettingInfo:array];
//                                       }
                                       
                                       [self parseModeASettingInfo:array];
                                   }
                                   _modbus_index ++;
                                   [self getIn];
                               } failure:^(NSError *error){
                                   _modbus_index ++;
                                   [self getProtectionSetting];
                               }];
    }
}

@end
