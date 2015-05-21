//
//  MonitorViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-4-22.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "MonitorViewController.h"
#import "MeaseValueView.h"
#import "DeviceManagerView.h"
#import "SystemManager.h"
#import "ModbusAuxiliary.h"

#define wheel_count 10
#define Max_Pf 65535

NSString *const kCurrentsKey = @"Current";
NSString *const kMaxCurrentsKey = @"Maximum current";
NSString *const kVoltageKey = @"Voltage";
NSString *const kFrequencyKey = @"Frequency";
NSString *const kPowerKey = @"Power";
NSString *const kEnergyKey = @"Energy";
NSString *const kCurrentDemandKey = @"Current Demand";
NSString *const kPowerDemandKey = @"Power demand";
NSString *const kMaxVolgatesKey = @"Maximum voltage";
NSString *const kPowerFactorKey = @"Power factor";


#define IS_3W(d) ((d) == 31 ? YES : NO)

enum {
    CreatMonitorValuesType = 0,
    RefreshMonitorValuesType,
    CloseValuesType,
};

@interface MonitorViewController ()
{
    int                 _value_type;
    ///user interface
    NSMutableArray      *_marrayTargetFrame;
    UIScrollView        *_scrollViewValues;
    DeviceManagerView   *_deviceManagerView;
    
    MonitorManager      *_monitor_manager;
    ///所有的subviews
    NSMutableDictionary *_mdict_valueViews;
    ///判断scrollview 是否可以移动
    BOOL                _is_scrollview_touches;
    
    UITableView         *_monitor_value_list;
    int                 _last_sel_category;
    
    ///data
    SystemManager       *_system_manager;
    NSMutableDictionary *_mdict_monitor_values;
    NSDictionary        *_device_information;
    NSString            *_str_model;
    CGFloat             _float_version;
    NSInteger           _int_system_setting;
    NSArray             *_array_value_keys;
    UIButton            *_btn_change_type;
}

@property (nonatomic, retain) NSString *last_category_key;
@property (nonatomic, retain) UIButton *_btn_change_type;
@end

@implementation MonitorViewController
@synthesize obj_modbus = _obj_modbus;
@synthesize int_device_position = _int_device_position;

- (void)dealloc
{
    [_monitor_value_list release];
    [_array_value_keys release];
    [_mdict_monitor_values release];
    [_scrollViewValues release];
    [_marrayTargetFrame release];
    [_monitor_manager release];
    [_btn_change_type release];
    [super dealloc];
}

- (id)initWithModbusObject:(CustomObjectModbus *)obj
{
    self.obj_modbus = obj;
    self = [super init];
    if (self) {
        _system_manager = [SystemManager shareManager];
        _mdict_monitor_values = [[NSMutableDictionary alloc] init];
        _device_information = [[_system_manager deviceInfomationOfDeviceid:_obj_modbus.device_id] objectForKey:kDeviceInfoKey];
        /* "device_infomation" =     {
        "device_breaker_name" = "N/A";
        "device_id" = 17;
        "device_model" = E;
        "device_system_setting_key" = 31;
        "device_version" = "5.0";
        "nor_image" = "isystem_middle.png";
        "sel_image" = "isystem_middle_sel.png";
    }*/
        _str_model = [_device_information objectForKey:kDeviceModelKey];//E
        _int_system_setting = [[_device_information objectForKey:kDeviceSystemTypeSettingKey] intValue];//31
        _float_version = [[_device_information objectForKey:kDeviceVersionKey] floatValue];//5
        
        _last_sel_category = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%d",_value_type);
    
    //change Type Button
    _btn_change_type = [[UIButton alloc] initWithFrame:CGRectMake(880, 7, 48, 48)];
    [_btn_change_type setImage:[UIImage imageNamed:@"数字.png"] forState:UIControlStateNormal];
    [_btn_change_type setImage:[UIImage imageNamed:@"仪表盘.png"] forState:UIControlStateSelected];
    [_btn_change_type addTarget:self action:@selector(changeCompassViewType:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:_btn_change_type];

    
    [self setTitleImage:@"imeasure_title.png"];
	// Do any additional setup after loading the view.
    [self loadMonitorValueList];
    _array_value_keys = [[NSArray alloc] initWithObjects:@"Current",@"Voltage",@"Power", @"Energy",@"Power factor",@"Frequency", nil];
    
    ///Current Voltage Power Energy Power factor Frequency
    [self loadingView:@"Loading..."];
    [self getFirstPartValues];
}
-(void)changeCompassViewType:(UIButton*)sender{

    sender.selected = !sender.selected;
    
   [_monitor_manager changeCompassType:sender.selected];
  

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _value_type = CloseValuesType;
    [_obj_modbus disconnect];
    [_obj_modbus release];
    _obj_modbus = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadMonitorValues) object:nil];
    
    NSMutableArray *marraySel = [_monitor_manager marraySelectedDeviceView];
    NSMutableArray *marrayMeasure = [[NSMutableArray alloc] init];
    for (int i = 0; i < [marraySel count] ;i++) {
        MonitorValueView *value_view = [marraySel objectAtIndex:i];
        if (!value_view.dict_monitor) {
            [marrayMeasure addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],kPositionEmptyKey, nil]];
        } else {
            [marrayMeasure addObject:value_view.dict_monitor];
        }
    }
    SystemManager *system_manager = [SystemManager shareManager];
    NSMutableArray *marray = [[NSMutableArray alloc] initWithArray:[system_manager marrayDevicePositionInfo]];
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:[marray objectAtIndex:_int_device_position]];
    [mdict setObject:marrayMeasure forKey:kMeasurePositionKey];
    [marray replaceObjectAtIndex:_int_device_position withObject:mdict];
    [system_manager setMarrayDevicePositionInfo:marray];
    [mdict release];
    [system_manager save];
    [marrayMeasure release];
    [marray release];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)backButtonClicked:(UIButton *)btn
{
    [self xhDismissViewControllerAnimated:YES];
}

