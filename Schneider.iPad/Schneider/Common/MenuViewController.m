//
//  MenuViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-5-23.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
{
    UITableView *_vTable_menu;
}
@end

@implementation MenuViewController
- (void)dealloc
{
    [_vTable_menu release];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
