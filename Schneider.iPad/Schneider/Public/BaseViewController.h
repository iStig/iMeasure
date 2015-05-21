//
//  BaseViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHud.h"
#import "ATMHudDelegate.h"

@interface BaseViewController : UIViewController <UIGestureRecognizerDelegate, ATMHudDelegate>
{
    UIView *_contentView;
    UIImageView *_navBar;
    ATMHud  *_atm_hud;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIImageView *navBar;
@property (nonatomic, retain) ATMHud *atm_hud;

- (void)loadingView:(NSString *)title;
- (void)progressLoadingView:(NSString *)title index:(int)cur count:(CGFloat)total;
- (void)showLoadingView:(BOOL)show;
- (void)showInforAlert:(NSString *)message;

- (void)setTitleImage:(NSString *)strImage;
- (void)selectFunctionButton:(NSInteger)index;

- (void)xhPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)xhDismissViewControllerAnimated:(BOOL)flag;

- (void)menuButtonClicked:(UIButton *)btn;
- (void)showMenuWithoutAnimation;
- (void)hideLeftMenu;

@end
