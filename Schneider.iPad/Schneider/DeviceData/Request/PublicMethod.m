//
//  PublicMethod.m
//  QBAutoInsurance
//
//  Created by GongXuehan on 12-12-24.
//  Copyright (c) 2012年 xhgong. All rights reserved.
//

#import "PublicMethod.h"


@interface PublicMethod ()
{
}

@end

@implementation PublicMethod

static PublicMethod *sharedInstance = nil;

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////
+ (PublicMethod *) sharedPublicMethod{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
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
    }
    return self;
}

@end
