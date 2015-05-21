//
//  DeviceView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DeviceView.h"
#import "SystemManager.h"
#import <math.h>

#define DRAG_THRESHOLD 10.0f

@interface DeviceView ()
{
    UILabel             *_deviceName;
    CGRect              _start_frame;
    ///touches property
    BOOL                _can_move;          ///default is no,if yes, device view can move.
    CGPoint             _touch_location;
}
@end

@implementation DeviceView
@synthesize target_frame = _target_frame;
@synthesize last_point   = _last_point;
@synthesize device_id    = _device_id;
@synthesize target_index = _target_index;

@synthesize device_information = _device_information;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_device_information release];
    [super dealloc];
}

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = _start_frame = frame;
        self.target_frame = targetFrame;
        _target_index = -1;
        
        _last_point = CGPointMake(frame.size.width / 2, frame.origin.y + frame.size.height / 2);
        self.backgroundColor = [UIColor clearColor];
        
        //device name
        _deviceName = [[UILabel alloc] initWithFrame:self.bounds];
        _deviceName.font = [UIFont systemFontOfSize:80.0f];
        _deviceName.textAlignment = UITextAlignmentCenter;
        _deviceName.backgroundColor = [UIColor clearColor];
        //[self addSubview:_deviceName];
    }
    return self;
}

- (void)setDevice_information:(NSDictionary *)device_information
{
    [_device_information release];
    _device_information = [device_information retain];
    
    //_deviceName.text = [_device_information objectForKey:kDeviceIdKey];
    _device_id = [[_device_information objectForKey:kDeviceIdKey] intValue];
}

- (CGRect)startFrame
{
    return _start_frame;
}

#pragma mark - gesture method -
/*
    1.dragging is closed when touches began
    2.if translation is bigger than a value, can move
    3.close dragging when touches ended
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touch_location = [[touches anyObject] locationInView:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    if (_can_move) {
        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
            [_delegate lockScrollView:YES];
        }
        float deltaX = newTouchLocation.x - _touch_location.x;
        float deltaY = newTouchLocation.y - _touch_location.y;
        
        [self setCenter:CGPointMake(self.center.x + deltaX,
                                    self.center.y + deltaY)];
        if ([_delegate respondsToSelector:@selector(exchangeSuperView:)]) {
            [_delegate exchangeSuperView:self];
        }
    }
    else if (distanceBetweenPoints(_touch_location, newTouchLocation) > DRAG_THRESHOLD) {
        _touch_location = newTouchLocation;
        _can_move = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_can_move) {
        _can_move = NO;
        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
            [_delegate lockScrollView:NO];
        }
    }
    ///method to process device view when touches ended
    [self processTouchesEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_can_move) {
        _can_move = NO;
        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
            [_delegate lockScrollView:NO];
        }
    }
    ///method to process device view when touches ended
    [self processTouchesEnded];
}

#pragma mark - method -
- (CGPoint)centerOfRect:(CGRect)rect
{
    CGPoint center = CGPointZero;
    center.x = rect.origin.x + rect.size.width / 2;
    center.y = rect.origin.y + rect.size.height / 2;
    return center;
}

- (void)backToStartFrameDisplayFrame:(CGRect)displayRect
{
    [UIView animateWithDuration:Device_Animation_Dr(1)
                     animations:^(void){
                         self.frame = displayRect;
                     } completion:^(BOOL finished){
                         self.frame = _start_frame;
                     }];
}

- (void)moveToTargetFrame:(NSInteger)index
{
    if (index < 0 || index > [_target_frame count]) {
        return;
    }
    self.target_index = index;
    CGRect targetFrame = [[_target_frame objectAtIndex:index] CGRectValue];
    [UIView animateWithDuration:Device_Animation_Dr(1)
                     animations:^(void){
                         self.frame = targetFrame;
                     } completion:^(BOOL finished){
                     }];
}

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}

- (void)processTouchesEnded
{
    if ([_delegate respondsToSelector:@selector(touchesEnded:)]) {
        [_delegate touchesEnded:self];
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
