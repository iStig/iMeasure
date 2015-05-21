//
//  BaseViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "SystemManager.h"
#import "Global.h"

NSInteger const kLeftMenuButtonTag = 90001;

@interface BaseViewController ()
{
    NSArray     *_array_menu;
    UIImageView *_left_menu_view;
    UIView      *_cover_view;
    UIImageView *_title_image;
    UIView      *_busyView;
    UIView      *_busy_background;
}
@end

@implementation BaseViewController
@synthesize contentView = _contentView;
@synthesize navBar = _navBar;
@synthesize atm_hud = _atm_hud;

- (void)dealloc
{
    _atm_hud.delegate = nil;
    [_atm_hud release];
    
    [_busy_background release];
    [_busyView release];
    [_title_image release];
    [_cover_view release];
    [_left_menu_view release];
    [_array_menu release];
    [_contentView release];
    [_navBar release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 1024, 748);
    self.navigationController.navigationBarHidden = YES;
    
    [self creatNavigationBar];
    ///table menu view
    [self creatLeftMenu];
    [self creatContentCoverView];
    
    _busyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    _busy_background = [[UIView alloc] initWithFrame:_busyView.bounds];
    _busy_background.backgroundColor = [UIColor grayColor];
    _busy_background.alpha = 0.5;
    [_busyView addSubview:_busy_background];
    
    _atm_hud = [[ATMHud alloc] initWithDelegate:self];
    [_atm_hud setFixedSize:CGSizeMake(300, 200)];
    [_busyView addSubview:_atm_hud.view];
}

- (void)loadingView:(NSString *)title
{
    [_atm_hud setCaption:title];
    [_atm_hud setActivity:YES];
    [self showLoadingView:YES];
}

- (void)progressLoadingView:(NSString *)title index:(int)cur count:(CGFloat)total
{
    CGFloat per = cur / total;
    if (per > 1.0) {
        per = 0.98;
    }
    [_atm_hud setCaption:[NSString stringWithFormat:@"%@... %d/%.0f",title,cur,total]];
    [_atm_hud setProgress:per];
    [_atm_hud update];
}

- (void)userDidTapHud:(ATMHud *)_hud
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showInforAlert:(NSString *)message
{
    [_atm_hud setCaption:message];
    [_atm_hud setProgress:0];
    [_atm_hud update];
    [self showLoadingView:YES];
    [self performSelector:@selector(showLoadingView:) withObject:NO afterDelay:1.5];
}

- (void)showLoadingView:(BOOL)show
{
    if (show)
    {
        [self.view addSubview:_busyView];
        [_atm_hud show];
    }
    else
    {
        if ([_busyView superview])
        {
            [_busyView removeFromSuperview];
        }
    }
}

- (void)creatContentCoverView
{
    _cover_view = [[UIView alloc] initWithFrame:_contentView.bounds];
    _cover_view.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_cover_view];
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    //设置滑动方向，下面以此类推
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_cover_view addGestureRecognizer:recognizer];
    [recognizer release];
    
    UITapGestureRecognizer *tap;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_cover_view addGestureRecognizer:tap];
    [tap release];
    [_cover_view setHidden:YES];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"向左滑动");
        //执行程序
        [self hideLeftMenu];
    }
}

- (void)handleTap:(UIGestureRecognizer *)tap
{
    [self hideLeftMenu];
}

