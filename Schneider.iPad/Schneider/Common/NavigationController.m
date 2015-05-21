//
//  NavigationController.m
//  ChatClient
//
//  Created by Zhang Liang on 6/15/11.
//  Copyright 2011 QiHoo. All rights reserved.
//

#import "NavigationController.h"

#define NAV_BAR_FRAME CGRectMake(0.0, 0.0, 1024.0, NAV_BAR_HEIGHT)


@interface NavigationController ()
{
    UIView       *_view;
    SInt32        _viewType;
}

@end

@implementation NavigationController
@synthesize navBar = _navBar;

@synthesize customNavDelegate = _customNavDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self){
    }
    return self;
}

//liubin modify, camera take photo cause memory warning, cause viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 1024, NAV_BAR_HEIGHT);
    _navBar = [[CustomNavigationBar alloc] initWithFrame:NAV_BAR_FRAME];
    _navBar.navigationController = self;
    
    self.navigationBar.userInteractionEnabled = NO;
    self.navigationBar.alpha = 0.0001;
    [self.view addSubview:_navBar];
    _navBar.showBackButtonItem = NO;
    [self setDefaultLeftSettingButton];
    [self setDefaultRightSettingButton];
    _leftButton = nil;
    _rightButton = nil;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    if (navigationBarHidden) {
        _navBar.hidden = YES;
    }
    else 
    {
        _navBar.hidden = NO;
    }
    [super setNavigationBarHidden:navigationBarHidden];
}
    
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma -
#pragma Overrides

- (CustomNavigationBar *)realNavigationBar{
    return _navBar;
}


- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated{
    [super setNavigationBarHidden:hidden animated:animated];
    if(animated){
        CGRect frame = _navBar.frame;
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
        if(hidden){
            frame.origin.y = -frame.size.height;
        }else{
            frame.origin.y = 0;
        }
        _navBar.frame = frame;
        [UIView commitAnimations];
    } else {
        CGRect frame = _navBar.frame;
        if(hidden){
            frame.origin.y = -frame.size.height;
        }else{
            frame.origin.y = 0;
        }
        _navBar.frame = frame;
    }
    [self.view bringSubviewToFront:_navBar];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [_navBar setShowBackButtonItemAnimated:YES];
    [super pushViewController:viewController animated:animated];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    NSArray *vcs = [self viewControllers];
    if([vcs count]==2){
        [_navBar setHideBackButtonItemAnimated:YES];
    }
    UIViewController *controller;
    
    if ([_customNavDelegate respondsToSelector:@selector(willPopViewController:animated:)]) {
        controller = [_customNavDelegate willPopViewController:self animated:animated];
    } else {
        controller = [super popViewControllerAnimated:animated];
    }
    return controller;
}

- (UIButton *)leftButton{
    return _leftButton;
}
- (void)setLeftButton:(id)_button animated:(BOOL)animated{
    if(_leftButton && !_button && animated){
        [UIView beginAnimations:@"1" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.3f];
        _leftButton.alpha = 0.0;
        [UIView commitAnimations];
        return;
    }
    if(_leftButton){
        if(_leftButton == _button){
            return;
        }
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    if(_button){
        _leftButton = _button;
//        CGRect frame = _leftButton.frame;
//        frame.origin.x = 5.0;
//        frame.origin.y = (NAV_BAR_HEIGHT - frame.size.height)/2.0;
//        _leftButton.frame = frame;
        [_navBar addSubview:_leftButton];
        if(animated){
            _leftButton.alpha = 0.0;
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];            
            [UIView setAnimationDuration:0.3f];
            _leftButton.alpha = 1.0;
            [UIView commitAnimations];
        }else{
            
        }
    }
}

- (UIButton *)rightButton{
    return _rightButton;
}

- (void)homeButtonClicked:(UIButton *)btn
{
    [self popToRootViewControllerAnimated:NO];
}

- (void)setDefaultLeftSettingButton 
{
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(890, 6, 60, 33)];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_n.png"] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_p.png"] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(homeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftButton:homeButton animated:NO];
    [[self leftButton] setHidden:NO];
    [homeButton release];
}

- (void)setDefaultRightSettingButton 
{
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 6, 60, 33)];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"back_n.png"] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"back_p.png"] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(homeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightButton:homeButton animated:NO];
    [[self rightButton] setHidden:NO];
    [homeButton release];
}

//a button with any origin
- (void)setRightButton:(id)_button animated:(BOOL)animated{
    if(_rightButton && !_button){
        if (animated) {
            [UIView beginAnimations:@"0" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.3f];
            _rightButton.alpha = 0.0;
            [UIView commitAnimations];
        } else {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
         return;
    }
    if(_rightButton){
        if(_rightButton == _button){
            return;
        }

        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
    if(_button){
        _rightButton = _button;
//        CGRect frame = _rightButton.frame;
//        frame.origin.x = _navBar.frame.size.width - frame.size.width - 5.0;
//        frame.origin.y = (NAV_BAR_HEIGHT - frame.size.height)/2.0;
//        _rightButton.frame = frame;
        [self.navBar addSubview:_button];
        if(animated){
            _rightButton.alpha = 0.0;
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];            
            [UIView setAnimationDuration:0.3f];
            _rightButton.alpha = 1.0;
            [UIView commitAnimations];
        }else{
            
        }
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if([animationID compare:@"1"] == NSOrderedSame){
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }else if([animationID compare:@"0"] == NSOrderedSame){
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
}

#pragma -
-(void)setBackButtonTitle:(NSString *)title{
    [[self realNavigationBar] setBackButtonTitle:title];
}

- (void)setTitle:(NSString *)title{
    [[self realNavigationBar] setTitle:title];
}

-(void)setTitleView:(UIView*)view
{
    [[self realNavigationBar] setTitleView:view];
}

- (void)setLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont systemFontOfSize:13];
    CGSize size = [title sizeWithFont:font];
    CGFloat margin = 8.0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, size.width + margin*2, 30.0);
    UIImage *back = [[UIImage imageNamed:@"nav_button_normal.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setBackgroundImage:back forState:UIControlStateNormal];
    back = [[UIImage imageNamed:@"nav_button_click.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setBackgroundImage:back forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleShadowColor:[UIColor colorWithRed:0.24 green:0.40 blue:0.14 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self setLeftButton:button animated:YES];
}

- (void)setRightButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGSize size = [title sizeWithFont:font];
    CGFloat margin = 8.0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, size.width + margin*2, 30.0);
    UIImage *back = [[UIImage imageNamed:@"nav_button_normal.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setBackgroundImage:back forState:UIControlStateNormal];
    back = [[UIImage imageNamed:@"nav_button_click.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setBackgroundImage:back forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleShadowColor:[UIColor colorWithRed:0.24 green:0.40 blue:0.14 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightButton:button animated:NO];
}

- (void)setShowBackButtonItemAnimated:(BOOL)animated
{
    [_navBar setShowBackButtonItemAnimated:animated];
}
- (void)setHideBackButtonItemAnimated:(BOOL)animated
{
    [_navBar setHideBackButtonItemAnimated:animated];
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - feedback -
@end


#undef NAV_BAR_FRAME