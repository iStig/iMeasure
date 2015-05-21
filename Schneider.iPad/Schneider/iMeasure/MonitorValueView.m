//
//  MonitorValueView.m
//  Schneider
//
//  Created by GongXuehan on 13-5-30.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "MonitorValueView.h"
#import "DeviceView.h"
#import "SystemManager.h"
#import <QuartzCore/QuartzCore.h>

#define DRAG_THRESHOLD_M 10.0f

@interface MonitorValueView ()
{
    CGRect              _start_frame;

    BOOL                _can_move;          ///default is no,if yes, device view can move.
    CGPoint             _touch_location;
    
    UILabel             *_lbl_name;
    UILabel             *_lbl_value;
    UILabel             *_lbl_unit;
    //compass
    UIImageView              *_compass_view;
    
    UILabel             *_compass_lbl_name;
    UILabel             *_compass_lbl_unit;
    UILabel             *_compass_lbl_value;
    UILabel             *_compass_lbl_unit_name;
    UIImageView         *_compass_image_bg;
    UIImageView         *_compass_img_Pointer;
    UIImageView         *_compass_center_img;
    
    BOOL                isCompassType;
    
    CGFloat             angleValue;
}

@end

@implementation MonitorValueView
@synthesize delegate = _delegate;
@synthesize target_frame = _target_frame;
@synthesize target_index = _target_index;
@synthesize dict_monitor = _dict_monitor;
- (void)dealloc
{
    [_dict_monitor release];
    [_lbl_name release];
    [_lbl_value release];
    [_lbl_unit release];
    [_target_frame release];
    
    [_compass_lbl_name release];
    [_compass_lbl_unit release];
    [_compass_lbl_value release];
    [_compass_lbl_unit_name release];
    [_compass_image_bg release];
    [_compass_img_Pointer release];
    [_compass_view release];
    [super dealloc];
}

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"value_view_bg.png"];
        self.layer.borderWidth = 3.0;
        self.layer.cornerRadius = 10.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;

        self.frame = _start_frame = frame;
        self.target_frame = targetFrame;
        _target_index = -1;
        isCompassType = NO;
        
        
        [self updateUserInterface:ThumbSizeType compass:isCompassType];
    }
    return self;
}

