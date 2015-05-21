//
//  CustomObjectModbus.m
//  Schneider
//
//  Created by GongXuehan on 13-4-18.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "CustomObjectModbus.h"

@implementation CustomObjectModbus
@synthesize device_id = _device_id;
@synthesize is_connected = _is_connected;
@synthesize device_information = _device_information;

- (void)dealloc
{
    [_device_information release];
    [super dealloc];
}

- (id) initWithTCP: (NSString *)ipAddress
              port: (int)port
            device:(int)device
       device_info:(NSDictionary *)info {
    self = [super initWithTCP:ipAddress port:port device:device];
    
    if (self != nil)
    {
        // your code here
        _device_id = device;
        self.device_information = info;
        return self;
    }
    
    return NULL;
}

@end
