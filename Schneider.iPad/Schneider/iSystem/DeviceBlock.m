//
//  DeviceBlock.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DeviceBlock.h"

@interface DeviceBlock ()
{
    UILabel     *_lblDeviceName;
    UIButton    *_removeBtn;
}

@end

@implementation DeviceBlock
@synthesize strDeviceName = _strDeviceName;
@synthesize intDeviceId   = _intDeviceId;
@synthesize deviceDelegate = _deviceDelegate;

- (void)dealloc
{
    [_removeBtn release];
    [_strDeviceName release];
    [_lblDeviceName release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
         startFrame:(CGRect)startFrame
         goodFrames:(NSArray *)goodFrames
          badFrames:(NSArray *)badFrames
        andDelegate:(id<TKDragViewDelegate>)delegate
{
    self = [super initWithImage:image
                     startFrame:startFrame
                     goodFrames:goodFrames
                      badFrames:badFrames
                    andDelegate:delegate];
    if (self) {
        _lblDeviceName = [[UILabel alloc] initWithFrame:self.bounds];
        _lblDeviceName.font = [UIFont systemFontOfSize:18.0f];
        _lblDeviceName.backgroundColor = [UIColor clearColor];
        _lblDeviceName.textAlignment = UITextAlignmentCenter;
        _lblDeviceName.numberOfLines = 0;
        [self addSubview:_lblDeviceName];
        
        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_removeBtn setImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
        [_removeBtn addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_removeBtn];
        _removeBtn.hidden = YES;
    }
    return self;
}

- (void)showEditModel:(BOOL)edit
{
    if (edit) {
        _removeBtn.hidden = NO;
    } else {
        _removeBtn.hidden = YES;
    }
}

- (void)removeButtonClicked:(UIButton *)btn
{
    if ([_deviceDelegate respondsToSelector:@selector(deviceViewRemoveButtonClicked:)]) {
        [_deviceDelegate deviceViewRemoveButtonClicked:self];
    }
}

- (void)setStrDeviceName:(NSString *)strDeviceName
{
    [_strDeviceName release];
    _strDeviceName = [strDeviceName retain];
    
    _lblDeviceName.text = _strDeviceName;
}

- (void)setDictDeviceInfo:(NSDictionary *)dictDeviceInfo
{
    [super setDictDeviceInfo:dictDeviceInfo];
    _lblDeviceName.text = [dictDeviceInfo objectForKey:@"device_name"];
    _intDeviceId = [[dictDeviceInfo objectForKey:@"device_id"] intValue];
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
