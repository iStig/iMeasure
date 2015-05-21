//
//  SystemStructViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-4-15.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "SystemStructView.h"
#import "SystemManager.h"
#import "CustomObjectModbus.h"
#import "ModbusAuxiliary.h"

@interface SystemStructViewController : BaseViewController <SystemStructViewDelegate>
{
    SystemManager       *_systemManger;
    NSDictionary        *_device_information;
    NSMutableArray      *_marray_modbusObjs;
    SystemStructView    *_vSystemStruct;
}

@property (nonatomic, retain) NSDictionary      *device_information;
@property (nonatomic, retain) NSMutableArray    *marray_modbusObjs;
@property (nonatomic, retain) SystemManager     *systemManger;
@property (nonatomic, retain) SystemStructView  *vSystemStruct;

/*
    different handle of different module
 */
- (void)handleTargetFrameClickedEvent:(NSInteger)target_index;
- (void)refreshDeviceStructView;

@end
