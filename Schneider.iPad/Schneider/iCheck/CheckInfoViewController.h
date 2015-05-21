//
//  CheckInfoViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-6-4.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomObjectModbus.h"

@interface CheckInfoViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
{
    CustomObjectModbus *_obj_modbus;
    NSInteger          _int_device_position;
}

@property (nonatomic, retain) CustomObjectModbus *obj_modbus;
@property (nonatomic, assign) NSInteger           int_device_position;
@property (nonatomic, retain) UIScrollView       *doc_scroll;

- (id)initWithModbusObject:(CustomObjectModbus *)obj;

@end
