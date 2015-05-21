//
//  MeaseValueView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-25.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DeviceView.h"

@interface MeaseValueView : DeviceView
{
    NSIndexPath     *_value_indexpath;
}

@property (nonatomic, retain) NSIndexPath *value_indexpath;

@end
