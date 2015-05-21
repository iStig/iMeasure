//
//  AlarmInfoViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-6-5.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "AlarmInfoViewController.h"
#import "SystemManager.h"
#import "ModbusAuxiliary.h"
#import "eventTableViewCell.h"

#define record_count 10
#define record_display_count 9

typedef enum {
    OldVersionCommand = 0,
    NewVersionCommand,
}CommandType;

@interface AlarmInfoViewController ()
{
    SystemManager *_system_manager;
    
    NSInteger _alarm_count;
    NSInteger _new_alarm_index;
    NSInteger _of_value;
    NSInteger _sd_value;
    NSInteger _sed_value;
    NSInteger _ch_value;
    
    BOOL      _show_trip_warnning_animation;
    BOOL      _auto_refresh_current_value;
    
    
    ///battery
    UIImageView     *_vImg_battery_bg;
    ///load
    UIImageView     *_vImg_load_bg;
    NSMutableArray  *_marry_trip_current;
    NSMutableArray  *_marray_events;
    UITableView     *_event_list;
    
    ///10 record
    CGFloat         _battery;
    NSInteger       _record_index;      //current record index
    NSMutableArray *_marray_record_sort;
    NSMutableArray *_marray_records;
    NSDictionary   *_dict_proetction;
    NSDictionary   *_dict_alarm_type;
    
    NSMutableDictionary *_mdict_alarm_info;
    
    CommandType    _is_new_command;
}
@end

@implementation AlarmInfoViewController
@synthesize obj_modbus = _obj_modbus;
@synthesize int_device_position = _int_device_position;

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getBatteryCapacity) object:nil];
    [_vImg_battery_bg release];
    [_vImg_load_bg release];
    [_event_list release];
    [_marray_events release];
    [_marry_trip_current release];
    [_mdict_alarm_info release];
    [_dict_alarm_type release];
    [_dict_proetction release];
    [_marray_records release];
    [_obj_modbus release];
    [super dealloc];
}

- (id)initWithModbusObject:(CustomObjectModbus *)obj
{
    self = [super init];
    if (self) {
        self.obj_modbus = obj;
        _system_manager = [SystemManager shareManager];
        _marray_records = [[NSMutableArray alloc] init];
        _mdict_alarm_info = [[NSMutableDictionary alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Isetting.plist" ofType:nil];
        NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
        _dict_proetction = [[NSDictionary alloc] initWithDictionary:[rootDict objectForKey:@"protection_setting"]];
        _dict_alarm_type = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IAlarm.plist" ofType:nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleImage:@"ievent_title.png"];
	// Do any additional setup after loading the view.
    [self initDeviceModel];
    [self initLoadAndBatteryInfoView];
    [self initAlarmUserInterface];
    
    _is_new_command = NO;
    NSDictionary *dict_device_info = [_obj_modbus device_information];
    if (dict_device_info) {
        NSString *str_version = [dict_device_info objectForKey:kDeviceVersionKey];
        NSArray *array_version = [str_version componentsSeparatedByString:@"."];
        if ([array_version count] == 2) {
            if ([[array_version lastObject] intValue] != 0) {
                _is_new_command = YES;
            }
        }
    }
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        [self refreshBatteryInfo:100];
        [_marray_events removeAllObjects];
        [_marray_events insertObject:@"Ii      1/7/2013   10:22:32:450  Trip due to Instantaneous protection" atIndex:0];
        [_marray_events insertObject:@"OF   1/7/2013   10:22:32:400   Breaker  Opened" atIndex:1];
        [_marray_events insertObject:@"Isd   1/7/2013   10:15:30:250   Trip due to Short-time protection" atIndex:2];
        [_marray_events insertObject:@"OF   1/7/2013   10:13:22:150   Breaker  Closed" atIndex:3];
        [_marray_events insertObject:@"Ir      1/7/2013   10:10:25:230   Trip due to Long-time protection" atIndex:4];
        [self refreshTripListInfo];
        [self checkRecord];
       
    }else{
        [self getBatteryCapacity];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:5];
//    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
//        [self refreshBatteryInfo:100];
//        [_marray_events removeAllObjects];
//        [_marray_events insertObject:@"Ii      1/7/2013   10:22:32:450  Trip due to Instantaneous protection" atIndex:0];
//        [_marray_events insertObject:@"OF   1/7/2013   10:22:32:400   Breaker  Opened" atIndex:1];
//        [_marray_events insertObject:@"Isd   1/7/2013   10:15:30:250   Trip due to Short-time protection" atIndex:2];
//        [_marray_events insertObject:@"OF   1/7/2013   10:13:22:150   Breaker  Closed" atIndex:3];
//        [_marray_events insertObject:@"Ir      1/7/2013   10:10:25:230   Trip due to Long-time protection" atIndex:4];
//        [self refreshTripListInfo];
//        [self checkRecord];
//        
//    }else{
//        [self getBatteryCapacity];
//    }

  
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getBatteryCapacity) object:nil];
}

