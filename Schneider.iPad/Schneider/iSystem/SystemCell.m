//
//  SystemCell.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SystemCell.h"
#import "SystemManager.h"

@interface SystemCell ()
{
}
@end
@implementation SystemCell
@synthesize delegate = _delegate;
@synthesize isSelected = _isSelected;
@synthesize device_id = _device_id;
@synthesize device_information = _device_information;

- (void)dealloc
{
    [_device_information release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setDevice_information:(NSDictionary *)device_information
{
    [_device_information release];
    _device_information = [device_information retain];
    
    self.device_id = [[device_information objectForKey:kDeviceIdKey] intValue];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.accessoryView.hidden = _isSelected ? NO : YES;
}

#pragma mark - touches method -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    if ([_delegate respondsToSelector:@selector(systemCellTouchesBegan:atPoint:)]) {
        [_delegate systemCellTouchesBegan:self atPoint:point];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_isSelected) {return;}
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    if ([_delegate respondsToSelector:@selector(systemCellTouchesMoved:toPoint:)]) {
        [_delegate systemCellTouchesMoved:self toPoint:point];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (!_isSelected) {return;}
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    if ([_delegate respondsToSelector:@selector(systemCellTouchesEnded:atPoint:)]) {
        [_delegate systemCellTouchesEnded:self atPoint:point];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    if ([_delegate respondsToSelector:@selector(systemCellTouchesEnded:)]) {
        [_delegate systemCellTouchesEnded:self atPoint:point];
    }
}

@end
