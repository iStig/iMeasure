//
//  MonitorManager.m
//  Schneider
//
//  Created by GongXuehan on 13-5-30.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "MonitorManager.h"

@interface MonitorManager ()
{
    UIScrollView *_source_scroll;
    UIScrollView *_target_scroll;
    UIImageView  *_source_view;
    UIButton     *_cancel_source_scroll_btn;
    
    MonitorValueView *_emptyView;
    
    ///target
    NSMutableArray *_marray_target_frame;
    NSMutableArray *_marray_target_views;
}

@property (nonatomic, retain) NSMutableArray *marray_target_frame;
@end

@implementation MonitorManager
@synthesize marrayFreeDeviceView = _marrayFreeDeviceView;
@synthesize marraySelectedDeviceView = _marraySelectedDeviceView;
@synthesize marray_target_frame = _marray_target_frame;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_emptyView release];
    [_source_view release];
    [_cancel_source_scroll_btn release];
    [_marray_target_views release];
    [_marray_target_frame release];
    [_target_scroll release];
    
    [_marrayFreeDeviceView release];
    [_marraySelectedDeviceView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
        targetFrame:(NSArray *)targetFrame
        freeDevices:(NSMutableArray *)freeDevices
    selectedDevices:(NSMutableArray *)selectedDevices
         scrollview:(UIScrollView *)scrollview
          superView:(UIView *)superView
           delegate:(id<MonitorManagerDelegate>)delegate
{
    self = [super initWithFrame:frame];// 初始化self frame
    if (self) {
        self.clipsToBounds = YES;
        _emptyView = [[MonitorValueView alloc] initWithStartFrame:CGRectZero targetFrame:nil];

        CGRect target_rect = self.bounds;
        target_rect.origin.x += Monitor_Left_Margin;
        target_rect.origin.y += Monitor_Top_Margin;
        target_rect.size.height -= 40;
        _target_scroll = [[UIScrollView alloc] initWithFrame:target_rect];
        _target_scroll.backgroundColor = [UIColor clearColor];
        _target_scroll.clipsToBounds = NO;
        [self addSubview:_target_scroll];
        _source_scroll = scrollview;

        ///source scroll view
        _cancel_source_scroll_btn = [[UIButton alloc] initWithFrame:CGRectMake(605 + 12, scrollview.frame.origin.y - 44, 68, 57)];
        [_cancel_source_scroll_btn setImage:[UIImage imageNamed:@"cancel_value_scroll_btn.png"] forState:UIControlStateNormal];
        [_cancel_source_scroll_btn addTarget:self action:@selector(cancelSourceScrollBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancel_source_scroll_btn];

        CGRect rect = scrollview.frame;
        _source_view = [[UIImageView alloc] initWithFrame:rect];
        _source_view.backgroundColor = [UIColor clearColor];
        _source_view.userInteractionEnabled = YES;
    
        rect.origin = CGPointZero;
        rect.size.height -= 40;
        UIImageView *img_bg = [[UIImageView alloc] initWithFrame:rect];
        img_bg.image = [UIImage imageNamed:@"measure_value_scroll_bg.png"];
        img_bg.alpha = 0.8;
        img_bg.userInteractionEnabled = YES;
        [_source_view addSubview:img_bg];
        [img_bg release];
        
        //_source_view.clipsToBounds = YES;
        rect.size.width -= 4; rect.origin.x = 2; rect.origin.y = 0; rect.size.height += 37;
        _source_scroll.frame = rect;
        [_source_view addSubview:_source_scroll];
        [self addSubview:_source_view];
                
        _marray_target_views = [[NSMutableArray alloc] init];
        _marray_target_frame = [[NSMutableArray alloc] initWithArray:targetFrame];
        [self loadTargetSubviews];

        _marrayFreeDeviceView = [[NSMutableArray alloc] initWithArray:freeDevices];
        for (MonitorValueView *valueView in _marrayFreeDeviceView) {
            valueView.delegate = self;//delegate
        }
        
        self.delegate = delegate;//delegate
        ///selected device
        _marraySelectedDeviceView = [[NSMutableArray alloc] initWithArray:selectedDevices];
        [self initStartStruct];
    }
    return self;
}

- (void)initStartStruct
{
    for (int i = 0; i < [_marraySelectedDeviceView count]; i++) {
        MonitorValueView *valueView = [_marraySelectedDeviceView objectAtIndex:i];
        if (valueView.target_frame) {
            ///target frame is empgy
            ///device is subview of scroll view
            valueView.center = [self relativeCenterFromScrollToManager:valueView.center];
            ///move to target frame
            [valueView moveToTargetFrame:i];
            ///add to manager view
            [_target_scroll addSubview:valueView];
        }
    }
}

- (void)cancelSourceScrollBtnClicked
{
    if (_source_view.frame.origin.y < self.frame.size.height) {
        [self hideSourceScrollView];
    }
}

- (void)hideSourceScrollView
{
    CGRect rect = _source_view.frame;
    rect.origin.y = self.frame.size.height + 44;
    if ([_delegate respondsToSelector:@selector(sourceValuesViewWillHide)]) {
        [_delegate sourceValuesViewWillHide];
    }
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         _source_view.frame = rect;
                         _cancel_source_scroll_btn.frame = CGRectMake(605, self.frame.size.height, 68, 57);
                     }];
}