- (void)initDeviceModel
{
    NSDictionary *device_information = [[_system_manager deviceInfomationOfDeviceid:_obj_modbus.device_id] objectForKey:kDeviceInfoKey];
    NSString *str_model = [device_information objectForKey:kDeviceModelKey];
    CGFloat float_version = [[device_information objectForKey:kDeviceVersionKey] floatValue];
    
    NSDictionary *dict_event_info = [[NSDictionary alloc] initWithDictionary:
                                     [[_system_manager deviceInfomationOfDeviceid:_obj_modbus.device_id] objectForKey:kTripAlarmInfoKey]];
    _marray_events = [[NSMutableArray alloc] initWithArray:[dict_event_info objectForKey:kTripListKey]];
    _new_alarm_index = [[dict_event_info objectForKey:kLastTripIndexKey] intValue];
    _of_value = [[dict_event_info objectForKey:kLastSoeValueKey] intValue];
    _ch_value = [[dict_event_info objectForKey:kLastCHValueKey] intValue];
    _sd_value = [[dict_event_info objectForKey:kLastSDValueKey] intValue];
    _sed_value = [[dict_event_info objectForKey:kLastSEDValueKey] intValue];
    
    if (![_marray_events count]) {
        _new_alarm_index = -1;
        _of_value = -1;
        _sd_value = -1;
        _sed_value = -1;
        _ch_value = -1;
    }
    
    UILabel *lbl_device_name = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 200, 30)];
    lbl_device_name.backgroundColor = [UIColor clearColor];
    lbl_device_name.font = [UIFont boldSystemFontOfSize:18.0f];
    lbl_device_name.textColor = colorWithHexString(@"666666");
    
    NSString *str_device_name = [NSString stringWithFormat:@"Micrologic %.1f %@",
                                 float_version, str_model];
    lbl_device_name.text = str_device_name;
    [_contentView addSubview:lbl_device_name];
    [lbl_device_name release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI -
- (void)initLoadAndBatteryInfoView
{
    _vImg_load_bg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 67, 292, 430)];
    _vImg_load_bg.image = [UIImage imageNamed:@"alarm_load_bg.png"];
    [_contentView addSubview:_vImg_load_bg];
    /*
        Role : 1.A/E 有图 9.10.11.12
     */
    NSDictionary *device_information = [[_system_manager deviceInfomationOfDeviceid:_obj_modbus.device_id]
                                        objectForKey:kDeviceInfoKey];
    NSString *str_model = [device_information objectForKey:kDeviceModelKey];
    
    UIImageView *img_chart = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 277, 224)];
    img_chart.image = [UIImage imageNamed:@"alarm_img.png"];
    [_vImg_load_bg addSubview:img_chart];
    [img_chart release];
    
    
    NSArray *array_version = [[NSString stringWithFormat:@"%.1f",
                               [[device_information objectForKey:kDeviceVersionKey] floatValue]] componentsSeparatedByString:@"."];
    
    if ([str_model isEqualToString:@"P"] || [str_model isEqualToString:@"H"] || (
        [str_model isEqualToString:@"E"] && [[array_version lastObject] intValue])) {
        UIImageView *img_chart_box = [[UIImageView alloc] initWithFrame:CGRectMake(23, 260, 244, 158)];
        img_chart_box.image = [UIImage imageNamed:@"chart_box.png"];
        [_vImg_load_bg addSubview:img_chart_box];
        [img_chart_box release];

        UILabel *lbl_fault_current = [[UILabel alloc] initWithFrame:CGRectMake(23, 240, 100, 15)];
        lbl_fault_current.font = [UIFont boldSystemFontOfSize:15.0f];
        lbl_fault_current.textColor = colorWithHexString(@"999999");
        lbl_fault_current.backgroundColor = [UIColor clearColor];
        lbl_fault_current.text = @"Fault Current";
        [_vImg_load_bg addSubview:lbl_fault_current];
        [lbl_fault_current release];
        
        _marry_trip_current = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i ++) {
            UILabel *lbl_value = [[UILabel alloc] initWithFrame:CGRectMake(23, 260 + 40 * i, 121, 40)];
            lbl_value.font = [UIFont boldSystemFontOfSize:18.0f];
            lbl_value.backgroundColor = [UIColor clearColor];
            lbl_value.textColor = colorWithHexString(@"999999");
            lbl_value.textAlignment = UITextAlignmentCenter;
            NSString *str_lbl_value = nil;
            str_lbl_value = i < 3 ? [NSString stringWithFormat:@"I%d",i + 1] : @"In";
            lbl_value.text = str_lbl_value;
            [_vImg_load_bg addSubview:lbl_value];
            [lbl_value release];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(23 + 121, 260 + 40 * i, 121, 40)];
            lbl.font = [UIFont boldSystemFontOfSize:18.0f];
            lbl.textAlignment = UITextAlignmentCenter;
            lbl.textColor = colorWithHexString(@"999999");
            lbl.backgroundColor = [UIColor clearColor];
            [_vImg_load_bg addSubview:lbl];
            [_marry_trip_current addObject:lbl];
            [lbl release];
        }
    }
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        UIImageView *img_chart_box = [[UIImageView alloc] initWithFrame:CGRectMake(23, 260, 244, 158)];
        img_chart_box.image = [UIImage imageNamed:@"chart_box.png"];
        [_vImg_load_bg addSubview:img_chart_box];
        [img_chart_box release];
        
        UILabel *lbl_fault_current = [[UILabel alloc] initWithFrame:CGRectMake(23, 240, 100, 15)];
        lbl_fault_current.font = [UIFont boldSystemFontOfSize:15.0f];
        lbl_fault_current.textColor = colorWithHexString(@"999999");
        lbl_fault_current.backgroundColor = [UIColor clearColor];
        lbl_fault_current.text = @"Fault Current";
        [_vImg_load_bg addSubview:lbl_fault_current];
        [lbl_fault_current release];
        
        _marry_trip_current = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i ++) {
            UILabel *lbl_value = [[UILabel alloc] initWithFrame:CGRectMake(23, 260 + 40 * i, 121, 40)];
            lbl_value.font = [UIFont boldSystemFontOfSize:18.0f];
            lbl_value.backgroundColor = [UIColor clearColor];
            lbl_value.textColor = colorWithHexString(@"999999");
            lbl_value.textAlignment = UITextAlignmentCenter;
            NSString *str_lbl_value = nil;
            str_lbl_value = i < 3 ? [NSString stringWithFormat:@"I%d",i + 1] : @"In";
            lbl_value.text = str_lbl_value;
            [_vImg_load_bg addSubview:lbl_value];
            [lbl_value release];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(23 + 121, 260 + 40 * i, 121, 40)];
            lbl.font = [UIFont boldSystemFontOfSize:18.0f];
            lbl.textAlignment = UITextAlignmentCenter;
            lbl.textColor = colorWithHexString(@"999999");
            lbl.backgroundColor = [UIColor clearColor];
            [_vImg_load_bg addSubview:lbl];
            [_marry_trip_current addObject:lbl];
            [lbl release];
        }
    }
    
    _vImg_battery_bg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 511, 292, 127)];
    _vImg_battery_bg.image = [UIImage imageNamed:@"alarm_battery_bg.png"];
    [_contentView addSubview:_vImg_battery_bg];
}

