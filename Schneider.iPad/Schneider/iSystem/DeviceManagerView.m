//
//  DeviceManagerView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-17.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DeviceManagerView.h"
#import "SystemManager.h"
#import <QuartzCore/QuartzCore.h>

#define Manager_Tag 89757

@interface DeviceManagerView ()
{
    UIScrollView *_scroll_view;
    UIView       *_super_view;
    DeviceView   *_emptyDevice;
    NSArray      *_target_frames;
    Direction    _direction;
}

@property (nonatomic, retain) NSArray *target_frames;

@end

@implementation DeviceManagerView
@synthesize marrayFreeDeviceView = _marrayFreeDeviceView;
@synthesize marraySelectedDeviceView = _marraySelectedDeviceView;
@synthesize target_frames = _target_frames;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_target_frames release];
    [_emptyDevice release];
    [_marrayFreeDeviceView release];
    [_marraySelectedDeviceView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
          fangxiang:(Direction)direction
        deviceFrame:(CGRect)deviceFrame
        targetFrame:(NSArray *)targetFrame
        freeDevices:(NSMutableArray *)freeDevices
    selectedDevices:(NSMutableArray *)selectedDevices
         scrollview:(UIScrollView *)scrollview
          superView:(UIView *)superView
           delegate:(id<DeviceManagerViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.tag = Manager_Tag;
        // Initialization code
        _scroll_view = scrollview;
        _scroll_view.clipsToBounds = YES;
        _scroll_view.layer.cornerRadius = 8.0f;
        _scroll_view.layer.borderWidth = 1.0f;
        _scroll_view.layer.borderColor = colorWithHexString(@"cccccc").CGColor;
        [self addSubview:_scroll_view];
        
        _super_view = superView;
        _direction = direction;
        self.target_frames = targetFrame;
        
        _emptyDevice = [[DeviceView alloc] initWithStartFrame:CGRectZero targetFrame:nil];
        ///free device 
        _marrayFreeDeviceView = [[NSMutableArray alloc] initWithArray:freeDevices];
        for (DeviceView *device in _marrayFreeDeviceView) {
            device.delegate = self;
        }
        
        self.delegate = delegate;
        ///selected device
        _marraySelectedDeviceView = [[NSMutableArray alloc] initWithArray:selectedDevices];
        [self initStartStruct];
    }
    return self;
}

- (void)initStartStruct
{
    for (int i = 0; i < [_marraySelectedDeviceView count]; i++) {
        DeviceView *device = [_marraySelectedDeviceView objectAtIndex:i];
        if (device.target_frame) {
            ///target frame is empgy
            ///device is subview of scroll view
            device.center = [self relativeCenterFromScrollToManager:device.center];
            ///move to target frame
            [device moveToTargetFrame:i];
            ///add to manager view
            [self addSubview:device];
            
            if ([_delegate respondsToSelector:@selector(targetFrame:selectedBy:)]) {
                [_delegate targetFrame:device.target_index selectedBy:device];
            }
        }
    }
}