- (void)saveButtonClicked:(UIButton *)btn
{
    NSArray *array = [_deviceManagerView marraySelectedDeviceView];
    [_system_manager saveMeasureValuesStruct:array forDevice:_obj_modbus.device_id];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - monitor value list -
- (void)loadMonitorValueList
{
    UIImageView *imgCategoryBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 26, 258, 629)];
    imgCategoryBg.image = [UIImage imageNamed:@"category_list_bg.png"];
    imgCategoryBg.userInteractionEnabled = YES;
    imgCategoryBg.clipsToBounds = YES;
    [_contentView addSubview:imgCategoryBg];

    _monitor_value_list = [[UITableView alloc] initWithFrame:imgCategoryBg.bounds];
    _monitor_value_list.backgroundColor = [UIColor clearColor];
    _monitor_value_list.delegate = self;
    _monitor_value_list.dataSource = self;
    _monitor_value_list.scrollEnabled = NO;
    [imgCategoryBg addSubview:_monitor_value_list];
    [imgCategoryBg release];
    
    UIImageView *v_line = [[UIImageView alloc] initWithFrame:CGRectMake(286, 26, 1, 628)];
    v_line.image = [UIImage imageNamed:@"vertica_line.png"];
    [_contentView addSubview:v_line];
    [v_line release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    
{
    return [_array_value_keys count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57.0f;
}

#define kMeasureCoverView 98711

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monitor_table_identifier"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"monitor_table_identifier"] autorelease];
        
        UIImageView *accessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory.png"]];
        cell.accessoryView = accessory;
        [accessory release];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!indexPath.row) {
        cell.textLabel.text = [NSString stringWithFormat:@"Micrologic %.1f %@",
                                _float_version,
                               _str_model];
        cell.accessoryView.hidden = YES;
        cell.imageView.hidden = YES;
    } else {
        cell.textLabel.text = [_array_value_keys objectAtIndex:indexPath.row - 1];
        cell.imageView.hidden = NO;
        if (_last_sel_category == indexPath.row) {//_last_sel_category default=1;
            cell.imageView.image = [UIImage imageNamed:@"sel_box.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"nor_box.png"];
        }
        cell.accessoryView.hidden = NO;
    }
    
    if ([[_mdict_monitor_values allKeys] count] && indexPath.row && (_value_type == CreatMonitorValuesType)) {
        NSArray *arrayValues = [_mdict_monitor_values objectForKey:[_array_value_keys objectAtIndex:indexPath.row - 1]];
        ///clean history value views from scroll view
        if (![arrayValues count]) {
            if (![cell viewWithTag:kMeasureCoverView]) {
                cell.imageView.image = [UIImage imageNamed:@"nor_box.png"];
                cell.userInteractionEnabled = NO;

                UIImageView *vImage = [[UIImageView alloc] initWithFrame:cell.bounds];
                vImage.tag = kMeasureCoverView;
                vImage.backgroundColor = [UIColor grayColor];
                vImage.alpha = 0.1;
                [cell addSubview:vImage];
                [vImage release];
            }
        }
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    cell.textLabel.textColor = colorWithHexString(@"666666");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row != _last_sel_category) && indexPath.row) {
        _last_sel_category = indexPath.row;
        NSLog(@"last_sel_category %d",indexPath.row);
        [tableView reloadData];
        
        NSArray *arrayValues = [_mdict_valueViews objectForKey:[_array_value_keys objectAtIndex:indexPath.row - 1]];
        ///clean history value views from scroll view
        if ([arrayValues count]) {
            CGRect startFrame = [(MonitorValueView *)[arrayValues objectAtIndex:0] startFrame];
            [_scrollViewValues setContentOffset:CGPointMake(startFrame.origin.x - 13, 0) animated:YES];
        }         
        [_monitor_manager showSourceScrollView];
    }
}

