//
//  SystemManager.h
//  Schneider
//
//  Created by GongXuehan on 13-4-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#define Max_Display_Device_Count 6

NSString *const kPositionEmptyKey;
NSString *const kDeviceInfoKey;       
NSString *const kSystemDeviceDistributionKey;

///device information key
NSString *const kDeviceIdKey;
NSString *const kDeviceNameKey;

NSString *const kDeviceVersionKey;
NSString *const kDeviceModelKey;

NSString *const kDeviceSystemTypeSettingKey;
NSString *const kDeviceStringDisplaySTSKey;
NSString *const kDeviceBreakerNameKey;

NSString *const kDeviceIpAddressKey;
NSString *const kDevicePortKey;

NSString *const kNorImageKey;
NSString *const kSelImageKey;

///imeasure information
NSString *const kMeasureInfoKey;
NSString *const kMeasurePositionKey;
NSString *const kValueKey;
NSString *const kLastValueKey;
NSString *const kUnitKey;
NSString *const kNameKey;
NSString *const kUnitNameKey;

///ievent
NSString *const kTripAlarmInfoKey;
NSString *const kLastTripIndexKey;
NSString *const kTripListKey;
NSString *const kLastSoeValueKey;
NSString *const kLastSDValueKey;
NSString *const kLastSEDValueKey;
NSString *const kLastCHValueKey;

@interface SystemManager : NSObject
{
    NSMutableArray *_marrayDevicePositionInfo;
}

@property (nonatomic ,retain) NSMutableArray *marrayDevicePositionInfo;

+ (SystemManager *) shareManager;

#pragma mark - get position information method -
/*
    get device position information
 */
- (NSArray *)devicePositionInfo;

/*
    get device information with position index
 */
- (NSDictionary *)deviceInfomationOfPosition:(NSInteger)position_index;

/*
    get device information with device id
 */
- (NSDictionary *)deviceInfomationOfDeviceid:(NSInteger)device_id;

#pragma mark - set position information method -
/*
 save the device position info
 */
- (void)save;

/*
    save struct information from isystem
 */
- (void)saveSystemStruct:(NSArray *)deviceStruct;

/*
    save measure values of device from iMeasure
 */
- (void)saveMeasureValuesStruct:(NSArray *)measureStruct forDevice:(NSInteger)device_id;


- (NSArray *)structRect;

@end
