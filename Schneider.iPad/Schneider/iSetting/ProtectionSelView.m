//
//  ProtectionSelView.m
//  Schneider
//
//  Created by GongXuehan on 13-6-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ProtectionSelView.h"
#import "SystemManager.h"

#define Select_Btn_Sub_Tag 87771
#define Select_Btn_Tag 88771

@interface ProtectionSelView  ()
{
    NSMutableArray *_marray_btns;
    NSMutableArray *_marray_sel_btns;
    SystemManager  *_system_manager;
}
@end

@implementation ProtectionSelView
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_marray_btns release];
    [_marray_sel_btns release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _system_manager = [SystemManager shareManager];
        // Initialization code
        UIView *v_cover = [[UIView alloc] initWithFrame:self.bounds];
        v_cover.backgroundColor = [UIColor grayColor];
        v_cover.alpha = 0.5;
        [self addSubview:v_cover];
        
        [self creatSelectButton];
    }
    return self;
}

- (NSArray *)marraySelectedDevices
{
    return _marray_sel_btns;
}

- (void)creatSelectButton
{
    _marray_btns = [[NSMutableArray alloc] init];
    _marray_sel_btns = [[NSMutableArray alloc] init];
    
    CGRect rect1 = CGRectMake(0 + 82, 63 + 27, 248, 260);
    CGRect rect2 = CGRectMake(250 + 82, 63 + 27, 315, 260);
    CGRect rect3 = CGRectMake(570 + 82, 63 + 27, 275, 260);
    CGRect rect4 = CGRectMake(0 + 82, 330 + 27, 220, 260);
    CGRect rect5 = CGRectMake(225 + 82, 330 + 27, 310, 260);
    CGRect rect6 = CGRectMake(540 + 82, 330 + 27, 295, 260);
    
    NSArray *btn_rect = [[NSArray alloc] initWithObjects:[NSValue valueWithCGRect:rect1],[NSValue valueWithCGRect:rect2],
                     [NSValue valueWithCGRect:rect3],[NSValue valueWithCGRect:rect4],[NSValue valueWithCGRect:rect5],
                     [NSValue valueWithCGRect:rect6],nil];
    
    
    NSArray *arrayP = [_system_manager devicePositionInfo];
    for (int i = 0; i < [btn_rect count]; i ++) {
        CGRect rect = [[btn_rect objectAtIndex:i] CGRectValue];
        UIButton *btn = [[UIButton alloc] initWithFrame:rect];
        [btn addTarget:self action:@selector(protectionSelectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor clearColor]];
        [self addSubview:btn];
        btn.tag = Select_Btn_Tag + i;
        
        rect.origin.x = rect.size.width - 27 * 2;
        rect.origin.y = rect.size.height - 27 * 2;
        rect.size.width = 27;
        rect.size.height = 27;
        
        UIImageView *imgSel = [[UIImageView alloc] initWithFrame:rect];
        imgSel.image = [UIImage imageNamed:@"protection_nor.png"];
        imgSel.tag = Select_Btn_Sub_Tag;
        [btn addSubview:imgSel];
        [imgSel release];
        
        [_marray_btns addObject:btn];
        
        NSDictionary *dictDevice = [arrayP objectAtIndex:i];
        if ([[dictDevice objectForKey:kPositionEmptyKey] boolValue]) {
            btn.userInteractionEnabled = NO;
        }

        [_marray_sel_btns addObject:[NSNumber numberWithInt:0]];
        [btn release];
    }
}

- (void)protectionSelectButtonClicked:(UIButton *)btn
{
    int index = btn.tag - Select_Btn_Tag;
    int is_selected = [[_marray_sel_btns objectAtIndex:index] intValue];
    UIImageView *imgSel = (UIImageView *)[btn viewWithTag:Select_Btn_Sub_Tag];
    if (is_selected) {
        [_marray_sel_btns replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:0]];
        imgSel.image = [UIImage imageNamed:@"protection_nor.png"];
    } else {
        int select_count = 0;
        for (NSNumber *num in _marray_sel_btns) {
            if ([num intValue]) {
                select_count ++;
            }
        }
        if (select_count > 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Too many devices" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        } else {
            [_marray_sel_btns replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:1]];
            imgSel.image = [UIImage imageNamed:@"protection_sel.png"];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(selectedDeviceButtonClicked:)]) {
        [_delegate selectedDeviceButtonClicked:_marray_sel_btns];
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
