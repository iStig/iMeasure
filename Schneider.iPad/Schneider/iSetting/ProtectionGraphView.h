//
//  ProtectionGraphView.h
//  Schneider
//
//  Created by GongXuehan on 13-4-28.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const kIrKey;
NSString *const kTrKey;
NSString *const kIsdKey;
NSString *const kTsdKey;
NSString *const kIiKey;
NSString *const kInKey;

@interface ProtectionGraphView : UIView

- (id)initWithFrame:(CGRect)frame values:(NSDictionary *)values version:(CGFloat)version;

@end