- (void)refreshBatteryInfo:(int)int_battery
{
    for (UIView *subView in [_vImg_battery_bg subviews]) {
        [subView removeFromSuperview];
    }
    
    if (int_battery == Undisplay_num) {
        int_battery = 0;
    }
    int battery = int_battery / 20;
    for (int i = 0; i < battery; i ++) {
        UIImageView *imgBatteryBlock = [[UIImageView alloc] initWithFrame:CGRectMake(47 + (4 - i) * 15, 70, 10, 19)];
        imgBatteryBlock.image = [UIImage imageNamed:@"alarm_battery_block.png"];
        [_vImg_battery_bg addSubview:imgBatteryBlock];
    }
    
    UILabel *lbl_battery = [[UILabel alloc] initWithFrame:CGRectMake(182, 58, 80, 42)];
    lbl_battery.font = [UIFont boldSystemFontOfSize:24.0f];
    lbl_battery.textColor = colorWithHexString(@"999999");
    lbl_battery.text = [NSString stringWithFormat:@"%d%%",int_battery];
    [_vImg_battery_bg addSubview:lbl_battery];
    [lbl_battery release];
}

- (void)refreshTripCurrent:(NSArray *)array
{
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        for (int i = 8; i < 12; i ++) {
            if (i==8) {
                UILabel *lbl = [_marry_trip_current objectAtIndex:i - 8];
                lbl.text = @"10KA";
            }
            else if(i==9){
                UILabel *lbl = [_marry_trip_current objectAtIndex:i - 8];
                lbl.text = @"850A";
    
            }
            else if(i==10){
                UILabel *lbl = [_marry_trip_current objectAtIndex:i - 8];
                lbl.text = @"260A";
                
            }
            else if(i==11){
                UILabel *lbl = [_marry_trip_current objectAtIndex:i - 8];
                lbl.text = @"80A";
                
            }
        
        }
        
        
    }
    else{
    ///9 10 11 12
    if (!_is_new_command) {
        for (int i = 8; i < 12; i ++) {
            int trip = [[array objectAtIndex:i] intValue];
            trip = (trip == 32768) ? -1 : trip;
            UILabel *lbl = [_marry_trip_current objectAtIndex:i - 8];
            if (lbl) {
                if (trip == -1) {
                    lbl.text = @"N/A";
                } else {
                    lbl.text = [NSString stringWithFormat:@"%d A", trip];
                }
            }
        }
    } else {
        NSInteger i_key = [[array objectAtIndex:5] intValue];
        NSInteger i_vaule = [[array objectAtIndex:6] intValue];
        i_vaule = i_vaule == Undisplay_num ? -1 : i_vaule;
        
        if (i_key > 0 && i_key < 5) {
            for (int i = 0; i < 4; i ++) {
                UILabel *lbl = [_marry_trip_current objectAtIndex:i];
                if (i_key != i + 1) {
                    lbl.text = @"N/A";
                } else {
                    if (i_vaule == -1) {
                        lbl.text = @"N/A";
                    } else {
                      
                        lbl.text = [NSString stringWithFormat:@"%d A", i_vaule];
                        NSLog(@"%d",i_vaule);
                    }
                }
            }
        }
    }
}
    
}

