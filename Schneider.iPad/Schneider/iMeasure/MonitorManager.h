//
//  MonitorManager.h
//  Schneider
//
//  Created by GongXuehan on 13-5-30.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonitorValueView.h"

@protocol MonitorManagerDelegate <NSObject>

- (void)sourceValuesViewWillHide;

@end

@interface MonitorManager : UIView <MonitorValueViewDelegate>
{
    NSMutableArray                  *_marrayFreeDeviceView;
    NSMutableArray                  *_marraySelectedDeviceView;
    id<MonitorManagerDelegate>      _delegate;
}

@property (nonatomic, retain) NSMutableArray *marrayFreeDeviceView;
@property (nonatomic, retain) NSMutableArray *marraySelectedDeviceView;
@property (nonatomic, assign) id<MonitorManagerDelegate> delegate;


- (id)initWithFrame:(CGRect)frame
        targetFrame:(NSArray *)targetFrame
        freeDevices:(NSMutableArray *)freeDevices
    selectedDevices:(NSMutableArray *)selectedDevices
         scrollview:(UIScrollView *)scrollview
          superView:(UIView *)superView
           delegate:(id<MonitorManagerDelegate>)delegate;

- (void)showSourceScrollView;
- (void)changeCompassType:(BOOL)isCompassType;

@end
