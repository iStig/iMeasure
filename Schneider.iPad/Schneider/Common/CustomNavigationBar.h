//
//  CustomNavigationBar.h
//  SystemExpert
//
//  Created by Ray Zhang  on 11-8-9.
//  Copyright 2011 QIHOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (CustomStyle)

//- (void)applyDefaultStyle;

@end


@interface CustomNavigationBar : UIImageView {
@private
    UINavigationController *navigationController;    
    UIButton *_backButton;
    UILabel *titleLabel;
    UIView* titleView;
    UIImageView *imgvLogo;
}

@property(nonatomic, readwrite) BOOL showBackButtonItem;
@property(nonatomic, assign) UINavigationController *navigationController;

- (void)setShowBackButtonItemAnimated:(BOOL)animated;
- (void)setHideBackButtonItemAnimated:(BOOL)animated;

- (void)setTitle:(NSString *)title;
-(void)setTitleView:(UIView*)view;
//update lable title of _backButton 
- (void)setBackButtonTitle:(NSString *)title;
@end
