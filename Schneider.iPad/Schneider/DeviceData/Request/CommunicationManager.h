//
//  CommunicationManager.h
//  Schneider
//
//  Created by GongXuehan on 13-4-18.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    judging device is connected delegate
    for isystem or icontrol.
 */
@protocol DeviceConnecteDelected <NSObject>

- (void)device:(NSInteger)device_id isConnected:(BOOL)is_connected;

@end

@interface CommunicationManager : NSObject
{
    id<DeviceConnecteDelected> _connect_delegate;
}

@property (nonatomic, assign) id<DeviceConnecteDelected> connect_delegate;


+ (CommunicationManager *) commManager;

@end
