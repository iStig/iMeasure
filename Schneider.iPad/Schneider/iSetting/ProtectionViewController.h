//
//  ProtectionViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-4-28.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomObjectModbus.h"

@interface ProtectionViewController : BaseViewController
{
    NSArray *_array_obj_modbus;
}

@property (nonatomic, retain) NSArray *array_obj_modbus;

@end
