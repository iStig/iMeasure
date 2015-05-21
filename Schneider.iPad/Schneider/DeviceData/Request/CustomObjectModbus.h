//
//  CustomObjectModbus.h
//  Schneider
//
//  Created by GongXuehan on 13-4-18.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ObjectiveLibModbus.h"

@interface CustomObjectModbus : ObjectiveLibModbus
{
    NSInteger       _device_id;
    BOOL            _is_connected;
    NSDictionary    *_device_information;
}

@property (nonatomic, assign) NSInteger     device_id;
@property (nonatomic, assign) BOOL          is_connected;
@property (nonatomic, retain) NSDictionary *device_information;

- (id) initWithTCP: (NSString *)ipAddress
              port: (int)port
            device:(int)device
       device_info:(NSDictionary *)info;
@end
