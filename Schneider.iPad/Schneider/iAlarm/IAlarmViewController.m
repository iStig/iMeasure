//
//  IAlarmViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-19.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "IAlarmViewController.h"
#import "AlarmInfoViewController.h"

@interface IAlarmViewController ()
{
}
@end

@implementation IAlarmViewController
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
    [self setTitleImage:@"ievent_title.png"];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTargetFrameClickedEvent:(NSInteger)target_index
{
    ///get alarm recorded list
    CustomObjectModbus *obj = [_marray_modbusObjs objectAtIndex:target_index];
    if (obj) {
        AlarmInfoViewController *alarm = [[AlarmInfoViewController alloc] initWithModbusObject:obj];
        alarm.int_device_position = target_index;
        [self.navigationController pushViewController:alarm animated:YES];
        [alarm release];
    }
}

@end