- (void)showSourceScrollView
{
    CGRect rect = _source_view.frame;
    rect.origin.y = 484;
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         _cancel_source_scroll_btn.frame = CGRectMake(605, 440, 68, 57);
                         _source_view.frame = rect;
                         
                     }];
}

- (void)changeCompassType:(BOOL)isCompassType{
   
    for (MonitorValueView *valueView in _marrayFreeDeviceView) {
        //[valueView updateUserInterface:0 compass:isCompassType];
        [valueView changecompass:isCompassType];
    }
}

- (void)loadTargetSubviews
{
    UIImage *img = [UIImage imageNamed:@"measure_empty_box.png"];
    for (NSValue *value in _marray_target_frame) {
        CGRect rect = [value CGRectValue];
        UIImageView *imgTarget = [[UIImageView alloc] initWithFrame:rect];
        imgTarget.image = img;
        imgTarget.userInteractionEnabled = YES;
        [_target_scroll addSubview:imgTarget];
        [_marray_target_views addObject:imgTarget];
        [imgTarget release];
    }
    
    CGFloat contentHeight = (Max_Row - 1) * Mon_small_box_size.height +
                            Mon_big_box_size.height + Max_Row * Mon_space_height;
    _target_scroll.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
}

#pragma mark - relative center between scroll view and manager view -
- (CGPoint)relativeCenterFromScrollToManager:(CGPoint)point
{
    CGPoint managerCenter = point;
    managerCenter.x = point.x - _source_scroll.contentOffset.x;
    managerCenter.y = point.y + _target_scroll.contentOffset.y  + _source_view.frame.origin.y - 26;
    return managerCenter;
}

- (CGPoint)relativeCenterFromManagerToScroll:(CGPoint)point
{
    CGPoint scrollCenter = point;
    scrollCenter.x = point.x + _source_scroll.contentOffset.x;
    scrollCenter.y = point.y - _target_scroll.contentOffset.y  - _source_view.frame.origin.y;
    return scrollCenter;
}


#pragma mark - Monitor manager delegate method -
- (void)lockScrollView:(BOOL)lock
{
    _target_scroll.scrollEnabled = !lock;
    _source_scroll.scrollEnabled = !lock;
}

- (void)exchangeSuperView:(MonitorValueView *)valueView
{
    [valueView.superview bringSubviewToFront:valueView];
    if ([valueView superview]!= _target_scroll) {
        ///device is subview of scroll view
        valueView.center = [self relativeCenterFromScrollToManager:valueView.center];
        ///add to manager view
        [_target_scroll addSubview:valueView];
    } else {
        CGPoint contentOffset = _target_scroll.contentOffset;
        CGPoint value_center = valueView.center;
        if (valueView.center.y < contentOffset.y && value_center.y > 0) {
            [_target_scroll setContentOffset:CGPointMake(contentOffset.x, value_center.y)];
        } else if ((valueView.center.y > contentOffset.y + _target_scroll.frame.size.height)
                   && (value_center.y < _target_scroll.contentSize.height)) {
            [_target_scroll setContentOffset:CGPointMake(contentOffset.x,
                                                         value_center.y - _target_scroll.frame.size.height)];
        }
    }
}

#pragma mark - manager device view method -
- (void)removeADeviceView:(MonitorValueView *)valueView
{
    if ([_marraySelectedDeviceView containsObject:valueView]) {
        [_marraySelectedDeviceView replaceObjectAtIndex:valueView.target_index withObject:_emptyView];
        valueView.target_index = -1;
    }
}

- (void)addADeviceView:(MonitorValueView *)valueView
{
    if (![_marraySelectedDeviceView containsObject:valueView]) {
        [_marraySelectedDeviceView replaceObjectAtIndex:valueView.target_index withObject:valueView];
    }
}