- (void)loadTargetFrame
{
    _marrayTargetFrame = [[NSMutableArray alloc] init];

    CGRect target_rect = CGRectZero;
    for (int row = 0; row < Max_Row; row ++) {
        int max_colum = row ? 3 : 2;
        for (int colum = 0; colum < max_colum; colum ++) {
            if (!row) {
                target_rect.origin.x = colum * (Mon_space_width + Mon_big_box_size.width);
                target_rect.origin.y = 0;
                target_rect.size = Mon_big_box_size;
            } else {
                target_rect.origin.x = colum * (Mon_space_width + Mon_small_box_size.width);
                target_rect.origin.y = row * Mon_space_height +
                            (row - 1) * Mon_small_box_size.height + Mon_big_box_size.height;
                target_rect.size = Mon_small_box_size;
            }
            [_marrayTargetFrame addObject:[NSValue valueWithCGRect:target_rect]];
        }
    }
}

- (NSString *)unit_NameForCategory:(int)category_index name:(NSString *)str_name{

    NSString *unit = @"UN";
    switch (category_index) {
        case 0:
            unit = @"A";
            break;
        case 1:
            unit = @"V";
            break;
        case 2:
            if ([str_name isEqualToString:@"P1"] ||
                [str_name isEqualToString:@"P2"] ||
                [str_name isEqualToString:@"P3"] ||
                [str_name isEqualToString:@"Ptot"] ||
                [str_name isEqualToString:@"P_Demd"] ||
                [str_name isEqualToString:@"P_Demd_Max"]) {
                unit = @"P";
            } else if ([str_name isEqualToString:@"Q1"] ||
                       [str_name isEqualToString:@"Q2"] ||
                       [str_name isEqualToString:@"Q3"] ||
                       [str_name isEqualToString:@"Qtot"]) {
                unit = @"Q";
            } else if ([str_name isEqualToString:@"S1"] ||
                       [str_name isEqualToString:@"S2"] ||
                       [str_name isEqualToString:@"S3"] ||
                       [str_name isEqualToString:@"Stot"]) {
                unit = @"S";
            }
            break;
        case 3:
        {
            /*
             EP,Epin,Epout: unit	 Kwh
             Eq 			 KVarh
             ES			 KVAh
             */
            if ([str_name isEqualToString:@"Ep"] ||
                [str_name isEqualToString:@"EpIn"] ||
                [str_name isEqualToString:@"EpOut"]) {
                unit = @"E";
            } else if ([str_name isEqualToString:@"Eq"] ||
                       [str_name isEqualToString:@"EqIn"] ||
                       [str_name isEqualToString:@"EqOut"]) {
                unit = @"E";
            } else if ([str_name isEqualToString:@"Es"]) {
                unit = @"E";
            }
        }
            break;
        case 4:
            unit = @"PF";
            break;
        case 5:
            unit = @"";
            break;
        default:
            break;
    }
    return unit;



}



- (NSString *)unitForCategory:(int)category_index name:(NSString *)str_name
{
    NSString *unit = @"UN";
    switch (category_index) {
        case 0:
            unit = @"A";
            break;
        case 1:
            unit = @"V";
            break;
        case 2:
            if ([str_name isEqualToString:@"P1"] ||
                [str_name isEqualToString:@"P2"] ||
                [str_name isEqualToString:@"P3"] ||
                [str_name isEqualToString:@"Ptot"] ||
                [str_name isEqualToString:@"P_Demd"] ||
                [str_name isEqualToString:@"P_Demd_Max"]) {
                unit = @"KW";
            } else if ([str_name isEqualToString:@"Q1"] ||
                       [str_name isEqualToString:@"Q2"] ||
                       [str_name isEqualToString:@"Q3"] ||
                       [str_name isEqualToString:@"Qtot"]) {
                unit = @"KVar";
            } else if ([str_name isEqualToString:@"S1"] ||
                       [str_name isEqualToString:@"S2"] ||
                       [str_name isEqualToString:@"S3"] ||
                       [str_name isEqualToString:@"Stot"]) {
                unit = @"KVA";
            }
            break;
        case 3:
        {
            /*
             EP,Epin,Epout: unit	 Kwh
             Eq 			 KVarh
             ES			 KVAh
             */
            if ([str_name isEqualToString:@"Ep"] ||
                [str_name isEqualToString:@"EpIn"] ||
                [str_name isEqualToString:@"EpOut"]) {
                unit = @"KWh";
            } else if ([str_name isEqualToString:@"Eq"] ||
                       [str_name isEqualToString:@"EqIn"] ||
                       [str_name isEqualToString:@"EqOut"]) {
                unit = @"KVarh";
            } else if ([str_name isEqualToString:@"Es"]) {
                unit = @"KVAh";
            }
        }
            break;
        case 4:
            unit = @"";
            break;
        case 5:
            unit = @"Hz";
            break;
        default:
            break;
    }
    return unit;
}

