//
//  DeviceManagerView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-17.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceView.h"
#import "SystemDeviceView.h"

typedef enum {
    kHorizontalDirection = 0,
    kVerticalDirection = 1,
}Direction;

@protocol DeviceManagerViewDelegate <NSObject>

- (void)targetFrame:(int)target_index selectedBy:(DeviceView *)deviceView;
- (void)unSelectedTargetFrame:(int)target_index device:(DeviceView*)deviceView;

@end

@interface DeviceManagerView : UIView <DeviceViewMoveDelegate>
{
    NSMutableArray                  *_marrayFreeDeviceView;
    NSMutableArray                  *_marraySelectedDeviceView;
    id<DeviceManagerViewDelegate>   _delegate;
}

@property (nonatomic, retain) NSMutableArray *marrayFreeDeviceView;
@property (nonatomic, retain) NSMutableArray *marraySelectedDeviceView;
@property (nonatomic, assign) id<DeviceManagerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          fangxiang:(Direction)direction
        deviceFrame:(CGRect)deviceFrame
        targetFrame:(NSArray *)targetFrame
        freeDevices:(NSMutableArray *)freeDevices
    selectedDevices:(NSMutableArray *)selectedDevices
         scrollview:(UIScrollView *)scrollview
          superView:(UIView *)superView
        delegate:(id<DeviceManagerViewDelegate>)delegate;

@end