-(NSArray *)alarmparseAsc:(NSNumber *)resp
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    int intResp = [resp intValue];
    ///dec - > asc
    char *buf = &intResp;
    buf ++;
    char c[2];
    for(int i=0;i < 2;i++){
        c[i] = *buf;
        buf--;
    }
    [marray addObject:[NSNumber numberWithChar:c[0]]];
    [marray addObject:[NSNumber numberWithBool:c[1]]];
    return [marray autorelease];
}

- (NSArray *)hexFromInt:(int)int_num
{    
    NSArray *array = [self alarmparseAsc:[NSNumber numberWithInt:int_num]];
    NSMutableArray *marrayResult = [[NSMutableArray alloc] init];
    NSString *str_first = [[NSString alloc] initWithFormat:@"%1x",[[array objectAtIndex:0] intValue]];
    str_first = [str_first length] ? str_first : @"00";
    
    NSString *str_sec = [NSString stringWithFormat:@"%1x",[[array objectAtIndex:1] intValue]];
    str_sec = [str_sec length] ?  str_sec : @"00";
    
    [marrayResult addObject:str_first];
    [marrayResult addObject:str_sec];
    return [marrayResult autorelease];
}

- (int)intFromHex:(NSString *)hex
{
    return [[NSString stringWithFormat:@"%ld",strtoul([hex UTF8String],0,16)] intValue];
}

- (int)processYear:(NSString *)hex
{
    NSString *strRest = nil;
    int year = [self intFromHex:hex] % 100;
    if ((year >= 0) && (year < 50)) {
        if (year < 10) {
            strRest = [NSString stringWithFormat:@"200%d", year];
        } else {
            strRest = [NSString stringWithFormat:@"20%d",year];
        }
    } else if (year < 100){
        strRest = [NSString stringWithFormat:@"19%d",year];
    }
    
    return [strRest intValue];
}   


#pragma mark - UITableview event list -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_marray_events count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}


- (BOOL)isLeapYear:(int)year
{
    BOOL leap_year = NO;
    if (year / 400 == 0) {
        leap_year = YES;
    } else if ((year / 4 == 0)  && (year / 100 != 0)) {
        leap_year = YES;
    }
    return leap_year;
}