- (void)loadSubValuesManagerView
{
    ///first load target frame array
    [self loadTargetFrame];

    _mdict_valueViews = [[NSMutableDictionary alloc] init];
    
    _scrollViewValues = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 494, 687, 175)];
    _scrollViewValues.backgroundColor = [UIColor clearColor];
    _scrollViewValues.clipsToBounds = YES;
    _scrollViewValues.showsHorizontalScrollIndicator = NO;
    _scrollViewValues.showsVerticalScrollIndicator = NO;    
    _scrollViewValues.delegate = self;
    
    NSMutableArray *marrayFreeViews = [[NSMutableArray alloc] init];
    NSMutableArray *marraySelectedViews = [[NSMutableArray alloc] init];
    CGRect startFrame = CGRectMake(13, 9, 146, 119);
    for (int i = 0; i < [_array_value_keys count]; i ++) {
        NSArray *arrayValues = [_mdict_monitor_values objectForKey:[_array_value_keys objectAtIndex:i]];
        NSMutableArray *marrayCategoryViews = [[NSMutableArray alloc] init];
        for (int j = 0; j < [arrayValues count]; j ++) {
            ///target frame FIXME:xhg
            MonitorValueView *valueView = [[MonitorValueView alloc] initWithStartFrame:startFrame targetFrame:_marrayTargetFrame];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[arrayValues objectAtIndex:j], kValueKey, [NSString stringWithFormat:@"%@_%d",[_array_value_keys objectAtIndex:i], j], kNameKey,[self unitForCategory:i name:[[[arrayValues objectAtIndex:j] allKeys] lastObject]],kUnitKey,[self unit_NameForCategory:i name:[[[arrayValues objectAtIndex:j] allKeys] lastObject]],kUnitNameKey,nil];
            valueView.dict_monitor = dict;
            [dict release];
            [_scrollViewValues addSubview:valueView];
            [marrayFreeViews addObject:valueView];//所有横scroll的view
            [marrayCategoryViews addObject:valueView];//比如电流i scrollview
            [valueView release];
            startFrame.origin.x += (startFrame.size.width + 13);
        }
        startFrame.origin.x += _scrollViewValues.frame.size.width;
        [_mdict_valueViews setObject:marrayCategoryViews forKey:[_array_value_keys objectAtIndex:i]];//所有类别的views
        [marrayCategoryViews release];
    }
    _scrollViewValues.contentSize = CGSizeMake(startFrame.origin.x, 135);
    
    SystemManager *system_manager = [SystemManager shareManager];
    NSDictionary *dictDevice = [system_manager deviceInfomationOfPosition:_int_device_position];
    NSArray *arrayMeasurePosition = [dictDevice objectForKey:kMeasurePositionKey];
    MonitorValueView *emptyView = [[MonitorValueView alloc] initWithStartFrame:CGRectZero targetFrame:nil];
    for (int i = 0; i < [arrayMeasurePosition count]; i ++) {
        if ([[[arrayMeasurePosition objectAtIndex:i] objectForKey:kPositionEmptyKey] intValue]) {
            [marraySelectedViews addObject:emptyView];
        } else {
            NSArray *arrayKeys = [[[arrayMeasurePosition objectAtIndex:i] objectForKey:kNameKey] componentsSeparatedByString:@"_"];
            MonitorValueView *view = [[_mdict_valueViews objectForKey:[arrayKeys objectAtIndex:0]] objectAtIndex:[[arrayKeys objectAtIndex:1] intValue]];
            [marraySelectedViews addObject:view];
        }
    }
    
    if (![marraySelectedViews count]) {
        for (int i = 0; i < Max_Row * 3 - 1; i ++) {
            [marraySelectedViews addObject:emptyView];
        }
    }
    
    _monitor_manager = [[MonitorManager alloc] initWithFrame:CGRectMake(300 - 12, 4, 720 + 8, 630 + 37) targetFrame:_marrayTargetFrame freeDevices:marrayFreeViews selectedDevices:marraySelectedViews scrollview:_scrollViewValues superView:_contentView delegate:self];
    _monitor_manager.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_monitor_manager];
    [marrayFreeViews release];
    [marraySelectedViews release];
}

#pragma mark - monitor manager delegate -
- (void)sourceValuesViewWillHide//刷新当前界面左视图tableview
{
    _last_sel_category = -1;
    [_monitor_value_list reloadData];
}