- (void)setDict_monitor:(NSDictionary *)dict_monitor
{
    [_dict_monitor release];
    _dict_monitor = [dict_monitor retain];
    
    NSDictionary *dict = [dict_monitor objectForKey:kValueKey];
    if (dict) {
        _lbl_name.text = [[dict allKeys] lastObject];
        _compass_lbl_name.text = [[dict allKeys] lastObject];
        
        if ([[dict objectForKey:_lbl_name.text] isKindOfClass:[NSString class]]) {
            _lbl_value.text = [dict objectForKey:_lbl_name.text];
            _compass_lbl_value.text = [dict objectForKey:_lbl_name.text];
            angleValue = [[dict objectForKey:_lbl_name.text] floatValue];

        } else {
            _lbl_value.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:_lbl_name.text] intValue]];
            _compass_lbl_value.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:_lbl_name.text] intValue]];
            angleValue = [[dict objectForKey:_lbl_name.text] floatValue];

        }
        CGFloat angleFloat = 0;

        
        if ([[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"A"]) {
              angleFloat = angleValue/1000*100-60;
        }
       if([[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"V"]){
              angleFloat = angleValue/440*100-60;
        }
        else if([[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"P"]||[[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"Q"]||[[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"S"]){
            angleFloat = angleValue/66000*100-60;
            
        }
        else if([[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"E"]){
            angleFloat = angleValue/100*100-60;
            
        }
        else if([[dict_monitor objectForKey:kUnitNameKey]  isEqualToString:@"PF"]){
            angleFloat = angleValue/1*100-60;
        }
        else {
//            angleFloat = angleValue/1000*100-60;
        }
        
        if (angleFloat > 60.0) {
            angleFloat = 60.0;
        }

        _compass_img_Pointer.layer.transform = CATransform3DMakeRotation(angleFloat*M_PI/180, 0, 0, 1);
        NSLog(@"%0.1f",angleFloat*M_PI/180);
        
        _lbl_unit.text = [dict_monitor objectForKey:kUnitKey];
        _compass_lbl_unit.text = [dict_monitor objectForKey:kUnitKey];
        _compass_lbl_unit_name.text = [dict_monitor objectForKey:kUnitNameKey];
        
    }
    
    
}

- (void)changecompass:(BOOL)isCompass{
    
    _compass_view.hidden=!isCompass;
    isCompassType=isCompass;


}

- (void)updateUserInterface:(SizeType)type compass:(BOOL)isCompass
{
   
    
    
    if (!_lbl_name)  {
        _lbl_name = [[UILabel alloc] init];
        _lbl_name.text = @"Test";
        _lbl_name.backgroundColor = [UIColor clearColor];
        _lbl_name.textAlignment = UITextAlignmentCenter;
        _lbl_name.textColor = colorWithHexString(@"999999");
        [self addSubview:_lbl_name];
    }
    if (!_lbl_value) {
        _lbl_value = [[UILabel alloc] init];
        _lbl_value.textAlignment = UITextAlignmentCenter;
        _lbl_value.backgroundColor = [UIColor clearColor];
        _lbl_value.textColor = colorWithHexString(@"666666");
        _lbl_value.text = @"12580";
        [self addSubview:_lbl_value];
    }
    
    if (!_lbl_unit) {
        _lbl_unit = [[UILabel alloc] init];
        //_lbl_unit.textAlignment = UITextAlignmentCenter;
        _lbl_unit.backgroundColor = [UIColor clearColor];
        _lbl_unit.textAlignment = UITextAlignmentRight;
        _lbl_unit.textColor = colorWithHexString(@"666666");
        _lbl_unit.text = @"UN";
        [self addSubview:_lbl_unit];
    }
    
    
    //COMPASS
    if (!_compass_view) {
        _compass_view = [[UIImageView alloc] init];
        _compass_view.userInteractionEnabled = YES;
        _compass_view.image = [UIImage imageNamed:@"仪表盘背景.png"];
        [self addSubview:_compass_view];
        _compass_view.hidden=YES;
    }
    
    if (!_compass_img_Pointer) {
        _compass_img_Pointer = [[UIImageView alloc] init];
        _compass_img_Pointer.layer.anchorPoint = CGPointMake(0.5, 1);
        _compass_img_Pointer.transform = CGAffineTransformMakeScale(1, 1);
        _compass_img_Pointer.image = [UIImage imageNamed:@"指针.png"];
        [_compass_view addSubview:_compass_img_Pointer];
    }
    
    if (!_compass_center_img) {
        _compass_center_img = [[UIImageView alloc] init];
        _compass_center_img.image = [UIImage imageNamed:@"原点.png"];
        [_compass_view addSubview:_compass_center_img];
    }
    
  
    if (!_compass_lbl_unit_name) {
        _compass_lbl_unit_name = [[UILabel alloc] init];
        _compass_lbl_unit_name.backgroundColor = [UIColor clearColor];
        _compass_lbl_unit_name.textColor = colorWithHexString(@"fefbff");
        _compass_lbl_unit_name.textAlignment = UITextAlignmentCenter;
        _compass_lbl_unit_name.text = @"A";
        [_compass_view addSubview:_compass_lbl_unit_name];
    }
    if (!_compass_lbl_unit) {
        _compass_lbl_unit = [[UILabel alloc] init];
        _compass_lbl_unit.textAlignment = UITextAlignmentRight;
        _compass_lbl_unit.text = @"UN";
        _compass_lbl_unit.textColor = colorWithHexString(@"666666");
        _compass_lbl_unit.backgroundColor=[UIColor clearColor];
        [_compass_view addSubview:_compass_lbl_unit];
    }
    if (!_compass_lbl_name) {
        _compass_lbl_name = [[UILabel alloc] init];
        _compass_lbl_name.textColor = colorWithHexString(@"999999");
        _compass_lbl_name.textAlignment = UITextAlignmentLeft;
        _compass_lbl_name.text = @"Test";
        _compass_lbl_name.backgroundColor = [UIColor clearColor];
        [_compass_view addSubview:_compass_lbl_name];
    }
    if (!_compass_lbl_value) {
        _compass_lbl_value = [[UILabel alloc] init];
        _compass_lbl_value.backgroundColor = [UIColor clearColor];
        _compass_lbl_value.textAlignment = UITextAlignmentCenter;
        _compass_lbl_value.textColor = colorWithHexString(@"4fa900");
        _compass_lbl_value.text = @"12580";
        [_compass_view addSubview:_compass_lbl_value];
    }
      _compass_view.frame = CGRectMake(0, 0, self.frame.size.width,  self.frame.size.height);
      _compass_img_Pointer.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
    if (type == ThumbSizeType) {
        _lbl_name.frame = CGRectMake(10, 84, _start_frame.size.width - 20, 20);
        _lbl_name.font = [UIFont boldSystemFontOfSize:16.0f];
        
        _lbl_value.frame = CGRectMake(10, 26, _start_frame.size.width - 50, 37);
        _lbl_value.font = [UIFont boldSystemFontOfSize:30.0f];
        
        _lbl_unit.frame = CGRectMake(_start_frame.size.width - 60, 40, 50, 20);
        _lbl_unit.font = [UIFont boldSystemFontOfSize:15];
        
        //COMPASS
        _compass_center_img.frame = CGRectMake((self.frame.size.width-8)/2, 84, 8, 8);
        
        _compass_img_Pointer.frame = CGRectMake((self.frame.size.width-2)/2, 27, 2, 58);
        
         _compass_lbl_name.frame = CGRectMake(8,self.frame.size.height-self.frame.size.height/8-5, (self.frame.size.width-50)/4+10+5, self.frame.size.height/8);
        _compass_lbl_name.font = [UIFont boldSystemFontOfSize:11.0f];
        
        _compass_lbl_unit.frame = CGRectMake(146-8-((self.frame.size.width-50)/4+10+5), self.frame.size.height-self.frame.size.height/8-5,(self.frame.size.width-50)/4+10+5, self.frame.size.height/8);
        _compass_lbl_unit.font = [UIFont boldSystemFontOfSize:11.0f];
        
        
        _compass_lbl_value.frame =CGRectMake(8+(self.frame.size.width-50)/4+5+2, self.frame.size.height-self.frame.size.height/4+5, 68, 20);
        _compass_lbl_value.font = [UIFont boldSystemFontOfSize:18.0f];
        
        _compass_lbl_unit_name.frame = CGRectMake(146/2-10, 36, 20, 20);
        _compass_lbl_unit_name.font = [UIFont boldSystemFontOfSize:11.0f];
        
    } else if (type == SmallSizeType) {
        _lbl_name.frame = CGRectMake(10, 120, self.frame.size.width - 20, 30);
        _lbl_name.font = [UIFont boldSystemFontOfSize:20.0f];
        
        _lbl_value.frame = CGRectMake(10, 46, self.frame.size.width - 60, 60);
        _lbl_value.font = [UIFont boldSystemFontOfSize:50];
        
        _lbl_unit.frame = CGRectMake(self.frame.size.width - 80, 70, 70, 30);
        _lbl_unit.font = [UIFont boldSystemFontOfSize:20.0f];
        
        //COMPASS
         _compass_center_img.frame = CGRectMake((self.frame.size.width-10)/2, 120, 10, 10);
         _compass_img_Pointer.frame = CGRectMake((self.frame.size.width-3)/2, 38, 3, 83);
        _compass_lbl_name.frame = CGRectMake(10,self.frame.size.height-self.frame.size.height/8-7, (self.frame.size.width-50)/4+10, self.frame.size.height/8);
        _compass_lbl_name.font = [UIFont boldSystemFontOfSize:15.0f];
        
        _compass_lbl_unit.frame = CGRectMake(214-10-((self.frame.size.width-50)/4+10), self.frame.size.height-self.frame.size.height/8-7,(self.frame.size.width-50)/4+10, self.frame.size.height/8);
        _compass_lbl_unit.font = [UIFont boldSystemFontOfSize:15.0f];
        
        _compass_lbl_value.frame =CGRectMake(10+(self.frame.size.width-50)/4+15, self.frame.size.height-self.frame.size.height/4+7, 80, 28);
        _compass_lbl_value.font = [UIFont boldSystemFontOfSize:22.0f];
        _compass_lbl_unit_name.frame = CGRectMake(214/2-16, 50, 30, 30);
        _compass_lbl_unit_name.font = [UIFont boldSystemFontOfSize:15.0f];


    } else if (type == BigSizeType) {
        _lbl_name.frame = CGRectMake(10, 180, self.frame.size.width - 20, 40);
        _lbl_name.font = [UIFont boldSystemFontOfSize:30];
        
        _lbl_value.frame = CGRectMake(10, 57, self.frame.size.width - 80, 100);
        _lbl_value.font = [UIFont boldSystemFontOfSize:80];
        
        _lbl_unit.frame = CGRectMake(self.frame.size.width - 110, 100, 100, 40);
        _lbl_unit.font = [UIFont boldSystemFontOfSize:30.0f];
        
        //COMPASS
         _compass_center_img.frame = CGRectMake((self.frame.size.width-14)/2, 180, 14, 14);
         _compass_img_Pointer.frame = CGRectMake((self.frame.size.width-5)/2, 50, 5, 132);
        _compass_lbl_name.frame = CGRectMake(13,self.frame.size.height-self.frame.size.height/8-10, (self.frame.size.width-50)/4, self.frame.size.height/8);
        _compass_lbl_name.font = [UIFont boldSystemFontOfSize:20.0f];
        
        _compass_lbl_unit.frame = CGRectMake(332-13-((self.frame.size.width-50)/4), self.frame.size.height-self.frame.size.height/8-10,(self.frame.size.width-50)/4, self.frame.size.height/8);
        _compass_lbl_unit.font = [UIFont boldSystemFontOfSize:20.0f];


        _compass_lbl_value.frame =CGRectMake(13+(self.frame.size.width-50)/4+5, self.frame.size.height-self.frame.size.height/4+10, 155, 42);
        _compass_lbl_value.font = [UIFont boldSystemFontOfSize:28.0f];
        
        _compass_lbl_unit_name.frame = CGRectMake(332/2-22, 76, 40, 40);
        _compass_lbl_unit_name.font = [UIFont boldSystemFontOfSize:20.0f];
        

    }
    
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
    if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
        [_delegate lockScrollView:YES];
    }
    if ([_delegate respondsToSelector:@selector(exchangeSuperView:)]) {
        [_delegate exchangeSuperView:self];
    }

    self.layer.borderColor = colorWithHexString(@"4fa600").CGColor;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    //if (_can_move) {
//        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
//            [_delegate lockScrollView:YES];
//        }
        float deltaX = newTouchLocation.x - _touch_location.x;
        float deltaY = newTouchLocation.y - _touch_location.y;
        
        [self setCenter:CGPointMake(self.center.x + deltaX,
                                    self.center.y + deltaY)];
        if ([_delegate respondsToSelector:@selector(exchangeSuperView:)]) {
            [_delegate exchangeSuperView:self];
        }
    //}
//    else if ([self distanceBetweenPoints:_touch_location b:newTouchLocation] > DRAG_THRESHOLD_M) {
//        _touch_location = newTouchLocation;
//        _can_move = YES;
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_can_move) {
//        _can_move = NO;
        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
            [_delegate lockScrollView:NO];
        }
//    }
    ///method to process device view when touches ended
    [self processTouchesEnded];
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (_can_move) {
//        _can_move = NO;
        if ([_delegate respondsToSelector:@selector(lockScrollView:)]) {
            [_delegate lockScrollView:NO];
        }
//    }
    ///method to process device view when touches ended
    [self processTouchesEnded];
    self.layer.borderColor = [UIColor clearColor].CGColor;
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
                         [self updateUserInterface:ThumbSizeType compass:isCompassType];
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
                         if (targetFrame.size.width == Mon_small_box_size.width) {
                             [self updateUserInterface:SmallSizeType compass:isCompassType];
                         } else if (targetFrame.size.width == Mon_big_box_size.width) {
                             [self updateUserInterface:BigSizeType compass:isCompassType];
                         }
                     } completion:^(BOOL finished){
                     }];
}

- (float)distanceBetweenPoints:(CGPoint)a b:(CGPoint)b
{
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

@end