#pragma mark - judgment the position of device view -
- (NSInteger)inTargetFrame:(DeviceView *)deviceView
{
    CGPoint displayCenter = CGPointZero;
    displayCenter = deviceView.center;
    
//    if (![_marraySelectedDeviceView containsObject:deviceView]) {
//        ///if device view is subview of scrollview
//        if (_direction == kVerticalDirection) {
//            displayCenter = CGPointMake(deviceView.center.x + _scroll_view.frame.origin.x, deviceView.center.y - _scroll_view.contentOffset.y);
//        } else if (_direction == kHorizontalDirection) {
//            displayCenter = CGPointMake(deviceView.center.x - _scroll_view.contentOffset.x, displayCenter.y + _scroll_view.frame.origin.y);
//        }
//    }
    
    NSInteger index = -1;
    for (int i=0;i<[self.target_frames count];i++) {
        CGRect goodFrame = [[self.target_frames objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(goodFrame, displayCenter))
        {
            index = i;
            break;
        }
    }
    return index;
}
#pragma mark - manager device view method -
- (void)removeADeviceView:(DeviceView *)device
{
    if ([_marraySelectedDeviceView containsObject:device]) {
        [_marraySelectedDeviceView replaceObjectAtIndex:device.target_index withObject:_emptyDevice];
        device.target_index = -1;
    }
}

- (void)addADeviceView:(DeviceView *)device
{
    if (![_marraySelectedDeviceView containsObject:device]) {
        [_marraySelectedDeviceView replaceObjectAtIndex:device.target_index withObject:device];
    }
}

- (void)exchangeDevice:(DeviceView *)device1 andDevice:(DeviceView *)device2
{
    if ([_marraySelectedDeviceView containsObject:device1] &&
        [_marraySelectedDeviceView containsObject:device2]) {
        [_marraySelectedDeviceView exchangeObjectAtIndex:device1.target_index withObjectAtIndex:device2.target_index];
    }
}


- (CGRect)displayFrame:(DeviceView *)deviceView
{
    CGRect startFrame = [deviceView startFrame];
    
    if (_direction == kVerticalDirection) {
        //vertical direction , origin . y
        if (startFrame.origin.y - _scroll_view.contentOffset.y < 0) {
            startFrame.origin.y = _scroll_view.contentOffset.y - deviceView.frame.size.height;
        } else if (startFrame.origin.y - _scroll_view.contentOffset.y - _scroll_view.frame.size.height > self.frame.size.height) {
            startFrame.origin.y = _scroll_view.contentOffset.y + _scroll_view.frame.size.height;
        }
    } else if (_direction == kHorizontalDirection) {
        if (startFrame.origin.x - _scroll_view.contentOffset.x < 0) {
            startFrame.origin.x = _scroll_view.contentOffset.x - self.frame.size.width;
        } else if (startFrame.origin.x - _scroll_view.contentOffset.x - _scroll_view.frame.size.width > self.frame.size.width) {
            startFrame.origin.x = _scroll_view.contentOffset.x + _scroll_view.frame.size.width;
        }
    }
    return startFrame;
}

#pragma mark - relative center between scroll view and manager view -
- (CGPoint)relativeCenterFromScrollToManager:(CGPoint)point
{
    CGPoint managerCenter = point;
    if (_direction == kHorizontalDirection) {
        managerCenter.x = point.x - _scroll_view.contentOffset.x;
        managerCenter.y = point.y + _scroll_view.frame.origin.y;
    } else {
        managerCenter.y = point.y - _scroll_view.contentOffset.y;
        managerCenter.x = point.x + _scroll_view.frame.origin.x;
    }
    return managerCenter;
}

- (CGPoint)relativeCenterFromManagerToScroll:(CGPoint)point
{
    CGPoint scrollCenter = point;
    if (_direction == kHorizontalDirection) {
        scrollCenter.x = point.x + _scroll_view.contentOffset.x;
        scrollCenter.y = point.y - _scroll_view.frame.origin.y;
    } else {
        scrollCenter.y = point.y + _scroll_view.contentOffset.y;
        scrollCenter.x = point.x - _scroll_view.frame.origin.x;
    }
    return scrollCenter;
}

#pragma mark - device view delegate method -
- (void)lockScrollView:(BOOL)lock
{
    _scroll_view.scrollEnabled = !lock;
}

- (void)exchangeSuperView:(DeviceView *)deviceView
{
    if ([[deviceView superview] tag] != Manager_Tag) {
        ///device is subview of scroll view
        deviceView.center = [self relativeCenterFromScrollToManager:deviceView.center];
        ///add to manager view
        [self addSubview:deviceView];
    }
}

- (void)touchesEnded:(DeviceView *)deviceView
{
    ///judgment the target_index
    NSInteger target_index = [self inTargetFrame:deviceView];
    NSLog(@"targeet_index %d",target_index);
    if (target_index == -1) {
        ///not sotp at a target frame
        if ([_marraySelectedDeviceView containsObject:deviceView]) {
            ///deviceview is subview of managerview
            if ([_delegate respondsToSelector:@selector(unSelectedTargetFrame:device:)]) {
                [_delegate unSelectedTargetFrame:deviceView.target_index device:deviceView];
            }            
            deviceView.center = [self relativeCenterFromManagerToScroll:deviceView.center];
            ///add to scroll view
            [_scroll_view addSubview:deviceView];
            ///move to start frame
            [deviceView backToStartFrameDisplayFrame:[self displayFrame:deviceView]];
            ///remove frome selected views
            [self removeADeviceView:deviceView];
            
        } else {
            ///device is subview of scrollview
            deviceView.center = [self relativeCenterFromManagerToScroll:deviceView.center];
            [_scroll_view addSubview:deviceView];
            [deviceView backToStartFrameDisplayFrame:[self displayFrame:deviceView]];
        }
    } else  {
        ///stop at a target frame
        DeviceView *oldDeviceView = nil;
        if (target_index < [_marraySelectedDeviceView count]) {
            oldDeviceView = [_marraySelectedDeviceView objectAtIndex:target_index];
        }
        if (!oldDeviceView.target_frame) {
            ///target frame is empty
            if (![_marraySelectedDeviceView containsObject:deviceView]) {
                ///device is subview of scroll view
                //deviceView.center = [self relativeCenterFromScrollToManager:deviceView.center];
            } else {
                ///device is already of scroll view
                if ([_delegate respondsToSelector:@selector(unSelectedTargetFrame:device:)]) {
                    [_delegate unSelectedTargetFrame:deviceView.target_index device:deviceView];
                }
                [self removeADeviceView:deviceView];
            }
            ///move to target frame
            [deviceView moveToTargetFrame:target_index];
            ///add to manager view
            //[self addSubview:deviceView];
            [self addADeviceView:deviceView];
            if ([_delegate respondsToSelector:@selector(targetFrame:selectedBy:)]) {
                [_delegate targetFrame:deviceView.target_index selectedBy:deviceView];
            }
        } else {
            ///taraget frame is not empty
            if (deviceView == [_marraySelectedDeviceView objectAtIndex:target_index]) {
                ///the same device view
                [deviceView moveToTargetFrame:target_index];
            } else {
                ///not the same device, exchange
                if (deviceView.target_index == -1) {
                    ///old view back to start frame
                    if ([_delegate respondsToSelector:@selector(unSelectedTargetFrame:device:)]) {
                        [_delegate unSelectedTargetFrame:oldDeviceView.target_index device:oldDeviceView];
                    }
                    [(SystemDeviceView *)oldDeviceView showDeviceInformation];
                    
                    [self removeADeviceView:oldDeviceView];
                    oldDeviceView.center = [self relativeCenterFromManagerToScroll:oldDeviceView.center];
                    [_scroll_view addSubview:oldDeviceView];
                    [oldDeviceView backToStartFrameDisplayFrame:[self displayFrame:oldDeviceView]];

                    ///device view exchange old view
                    //deviceView.center = [self relativeCenterFromScrollToManager:deviceView.center];
                    //[self addSubview:deviceView];
                    [deviceView moveToTargetFrame:target_index];
                    [self addADeviceView:deviceView];
                    if ([_delegate respondsToSelector:@selector(targetFrame:selectedBy:)]) {
                        [_delegate targetFrame:deviceView.target_index selectedBy:deviceView];
                    }
                } else {
                    oldDeviceView.target_index = deviceView.target_index;
                    deviceView.target_index = target_index;
                    [self exchangeDevice:oldDeviceView andDevice:deviceView];
                    
                    if ([_delegate respondsToSelector:@selector(targetFrame:selectedBy:)]) {
                        [_delegate targetFrame:oldDeviceView.target_index selectedBy:oldDeviceView];
                    }
                    
                    [deviceView moveToTargetFrame:deviceView.target_index];
                    [oldDeviceView moveToTargetFrame:oldDeviceView.target_index];
                    if ([_delegate respondsToSelector:@selector(targetFrame:selectedBy:)]) {
                        [_delegate targetFrame:deviceView.target_index selectedBy:deviceView];
                    }

                }
            }
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