- (eventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    eventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"event_cell_identifier"];
    if (!cell) {
        cell = [[[eventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"event_cell_identifier"] autorelease];
        cell.frame = CGRectMake(0, 0, 627, 58.0f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
        
        id array_alarm = [_marray_events objectAtIndex:indexPath.row];
        if ([array_alarm isKindOfClass:[NSArray class]]) {
            if (!_is_new_command) {
                NSArray *arrayMonAndDay = [self hexFromInt:[[array_alarm objectAtIndex:0] intValue]];
                NSArray *arrayYearAndHour = [self hexFromInt:[[array_alarm objectAtIndex:1] intValue]];
                NSArray *arrayMinAndSec = [self hexFromInt:[[array_alarm objectAtIndex:2] intValue]];
                int m_sec = [[array_alarm objectAtIndex:3] intValue];
                
                int maybeError = [self intFromHex:[arrayMonAndDay objectAtIndex:0]] & 8;
                
                NSString *strDate = [NSString stringWithFormat:@"%d/%d/%d",
                                     [self intFromHex:[arrayMonAndDay objectAtIndex:0]] & 7,
                                     [self intFromHex:[arrayMonAndDay objectAtIndex:1]],
                                     [self processYear:[arrayYearAndHour objectAtIndex:0]]];
                NSString *strTime = [NSString stringWithFormat:@"%d:%d:%d:%d",
                                     [self intFromHex:[arrayYearAndHour objectAtIndex:1]],
                                     [self intFromHex:[arrayMinAndSec objectAtIndex:0]],
                                     [self intFromHex:[arrayMinAndSec objectAtIndex:1]],
                                     m_sec];
                
                NSString *strAlarmNum = [NSString stringWithFormat:@"%d",[[array_alarm objectAtIndex:4] intValue]];
                
                NSDictionary *dictAlarmInfo = [[_dict_alarm_type objectForKey:@"old_command_trip"] objectForKey:strAlarmNum];
                NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
                [alarm_info setValue:[NSNumber numberWithInt:maybeError] forKey:@"is_error"];
                [alarm_info setValue:[dictAlarmInfo objectForKey:@"description"] forKey:@"description"];
                [alarm_info setValue:strAlarmNum forKey:@"number"];
                [alarm_info setValue:[dictAlarmInfo objectForKey:@"event"] forKey:@"event"];
                [alarm_info setValue:strDate forKey:@"date"];
                [alarm_info setValue:strTime forKey:@"time"];
                cell.dict_alarm_info = alarm_info;
                [alarm_info release];
            } else {
                
                NSTimeInterval offset = 946656000;
                NSString *strAlarmNum = [NSString stringWithFormat:@"%d",[[array_alarm objectAtIndex:0] intValue]];
                
                ////calculation time
                NSTimeInterval time_intervalue = [[array_alarm objectAtIndex:1] intValue] * 65536 +
                [[array_alarm objectAtIndex:2] intValue];
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time_intervalue + offset];
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                [fmt setDateFormat:@"dd/MM/YYYY"];
                NSString *str_date = [fmt stringFromDate:date];
                
                [fmt setDateFormat:@"HH:MM:ss"];
                NSString *str_time = [fmt stringFromDate:date];
                NSString *str_time_ms = [NSString stringWithFormat:@"%@:%d",str_time,
                                         [[array_alarm objectAtIndex:2] intValue] & 951];
                
                NSDictionary *dictAlarmInfo = [[_dict_alarm_type objectForKey:@"new_command_trip"] objectForKey:strAlarmNum];
                NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
                [alarm_info setValue:[dictAlarmInfo objectForKey:@"description"] forKey:@"description"];
                [alarm_info setValue:strAlarmNum forKey:@"number"];
                [alarm_info setValue:[dictAlarmInfo objectForKey:@"event"] forKey:@"event"];
                [alarm_info setValue:str_date forKey:@"date"];
                [alarm_info setValue:str_time_ms forKey:@"time"];
                cell.dict_alarm_info = alarm_info;
                [alarm_info release];
            }
            
//            NSLog(@"%d",indexPath.row);
//            if (!indexPath.row) {
//                [cell showWarningAnimation:YES];
//            } else {
//                [cell showWarningAnimation:NO];
//            }
        } else if ([array_alarm isKindOfClass:[NSString class]]) {
            //SOE
            NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
            [alarm_info setValue:array_alarm forKey:@"soe_title"];
            cell.dict_alarm_info = alarm_info;
            [alarm_info release];
        }
        
        if (_auto_refresh_current_value) {
            id info = [_marray_events objectAtIndex:indexPath.row];
            if ([info isKindOfClass:[NSArray class]]) {
                [self refreshTripCurrent:[_marray_events objectAtIndex:indexPath.row]];
            }
        }
        
     //   NSLog(@"%d",indexPath.row);
        if (!indexPath.row) {
            [cell showWarningAnimation:YES];
        } else {
            [cell showWarningAnimation:NO];
        }
      
    }else{
       
   
    
    id array_alarm = [_marray_events objectAtIndex:indexPath.row];
    if ([array_alarm isKindOfClass:[NSArray class]]) {
        if (!_is_new_command) {
            NSArray *arrayMonAndDay = [self hexFromInt:[[array_alarm objectAtIndex:0] intValue]];
            NSArray *arrayYearAndHour = [self hexFromInt:[[array_alarm objectAtIndex:1] intValue]];
            NSArray *arrayMinAndSec = [self hexFromInt:[[array_alarm objectAtIndex:2] intValue]];
            int m_sec = [[array_alarm objectAtIndex:3] intValue];
            
            int maybeError = [self intFromHex:[arrayMonAndDay objectAtIndex:0]] & 8;
            
            NSString *strDate = [NSString stringWithFormat:@"%d/%d/%d",
                                 [self intFromHex:[arrayMonAndDay objectAtIndex:0]] & 7,
                                 [self intFromHex:[arrayMonAndDay objectAtIndex:1]],
                                 [self processYear:[arrayYearAndHour objectAtIndex:0]]];
            NSString *strTime = [NSString stringWithFormat:@"%d:%d:%d:%d",
                                 [self intFromHex:[arrayYearAndHour objectAtIndex:1]],
                                 [self intFromHex:[arrayMinAndSec objectAtIndex:0]],
                                 [self intFromHex:[arrayMinAndSec objectAtIndex:1]],
                                 m_sec];
            
            NSString *strAlarmNum = [NSString stringWithFormat:@"%d",[[array_alarm objectAtIndex:4] intValue]];
            
            NSDictionary *dictAlarmInfo = [[_dict_alarm_type objectForKey:@"old_command_trip"] objectForKey:strAlarmNum];
            NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
            [alarm_info setValue:[NSNumber numberWithInt:maybeError] forKey:@"is_error"];
            [alarm_info setValue:[dictAlarmInfo objectForKey:@"description"] forKey:@"description"];
            [alarm_info setValue:strAlarmNum forKey:@"number"];
            [alarm_info setValue:[dictAlarmInfo objectForKey:@"event"] forKey:@"event"];
            [alarm_info setValue:strDate forKey:@"date"];
            [alarm_info setValue:strTime forKey:@"time"];
            cell.dict_alarm_info = alarm_info;
            [alarm_info release];
        } else {
            
            NSTimeInterval offset = 946656000;
            NSString *strAlarmNum = [NSString stringWithFormat:@"%d",[[array_alarm objectAtIndex:0] intValue]];
            
            ////calculation time 
            NSTimeInterval time_intervalue = [[array_alarm objectAtIndex:1] intValue] * 65536 +
                                             [[array_alarm objectAtIndex:2] intValue];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time_intervalue + offset];
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            [fmt setDateFormat:@"dd/MM/YYYY"];
            NSString *str_date = [fmt stringFromDate:date];
            
            [fmt setDateFormat:@"HH:MM:ss"];
            NSString *str_time = [fmt stringFromDate:date];
            NSString *str_time_ms = [NSString stringWithFormat:@"%@:%d",str_time,
                                     [[array_alarm objectAtIndex:2] intValue] & 951];
            
            NSDictionary *dictAlarmInfo = [[_dict_alarm_type objectForKey:@"new_command_trip"] objectForKey:strAlarmNum];
            NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
            [alarm_info setValue:[dictAlarmInfo objectForKey:@"description"] forKey:@"description"];
            [alarm_info setValue:strAlarmNum forKey:@"number"];
            [alarm_info setValue:[dictAlarmInfo objectForKey:@"event"] forKey:@"event"];
            [alarm_info setValue:str_date forKey:@"date"];
            [alarm_info setValue:str_time_ms forKey:@"time"];
            cell.dict_alarm_info = alarm_info;
            [alarm_info release];
        }
        
       // NSLog(@"%d",indexPath.row);
        if (!indexPath.row && _show_trip_warnning_animation) {
            [cell showWarningAnimation:YES];
        } else {
            [cell showWarningAnimation:NO];
        }
    } else if ([array_alarm isKindOfClass:[NSString class]]) {
        //SOE
        NSMutableDictionary *alarm_info = [[NSMutableDictionary alloc] init];
        [alarm_info setValue:array_alarm forKey:@"soe_title"];
        cell.dict_alarm_info = alarm_info;
        [alarm_info release];
    }
    
    if (_auto_refresh_current_value) {
        id info = [_marray_events objectAtIndex:indexPath.row];
        if ([info isKindOfClass:[NSArray class]]) {
            [self refreshTripCurrent:[_marray_events objectAtIndex:indexPath.row]];
        }
    }
}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
        
        if (indexPath.row == 0) {
            eventTableViewCell *cell = (eventTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            if ([cell isWarning]) {
                _show_trip_warnning_animation = NO;
                [cell showWarningAnimation:NO];
            }
            
            [self refreshTripCurrent:[_marray_events objectAtIndex:indexPath.row]];
        }

        
    }else{
        
        eventTableViewCell *cell = (eventTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell isWarning]) {
            _show_trip_warnning_animation = NO;
            [cell showWarningAnimation:NO];
        }
        id info = [_marray_events objectAtIndex:indexPath.row];
        if ([info isKindOfClass:[NSArray class]]) {
            [self refreshTripCurrent:[_marray_events objectAtIndex:indexPath.row]];
        }
    }
}

