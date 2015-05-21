//
//  SwitchView.m
//  Schneider
//
//  Created by GongXuehan on 13-6-13.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SwitchView.h"
#import "SystemManager.h"
#import <QuartzCore/QuartzCore.h>

#define Switch_Base_Tag 9991
#define Switch_View_Base_Tag 8988
#define Open_Base_Tag 8989
#define Close_Base_Tag 9111

@interface SwitchView ()
{
    SystemManager   *_system_manager;
    NSArray         *_array_struct_rect;
    NSMutableArray  *_marray_sub_switch;
    NSMutableArray  *_marray_switch_rect;
}

@end

@implementation SwitchView
@synthesize marray_switch_state = _marray_switch_state;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_marray_switch_rect release];
    [_marray_switch_state release];
    [_marray_sub_switch release];
    [_array_struct_rect release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _system_manager = [SystemManager shareManager];
        [self creatSubSwitchBtnView];
    }
    return self;
}

- (void)creatSubSwitchBtnView
{
    _array_struct_rect = [[NSArray alloc] initWithArray:[_system_manager structRect]];
    for (int i = 0; i < [_array_struct_rect count]; i ++) {
        UIView *sub_switch_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 48)];
        sub_switch_view.backgroundColor = [UIColor clearColor];
        sub_switch_view.tag = Switch_View_Base_Tag + i;
        
        UIButton *btnOff = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [btnOff setImage:[UIImage imageNamed:@"control_off_btn.png"] forState:UIControlStateNormal];
        [btnOff addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnOff.tag = Open_Base_Tag;
        [sub_switch_view addSubview:btnOff];
        [btnOff release];
        
        UIButton *btnOn = [[UIButton alloc] initWithFrame:CGRectMake(95, 0, 48, 48)];
        [btnOn setImage:[UIImage imageNamed:@"control_open_btn.png"] forState:UIControlStateNormal];
        [btnOn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnOn.tag = Close_Base_Tag;
        [sub_switch_view addSubview:btnOn];
        [btnOn release];
        
        CGRect rect = [[_array_struct_rect objectAtIndex:i] CGRectValue];
        rect.origin.x += 82.0f;
        rect.origin.y += 27.0f;
        CGPoint center = CGPointZero;
        center.x =  rect.origin.x + rect.size.width / 2;
        
        if (i < 3) {
            center.y = rect.origin.y + rect.size.height - 65;
        } else {
            center.y = rect.origin.y + rect.size.height - 35;
        }
        
        sub_switch_view.center = center;
        [self addSubview:sub_switch_view];
        [sub_switch_view release];
    }
}

- (void)creatSwitchWithRect:(CGRect)frame index:(int)index
{
    UIImageView *image_switch = [[UIImageView alloc] initWithFrame:frame];
    image_switch.image = [UIImage imageNamed:@"control_switch.png"];
    image_switch.backgroundColor = [UIColor clearColor];
    image_switch.tag = Switch_Base_Tag + index;
    [self addSubview:image_switch];
    
    CGRect rect = frame;
    if (![[_marray_switch_state objectAtIndex:index] intValue]) {
        if (index != 1) {
            rect.origin.x -= 10;
            rect.origin.y += 5;
            image_switch.frame = rect;
            image_switch.transform = CGAffineTransformRotate(image_switch.transform, -3.14/4);
        }
    } else {
        if (index == 1) {
            rect.origin.x -= 22;
            rect.origin.y += 15;
            image_switch.frame = rect;
            image_switch.transform = CGAffineTransformRotate(image_switch.transform, -3.14/2);
        } 
    }
    
    [_marray_switch_rect addObject:[NSValue valueWithCGRect:frame]];
    [_marray_sub_switch addObject:image_switch];
    [image_switch release];
}

- (void)initSubSwitchView
{
    if (!_marray_sub_switch) {
        _marray_sub_switch = [[NSMutableArray alloc] init];
        _marray_switch_rect = [[NSMutableArray alloc] init];
    } else {
        for (UIImageView *img in _marray_sub_switch) {
            [img removeFromSuperview];
        }
        [_marray_sub_switch removeAllObjects];
        [_marray_switch_rect removeAllObjects];
    }
    ///switch 0
    [self creatSwitchWithRect:CGRectMake(322, 160, 19, 47) index:0];
    ///switch 1
    [self creatSwitchWithRect:CGRectMake(514, 311, 19, 47) index:1];
    ///switch 2
    [self creatSwitchWithRect:CGRectMake(639, 160, 19, 47) index:2];
    //bottom
    ///switch 3
    [self creatSwitchWithRect:CGRectMake(294, 442, 19, 47) index:3];
    ///switch 4
    [self creatSwitchWithRect:CGRectMake(610, 442, 19, 47) index:4];
    ///switch 5
    [self creatSwitchWithRect:CGRectMake(908, 442, 19, 47) index:5];
}

- (void)setMarray_switch_state:(NSMutableArray *)marray_switch_state
{
    [_marray_switch_state release];
    _marray_switch_state = [marray_switch_state retain];
    [self initSubSwitchView];
}

- (void)switchButtonClicked:(UIButton *)btn
{
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {    ///1 close 打开设备，0 open 关闭设备
        int state = btn.tag > Open_Base_Tag ? 1 : 0;
        int index = [[btn superview] tag] - Switch_View_Base_Tag;
     
        if(state){
                if ([_delegate respondsToSelector:@selector(device:switchIsChanged:)]) {
                    [_delegate device:index switchIsChanged:state];
                }}
       
    }else{
    ///1 close 打开设备，0 open 关闭设备
    int state = btn.tag > Open_Base_Tag ? 1 : 0;
    int index = [[btn superview] tag] - Switch_View_Base_Tag;
    if ([_marray_switch_state count] > index) {
        if ([[_marray_switch_state objectAtIndex:index] intValue] != state) {
            if ([_delegate respondsToSelector:@selector(device:switchIsChanged:)]) {
                [_delegate device:index switchIsChanged:state];
            }
        } else {
            NSLog(@"same");
        }
    }
  }
}

- (void)animation:(int)index close:(BOOL)is_close
{
    UIImageView *img_switch = [_marray_sub_switch objectAtIndex:index];
    CGAffineTransform transform;
    CGRect rect = [[_marray_switch_rect objectAtIndex:index] CGRectValue];
    if (is_close) {
        if (index == 1) {
            ///transform = CGAffineTransformRotate(CGAffineTransformIdentity, -3.14/2);
            rect.origin.x -= 20;
            rect.origin.y += 10;
            img_switch.frame = rect;
            img_switch.transform = CGAffineTransformRotate(img_switch.transform, -3.14/2);
            [_marray_switch_state replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:is_close]];
            return;
        } else {
            transform = CGAffineTransformIdentity;
        }
    } else {
        if (index == 1) {
            rect.origin.y -= 5;
            transform = CGAffineTransformIdentity;
        } else {
            rect.origin.x -= 10;
            rect.origin.y += 5;
            transform = CGAffineTransformRotate(img_switch.transform, -3.14/4);
        }
    }
    
    [UIView animateWithDuration:0.2
                     animations:^(void){
                         img_switch.transform = transform;
                         img_switch.frame = rect;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [_marray_switch_state replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:is_close]];
                         }
                     }];
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
