//
//  IMsasureViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-22.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "IMsasureViewController.h"
#import "MonitorViewController.h"

@interface IMsasureViewController ()
{
    CustomObjectModbus      *_obj;
    NSMutableDictionary     *_mdict_categorys;
}
@end

@implementation IMsasureViewController
- (void)dealloc
{
    [_mdict_categorys release];
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
    [self setTitleImage:@"imeasure_title.png"];
	// Do any additional setup after loading the view.
    _mdict_categorys = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadMonitorViewController:(NSInteger)index
{
    MonitorViewController *monitor = [[MonitorViewController alloc] initWithModbusObject:_obj];
    monitor.int_device_position = index;//0
    [self.navigationController pushViewController:monitor animated:YES];
    [monitor release];
}

#pragma mark - measure info -
#pragma mark - handle method -
- (void)handleTargetFrameClickedEvent:(NSInteger)target_index
{
    _obj = [_marray_modbusObjs objectAtIndex:target_index];
    if (_obj) {
        [self loadMonitorViewController:target_index];
    }
}
@end
