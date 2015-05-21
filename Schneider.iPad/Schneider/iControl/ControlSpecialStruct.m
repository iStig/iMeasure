//
//  ControlSpecialStruct.m
//  Schneider
//
//  Created by GongXuehan on 13-6-13.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ControlSpecialStruct.h"
#import "SystemManager.h"

@interface ControlSpecialStruct ()
{
    SystemManager *_systemManager;
    NSArray       *_arrayDeviceP;
}

@end

@implementation ControlSpecialStruct
- (void)dealloc
{
    [_arrayDeviceP release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _systemManager = [SystemManager shareManager];
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, 857, 579);
        self.image = [UIImage imageNamed:@"icontrol_struct.png"];
        self.userInteractionEnabled = YES;
        [self loadSystemStructData];
    }
    return self;
}

- (void)loadSystemStructData
{
    _arrayDeviceP = [[NSArray alloc] initWithArray:[_systemManager structRect]];
    [self refreshDeviceStructView];
}

- (void)refreshDeviceStructView
{
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    NSArray *arrayM = [_systemManager devicePositionInfo];
    for (int i = 0; i < [arrayM count]; i ++) {
        NSMutableString *mstring = [[NSMutableString alloc] initWithString:@""];
        
        if (i == 2) {
            [mstring appendString:@"l_device"];
        } else if (i == 1) {
            [mstring appendString:@"b_device"];
        } else if (i == 5){
            [mstring appendString:@"r_device_nsx"];
        } else {
            [mstring appendString:@"r_device"];
        }
        NSDictionary *dict = [arrayM objectAtIndex:i];
        if ([[dict objectForKey:kPositionEmptyKey] boolValue]) {
            [mstring appendString:@"_n.png"];
        } else {
            [mstring appendString:@"_h.png"];
        }
        
        CGRect rect = [[_arrayDeviceP objectAtIndex:i] CGRectValue];
        UIImageView *imgDevice = [[UIImageView alloc] initWithImage:[UIImage imageNamed:mstring]];
        
        CGPoint device_center = CGPointZero;
        device_center.x = rect.origin.x + rect.size.width / 2;
        if (i < 3) {
            if (i == 1) {
                device_center.y  = rect.origin.y + rect.size.height / 2 - 42;
            } else {
                device_center.y = rect.origin.y + rect.size.height / 2 - 50;
            }
        } else {
            device_center.y = rect.origin.y + rect.size.height / 2 - 20;
        }
        imgDevice.center = device_center;
        
        [self addSubview:imgDevice];
        [mstring release];
        [imgDevice release];
        
        UIButton *btnDevice = [[UIButton alloc] initWithFrame:[[_arrayDeviceP objectAtIndex:i] CGRectValue]];
        [btnDevice setBackgroundColor:[UIColor clearColor]];
        [btnDevice setUserInteractionEnabled:![[dict objectForKey:kPositionEmptyKey] boolValue]];
        [self addSubview:btnDevice];
        [btnDevice release];
        
        CGPoint center = CGPointZero;
        center.x = btnDevice.frame.origin.x + btnDevice.frame.size.width / 2;
        if (i < 3) {
            //top
            center.y = btnDevice.frame.origin.y - 24;
        } else {
            //bottom
            center.y = btnDevice.frame.origin.y + btnDevice.frame.size.height + 9;
        }
        
        NSDictionary *dict_info = [dict objectForKey:kDeviceInfoKey];
        if (dict_info) {
            UILabel *lbl_device_info = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 40)];
            lbl_device_info.numberOfLines = 0;
            lbl_device_info.font = [UIFont boldSystemFontOfSize:15.0f];
            lbl_device_info.textColor = colorWithHexString(@"666666");
            lbl_device_info.backgroundColor = [UIColor clearColor];
//            lbl_device_info.text = [NSString stringWithFormat:@"Micrologic %.1f %@ \n Device id: %d",
//                                    [[dict_info objectForKey:kDeviceVersionKey] floatValue],
//                                    [dict_info objectForKey:kDeviceModelKey],
//                                    [[dict_info objectForKey:kDeviceIdKey] intValue]];
            lbl_device_info.text = [NSString stringWithFormat:@"%@   id:%d\nMicrologic %.1f %@",
                                    [dict_info objectForKey:kDeviceBreakerNameKey],
                                    [[dict_info objectForKey:kDeviceIdKey] intValue],
                                    [[dict_info objectForKey:kDeviceVersionKey] floatValue],
                                    [dict_info objectForKey:kDeviceModelKey]];
            lbl_device_info.center = center;
            lbl_device_info.textAlignment = UITextAlignmentCenter;
            [self addSubview:lbl_device_info];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
