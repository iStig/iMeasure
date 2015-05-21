//
//  MonitorValueView.h
//  Schneider
//
//  Created by GongXuehan on 13-5-30.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Max_Row 30
#define Mon_space_height  20.0f
#define Mon_space_width  22.0f
#define Mon_big_box_size    CGSizeMake(332, 250)
#define Mon_small_box_size  CGSizeMake(214, 170)

#define Monitor_Left_Margin 12
#define Monitor_Top_Margin  26
#define Monitor_Height_Margin 37

typedef enum {
    ThumbSizeType = 0,
    SmallSizeType,
    BigSizeType,
} SizeType;

@protocol MonitorValueViewDelegate;

@interface MonitorValueView : UIImageView <UIGestureRecognizerDelegate>
{
    NSArray             *_target_frame;
    NSInteger           _target_index;
    id<MonitorValueViewDelegate> _delegate;
    
    NSDictionary        *_dict_monitor;
}

@property (nonatomic, assign) id<MonitorValueViewDelegate> delegate;
@property (nonatomic, retain) NSArray           *target_frame;
@property (nonatomic, assign) NSInteger         target_index;
@property (nonatomic, retain) NSDictionary      *dict_monitor;

- (CGRect)startFrame;

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame;
- (void)backToStartFrameDisplayFrame:(CGRect)displayRect;
- (void)moveToTargetFrame:(NSInteger)index;
- (void)updateUserInterface:(SizeType)type compass:(BOOL)isCompass;
- (void)changecompass:(BOOL)isCompass;
@end

@protocol MonitorValueViewDelegate <NSObject>

- (void)lockScrollView:(BOOL)lock;
- (void)touchesEnded:(MonitorValueView *)deviceView;
- (void)touchesBegan:(MonitorValueView *)deviceView;
- (void)exchangeSuperView:(MonitorValueView *)deviceView;

@end
