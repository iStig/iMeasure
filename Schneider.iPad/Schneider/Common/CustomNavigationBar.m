//
//  CustomNavigationBar.m
//  SystemExpert
//
//  Created by Ray Zhang  on 11-8-9.
//  Copyright 2011 QIHOO. All rights reserved.
//

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "NavigationController.h"

@implementation UINavigationBar (CustomStyle)

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

@end


@implementation CustomNavigationBar
@synthesize navigationController;
@synthesize showBackButtonItem;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.userInteractionEnabled = NO;
		UIImage *bgImage = [UIImage imageNamed:@"nav_bg.png"] ;
		self.image = bgImage;
        
        imgvLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 104, 37)];
        imgvLogo.image = [UIImage imageNamed:@"title_logo.png"];
        [self addSubview:imgvLogo];
        [imgvLogo release];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 42.0)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:148.0/255.0 blue:188.0/255.0 alpha:1];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 1;
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)back:(id)sender{
    if(navigationController){
        [navigationController popViewControllerAnimated:YES];
    }
}

- (void)setShowBackButtonItem:(BOOL)_showBackButtonItem{
    showBackButtonItem = _showBackButtonItem;
    _backButton.alpha = showBackButtonItem?1.0:0.0;
}

- (void)setShowBackButtonItemAnimated:(BOOL)animated{
    if(!animated){
        self.showBackButtonItem = YES;
    }else{
        if(!showBackButtonItem){
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3f];
            _backButton.alpha = 1.0;
            [UIView commitAnimations];
        }
        showBackButtonItem = YES;
    }
}

- (void)setHideBackButtonItemAnimated:(BOOL)animated{
    if(!animated){
        self.showBackButtonItem = NO;
    }else{
        if(showBackButtonItem){
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3f];
            _backButton.alpha = 0.0;
            [UIView commitAnimations];
        }
        showBackButtonItem = NO;
    }
}

-(void)setBackButtonTitle:(NSString *)title{
    [_backButton setTitle:title forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title{
    titleLabel.text = title;
    [self setNeedsLayout];
    
    CGSize textSize = [title sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(180, 42) lineBreakMode:titleLabel.lineBreakMode];
    CGRect labelFrame = CGRectMake (120, (44 - textSize.height) / 2 + 1, textSize.width, textSize.height);
    titleLabel.frame = labelFrame;
//    imgvLogo.frame = CGRectMake((320-textSize.width+24)/2-24, 11, 21, 22);
}

-(void)setTitleView:(UIView*)view
{
    [titleView removeFromSuperview];
    if (view) {
        [self addSubview:view];
    }
    titleView = view;
}

- (void)dealloc {
    [super dealloc];
}
@end