#pragma mark - scrollview delegate method -
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _is_scrollview_touches = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_is_scrollview_touches) {
        if (_last_sel_category > -1) {
            NSArray *array = [_mdict_valueViews objectForKey:[_array_value_keys objectAtIndex:_last_sel_category - 1]];
            
            MonitorValueView *firstView = [array objectAtIndex:0];//改
            MonitorValueView *lastView = [array lastObject];
            CGFloat start_x = firstView.startFrame.origin.x - 13;
            CGFloat end_x = lastView.startFrame.origin.x + lastView.startFrame.size.width + 13;
            
            if (end_x - start_x < _scrollViewValues.frame.size.width) {
                end_x = start_x;
            } else  {
                end_x = end_x - _scrollViewValues.frame.size.width;
            }
            
            if (scrollView.contentOffset.x < start_x) {
                scrollView.contentOffset = CGPointMake(start_x, 0);
            } else if (scrollView.contentOffset.x > end_x) {
                scrollView.contentOffset = CGPointMake(end_x, 0);
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _is_scrollview_touches = NO;
}


#pragma mark - monitor values pool -
/*
 common role: 1. H = P
 2.if value is 32768, not display
 */

- (void)getFirstPartValues
{
    
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
        
     
        
        NSArray *array_value = nil;
        NSArray *array_name = nil;
    
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:412],[NSNumber numberWithInt:423],[NSNumber numberWithInt:431], nil];// 412 423 431
        array_name = [NSArray arrayWithObjects:@"V12",@"V23",@"V31",@"V1N",@"V2N",@"V3N", nil];
        [self appendValue:array_value names:array_name forkey:kVoltageKey];
        
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:310],[NSNumber numberWithInt:850],[NSNumber numberWithInt:260], nil];// 310 850 260
        array_name = [NSArray arrayWithObjects:@"I1",@"I2",@"I3",@"IN", nil];
        [self appendValue:array_value names:array_name forkey:kCurrentsKey];
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:65415],[NSNumber numberWithInt:65327],[NSNumber numberWithInt:241], nil];// 65415 65327 241
        array_name = [NSArray arrayWithObjects:@"Ptot",@"Qtot",@"Stot", nil];
        [self appendValue:array_value names:array_name forkey:kPowerKey];
        
         [_mdict_monitor_values setObject:[NSArray  arrayWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0.95] forKey:@"PF1"]] forKey:kPowerFactorKey];
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:723],[NSNumber numberWithInt:740],[NSNumber numberWithInt:730], nil];// 723 740 730
        array_name = [NSArray arrayWithObjects:@"V12_Max",@"V23_Max",@"V31_Max",@"V1N_Max",@"V2N_Max",@"V3N_Max", nil];
        [self appendValue:array_value names:array_name forkey:kVoltageKey];
        
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:6071],[NSNumber numberWithInt:35826],[NSNumber numberWithInt:33092], nil];// 6071 35826 33092
        array_name = [NSArray arrayWithObjects:@"I1_Max",@"I2_Max",@"I3_Max",@"IN_Max", nil];
        [self appendValue:array_value names:array_name forkey:kCurrentsKey];

          array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:74],[NSNumber numberWithInt:99],[NSNumber numberWithInt:137], nil];// 74 99 137
        array_name = [NSArray arrayWithObjects:@"Ep",@"Eq",@"Es", nil];
        [self appendValue:array_value names:array_name forkey:kEnergyKey];
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:310],[NSNumber numberWithInt:850],[NSNumber numberWithInt:260], nil];
        array_name = [NSArray arrayWithObjects:@"I1_Demd",@"I2_Demd",@"I3_Demd",@"IN_Demd", nil];
        [self appendValue:array_value names:array_name forkey:kCurrentsKey];
        
        array_value = [NSArray arrayWithObjects:[NSNumber numberWithInt:65415],[NSNumber numberWithInt:299], nil];
        array_name = [NSArray arrayWithObjects:@"P_Demd",@"P_Demd_Max", nil];
        [self appendValue:array_value names:array_name forkey:kPowerKey];
        
        array_value = nil;
        array_name = [NSArray arrayWithObjects:@"f", nil];
        [self appendValue:array_value names:array_name forkey:kFrequencyKey];
        
        
   
        
        
        
        if (!_value_type) {//刚创建时默认为0
            [self showLoadingView:NO];
            [_monitor_value_list reloadData];
            [self loadSubValuesManagerView];
            NSLog(@"finished get monitor values");
            [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
        } else if (_value_type == RefreshMonitorValuesType) {
            NSLog(@"finished get monitor values");
            for (int i = 0; i < [_array_value_keys count]; i++) {
                NSArray *arrayCategory = [_mdict_monitor_values objectForKey:[_array_value_keys objectAtIndex:i]];
                NSArray *arrayCategoryViews = [_mdict_valueViews objectForKey:[_array_value_keys objectAtIndex:i]];
                
                for (int j = 0; j < [arrayCategory count]; j++) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[arrayCategory objectAtIndex:j], kValueKey, [NSString stringWithFormat:@"%@_%d",[_array_value_keys objectAtIndex:i], j], kNameKey,[self unitForCategory:i name:[[[arrayCategory objectAtIndex:j] allKeys] lastObject]],kUnitKey,[self unit_NameForCategory:i name:[[[arrayCategory objectAtIndex:j] allKeys] lastObject]],kUnitNameKey,nil];
                    [(MonitorValueView *)[arrayCategoryViews objectAtIndex:j] setDict_monitor:dict];
                    [dict release];
                }
            }
            [_monitor_value_list reloadData];
            [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
        }
        
    }
    else{
    //(V I P PF)
    register_str firstPart;
    firstPart.start_address = 999;
    firstPart.register_count = 50;
    
    if (_obj_modbus && (_value_type != CloseValuesType)) {
        [_obj_modbus readRegistersFrom:firstPart.start_address
                                 count:firstPart.register_count
                               success:^(NSArray *array){
                                   NSLog(@"current group successed");
                                   //[self appendData:array forKey:kCurrentsKey];
                                   [self processFirstPartValues:array];
                                   //[self getGroundFaultCurrent];
                               } failure:^(NSError *error){
                                   NSLog(@"current group failed");
                                   [self showLoadingView:NO];
                                    [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
                               }];
    }
        
    }
}

