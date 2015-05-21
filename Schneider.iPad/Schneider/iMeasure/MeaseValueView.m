//
//  MeaseValueView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-25.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "MeaseValueView.h"
#import "SystemManager.h"

@interface MeaseValueView()
{
    UILabel *_lblTag;
    UILabel *_lblValue;
}

@end
@implementation MeaseValueView
@synthesize value_indexpath = _value_indexpath;

- (void)dealloc
{
    [_value_indexpath release];
    [_lblValue release];
    [_lblTag release];
    [super dealloc];
}

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame
{
    self = [super initWithStartFrame:frame targetFrame:targetFrame];
    if (self) {
        // Initialization code
        _lblTag = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 2)];
        _lblTag.backgroundColor = [UIColor clearColor];
        _lblTag.font = [UIFont systemFontOfSize:20];
        _lblTag.textAlignment = UITextAlignmentCenter;
        [self addSubview:_lblTag];
        
        _lblValue = [[UILabel alloc] initWithFrame:self.bounds];
        _lblValue.backgroundColor = [UIColor clearColor];
        _lblValue.font = [UIFont systemFontOfSize:20];
        _lblValue.textAlignment  = UITextAlignmentCenter;
        [self addSubview:_lblValue];
    }
    return self;
}

- (void)setDevice_information:(NSDictionary *)device_information
{
    [super setDevice_information:device_information];
    
    _lblTag.text = [_device_information objectForKey:kDeviceIdKey];
    
    _lblValue.text = [_device_information objectForKey:kDeviceModelKey];
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
