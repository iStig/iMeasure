//
//  DeviceView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Device_Animation_Dr(d) (0.1f * (d + 1))

@protocol DeviceViewMoveDelegate;

@interface DeviceView : UIView <UIGestureRecognizerDelegate>
{
    ///device descrption
    NSInteger           _device_id;
    NSDictionary        *_device_information;
    
    ///device view information
    CGPoint             _last_point;
    NSArray             *_target_frame;
    NSInteger           _target_index;
    
    id<DeviceViewMoveDelegate> _delegate;
}

@property (nonatomic, assign) NSInteger         device_id;
@property (nonatomic, assign) CGPoint           last_point;
@property (nonatomic, retain) NSArray           *target_frame;
@property (nonatomic, retain) NSDictionary      *device_information;
@property (nonatomic, assign) id<DeviceViewMoveDelegate> delegate;

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame;
/*
    current target index of target frames of device
 */
@property (nonatomic, assign) NSInteger         target_index;

/*
    back to start frame
    display rect ,the device display rect
 */
- (void)backToStartFrameDisplayFrame:(CGRect)displayRect;

/*
    move to a target frame
 */
- (void)moveToTargetFrame:(NSInteger)index;

/*
    get start frame of device view
 */
- (CGRect)startFrame;

@end

@protocol DeviceViewMoveDelegate <NSObject>

- (void)lockScrollView:(BOOL)lock;
- (void)touchesEnded:(DeviceView *)deviceView;
- (void)touchesBegan:(DeviceView *)deviceView;
- (void)exchangeSuperView:(DeviceView *)deviceView;

@end