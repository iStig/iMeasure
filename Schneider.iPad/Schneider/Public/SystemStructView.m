//
//  SystemStructView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SystemStructView.h"
#import "SystemManager.h"

NSInteger const kSystemStructBaseTag = 29878;

@interface SystemStructView ()
{
    SystemManager *_systemManager;
    NSArray       *_arrayDeviceP;
}

@end

@implementation SystemStructView
@synthesize delegate = _delegate;
- (void)dealloc
{
    [_arrayDeviceP release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _systemManager = [SystemManager shareManager];
        // Initialization code
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, 857, 579);
        self.image = [UIImage imageNamed:@"struct_0.png"];
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
        imgDevice.center = CGPointMake(rect.origin.x + rect.size.width / 2,
                                       rect.origin.y + rect.size.height / 2);
        [self addSubview:imgDevice];
        [mstring release];
        [imgDevice release];
        
        UIButton *btnDevice = [[UIButton alloc] initWithFrame:[[_arrayDeviceP objectAtIndex:i] CGRectValue]];
        [btnDevice setBackgroundColor:[UIColor clearColor]];
        btnDevice.tag = kSystemStructBaseTag + i;
        [btnDevice addTarget:self action:@selector(deviceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnDevice setUserInteractionEnabled:![[dict objectForKey:kPositionEmptyKey] boolValue]];
        [self addSubview:btnDevice];
        [btnDevice release];
        
        CGPoint center = CGPointZero;
        center.x = btnDevice.frame.origin.x + btnDevice.frame.size.width / 2;
        if (i < 3) {
            //top
            center.y = btnDevice.frame.origin.y + 10;
        } else {
            //bottom
            center.y = btnDevice.frame.origin.y + btnDevice.frame.size.height - 15;
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
//            
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

- (void)deviceButtonClicked:(UIButton *)btn
{
    int index = btn.tag - kSystemStructBaseTag;
    if ([_delegate respondsToSelector:@selector(targeFrameIsClicked:)]) {
        [_delegate targeFrameIsClicked:index];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{`
    // Drawing code
}
*/

@end
