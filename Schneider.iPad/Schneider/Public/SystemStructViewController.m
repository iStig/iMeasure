//
//  SystemStructViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-15.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SystemStructViewController.h"

@interface SystemStructViewController ()
{
}

@end

@implementation SystemStructViewController
@synthesize device_information = _device_information;
@synthesize marray_modbusObjs = _marray_modbusObjs;
@synthesize systemManger = _systemManger;
@synthesize vSystemStruct = _vSystemStruct;

- (void)dealloc
{
    [_marray_modbusObjs release];
    [_device_information release];
    [_vSystemStruct release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _systemManger = [SystemManager shareManager];
    }
    return self;
}

- (void)loadSystemStruct
{
    ///1.system struct user interface
    UIImageView *imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 14, 957, 629)];
    imageBg.image = [UIImage imageNamed:@"struct_bg.png"];
    imageBg.userInteractionEnabled = YES;
    [_contentView addSubview:imageBg];
    [imageBg release];
    
    _vSystemStruct = [[SystemStructView alloc] initWithFrame:CGRectMake(82, 27, 0, 0)];
    _vSystemStruct.delegate = self;
    [_contentView addSubview:_vSystemStruct];
    _marray_modbusObjs = [[NSMutableArray alloc] init];
    ///2.device modbus objects
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadSystemStruct];
}

- (void)refreshDeviceStructView
{
    [_vSystemStruct refreshDeviceStructView];
    [_marray_modbusObjs removeAllObjects];
    for (int i = 0; i < [[_systemManger devicePositionInfo] count]; i ++) {
        NSDictionary *deviceInfo = [[[_systemManger devicePositionInfo] objectAtIndex:i] objectForKey:kDeviceInfoKey];
        NSString *strIP = getUIObjectForKey(Device_IP_Key);
        CustomObjectModbus *modbusObj = [[CustomObjectModbus alloc] initWithTCP:strIP port:Device_Port device:[[deviceInfo objectForKey:kDeviceIdKey] intValue] device_info:deviceInfo];
        [_marray_modbusObjs addObject:modbusObj];
        [modbusObj release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDeviceStructView];
}

//- (void)backButtonClicked:(UIButton *)btn
//{
//    [self xhDismissViewControllerAnimated:YES];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTargetFrameClickedEvent:(NSInteger)target_index
{
    
}

#pragma mark - system struct delegate -
- (void)targeFrameIsClicked:(NSInteger)target_index
{
    self.device_information = [_systemManger deviceInfomationOfPosition:target_index];
    [self handleTargetFrameClickedEvent:(NSInteger)target_index];
}
@end