- (void)appendValue:(NSArray *)values names:(NSArray *)names forkey:(NSString *)key
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [values count]; i ++) {
        if ([[values objectAtIndex:i] intValue] != 32768) {
            [marray addObject:[NSDictionary dictionaryWithObject:[values objectAtIndex:i] forKey:[names objectAtIndex:i]]];
        }
    }
    
    [self appendData:marray forKey:key];
    [marray release];
}

- (void)processFirstPartValues:(NSArray *)array
{
    //(V I P PF)
    int range_location = 0;
    int range_length = 0;
    
    NSArray *array_value = nil;
    NSArray *array_name = nil;

    /*
     unit: V
     role: 1.if 3W, netural not display
     */
    range_location = 0; //999
    range_length = IS_3W(_int_system_setting) ? 3 : 6;
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kVoltageKey];
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];// 412 423 431
    array_name = [NSArray arrayWithObjects:@"V12",@"V23",@"V31",@"V1N",@"V2N",@"V3N", nil];
    [self appendValue:array_value names:array_name forkey:kVoltageKey];
    
    /*
        voltage_unbalance_p_to_n
     */
    if (!IS_3W(_int_system_setting)) {
        range_location = 11; ///1010
        range_length = 3;
        
        array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
        array_name = [NSArray arrayWithObjects:@"V1N_Unbal",@"V2N_Unbal",@"V3N_Unbal", nil];
        [self appendValue:array_value names:array_name forkey:kVoltageKey];
    }
    
    /*----------------------------Current------------------------------------------*/
    /*
     unit: A
     role: 1.if 3W, netural not display
     */
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kCurrentsKey];
    range_location = 16;//1015
    range_length = IS_3W(_int_system_setting) ? 3 : 4;
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"I1",@"I2",@"I3",@"IN", nil];
    [self appendValue:array_value names:array_name forkey:kCurrentsKey];
    /*
     unit: A
     role: 1.if version = 6.0, read this value
     2.if version = 7.0, read 1022
     */
    if (_float_version == 6.0) {
        range_location = 21; //1020
        range_length = 1;
    } else if (_float_version == 7.0) {
        range_location = 22; //1021
        range_length = 1;
    } else {
        range_length = 0;
    }
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"Ig", nil];
    [self appendValue:array_value names:array_name forkey:kCurrentsKey];

    
    /*------------------------------power---------------------------------------*/
    /*
     unit: E
     role: 1.if 3W, only display total
     */
    range_location = 34;//1033
    range_length = 12;
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSArray *arrayPower = [array subarrayWithRange:NSMakeRange(range_location, range_length)];
    if (IS_3W(_int_system_setting)) {
        array_name = [NSArray arrayWithObjects:@"Ptot",@"Qtot",@"Stot", nil];
        [marray addObject:[arrayPower objectAtIndex:3]];
        [marray addObject:[arrayPower objectAtIndex:7]];
        [marray addObject:[arrayPower objectAtIndex:11]];
        [self appendValue:marray names:array_name forkey:kPowerKey];
    } else {
        array_name = [NSArray arrayWithObjects:@"P1",@"P2",@"P3",@"Ptot",@"Q1",@"Q2",@"Q3",@"Qtot",@"S1",@"S2",@"S3",@"Stot", nil];
        [marray addObjectsFromArray:arrayPower];
        [self appendValue:marray names:array_name forkey:kPowerKey];
    }
    [marray release];
    
    /*------------------------------power_factor-----------------------------------*/
    /*
     unit:  E
     role:  1.if 3w , only display total
     */
    
    if (IS_3W(_int_system_setting)) {
        range_location = 49; //1048
        range_length = 1;
    } else {
        range_location = 46; //1045
        range_length = 4;
    }
    
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    [self processPowerFactor:array_value key:kPowerFactorKey];
    [self getSecondPartValues];
}

- (void)processPowerFactor:(NSArray *)array key:(NSString *)str_name
{
    NSMutableArray *marray_values = [[NSMutableArray alloc] init];
    NSArray *array_name = [NSArray arrayWithObjects:@"PF1",@"PF2",@"PF3",@"PFtot", nil];
    for (NSNumber *value in array) {
        int int_value = [value intValue];
        if (int_value > 1000) {
            int_value -= Max_Pf;
        }
        [marray_values addObject:[NSString stringWithFormat:@"%.2f",(float)int_value / 1000.0f]];
    }
    [self appendValue:marray_values names:array_name forkey:str_name];
    [marray_values release];
}