- (void)exchangeDevice:(MonitorValueView *)valueView1 andDevice:(MonitorValueView *)valueView2
{
    if ([_marraySelectedDeviceView containsObject:valueView1] &&
        [_marraySelectedDeviceView containsObject:valueView2]) {
        [_marraySelectedDeviceView exchangeObjectAtIndex:valueView1.target_index withObjectAtIndex:valueView2.target_index];
    }
}

- (CGRect)displayFrame:(MonitorValueView *)valueView
{
    CGRect startFrame = [valueView startFrame];
    
    if (startFrame.origin.x - _source_scroll.contentOffset.x < 0) {
        startFrame.origin.x = _source_scroll.contentOffset.x - self.frame.size.width;
    } else if (startFrame.origin.x - _source_scroll.contentOffset.x - _source_scroll.frame.size.width > self.frame.size.width) {
        startFrame.origin.x = _source_scroll.contentOffset.x + _source_scroll.frame.size.width;
    }
    return startFrame;
}

- (NSInteger)inTargetFrame:(MonitorValueView *)valueView
{
    CGPoint displayCenter = CGPointZero;
    displayCenter = valueView.center;
    
    NSInteger index = -1;
    for (int i = 0;i < [self.marray_target_frame count];i++) {
        CGRect goodFrame = [[self.marray_target_frame objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(goodFrame, displayCenter))
        {
            index = i;
            break;
        }
    }
    return index;
}

- (void)touchesEnded:(MonitorValueView *)valueView
{
    ///judgment the target_index
    if ([valueView superview] != _target_scroll) {
        return;
    }
    NSInteger target_index = [self inTargetFrame:valueView];
    NSLog(@"target_index %d",target_index);
    if (target_index == -1) {
        ///not sotp at a target frame
        if ([_marraySelectedDeviceView containsObject:valueView]) {
            ///deviceview is subview of managerview
            valueView.center = [self relativeCenterFromManagerToScroll:valueView.center];
            ///add to scroll view
            [_source_scroll addSubview:valueView];
            ///move to start frame
            [valueView backToStartFrameDisplayFrame:[self displayFrame:valueView]];
            ///remove frome selected views
            [self removeADeviceView:valueView];
        } else {
            ///device is subview of scrollview
            valueView.center = [self relativeCenterFromManagerToScroll:valueView.center];
            [_source_scroll addSubview:valueView];
            [valueView backToStartFrameDisplayFrame:[self displayFrame:valueView]];
        }
    } else  {
        ///stop at a target frame
        MonitorValueView *oldValueView = nil;
        if (target_index < [_marraySelectedDeviceView count]) {
            oldValueView = [_marraySelectedDeviceView objectAtIndex:target_index];
        }
        if (!oldValueView.target_frame) {
            ///target frame is empty
            if (![_marraySelectedDeviceView containsObject:oldValueView]) {
                ///device is subview of scroll view
                //deviceView.center = [self relativeCenterFromScrollToManager:deviceView.center];
            } else {
                ///device is already of scroll view
                [self removeADeviceView:valueView];
            }
            ///move to target frame
            [valueView moveToTargetFrame:target_index];
            ///add to manager view
            //[self addSubview:deviceView];
            [self addADeviceView:valueView];
        } else {
            ///taraget frame is not empty
            if (valueView == [_marraySelectedDeviceView objectAtIndex:target_index]) {
                ///the same device view
                [valueView moveToTargetFrame:target_index];
            } else {
                ///not the same device, exchange
                if (valueView.target_index == -1) {
                    ///old view back to start frame
                    [self removeADeviceView:oldValueView];
                    oldValueView.center = [self relativeCenterFromManagerToScroll:oldValueView.center];
                    [_source_scroll addSubview:oldValueView];
                    [oldValueView backToStartFrameDisplayFrame:[self displayFrame:oldValueView]];
                    
                    ///device view exchange old view
                    //deviceView.center = [self relativeCenterFromScrollToManager:deviceView.center];
                    //[self addSubview:deviceView];
                    [valueView moveToTargetFrame:target_index];
                    [self addADeviceView:valueView];
                } else {
                    oldValueView.target_index = valueView.target_index;
                    valueView.target_index = target_index;
                    [self exchangeDevice:oldValueView andDevice:valueView];
                    
                    [valueView moveToTargetFrame:valueView.target_index];
                    [oldValueView moveToTargetFrame:oldValueView.target_index];
                }
            }
        }
    }
}

@end
