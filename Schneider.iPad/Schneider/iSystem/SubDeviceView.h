//
//  SubDeviceView.h
//  Schneider
//
//  Created by GongXuehan on 13-5-23.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    L_Device_Type = 0,
    R_Device_Type,
    B_Device_Type,
    R_Device_Nsx_Type,
}SubDeviceType;//用于区分设备类型 nsx是新添加的设备index＝5 // l r b 是对应图片箭头方向

@interface SubDeviceView : UIView
{
    NSDictionary    *_sub_device_info;
    CGRect          _rect;
    SubDeviceType   _device_type;
}

@property (nonatomic, retain) NSDictionary *sub_device_info;
@property (nonatomic, assign) CGRect        rect;
@property (nonatomic, assign) SubDeviceType device_type;

- (void)unSelect;
- (void)selectByDeviceInfo:(NSDictionary *)dict;

@end