- (void)getSecondPartValues
{
    //(Max V A)
    register_str secPart;
    secPart.start_address = 1599;
    secPart.register_count = 25;
    if (_obj_modbus && (_value_type != CloseValuesType)) {
        [_obj_modbus readRegistersFrom:secPart.start_address
                                 count:secPart.register_count
                               success:^(NSArray *array){
                                   NSLog(@"current group successed");
                                   //[self appendData:array forKey:kCurrentsKey];
                                   [self processSecondPartValues:array];
                               } failure:^(NSError *error){
                                   NSLog(@"current group failed");
                                   [self showLoadingView:NO];
                                    [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
                               }];
    }
}

- (void)processSecondPartValues:(NSArray *)array
{
    int range_location = 0;
    int range_length = 0;
    NSArray *array_value = nil;
    NSArray *array_name = nil;
    /*
     unit: V
     role: 1.if 3W, netural not display
     2.register address += 600
     */
    range_location = 0; //1599
    range_length = IS_3W(_int_system_setting) ? 3 : 6;
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kMaxVolgatesKey];
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"V12_Max",@"V23_Max",@"V31_Max",@"V1N_Max",@"V2N_Max",@"V3N_Max", nil];
    [self appendValue:array_value names:array_name forkey:kVoltageKey];

    /*
     unit: A
     role: 1.if 3W, netural not display
     2.register address += 600
     */
    range_location = 16; //1615
    range_length = IS_3W(_int_system_setting) ? 3 : 4;//3
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kMaxCurrentsKey];
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"I1_Max",@"I2_Max",@"I3_Max",@"IN_Max", nil];
    [self appendValue:array_value names:array_name forkey:kCurrentsKey];

    if (_float_version == 6.0) {
        range_location = 21; //1020
        range_length = 1;
    } else if (_float_version == 7.0) {
        range_location = 22; //1021
        range_length = 1;
    } else {
        range_length = 0;
    }

    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"Ig_Max", nil];
    [self appendValue:array_value names:array_name forkey:kCurrentsKey];
    [self getThirdPartValues];
}

- (void)getThirdPartValues
{
    //(Energy)
    register_str third;
    third.start_address = 1999;
    third.register_count = 28;
    
    if (![_str_model isEqualToString:@"A"] && _obj_modbus && (_value_type != CloseValuesType)) {
        [_obj_modbus readRegistersFrom:third.start_address
                                 count:third.register_count
                               success:^(NSArray *array){
                                   NSLog(@"current group successed");
                                   //[self appendData:array forKey:kCurrentsKey];
                                   [self processThirdPartValues:array];
                               } failure:^(NSError *error){
                                   NSLog(@"current group failed");
                                   [self showLoadingView:NO];
                                    [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
                               }];
    } else {
        [self getFourthPartValues];
    }
}


- (NSNumber *)processEnergyValue:(NSArray *)array
{
    long long result = 0;
    if ([array count] == 4) {
        result = [[array objectAtIndex:0] intValue] + [[array objectAtIndex:1] intValue] * 10000
        + [[array objectAtIndex:2] intValue] * pow(10000, 2) + [[array objectAtIndex:3] intValue] * pow(10000, 3);
    }
    return  [NSNumber numberWithLongLong:result];
}

- (void)processThirdPartValues:(NSArray *)array
{
    NSArray *array_name = nil;

    /*
     unit: P
     role:  1.if Model == E, 3 total
     2.if Model == P, display all
     3.A/H not display
     */
    
    NSArray *array_energy = nil;
    if ([_str_model isEqualToString:@"E"]) {
        NSMutableArray *marray = [[NSMutableArray alloc] initWithCapacity:12];
        ///3 total 2000~2004,2005~2008,2024~2028
        NSRange range;
        range.location = 0;
        range.length = 4;
        array_energy = [array subarrayWithRange:range];
        [marray addObject:[self processEnergyValue:[array subarrayWithRange:range]]];
        
        range.location = 4;
        [marray addObject:[self processEnergyValue:[array subarrayWithRange:range]]];
        
        range.location = 24;
        [marray addObject:[self processEnergyValue:[array subarrayWithRange:range]]];
        
        array_name = [NSArray arrayWithObjects:@"Ep",@"Eq",@"Es", nil];
        [self appendValue:marray names:array_name forkey:kEnergyKey];
        //[self appendData:marray forKey:kEnergyKey];
        [marray release];
    } else {
        array_name = [NSArray arrayWithObjects:@"Ep",@"Eq",@"EpIn",@"EpOut",@"EqIn",@"EqOut",@"Es", nil];
        NSMutableArray *marray = [[NSMutableArray alloc] initWithCapacity:12];
        NSRange range;
        range.location = 0;
        range.length = 4;
        
        for (int i = 0; i < [array count]; i += range.length) {
            [marray addObject:[self processEnergyValue:[array subarrayWithRange:range]]];
        }

        [self appendValue:marray names:array_name forkey:kEnergyKey];
        //[self appendData:array forKey:kEnergyKey];
        [marray release];
    }
    [self getFourthPartValues];
}

- (void)getFourthPartValues
{
    //(Demand current , power)
    register_str fourth;
    fourth.start_address = 2199;
    fourth.register_count = 27;
    
    if (_obj_modbus && (_value_type != CloseValuesType)) {
        [_obj_modbus readRegistersFrom:fourth.start_address
                                 count:fourth.register_count
                               success:^(NSArray *array){
                                   NSLog(@"current group successed");
                                   //[self appendData:array forKey:kCurrentsKey];
                                   [self processFourthPartValues:array];
                               } failure:^(NSError *error){
                                   NSLog(@"current group failed");
                                   [self showLoadingView:NO];
                                    [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
                               }];
    }
}

- (void)processFourthPartValues:(NSArray *)array
{
    int range_location = 0;
    int range_length = 0;
    NSArray *array_value = nil;
    NSArray *array_name = nil;
    
    range_location = 0;
    range_length = 4;
    
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"I1_Demd",@"I2_Demd",@"I3_Demd",@"IN_Demd", nil];
    [self appendValue:array_value names:array_name forkey:kCurrentsKey];
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kCurrentDemandKey];
    
    range_location = 24; //2223
    range_length = 2;///    total active_power
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"P_Demd",@"P_Demd_Max", nil];
    [self appendValue:array_value names:array_name forkey:kPowerKey];
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kPowerDemandKey];
    
    [self getFifthPartValues];
}

