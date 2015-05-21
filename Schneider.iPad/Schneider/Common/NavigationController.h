//
//  NavigationController.h
//  ChatClient
//
//  Created by Zhang Liang on 6/15/11.
//  Copyright 2011 QiHoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"


/*
 //sample code to add a new button to navigation bar
 
 //just copy lines below

 //1. find navigationController
 NavigationController *navi = (NavigationController *)self.navigationController;
 
 if([navi rightButton].tag == ButtonTagNew){
 return;
 }
 //2. create a button
 UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 button.tag = ButtonTagNew;
 button.frame = CGRectMake(0.0, 0.0, 32.0, 31.0);
 [button setBackgroundImage:[UIImage imageNamed:@"newchat_button_normal.png"] forState:UIControlStateNormal];
 [button setBackgroundImage:[UIImage imageNamed:@"newchat_button_pressed.png"] forState:UIControlStateHighlighted];
 //3. put it on the right of the navigationbar
 [navi setRightButton:button animated:YES];
 
 */

@class NavigationController;
#define NAV_BAR_HEIGHT 69.0f
#define Nav_Offset     NAV_BAR_HEIGHT - 44

@protocol NavigationControllerDelegate <NSObject>

@optional
- (UIViewController *)willPopViewController:(NavigationController *)navigationController animated:(BOOL)animated;

@end

@interface NavigationController : UINavigationController <NSObject>{
@private
    id<NavigationControllerDelegate> _customNavDelegate;
    CustomNavigationBar *_navBar;
    UIButton *_rightButton;
    UIButton *_leftButton;
}

@property (nonatomic, assign) id<NavigationControllerDelegate> customNavDelegate;
@property (nonatomic, retain) CustomNavigationBar *navBar;
//a button with any origin
- (void)setRightButton:(id)_button animated:(BOOL)animated;
- (void)setLeftButton:(id)_button animated:(BOOL)animated;

- (UIButton *)leftButton;
- (UIButton *)rightButton;

- (CustomNavigationBar *)realNavigationBar;
- (void)setTitle:(NSString *)title;
-(void)setTitleView:(UIView*)view;
//update title of back button
- (void)setBackButtonTitle:(NSString *)title;
- (void)setDefaultLeftSettingButton;
- (void)setDefaultRightSettingButton;
- (void)setLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)setRightButtonTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)setShowBackButtonItemAnimated:(BOOL)animated;
- (void)setHideBackButtonItemAnimated:(BOOL)animated;

@end
