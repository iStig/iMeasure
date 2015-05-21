//
//  ICheckViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-23.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ICheckViewController.h"
#import "CheckInfoViewController.h"

@interface ICheckViewController ()
{
}
@end

@implementation ICheckViewController
- (void)dealloc
{
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
    [self setTitleImage:@"iasset_title.png"];
	// Do any additional setup after loading the view.
    ///left imageview
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)intoCheckInfoViewController
{
    
}

- (void)handleTargetFrameClickedEvent:(NSInteger)target_index
{
    CustomObjectModbus *obj = [_marray_modbusObjs objectAtIndex:target_index];
    if (obj) {
        CheckInfoViewController *checkInfo = [[CheckInfoViewController alloc] initWithModbusObject:obj];
        checkInfo.int_device_position = target_index;
        [self.navigationController pushViewController:checkInfo animated:YES];
        [checkInfo release];
    }
}

@end
