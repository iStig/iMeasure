//
//  eventTableViewCell.h
//  Schneider
//
//  Created by GongXuehan on 13-6-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface eventTableViewCell : UITableViewCell
{
    NSDictionary *_dict_alarm_info;
}

@property (nonatomic, retain) NSDictionary *dict_alarm_info;
- (void)showWarningAnimation:(BOOL)show;
- (BOOL)isWarning;
@end
