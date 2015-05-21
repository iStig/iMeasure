//
//  SubDeviceView.m
//  Schneider
//
//  Created by GongXuehan on 13-5-23.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SubDeviceView.h"
#import "SystemManager.h"

@interface SubDeviceView()
{
    UIImageView *_device_image;
    UILabel     *_device_name;
    
    NSString    *_str_nor_img;
    NSString    *_str_sel_img;
}

@property (nonatomic, retain) NSString *str_nor_img;
@property (nonatomic, retain) NSString *str_sel_img;

@end

@implementation SubDeviceView
@synthesize str_nor_img = _str_nor_img;
@synthesize str_sel_img = _str_sel_img;
@synthesize sub_device_info = _sub_device_info;
@synthesize device_type = _device_type;
@synthesize rect = _rect;

- (void)dealloc
{
    [_str_sel_img release];
    [_str_nor_img release];
    [_sub_device_info release];
    [_device_image release];
    [_device_name release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 150, 180);
        _device_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _device_name.font = [UIFont boldSystemFontOfSize:15.0f];
        _device_name.textColor = colorWithHexString(@"666666");
        _device_name.backgroundColor = [UIColor clearColor];
        _device_name.text = @"Mic 6.0 E";
        _device_name.numberOfLines = 0;
        _device_name.textAlignment = UITextAlignmentCenter;
        _device_name.center = CGPointMake(self.frame.size.width / 2,
                                          self.frame.size.height - _device_name.frame.size.height + 15);
        [self addSubview:_device_name];
        _device_name.hidden = YES;
    }
    return self;
}

- (void)setDevice_type:(SubDeviceType)device_type
{
    if (device_type == R_Device_Type) {
        self.str_nor_img = @"r_device_nor.png";
        self.str_sel_img = @"r_device_sel.png";
    } else if (device_type == B_Device_Type) {
        self.str_nor_img = @"b_device_nor.png";
        self.str_sel_img = @"b_device_sel.png";
    } else if (device_type == L_Device_Type) {
        self.str_nor_img = @"l_device_nor.png";
        self.str_sel_img = @"l_device_sel.png";
    } else if (device_type == R_Device_Nsx_Type) {
        self.str_nor_img = @"r_device_nsx_nor.png";
        self.str_sel_img = @"r_device_nsx_sel.png";
    }
    _device_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.str_nor_img]];
    [self addSubview:_device_image];
    _device_image.center = CGPointMake(self.frame.size.width / 2, _device_image.frame.size.height / 2);
    if (device_type == B_Device_Type) {
        _device_image.center = CGPointMake(self.frame.size.width / 2,
                                           self.frame.size.height - _device_image.frame.size.height / 2);
        _device_name.center = CGPointMake(self.frame.size.width / 2, _device_name.frame.size.height / 2 - 10);
    }
}

- (void)setRect:(CGRect)rect
{
    CGPoint center = CGPointZero;
    center.x = rect.origin.x + rect.size.width / 2;
    center.y = rect.origin.y + rect.size.height / 2;
    self.center = center;
}

- (void)unSelect
{
    _device_name.hidden = YES;
    _device_image.image = [UIImage imageNamed:self.str_nor_img];
}

- (void)selectByDeviceInfo:(NSDictionary *)dict
{
    _device_name.hidden = NO;
    //_device_name.text = [dict objectForKey:kDeviceModelKey];
//    _device_name.text = [NSString stringWithFormat:@"Micrologic %.1f %@ \n Device id: %d",
//                         [[dict objectForKey:kDeviceVersionKey] floatValue],
//                         [dict objectForKey:kDeviceModelKey], [[dict objectForKey:kDeviceIdKey] intValue]];
    
    
    
    _device_name.text = [NSString stringWithFormat:@"%@   id:%d\nMicrologic %.1f %@",
                         [dict objectForKey:kDeviceBreakerNameKey],
                         [[dict objectForKey:kDeviceIdKey] intValue],
                         [[dict objectForKey:kDeviceVersionKey] floatValue],
                         [dict objectForKey:kDeviceModelKey]];

    _device_image.image = [UIImage imageNamed:self.str_sel_img];
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