- (void)getFifthPartValues
{
    //(Demand current , power)
    register_str fourth;
    fourth.start_address = 1053;
    fourth.register_count = 2;
    if (_obj_modbus && (_value_type != CloseValuesType)) {
        [_obj_modbus readRegistersFrom:fourth.start_address
                                 count:fourth.register_count
                               success:^(NSArray *array){
                                   NSLog(@"current group successed");
                                   //[self appendData:array forKey:kCurrentsKey];
                                   [self processFifthPartValues:array];
                               } failure:^(NSError *error){
                                   NSLog(@"current group failed");
                                    [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
                               }];
    }
}

- (void)processFifthPartValues:(NSArray *)array
{
    int range_location = 0;
    int range_length = 1;
    
    NSArray *array_value = nil;
    NSArray *array_name = nil;
    array_value = [NSArray arrayWithArray:[array subarrayWithRange:NSMakeRange(range_location, range_length)]];
    array_name = [NSArray arrayWithObjects:@"f", nil];
    [self appendValue:array_value names:array_name forkey:kFrequencyKey];
    //[self appendData:[array subarrayWithRange:NSMakeRange(range_location, range_length)] forKey:kFrequencyKey];
    
    if (!_value_type) {//刚创建时默认为0
        [self showLoadingView:NO];
        [_monitor_value_list reloadData];
        [self loadSubValuesManagerView];
        NSLog(@"finished get monitor values");
        [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
    } else if (_value_type == RefreshMonitorValuesType) {
        NSLog(@"finished get monitor values");
        for (int i = 0; i < [_array_value_keys count]; i++) {
            NSArray *arrayCategory = [_mdict_monitor_values objectForKey:[_array_value_keys objectAtIndex:i]];
            NSArray *arrayCategoryViews = [_mdict_valueViews objectForKey:[_array_value_keys objectAtIndex:i]];
            
            for (int j = 0; j < [arrayCategory count]; j++) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[arrayCategory objectAtIndex:j], kValueKey, [NSString stringWithFormat:@"%@_%d",[_array_value_keys objectAtIndex:i], j], kNameKey,[self unitForCategory:i name:[[[arrayCategory objectAtIndex:j] allKeys] lastObject]],kUnitKey,[self unit_NameForCategory:i name:[[[arrayCategory objectAtIndex:j] allKeys] lastObject]],kUnitNameKey,nil];
                [(MonitorValueView *)[arrayCategoryViews objectAtIndex:j] setDict_monitor:dict];
                [dict release];
            }
        }
        [_monitor_value_list reloadData];
        [self performSelector:@selector(reloadMonitorValues) withObject:nil afterDelay:2.0f];
    }
}

- (void)reloadMonitorValues {
    _value_type = RefreshMonitorValuesType;
    NSLog(@"start a new request");
    [_mdict_monitor_values removeAllObjects];
    [self getFirstPartValues];
}


#pragma mark -  -
- (void)appendData:(NSArray *)array forKey:(NSString *)key
{
    NSMutableArray *marray = [[NSMutableArray alloc] initWithArray:[_mdict_monitor_values objectForKey:key]];
    [marray addObjectsFromArray:array];
    [_mdict_monitor_values setObject:marray forKey:key];
    [marray release];
}

@end
