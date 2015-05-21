//
//  DeviceBlock.h
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "TKDragView.h"

@protocol DeviceBlockDelegate;

@interface DeviceBlock : TKDragView
{
    NSInteger               _intDeviceId;
    NSString                *_strDeviceName;
    id<DeviceBlockDelegate> _deviceDelegate;
}

@property (nonatomic, assign) NSInteger                 intDeviceId;
@property (nonatomic, retain) NSString                  *strDeviceName;
@property (nonatomic, assign) id<DeviceBlockDelegate>   deviceDelegate;

- (void)showEditModel:(BOOL)edit;

@end

@protocol DeviceBlockDelegate <NSObject>

- (void)deviceViewRemoveButtonClicked:(DeviceBlock *)device;

@end
