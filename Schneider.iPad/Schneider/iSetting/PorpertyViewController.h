//
//  PorpertyViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-6-7.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomObjectModbus.h"

@interface PorpertyViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

{
    CustomObjectModbus *_obj_modbus;
    NSInteger          _int_device_position;
}

@property (nonatomic, retain) CustomObjectModbus *obj_modbus;
@property (nonatomic, assign) NSInteger           int_device_position;

- (id)initWithModbusObject:(CustomObjectModbus *)obj;

@end
