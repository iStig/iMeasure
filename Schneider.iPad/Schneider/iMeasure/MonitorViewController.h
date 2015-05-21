//
//  MonitorViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-4-22.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "SMRotaryWheel.h"
#import "CustomObjectModbus.h"
#import "MonitorValueCell.h"
#import "MonitorManager.h"
#import "MonitorValueView.h"

NSString *const kCurrentsKey;
NSString *const kMaxCurrentsKey;
NSString *const kVoltageKey;
NSString *const kFrequencyKey;
NSString *const kPowerKey;
NSString *const kEnergyKey;
NSString *const kCurrentDemandKey;
NSString *const kPowerDemandKey;
NSString *const kMaxVolgatesKey;
NSString *const kPowerFactorKey;

@interface MonitorViewController : BaseViewController <UIScrollViewDelegate, UITableViewDelegate,
                                        UITableViewDataSource, MonitorManagerDelegate>
{
    CustomObjectModbus      *_obj_modbus;
    NSInteger               _int_device_position;
}

- (id)initWithModbusObject:(CustomObjectModbus *)obj;

@property (nonatomic, retain) CustomObjectModbus    *obj_modbus;
@property (nonatomic, assign) NSInteger             int_device_position;

@end
