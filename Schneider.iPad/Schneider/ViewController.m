
//
//  ViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ViewController.h"
#import "ISystemViewController.h"
#import "IControlViewController.h"
#import "IAlarmViewController.h"
#import "IMsasureViewController.h"
#import "ICheckViewController.h"
#import "ISettingViewController.h"
#import "LoginViewController.h"

NSInteger const kMainFuntionBaseTag = 10090;

@interface ViewController ()
{
    NSMutableArray *_marray_funtions;
    BOOL            _first;
    BOOL             first_Login;
    NSInteger       _last_funtion_index;
    LoginViewController *loginV;
}
@end

@implementation ViewController


- (void)dealloc
{
    [_marray_funtions release];
  
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkLogin:)
												 name:@"CHECKLOGIN"
											   object:nil];
    first_Login =YES;
    _first = YES;
	// Do any additional setup after loading the view, typically from a nib.
    self.view.frame = CGRectMake(0, 0, 1024, 748);
    [self performSelector:@selector(checkLogin:) withObject:nil afterDelay:0];
}

-(void)checkLogin:(NSNotification*)noti{
    
     [self initFuntionViewControllers];
    
        if (_first) {
            _first = NO;
            [self performSelector:@selector(delayFuntion) withObject:0 afterDelay:0];
        }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (first_Login) {
        first_Login = NO;
         //  [self showLoginView];
    }
    
   
}


-(void)showLoginView{

    loginV = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginV];
 
    [self presentModalViewController:nav animated:NO];
    [nav release];
}

- (void)delayFuntion
{
    _last_funtion_index = 0;
    UINavigationController *nav = [_marray_funtions objectAtIndex:0];
    [self presentModalViewController:nav animated:NO];
}

- (void)initFuntionViewControllers
{
    _marray_funtions = [[NSMutableArray alloc] init];
    ISystemViewController *isystem = [[ISystemViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:isystem];
    [_marray_funtions addObject:nav];
    [isystem release];
    [nav release];
    
    IMsasureViewController *imeasure = [[IMsasureViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:imeasure];
    [_marray_funtions addObject:nav];
    [imeasure release];
    [nav release];
    
    ICheckViewController *iCheck = [[ICheckViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:iCheck];
    [_marray_funtions addObject:nav];
    [iCheck release];
    [nav release];
    
    IControlViewController *iControl = [[IControlViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:iControl];
    [_marray_funtions addObject:nav];
    [iControl release];
    [nav release];
    
    ISettingViewController *iSetting = [[ISettingViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:iSetting];
    [_marray_funtions addObject:nav];
    [iSetting release];
    [nav release];
    
    IAlarmViewController *iAlarm = [[IAlarmViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:iAlarm];
    [_marray_funtions addObject:nav];
    [iAlarm release];
    [nav release];
}






- (void)changeFuntionFrom:(int)oldindex To:(int)index
{
    UINavigationController *nav = [_marray_funtions objectAtIndex:index];
    [self xhPresentModalViewController:nav animated:NO];
    [[[nav viewControllers] objectAtIndex:0] showMenuWithoutAnimation];
    [[[nav viewControllers] objectAtIndex:0] hideLeftMenu];
    
    UINavigationController *oldNav = [_marray_funtions objectAtIndex:index];
    [oldNav popToRootViewControllerAnimated:NO];
    _last_funtion_index = index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
#pragma mark - Autorotate method of ios6.0 -
- (BOOL)shouldAutorotate{
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations
{
    ///FIXME:6.0
    return UIInterfaceOrientationMaskLandscape;
}

- (void)xhPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    if (B_IOS_6_0()) {
        [self presentViewController:modalViewController animated:animated completion:^(void) {}];
    } else {
        [self presentModalViewController:modalViewController animated:animated];
    }
}



@end
