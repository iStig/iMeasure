//
//  CommunicationManager.m
//  Schneider
//
//  Created by GongXuehan on 13-4-18.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "CommunicationManager.h"
#import "CustomObjectModbus.h"

#define Device_IP       @"192.168.0.2"
#define Device_Port     502
#define Device_Count    47

@interface CommunicationManager ()
{
    NSMutableArray     *_marrayDeviceObjects;
}

@property (nonatomic, retain) NSMutableArray *marrayDeviceObjects;

@end

static CommunicationManager *commManager = nil;

@implementation CommunicationManager
@synthesize marrayDeviceObjects = _marrayDeviceObjects;
@synthesize connect_delegate = _connect_delegate;
/////////////////////////////////////////

/*
    init device objects,an object for each device,distinguish by device id
 */
- (void)initDeviceObjects
{
    _marrayDeviceObjects = [[NSMutableArray alloc] initWithCapacity:Device_Count];
    for (int i = 1; i < Device_Count + 1; i ++) {
        CustomObjectModbus *objModbus = [[CustomObjectModbus alloc] initWithTCP:Device_IP port:Device_Port device:i];
        [_marrayDeviceObjects addObject:objModbus];
        [self deviceIsOpened:objModbus];
        [objModbus release];
    }
}

/*
   Judging whether the device is opened
 */
- (void)deviceIsOpened:(CustomObjectModbus *)deviceObj
{
    if (deviceObj) {
        [deviceObj connect:^{
            NSLog(@"device_%d is opend",deviceObj.device_id);
            deviceObj.is_connected = YES;
//            if ([_connect_delegate respondsToSelector:@selector(device:isConnected:)]) {
//                [_connect_delegate device:deviceObj.device_id isConnected:YES];
//            }
        } failure:^(NSError *error) {
            NSLog(@"device_%d is not opend",deviceObj.device_id);
            deviceObj.is_connected = NO;
//            if ([_connect_delegate respondsToSelector:@selector(device:isConnected:)]) {
//                [_connect_delegate device:deviceObj.device_id isConnected:NO];
//            }
        }];
    } else {
        NSAssert(!deviceObj, @"device object is empty!");
    }
}

//////////////////////////////////////////
- (void)dealloc
{
    [_marrayDeviceObjects release];
    [super dealloc];
}

+ (CommunicationManager *) commManager{
    @synchronized(self) {
        if (commManager == nil) {
            [[self alloc] init];
        }
    }
    return commManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(commManager == nil) {
            commManager = [super allocWithZone:zone];
            return commManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        //[self initDeviceObjects];
    }
    return self;
}

@end
