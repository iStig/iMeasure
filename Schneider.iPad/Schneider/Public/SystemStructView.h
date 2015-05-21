//
//  SystemStructView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SystemStructViewDelegate <NSObject>

- (void)targeFrameIsClicked:(NSInteger)target_index;

@end

@interface SystemStructView : UIImageView
{
    id<SystemStructViewDelegate> _delegate;
}

@property (nonatomic, assign) id<SystemStructViewDelegate> delegate;

- (void)refreshDeviceStructView;

@end
