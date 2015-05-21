//
//  SystemManager.m
//  Schneider
//
//  Created by GongXuehan on 13-4-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SystemManager.h"
#import "DeviceView.h"

NSString *const kPositionEmptyKey = @"device_empty";
NSString *const kDeviceInfoKey = @"device_infomation";
NSString *const kSystemDeviceDistributionKey = @"system_device_distribution";

NSString *const kDeviceIdKey = @"device_id";
NSString *const kDeviceNameKey = @"device_name";
NSString *const kDeviceVersionKey = @"device_version";
NSString *const kDeviceModelKey = @"device_model";
NSString *const kDeviceSystemTypeSettingKey = @"device_system_setting_key";
NSString *const kDeviceStringDisplaySTSKey = @"display_string_device_system_setting_key";
NSString *const kDeviceBreakerNameKey = @"device_breaker_name";

//TCP into
NSString *const kDeviceIpAddressKey = @"device_ip_address";
NSString *const kDevicePortKey = @"device_port";

NSString *const kMeasureInfoKey = @"measure_infomation";

NSString *const kNorImageKey = @"nor_image";
NSString *const kSelImageKey = @"sel_image";

NSString *const kMeasurePositionKey = @"measure_position";
NSString *const kValueKey = @"value_key";
NSString *const kLastValueKey = @"last_value_key";
NSString *const kUnitKey = @"unit_key";
NSString *const kNameKey = @"name_key";
NSString *const kUnitNameKey = @"unit_name_key";

///ievent
NSString *const kTripAlarmInfoKey = @"trip_alarm_info";
NSString *const kLastTripIndexKey = @"last_trip_index";
NSString *const kTripListKey = @"trip_list";
NSString *const kLastSoeValueKey = @"last_soe_value";
NSString *const kLastSDValueKey = @"last_sd_value";
NSString *const kLastSEDValueKey = @"last_sed_value";
NSString *const kLastCHValueKey = @"last_ch_value";

static SystemManager *shareManager = nil;

@interface SystemManager ()
{
}
@end

@implementation SystemManager
@synthesize marrayDevicePositionInfo = _marrayDevicePositionInfo;
//////////////////////////////////////////

/*
    人为的将设备的位置从左向右，从上到下的进行编号。
    set device number from left to right,top to bottom
 */

///init device struct
- (void)loadDevicePositionStruct
{
    if (_marrayDevicePositionInfo) {
        [_marrayDevicePositionInfo release];
    }
    _marrayDevicePositionInfo = [[NSMutableArray alloc] initWithArray:getUIObjectForKey(kSystemDeviceDistributionKey)];
    if (![_marrayDevicePositionInfo count]) {
        _marrayDevicePositionInfo = [[NSMutableArray alloc] initWithCapacity:Max_Display_Device_Count];
        for (int i = 0; i < Max_Display_Device_Count; i++) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            [mdict setValue:[NSNumber numberWithBool:YES] forKey:kPositionEmptyKey];
            [mdict setValue:nil forKey:kDeviceInfoKey];
            [mdict setValue:[NSNumber numberWithInt:-1] forKey:kDeviceIdKey];
            [_marrayDevicePositionInfo addObject:mdict];
            [mdict release];
        }
    }
}

- (NSArray *)devicePositionInfo
{
    [self loadDevicePositionStruct];
    return _marrayDevicePositionInfo;
}

- (NSDictionary *)deviceInfomationOfPosition:(NSInteger)position_index
{
    return [_marrayDevicePositionInfo objectAtIndex:position_index];
}

- (NSDictionary *)deviceInfomationOfDeviceid:(NSInteger)device_id
{
    NSDictionary *resullt = nil;
    for (NSDictionary *dictDevice in _marrayDevicePositionInfo) {
        if ([[dictDevice objectForKey:kDeviceIdKey] intValue] == device_id) {
            resullt = dictDevice;
            break;
        }
    }
    return resullt;
}

- (void)save
{
    saveUDObject(_marrayDevicePositionInfo, kSystemDeviceDistributionKey);
    [self loadDevicePositionStruct];
}

