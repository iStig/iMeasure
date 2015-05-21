//
//  Global.h
//  DaiGou
//
//  Created by user on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Device_IP_Empty       @"192.168.0.2"
#define Device_Port           502
#define Device_Count          20.0f//47.0f
#define Undisplay_num         32768
#define Device_IP_Key         @"modbus_device_ip_key"
#define Control_User_Pwd      @"control_user_pwd"
#define Control_Admin_Pwd     @"control_admin_pwd"


#define Default_Device        @"default_device"
#define Default_Login         @"default_login"

BOOL B_IOS_6_0(void);

NSString * urlEncodedParaString(NSString *str);
NSInteger textAlignmentCenter();

void saveUDObject(id object, NSString *saveKey);
id  getUIObjectForKey(NSString *saveKey);
BOOL isCorrenctIP(NSString *strIP);

void errorMessageAlert(NSString *str, NSString *error);
UIColor * colorWithHexString(NSString *stringToConvert);
NSArray *alarmparseAsc(NSNumber *resp);
