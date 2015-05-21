//
//  SwitchView.h
//  Schneider
//
//  Created by GongXuehan on 13-6-13.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchViewDelegate <NSObject>

- (void)device:(int)index switchIsChanged:(BOOL)close;

@end

@interface SwitchView : UIView
{
    NSMutableArray          *_marray_switch_state;
    id<SwitchViewDelegate>  _delegate;
}

@property (nonatomic, assign) id<SwitchViewDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *marray_switch_state;

- (void)animation:(int)index close:(BOOL)is_close;

@end