- (void)creatNavigationBar
{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 68, 1024, 748 - 68)];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, -88, 1024, 768)];
    UIImage *bg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                           pathForResource:@"isystem_bg.png" ofType:nil]];
    background.image = bg;
    background.userInteractionEnabled = YES;
    [_contentView addSubview:background];
    [bg release];
    [background release];

    _navBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bg.png"]];
    _navBar.userInteractionEnabled = YES;
    [self.view addSubview:_navBar];
    
    UIImageView *imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_line.png"]];
    imgLine.center = CGPointMake(130, 33);
    [_navBar addSubview:imgLine];
    [imgLine release];
    
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(26, 8, 76, 48)];
    [menuBtn setImage:[UIImage imageNamed:@"nav_menu_btn.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_navBar addSubview:menuBtn];
    [menuBtn release];
}

- (void)setTitleImage:(NSString *)strImage
{
    UIImage *image = [UIImage imageNamed:strImage];
    if (!_title_image) {
        _title_image = [[UIImageView alloc] initWithImage:image];
    }
    [_title_image setImage:image];
    [_title_image sizeToFit];

    CGRect rect = _title_image.frame;
    rect.origin.x = 155;
    rect.origin.y = (_navBar.frame.size.height - _title_image.frame.size.height) / 2;
    _title_image.frame = rect;
    
    [_navBar addSubview:_title_image];
}

- (void)creatLeftMenu
{
    _left_menu_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 131, 747)];
    _left_menu_view.image = [[UIImage imageNamed:@"left_menu_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    _left_menu_view.userInteractionEnabled = YES;
    [self.view addSubview:_left_menu_view];
    [self.view sendSubviewToBack:_left_menu_view];
    
    
    ///menu data
    
    
    if ([getUIObjectForKey(Default_Login) isEqualToString:@"normal"]) {
        _array_menu = [[NSArray alloc] initWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"isystem_menu_nor.png", kNorImageKey,
                        @"isystem_menu_sel.png",kSelImageKey,nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"imeasure_menu_nor.png", kNorImageKey,
                        @"imeasure_menu_sel.png",kSelImageKey,nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"iasset_menu_nor.png", kNorImageKey,
                        @"iasset_menu_sel.png",kSelImageKey,nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"iControl_unable.png", kNorImageKey,
                        @"iControl_unable.png",kSelImageKey,nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"isetting_menu_nor.png", kNorImageKey,
                        @"isetting_menu_sel.png",kSelImageKey,nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"ievent_menu_nor.png", kNorImageKey,
                        @"ievent_menu_sel.png",kSelImageKey,nil], nil];
    }
    else{
    _array_menu = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:@"isystem_menu_nor.png", kNorImageKey,
                    @"isystem_menu_sel.png",kSelImageKey,nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:@"imeasure_menu_nor.png", kNorImageKey,
                    @"imeasure_menu_sel.png",kSelImageKey,nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:@"iasset_menu_nor.png", kNorImageKey,
                    @"iasset_menu_sel.png",kSelImageKey,nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:@"icontrol_menu_nor.png", kNorImageKey,
                    @"icontrol_menu_sel.png",kSelImageKey,nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:@"isetting_menu_nor.png", kNorImageKey,
                    @"isetting_menu_sel.png",kSelImageKey,nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:@"ievent_menu_nor.png", kNorImageKey,
                    @"ievent_menu_sel.png",kSelImageKey,nil], nil];
    }
    
    CGFloat height = 66;
    for (int i = 0; i < [_array_menu count]; i ++) {
        UIImage *image  = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kNorImageKey]];
        UIImage *h_image = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kSelImageKey]];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, height, image.size.width, image.size.height)];
        [btn setImage:image forState:UIControlStateNormal];
        btn.tag = kLeftMenuButtonTag + i;
        [btn setImage:h_image forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(functionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if ([getUIObjectForKey(Default_Login) isEqualToString:@"normal"]) {
            if (i == 3) {
                btn.enabled =  NO;
            }
        }
        [_left_menu_view addSubview:btn];
        height += image.size.height;
        [btn release];
    }
}

- (void)menuButtonClicked:(UIButton *)btn
{
    [_contentView bringSubviewToFront:_cover_view];
    if (!_contentView.frame.origin.x) {
        [self showLeftMenu];
    } else {
        [self hideLeftMenu];
    }
}

- (void)showMenuWithoutAnimation
{
    [_contentView bringSubviewToFront:_cover_view];
    _cover_view.hidden = NO;
     CGRect rect = _contentView.frame;
     rect.origin.x = 131;
     _contentView.frame = rect;
}

- (void)functionButtonClicked:(UIButton *)btn
{
    [self dismissModalViewControllerAnimated:NO];
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate]
      viewController] changeFuntionFrom:0 To:btn.tag - kLeftMenuButtonTag];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)selectFunctionButton:(NSInteger)index
{
    for (int i = 0; i < [_array_menu count]; i ++) {
        UIImage *strimage = nil;
        UIImage *sel_image = nil;
        if (i == index) {
            strimage  = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kSelImageKey]];
            sel_image  = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kNorImageKey]];
        } else {
            strimage  = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kNorImageKey]];
            sel_image  = [UIImage imageNamed:[[_array_menu objectAtIndex:i] objectForKey:kSelImageKey]];
        }
        UIButton *btn = (UIButton *)[_left_menu_view viewWithTag:(i + kLeftMenuButtonTag)];
        [btn setImage:strimage forState:UIControlStateNormal];
        [btn setImage:sel_image forState:UIControlStateHighlighted];
    }
}

- (void)showLeftMenu
{
    _cover_view.hidden = NO;
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         CGRect rect = _contentView.frame;
                         rect.origin.x = 131;
                         _contentView.frame = rect;
                     }];
}

- (void)hideLeftMenu
{
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         CGRect rect = _contentView.frame;
                         rect.origin.x = 0;
                         _contentView.frame = rect;
                     } completion:^(BOOL finished) {
                         _cover_view.hidden = YES;
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_contentView bringSubviewToFront:_cover_view];
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
//- (NSUInteger)supportedInterfaceOrientations
//{
//    ///FIXME:6.0
//    return UIInterfaceOrientationMaskLandscape;
//}

- (void)xhPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    if (B_IOS_6_0()) {
        [self presentViewController:modalViewController animated:animated completion:^(void) {}];
    } else {
        [self presentModalViewController:modalViewController animated:animated];
    }
}

- (void)xhDismissViewControllerAnimated:(BOOL)flag
{
    if (B_IOS_6_0()) {
        [self dismissViewControllerAnimated:flag completion:^(void) {}];
    } else {
        [self dismissModalViewControllerAnimated:flag];
    }
}

@end