- (void)refreshTripListInfo
{
    NSMutableArray *marrayPosition = [[NSMutableArray alloc] initWithArray:[_system_manager devicePositionInfo]];
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:[marrayPosition objectAtIndex:_int_device_position]];
    NSMutableDictionary *mdictInfo = [[NSMutableDictionary alloc] initWithDictionary:[mdict objectForKey:kTripAlarmInfoKey]];
    [mdictInfo setValue:[NSNumber numberWithInt:_new_alarm_index] forKey:kLastTripIndexKey];
    [mdictInfo setValue:[NSNumber numberWithInt:_of_value] forKey:kLastSoeValueKey];
    [mdictInfo setValue:[NSNumber numberWithInt:_ch_value] forKey:kLastCHValueKey];
    [mdictInfo setValue:[NSNumber numberWithInt:_sd_value] forKey:kLastSDValueKey];
    [mdictInfo setValue:[NSNumber numberWithInt:_sed_value] forKey:kLastSEDValueKey];
    
    [mdictInfo setValue:_marray_events forKey:kTripListKey];
    
    [mdict setObject:mdictInfo forKey:kTripAlarmInfoKey];
    [marrayPosition replaceObjectAtIndex:_int_device_position withObject:mdict];
    
    [_system_manager setMarrayDevicePositionInfo:marrayPosition];
    [mdictInfo release];
    [marrayPosition release];
    [mdict release];
    
    [_system_manager save];
    [_event_list reloadData];
}

- (void)initAlarmUserInterface
{
    _event_list = [[UITableView alloc] initWithFrame:CGRectMake(357, 65, 627, 574)];
    _event_list.delegate = self;
    _event_list.dataSource = self;
    _event_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    _event_list.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_event_list];
}

