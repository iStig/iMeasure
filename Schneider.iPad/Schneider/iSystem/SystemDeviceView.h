//
//  SystemDeviceView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-19.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DeviceView.h"
#import "ObjectiveLibModbus.h"

typedef enum {
    kUnknownState = 0,
    kNotConnectState,
    kConnectState,
}ConnectState;

@interface SystemDeviceView : DeviceView
{
    ObjectiveLibModbus *_modbusObj;
}

/*
    init method
 */
- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame
                modbusIp:(NSString *)ipAddress
                    port:(NSInteger)port
               device_id:(NSInteger)device_id;

/*
    current connect state
 */
- (ConnectState)connectState;


#pragma mark - modbus method -
/*
    check connect state of device
 */
- (void)checkDeviceConnect;

/*
    get device model of device
 */
- (void)getDeviceModel;


- (void)hideDeviceInformation;
- (void)showDeviceInformation;

@end
