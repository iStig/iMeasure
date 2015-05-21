//
//  ProtectionSelView.h
//  Schneider
//
//  Created by GongXuehan on 13-6-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProtectionSelViewDelegate <NSObject>

- (void)selectedDeviceButtonClicked:(NSArray *)array_sel;

@end

@interface ProtectionSelView : UIView
{
    id<ProtectionSelViewDelegate> _delegate;
}

@property (nonatomic, assign) id<ProtectionSelViewDelegate> delegate;

- (NSArray *)marraySelectedDevices;

@end