////////////////////////////////////////////////////////////////////////////////
- (void)parseRecordList:(NSArray *)respond
{
    ///date  first value is 0
    BOOL is_useful = YES;
    if (![[respond objectAtIndex:0] intValue]
        || [[respond objectAtIndex:0] intValue] == 32768) {
        is_useful = NO;
    }
    
  //  NSLog(@"%d",[[respond objectAtIndex:4] intValue]);
    
    ///处理月
    NSInteger int_mon = [[respond objectAtIndex:0] intValue];
    NSArray *arrayMonAndDay = [self hexFromInt:(int_mon >> 1)];
    NSArray *arrayYearAndHour = [self hexFromInt:[[respond objectAtIndex:1] intValue]];
    NSArray *arrayMinAndSec = [self hexFromInt:[[respond objectAtIndex:2] intValue]];
    ///alarm num
    if ([arrayMonAndDay count] < 2 || [arrayYearAndHour count] < 2 || [arrayMinAndSec count] < 2)  {
        is_useful = NO;
    }
    
    if (is_useful) {
        [_marray_events addObject:respond];
    }
    
    _record_index ++;
    if (_record_index < [_marray_record_sort count]) {
        [self getRecordList];
    } else  {
        [self showLoadingView:NO];
        [self refreshTripListInfo];
        [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)parseNewCommandRecordList:(NSArray *)array
{
    int new_record_count = [array count] / 7;
    for (int i = 0; i < new_record_count; i ++) {
       // NSLog(@"%d, %@",i, [array subarrayWithRange:NSMakeRange(i * 7, 7)]);
        [_marray_events addObject:[array subarrayWithRange:NSMakeRange(i * 7, 7)] ];
    }
    [self refreshTripListInfo];
    [self showLoadingView:NO];
    [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
}

/*
 get one record information
 ///E 不解析 date
 ///P
 */
- (void)getRecordList
{
    if (!_is_new_command) {
        [_obj_modbus readRegistersFrom:(alarm_list().start_address +
                                        [[_marray_record_sort objectAtIndex:_record_index] intValue] * alarm_list().register_count)
                                 count:alarm_list().register_count
                               success:^(NSArray *array){
                                   if (_record_index < [_marray_record_sort count]) {
                                       [self parseRecordList:array];
                                   }
                               } failure:^(NSError *error){
                                   [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                               }];
    }
}

/*
 sort record
 list
 */
- (void)recordSort:(int)index
{
    if (!_marray_record_sort) {
        _marray_record_sort = [[NSMutableArray alloc] init];
    }
    [_marray_record_sort removeAllObjects];
    
    for (int i = index ; i < record_count; i ++) {
        [_marray_record_sort addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < index; i ++) {
        [_marray_record_sort addObject:[NSNumber numberWithInt:i]];
    }
    [self getRecordList];
}

/*
 get battery capacity
 */
- (void)getBatteryCapacity
{
    [_obj_modbus readRegistersFrom:battery_capacity().start_address
                      count:battery_capacity().register_count
                    success:^(NSArray *array){
                        [self refreshBatteryInfo:[[array lastObject] intValue]];
                        [self checkEvents];
                    }
                    failure:^(NSError *error){
                        //errorMessageAlert(@"Get battery info failed _%@",error.description);
                        [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                    }];
}

#pragma mark - 定时刷新 -
- (void)checkEvents
{
    int portValue;
    if (_is_new_command) {
        portValue = 12000;
    }
    else {
        portValue = 660;
    }
    
    [_obj_modbus readRegistersFrom:portValue
                             count:1
                           success:^(NSArray *array){
                               int cur_soe = [[array lastObject] intValue] & 1;
                               int cur_sd = [[array lastObject] intValue] & 2;
                               int cur_sed = [[array lastObject] intValue] & 4;
                               int cur_ch = [[array lastObject] intValue] & 8;
                               
                               NSDate *current_date = [NSDate date];
                               NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                               [fmt setDateFormat:@"dd/MM/YYYY          HH:MM:ss:SSS"];
                               NSString *str_date = [fmt stringFromDate:current_date];
                               
                               NSMutableString *mstr = [[NSMutableString alloc] initWithString:@""];
                               
                               BOOL has_date = NO;
                               if ((cur_soe != _of_value) && (_of_value != -1)) {
                                   [mstr appendString:str_date];
                                   has_date = YES;
                                   if (cur_soe) {
                                       [mstr appendString:@"                     OF:Breaker is Closed "];
                                   } else {
                                       [mstr appendString:@"                     OF:Breaker is Opened "];
                                   }
                               }
                               if ((cur_sd != _sd_value) && (_sd_value != -1)) {
                                   if (!has_date) {
                                       [mstr appendString:str_date];
                                   }
                                   if (has_date) {
                                       if (cur_sd) {
                                           [mstr appendString:@"& SD:Breaker has tripped "];
                                       } else {
                                           [mstr deleteCharactersInRange:NSMakeRange(0, [mstr length])];
                                       }
                                   } else {
                                       has_date = YES;
                                       if (cur_sd) {
                                           [mstr appendString:@"                     SD:Breaker has tripped "];
                                       } else {
                                           [mstr deleteCharactersInRange:NSMakeRange(0, [mstr length])];
                                       }
                                   }
                               }
                               if ((cur_sed != _sed_value) && (_sed_value != -1)) {
                                   if (!has_date) {
                                       [mstr appendString:str_date];
                                   }
                                   
                                   if (has_date) {
                                       if (cur_sed) {
                                           [mstr appendString:@"& SDE:Breaker has tripped "];
                                       } else {
                                           [mstr deleteCharactersInRange:NSMakeRange(0, [mstr length])];
                                       }
                                   } else {
                                       has_date = YES;
                                       if (cur_sed) {
                                           [mstr appendString:@"                     SDE:Breaker has tripped "];
                                       } else {
                                           [mstr deleteCharactersInRange:NSMakeRange(0, [mstr length])];
                                       }
                                   }
                               }
                               if ((cur_ch != _ch_value) && (_ch_value != -1)) {
                                   if (!has_date) {
                                       [mstr appendString:str_date];
                                   }
                                   
                                   if (has_date) {
                                       if (cur_ch) {
                                           [mstr appendString:@"& CH:spring loaded "];
                                       } else {
                                           [mstr appendString:@"& CH:spring discharged "];
                                       }
                                   } else {
                                       has_date = YES;
                                       if (cur_ch) {
                                           [mstr appendString:@"                     CH:spring loaded "];
                                       } else {
                                           [mstr appendString:@"                     CH:spring discharged "];
                                       }
                                   }
                               }
                               
                               _of_value = cur_soe;
                               _sd_value = cur_sd;
                               _sed_value = cur_sed;
                               _ch_value = cur_ch;

                               if ([mstr length]) {
                                   [_marray_events insertObject:mstr atIndex:0];
                                   [self refreshTripListInfo];
                               }
                               
                               [self checkRecord];
                           }
                           failure:^(NSError *error){
                               //errorMessageAlert(@"Get battery info failed _%@",error.description);
                               [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                           }];
}

- (void)checkRecord
{
    if (!_is_new_command) {
        [_obj_modbus readRegistersFrom:alarm_recorded().start_address
                                 count:alarm_recorded().register_count
                               success:^(NSArray *array){
                                   ///-1 说明是第一次，加载整个警告列表
                                   if (_new_alarm_index == -1) {
                                       for (int i = 0; i < [array count]; i ++) {
                                           if (!i) {
                                               _alarm_count = [[array objectAtIndex:i] intValue];
                                           } else if (i == 1) {
                                               _new_alarm_index = [[array objectAtIndex:i] intValue];
                                           }
                                       }
                                       [self loadingView:@"Loading..."];
                                       _auto_refresh_current_value = YES;
                                       [self recordSort:[[array objectAtIndex:1] intValue] ];
                                   } else if (_new_alarm_index != [[array objectAtIndex:1] intValue]) {
                                       ///new_index != last_index 说明有新的信息
                                       for (int i = 0; i < [array count]; i ++) {
                                           if (!i) {
                                               _alarm_count = [[array objectAtIndex:i] intValue];
                                           } else if (i == 1) {
                                               _new_alarm_index = [[array objectAtIndex:i] intValue];
                                           }
                                       }
                                       [self appendNewTripHistory:[[array objectAtIndex:1] intValue]];
                                   } else {
                                       //[self refreshTripListInfo];
                                       [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                                   }
                               } failure:^(NSError *error){
                                   [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                               }];
    } else {
        if (_new_alarm_index == -1) {
            _new_alarm_index = 1;
            [self loadingView:@"Loading..."];
            [_obj_modbus readRegistersFrom:9099
                                     count:7 * 17
                                   success:^(NSArray *array){
                                       _auto_refresh_current_value = YES;
                                       [self parseNewCommandRecordList:array];
                                   } failure:^(NSError *error){
                                       [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                                   }];

        } else {
            [_obj_modbus readRegistersFrom:9099
                                     count:7
                                   success:^(NSArray *array){
                                       [self compareNewCommandRecord:array];
                                   } failure:^(NSError *error){
                                       [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                                   }];
        }
    }
}

#pragma mark - new command -
- (void)compareNewCommandRecord:(NSArray *)array
{
    NSArray *array_old = nil;
    for (int i = 0 ; i < [_marray_events count]; i ++) {
        id old = [_marray_events objectAtIndex:i];
        if ([old isKindOfClass:[NSString class]]) {
            continue;
        } else {
            array_old = old;
            break;
        }
    }
    NSTimeInterval old_time = 0;
    NSTimeInterval new_time = 0;
    if ([array_old count]) {
        old_time = [[array_old objectAtIndex:1] intValue] * 65536 + [[array_old objectAtIndex:2] intValue];
        new_time = [[array objectAtIndex:1] intValue] * 65536 + [[array objectAtIndex:2] intValue];
        
        if (new_time > old_time) {
            [_marray_events insertObject:array atIndex:0];
            _show_trip_warnning_animation = YES;
            [self refreshTripListInfo];
        }
    }
    [self showLoadingView:NO];
    [self refreshTripListInfo];
    [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
}

#pragma mark - not new command -
- (void)appendNewTripHistory:(int)index
{
    [_obj_modbus readRegistersFrom:(alarm_list().start_address +
                                    [[_marray_record_sort objectAtIndex:index] intValue] * alarm_list().register_count)
                             count:alarm_list().register_count
                           success:^(NSArray *array){
                               BOOL is_useful = YES;
                               if (![[array objectAtIndex:0] intValue]
                                   || [[array objectAtIndex:0] intValue] == 32768) {
                                   is_useful = NO;
                               }
                               
                               NSArray *arrayMonAndDay = [self hexFromInt:[[array objectAtIndex:0] intValue]];
                               NSArray *arrayYearAndHour = [self hexFromInt:[[array objectAtIndex:1] intValue]];
                               NSArray *arrayMinAndSec = [self hexFromInt:[[array objectAtIndex:2] intValue]];
                               ///alarm num
                               if ([arrayMonAndDay count] < 2 || [arrayYearAndHour count] < 2 || [arrayMinAndSec count] < 2)  {
                                   is_useful = NO;
                               }
                               
                               if (is_useful) {
                                   [_marray_events insertObject:array atIndex:0];
                               }
                               
                               _show_trip_warnning_animation = YES;
                               [self refreshTripListInfo];
                               [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                           } failure:^(NSError *error){
                               //errorMessageAlert(@"Get Record list failed _%@",error.description);
                               [self performSelector:@selector(getBatteryCapacity) withObject:nil afterDelay:1.0f];
                           }];
}

@end
