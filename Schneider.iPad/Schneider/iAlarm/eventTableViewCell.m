//
//  eventTableViewCell.m
//  Schneider
//
//  Created by GongXuehan on 13-6-12.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "eventTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface eventTableViewCell ()
{
    UIImageView *_vImg_bg;
    UIImageView *_warring_bg;
    NSTimer     *_warning_timer;
    BOOL        _bLuminous;
}
@end

@implementation eventTableViewCell
@synthesize dict_alarm_info =  _dict_alarm_info;

- (void)dealloc
{
    [_vImg_bg release];
    [_warring_bg release];
    [_dict_alarm_info release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _vImg_bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 627, 49)];
        _vImg_bg.image = [UIImage imageNamed:@"alarm_info_list.png"];
        _vImg_bg.userInteractionEnabled = YES;
        [self addSubview:_vImg_bg];
        
        _warring_bg = [[UIImageView alloc] initWithFrame:_vImg_bg.bounds];
        _warring_bg.backgroundColor = [UIColor redColor];
        _warring_bg.layer.cornerRadius = 10.0f;
        _warring_bg.alpha = 0;
        [_vImg_bg addSubview:_warring_bg];
    }
    return self;
}

- (void)creatLabelWithContent:(NSString *)content frame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = colorWithHexString(@"666666");
    label.font = [UIFont systemFontOfSize:18.0f];
    label.text = content;
    [_vImg_bg addSubview:label];
    [label release];
}

- (void)setDict_alarm_info:(NSDictionary *)dict_alarm_info
{
    [_dict_alarm_info release];
    _dict_alarm_info = [dict_alarm_info retain];
    
    for (UIView *sub in [_vImg_bg subviews]) {
        if (sub != _warring_bg) {
            [sub removeFromSuperview];
        }
    }
    
    if ([[dict_alarm_info objectForKey:@"soe_title"] length]) {
        ///soe
//        [self creatLabelWithContent:[_dict_alarm_info objectForKey:@"soe_title"]
//                              frame:CGRectMake(10, 0, self.frame.size.width - 20, 50)];
//        
        UILabel *lbl_desc = [[UILabel alloc] initWithFrame:CGRectZero];
        lbl_desc.backgroundColor = [UIColor clearColor];
        lbl_desc.textColor = colorWithHexString(@"666666");
        lbl_desc.font = [UIFont systemFontOfSize:18.0f];
        lbl_desc.text = [_dict_alarm_info objectForKey:@"soe_title"];
        [lbl_desc sizeToFit];
        
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0,
                                                                              self.frame.size.width - 20, 50)];
        scroll.backgroundColor = [UIColor clearColor];
        
        CGPoint center = lbl_desc.center;
        center.y = scroll.frame.size.height / 2;
        lbl_desc.center = center;
        scroll.contentSize = CGSizeMake(lbl_desc.frame.size.width, scroll.frame.size.height);
        
        [scroll addSubview:lbl_desc];
        [_vImg_bg addSubview:scroll];
        [scroll release];
        [lbl_desc release];
    } else {
        ///event
        [self creatLabelWithContent:[_dict_alarm_info objectForKey:@"event"] frame:CGRectMake(10, 0, 60, 50)];
        ///date
        [self creatLabelWithContent:[_dict_alarm_info objectForKey:@"date"] frame:CGRectMake(90, 0, 100, 50)];
        ///time
        [self creatLabelWithContent:[_dict_alarm_info objectForKey:@"time"] frame:CGRectMake(205, 0, 125, 50)];
        ///descrption
        UILabel *lbl_desc = [[UILabel alloc] initWithFrame:CGRectZero];
        lbl_desc.backgroundColor = [UIColor clearColor];
        lbl_desc.textColor = colorWithHexString(@"666666");
        lbl_desc.font = [UIFont systemFontOfSize:18.0f];
        lbl_desc.text = [dict_alarm_info objectForKey:@"description"];
        [lbl_desc sizeToFit];
        
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(330, 0,
                                                                              self.frame.size.width - 331,
                                                                              50)];
        scroll.backgroundColor = [UIColor clearColor];
        
        CGPoint center = lbl_desc.center;
        center.y = scroll.frame.size.height / 2;
        lbl_desc.center = center;
        scroll.contentSize = CGSizeMake(lbl_desc.frame.size.width, scroll.frame.size.height);
        
        [scroll addSubview:lbl_desc];
        [_vImg_bg addSubview:scroll];
        [scroll release];
        [lbl_desc release];
    }
}

- (void)showWarningAnimation:(BOOL)show
{
    if (show) {
        if (!_warning_timer) {
            _warning_timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self selector:@selector(changeAlpha) userInfo:nil repeats:YES];
        }
    } else {
        if (_warning_timer) {
            [_warning_timer invalidate];
            _warning_timer = nil;
        }
        _warring_bg.alpha = 0;
    }
}

- (void)changeAlpha
{
    CGFloat alpha = _warring_bg.alpha;
    if ((alpha > 0) && _bLuminous)
    {
        alpha -= 0.1;
        if (alpha < 0.1)
        {
            _bLuminous = NO;
        }
    }
    else if ((alpha < 1.0) && !_bLuminous)
    {
        alpha += 0.1;
        if (alpha > 0.8)
        {
            _bLuminous = YES;
        }
    }
    _warring_bg.alpha = alpha;
}

- (BOOL)isWarning
{
    if (_warning_timer) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