- (void)saveSystemStruct:(NSArray *)deviceStruct
{
    NSMutableDictionary *mdictEmoty = [[NSMutableDictionary alloc] init];
    [mdictEmoty setValue:[NSNumber numberWithBool:YES] forKey:kPositionEmptyKey];
    
    for (int i = 0; i < [deviceStruct count]; i ++) {
        DeviceView *device = [deviceStruct objectAtIndex:i];
        if (!device.target_frame) {
            ///empgy device
            [_marrayDevicePositionInfo replaceObjectAtIndex:i withObject:mdictEmoty];
        } else {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            [mdict setValue:[NSNumber numberWithBool:NO] forKey:kPositionEmptyKey];
            [mdict setObject:device.device_information forKey:kDeviceInfoKey];
            [mdict setValue:[NSNumber numberWithInt:device.device_id] forKey:kDeviceIdKey];
            [_marrayDevicePositionInfo replaceObjectAtIndex:i withObject:mdict];
            [mdict release];
        }
    }

    [self save];
}

- (void)saveMeasureValuesStruct:(NSArray *)measureStruct forDevice:(NSInteger)device_id
{
    ///measure struct
    NSMutableArray *marrayMeasure = [[NSMutableArray alloc] init];
    for (int i = 0; i < [measureStruct count]; i ++) {
        DeviceView *valueView = [measureStruct objectAtIndex:i];
        BOOL isEmpty = YES;
        if (valueView.target_frame) {
            ///not empty
            isEmpty = NO;
        }
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isEmpty],kPositionEmptyKey,valueView.device_information, kDeviceInfoKey, nil];
        [marrayMeasure addObject:dict];
        [dict release];
    }
    
    for (int i = 0; i < [self.marrayDevicePositionInfo count];  i ++)
    {
        NSDictionary *dict = [self.marrayDevicePositionInfo objectAtIndex:i];
        if ([[dict objectForKey:kDeviceIdKey] intValue] == device_id) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [mdict setObject:marrayMeasure forKey:kMeasureInfoKey];
            [self.marrayDevicePositionInfo replaceObjectAtIndex:i withObject:mdict];
            [mdict release];
            break;
        }
    }
    [marrayMeasure release];
    [self save];
}

- (NSArray *)structRect
{
    CGRect rect1 = CGRectMake(0, 63, 248, 260);
    CGRect rect2 = CGRectMake(250, 63, 315, 260);
    CGRect rect3 = CGRectMake(570, 63, 275, 260);
    CGRect rect4 = CGRectMake(0, 330, 220, 260);
    CGRect rect5 = CGRectMake(225, 330, 310, 260);
    CGRect rect6 = CGRectMake(540, 330, 295, 260);
    
    NSArray *array_result = [[NSArray alloc] initWithObjects:[NSValue valueWithCGRect:rect1],[NSValue valueWithCGRect:rect2],
                     [NSValue valueWithCGRect:rect3],[NSValue valueWithCGRect:rect4],[NSValue valueWithCGRect:rect5],
                     [NSValue valueWithCGRect:rect6],nil];
    return [array_result autorelease];
}

//////////////////////////////////////////
- (void)dealloc
{
    [_marrayDevicePositionInfo release];
    [super dealloc];
}

+ (SystemManager *) shareManager{
    @synchronized(self) {
        if (shareManager == nil) {
            [[self alloc] init];
        }
    }
    return shareManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(shareManager == nil) {
            shareManager = [super allocWithZone:zone];
            return shareManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        if (![getUIObjectForKey(Device_IP_Key) length]) {
            saveUDObject(@"192.168.0.2", Device_IP_Key);
        }
        
        if (![getUIObjectForKey(Control_Admin_Pwd) length]) {
            saveUDObject(@"123456", Control_Admin_Pwd);
        }
        
        if (![getUIObjectForKey(Control_User_Pwd) length]) {
            saveUDObject(@"123123", Control_User_Pwd);
        }
        
        [self loadDevicePositionStruct];
    }
    return self;
}

@end
