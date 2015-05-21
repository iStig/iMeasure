//
//  PorpertyViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-6-7.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "PorpertyViewController.h"
#import "SystemManager.h"

NSString *kProSystemTypeSettingKey = @"System type setting:";
NSString *kPowerSignKey = @"Power Sign:";
NSString *kCurrentDemandCalculationMethodKey = @"Current demand caculation method:";
NSString *kCurrentDemandWindowSizeKey = @"Current demand window size:";
NSString *kPowerDemandMethodKey = @"Power demand method:";
NSString *kPowerDemandSizeKey = @"Power demand size:";
NSString *kM2CKey = @"M2C:";
NSString *kM2CRelayKey = @"realy";
NSString *kM2CEventKey = @"event";
NSString *kM2CModeKey = @"mode";

@interface PorpertyViewController ()
{
    SystemManager *_system_manager;
    UIImageView   *_vImg_property;
    
    NSInteger     _selected_index;
    NSArray       *_value_keys;
    UITableView   *_table_view;
    NSMutableDictionary *_mdict_operation_values;
    NSMutableDictionary *_mdict_current_values;
    
    NSDictionary *_dict_source_values;
    NSArray      *_array_modify_values;
    int           _write_index;
}

@property (nonatomic, retain) NSArray *array_modify_values;

@end

@implementation PorpertyViewController
@synthesize obj_modbus = _obj_modbus;
@synthesize int_device_position = _int_device_position;
@synthesize array_modify_values = _array_modify_values;

- (void)dealloc
{
    [_array_modify_values release];
    [_dict_source_values release];
    [_mdict_current_values release];
    [_mdict_operation_values release];
    [_value_keys release];
    [_vImg_property release];
    [_obj_modbus release];
    [super dealloc];
}

- (id)initWithModbusObject:(CustomObjectModbus *)obj
{
    self = [super init];
    if (self) {
        _system_manager = [SystemManager shareManager];
        self.obj_modbus = obj;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectFunctionButton:4];//左侧导航栏选中当前isetting
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleImage:@"isetting_title.png"];
	// Do any additional setup after loading the view.
    ///property background
    _vImg_property = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"property_setting_bg.png"]];
    _vImg_property.center = CGPointMake(_contentView.frame.size.width / 2, _contentView.frame.size.height / 2);
    [_vImg_property setUserInteractionEnabled:YES];
    [_contentView addSubview:_vImg_property];
    
    _selected_index = -1;
    ///Product name
    [self getCurrentProductSettingData];
    [self loadValuesData];
    [self creatDeviceNameCell];
}

- (void)initUserInterface
{
    [self creatSystemTypeSetting];
    [self creatPowerSign];
    [self creatCurrentDemandCaculationMethod];
    [self creatCurrentDemandWindowSize];
    [self creatPowerDemandMethod];
    [self creatPowerDemandSize];
    [self creatM2C];
}

- (void)loadValuesData {
    _value_keys = [[NSArray alloc] initWithObjects:kProSystemTypeSettingKey,kPowerSignKey,kCurrentDemandCalculationMethodKey,
                   kCurrentDemandWindowSizeKey,kPowerDemandMethodKey,kPowerDemandSizeKey,kM2CRelayKey,kM2CEventKey,kM2CModeKey,nil];
    _mdict_operation_values = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *array_times = [[NSMutableArray alloc] init];
    for (int i = 5; i < 61; i ++) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:i],
                              [NSString stringWithFormat:@"%d",i],nil];
        [array_times addObject:dict];
        [dict release];
    }
    ///system type
    NSArray *arrayValues = [[NSArray alloc] initWithObjects:
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:@"4Wires 4Cts not connected VN"],
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:31] forKey:@"3Wires 3Cts not connected VN"],
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:40] forKey:@"4Wires 3Cts connected VN"],
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:41] forKey:@"4Wires 4Cts connected VN"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kProSystemTypeSettingKey];
    [arrayValues release];

    ///Power Sign
    arrayValues = [[NSArray alloc] initWithObjects:
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Topfed"],
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"Bottomfed"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kPowerSignKey];
    [arrayValues release];
    
    ///Current demand caculation method
    arrayValues = [[NSArray alloc] initWithObjects:
                          [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Block interval; sliding"],
                          [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"Thermal; sliding"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kCurrentDemandCalculationMethodKey];
    [arrayValues release];

    ///current demand window size
    [_mdict_operation_values setValue:array_times forKey:kCurrentDemandWindowSizeKey];

    ///Power demand method
    arrayValues = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Block interval; sliding"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"Thermal; sliding"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"block interval; block"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"Synchronised to communication"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kPowerDemandMethodKey];
    [arrayValues release];

    ///Power demand size
    [_mdict_operation_values setValue:array_times forKey:kPowerDemandSizeKey];
    
    ///M2C relay
    arrayValues = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Realy 1"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"Realy 2"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kM2CRelayKey];
    [arrayValues release];
    
    ///M2C event
    arrayValues = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1000] forKey:@"Ir"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1001] forKey:@"Isd"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1002] forKey:@"Ii"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1003] forKey:@"Ig"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1004] forKey:@"IDelta n"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1005] forKey:@"I>>"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kM2CEventKey];
    [arrayValues release];
    
    ///M2C mode
    arrayValues = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"non-latchrng-mode"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"latching"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"force-one"],
                   [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"force-zero"],nil];
    [_mdict_operation_values setValue:arrayValues forKey:kM2CModeKey];
    [arrayValues release];

    [array_times release];
}

#pragma mark - property value method -
#define Property_Cell_Width  964
#define Property_Device_Cell_Height 66
#define Property_Cell_Heght 76
#define Property_Title_Left_Margin 29
#define Value_Btn_Tag 98900
#define Value_Bg_Tag 99800

#define Property_Font_Color  colorWithHexString(@"999999");
#pragma mark - Device name & save button -
- (void)creatDeviceNameCell
{
    UIView *__device_name_cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Property_Cell_Width, Property_Device_Cell_Height)];
    __device_name_cell.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__device_name_cell];
    
    ///device_name
    NSDictionary *dict = [[_system_manager deviceInfomationOfPosition:_int_device_position] objectForKey:kDeviceInfoKey];
    NSString *str_device_name = [NSString stringWithFormat:@"Micrologic %.1f %@",
                                [[dict objectForKey:kDeviceVersionKey] floatValue],
                                [dict objectForKey:kDeviceModelKey]];
    UILabel *lbl_device_name = [[UILabel alloc] initWithFrame:CGRectMake(Property_Title_Left_Margin,
                                                                         0, 300, Property_Device_Cell_Height)];
    lbl_device_name.backgroundColor = [UIColor clearColor];
    lbl_device_name.textColor = Property_Font_Color;
    lbl_device_name.font = [UIFont boldSystemFontOfSize:24.0f];
    lbl_device_name.text = str_device_name;
    [__device_name_cell addSubview:lbl_device_name];
    [lbl_device_name release];
    
    ///save button
    UIButton *btn_save = [[UIButton alloc] initWithFrame:CGRectMake(841, 12, 95, 43)];
    [btn_save setImage:[UIImage imageNamed:@"property_save_btn.png"] forState:UIControlStateNormal];
    [btn_save addTarget:self action:@selector(savePropertyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [__device_name_cell addSubview:btn_save];
    [btn_save release];
    
    [__device_name_cell release];
}

- (void)savePropertyButtonClicked:(UIButton *)btn
{
    [self setValueToDevice];
}

#pragma mark -- 
- (void)titleLabelOnView:(UIView *)superView title:(NSString *)content index:(int)index
{
    UILabel *lbl_title = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl_title.backgroundColor = [UIColor clearColor];
    lbl_title.textColor = Property_Font_Color;
    lbl_title.font = [UIFont boldSystemFontOfSize:18.0f];
    lbl_title.text = content;
    [lbl_title sizeToFit];
    
    CGRect rect = lbl_title.frame;
    rect.origin.x = Property_Title_Left_Margin;
    rect.origin.y = (Property_Cell_Heght - lbl_title.frame.size.height) / 2;
    lbl_title.frame = rect;
    
    [superView addSubview:lbl_title];
    [lbl_title release];
}

- (void)valueViewOnView:(UIView *)superView empty:(BOOL)isEmpty
                  frame:(CGRect)frame placeholder:(NSString *)str index:(int)index
{
    UIImage *img = nil;
    UIButton *btn_box = [[UIButton alloc] initWithFrame:frame];
    btn_box.tag = Value_Btn_Tag + index;
    if (isEmpty) {
        img = [[UIImage imageNamed:@"property_box_empty.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:0];
    } else {
        img = [[UIImage imageNamed:@"property_box.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:0];
    }
    [btn_box setBackgroundImage:img forState:UIControlStateNormal];
    [btn_box addTarget:self action:@selector(showOptionsViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_box.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [btn_box setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_box setTitle:str forState:UIControlStateNormal];
    [superView addSubview:btn_box];
    [btn_box release];
}

- (void)showOptionsViewButtonClicked:(UIButton *)btn
{
    if ((_selected_index == btn.tag - Value_Btn_Tag) && !_table_view.hidden) {
        _table_view.hidden = YES;
    } else {
        [self showOptionsView:btn.tag - Value_Btn_Tag];
    }
}

- (void)showOptionsView:(int)index
{
    CGRect rect = CGRectZero;
    _selected_index = index;
    if (!_table_view) {
        _table_view = [[UITableView alloc] initWithFrame:CGRectZero];
        _table_view.delegate = self;
        _table_view.dataSource = self;
        [_vImg_property addSubview:_table_view];
    }

    NSArray *arrayValues = [_mdict_operation_values objectForKey:[_value_keys objectAtIndex:index]];
    
    rect.size.height = [arrayValues count] > 3 ? 44 * 4 : 44 * [arrayValues count];
    switch (index) {
        case 0:
            rect.origin.y = 60 + Property_Device_Cell_Height;
            rect.origin.x = 227;
            rect.size.width = 706;
            break;
        case 2:
            rect.origin.y = 60 + Property_Device_Cell_Height + Property_Cell_Heght * 2;
            rect.origin.x = 369;
            rect.size.width = 561;
            break;
        case 3:
            rect.origin.y = 60 + Property_Device_Cell_Height + Property_Cell_Heght * 3;
            rect.origin.x = 314;
            rect.size.width = 616;
            break;
        case 4:
            rect.origin.y = 60 + Property_Device_Cell_Height + Property_Cell_Heght * 4;
            rect.origin.x = 258;
            rect.size.width = 671;
            break;
        case 5:
            rect.origin.y = Property_Device_Cell_Height + Property_Cell_Heght * 5 + 15 - rect.size.height;
            rect.origin.x = 228;
            rect.size.width = 701;
            break;
        case 6:
            rect.origin.y = Property_Device_Cell_Height + Property_Cell_Heght * 6 + 15 - rect.size.height;
            rect.origin.x = 98;
            rect.size.width = 220;
            break;
        case 7:
            rect.origin.y = Property_Device_Cell_Height + Property_Cell_Heght * 6 + 15 - rect.size.height;
            rect.origin.x = 98 + 285 + 20;
            rect.size.width = 220;
            break;
        case 8:
            rect.origin.y = Property_Device_Cell_Height + Property_Cell_Heght * 6 + 15 - rect.size.height;
            rect.origin.x = 98 + 285 + 40 + 240 + 45;
            rect.size.width = 220;
            break;

        default:
            break;
    }
    
    UIImageView *table_bg = [[UIImageView alloc] initWithFrame:rect];
    table_bg.image = [[UIImage imageNamed:@"property_box_empty.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    _table_view.backgroundView = table_bg;
    [table_bg setUserInteractionEnabled:YES];
    [table_bg release];
    
    [_table_view reloadData];
    _table_view.frame = rect;
    _table_view.hidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayValues = [_mdict_operation_values objectForKey:[_value_keys objectAtIndex:_selected_index]];
    return [arrayValues count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"protect_setting_idenetifier"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"protect_setting_idenetifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSArray *arrayValues = [_mdict_operation_values objectForKey:[_value_keys objectAtIndex:_selected_index]];
    NSDictionary *dict = [arrayValues objectAtIndex:indexPath.row];
    cell.textLabel.text = [[dict allKeys] lastObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *values = [_mdict_operation_values objectForKey:[_value_keys objectAtIndex:_selected_index]];
    NSDictionary *dict_value = [values objectAtIndex:indexPath.row];
    
    if (_selected_index == 6) {
        [_mdict_current_values setValue:dict_value forKey:[_value_keys objectAtIndex:_selected_index]];
        
        UIButton *btn = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + _selected_index] viewWithTag:Value_Btn_Tag + _selected_index];
        [btn setTitle:[[dict_value allKeys] lastObject] forState:UIControlStateNormal];
        
        UIButton *btnEvent = (UIButton *)[(UIButton *)[_vImg_property viewWithTag:Value_Bg_Tag + 6] viewWithTag:Value_Btn_Tag + 7];
        UIButton *btnMode = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + 6] viewWithTag:Value_Btn_Tag + 8];
        
        NSArray *event = [_mdict_current_values objectForKey:kM2CEventKey];
        NSArray *mode = [_mdict_current_values objectForKey:kM2CModeKey];
        
        int index = [[[dict_value allValues] lastObject] intValue];
        if ([event count] > index) {
            [btnEvent setTitle:[[[event objectAtIndex:index] allKeys] lastObject] forState:UIControlStateNormal];
        }
        
        if ([mode count] > index) {
            [btnMode setTitle:[[[mode objectAtIndex:index] allKeys] lastObject] forState:UIControlStateNormal];
        }
    }
    
    if (_selected_index > 6) { ///M2C values
        NSMutableArray *marray = [[NSMutableArray alloc] initWithArray:
                                  [_mdict_current_values objectForKey:[_value_keys objectAtIndex:_selected_index]]];
        if (![[[[_mdict_current_values objectForKey:kM2CRelayKey] allValues] lastObject] intValue]) {
            ///Realy 1
            [marray replaceObjectAtIndex:0 withObject:dict_value];
        } else {
            [marray replaceObjectAtIndex:1 withObject:dict_value];
        }
        [_mdict_current_values setValue:marray forKey:[_value_keys objectAtIndex:_selected_index]];
        
        UIButton *btnEvent = (UIButton *)[(UIButton *)[_vImg_property viewWithTag:Value_Bg_Tag + 6] viewWithTag:Value_Btn_Tag + 7];
        UIButton *btnMode = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + 6] viewWithTag:Value_Btn_Tag + 8];
        
        NSArray *event = [_mdict_current_values objectForKey:kM2CEventKey];
        NSArray *mode = [_mdict_current_values objectForKey:kM2CModeKey];
        
        int index = [[[[_mdict_current_values objectForKey:kM2CRelayKey ] allValues] lastObject] intValue];
        [btnEvent setTitle:[[[event objectAtIndex:index] allKeys] lastObject] forState:UIControlStateNormal];
        
        if ([mode count] > index) {
            [btnMode setTitle:[[[mode objectAtIndex:index] allKeys] lastObject] forState:UIControlStateNormal];
        }

        [marray release];
    } else {
        [_mdict_current_values setValue:dict_value forKey:[_value_keys objectAtIndex:_selected_index]];
        UIButton *btn = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + _selected_index] viewWithTag:Value_Btn_Tag + _selected_index];
        [btn setTitle:[[dict_value allKeys] lastObject] forState:UIControlStateNormal];
    }
    
    _table_view.hidden = YES;
    NSLog(@"123");
}

#pragma mark - System type setting -
- (NSString *)systemType:(int)int_type
{
    NSString *strResult = nil;
    switch (int_type) {
        case 30:
            strResult = @"4Wires 4Cts not connected VN";
        case 31:
            strResult = @"3Wires 3Cts not connected VN";
            break;
        case 40:
            strResult = @"4Wires 3Cts connected VN";
            break;
        case 41:
            strResult = @"4Wires 4Cts connected VN";
            break;
        default:
            break;
    }
    return strResult;
}

- (void)creatSystemTypeSetting
{
    UIView *__device_sype_cell = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height,
                                                                          Property_Cell_Width,
                                                                          Property_Cell_Heght)];
    __device_sype_cell.backgroundColor = [UIColor clearColor];
    __device_sype_cell.tag = Value_Bg_Tag;

    [_vImg_property addSubview:__device_sype_cell];

    int system = [[[[_mdict_current_values objectForKey:kProSystemTypeSettingKey] allValues] lastObject] intValue];
    ///title
    [self titleLabelOnView:__device_sype_cell title:kProSystemTypeSettingKey index:0];
    [self valueViewOnView:__device_sype_cell empty:NO frame:CGRectMake(227, 15, 706, 45) placeholder:[self systemType:system] index:0];
    [__device_sype_cell release];
}

#pragma mark - Power sign -
#define Power_sign_tag 76401
- (void)powerSignButtonClicked:(UIButton *)btn
{
    UIButton *btn_plus = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + 1] viewWithTag:Power_sign_tag + 1];
    UIButton *btn_min = (UIButton *)[[_vImg_property viewWithTag:Value_Bg_Tag + 1] viewWithTag:Power_sign_tag];
    
    NSString *key = [_value_keys objectAtIndex:1];
    NSDictionary *dict = nil;
    if (!(btn.tag - Power_sign_tag)) {
        /// -
        dict = [[_mdict_operation_values objectForKey:key] objectAtIndex:0];
        [btn_plus setImage:[UIImage imageNamed:@"property_plus.png"] forState:UIControlStateNormal];
        [btn_min setImage:[UIImage imageNamed:@"property_minus_sel.png"] forState:UIControlStateNormal];
    } else {
        /// +
        dict = [[_mdict_operation_values objectForKey:key] objectAtIndex:1];
        [btn_plus setImage:[UIImage imageNamed:@"property_plus_sel.png"] forState:UIControlStateNormal];
        [btn_min setImage:[UIImage imageNamed:@"property_minus.png"] forState:UIControlStateNormal];
    }
    
    [_mdict_current_values setValue:dict forKey:key];
}

- (void)creatPowerSign
{
    UIView *__power_size_cell = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                                         + Property_Cell_Heght,
                                                                          Property_Cell_Width,
                                                                          Property_Cell_Heght)];
    __power_size_cell.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__power_size_cell];
    __power_size_cell.tag = Value_Bg_Tag + 1;

    ///title
    [self titleLabelOnView:__power_size_cell title:kPowerSignKey index:1];
    
    ///uibutton 1
    UIButton *btn_plus = [[UIButton alloc] initWithFrame:CGRectMake(223, 16, 50, 48)];
    [btn_plus addTarget:self action:@selector(powerSignButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn_plus.tag = Power_sign_tag + 1;
    [__power_size_cell addSubview:btn_plus];
    
    UIButton *btn_min = [[UIButton alloc] initWithFrame:CGRectMake(308, 16, 50, 48)];
    [btn_min addTarget:self action:@selector(powerSignButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn_min.tag = Power_sign_tag;
    [__power_size_cell addSubview:btn_min];

    int sign = [[[[_mdict_current_values objectForKey:[_value_keys objectAtIndex:1]] allValues] lastObject] intValue];
    if (!sign) {
        [btn_plus setImage:[UIImage imageNamed:@"property_plus.png"] forState:UIControlStateNormal];
        [btn_min setImage:[UIImage imageNamed:@"property_minus_sel.png"] forState:UIControlStateNormal];
    } else {
        [btn_plus setImage:[UIImage imageNamed:@"property_plus_sel.png"] forState:UIControlStateNormal];
        [btn_min setImage:[UIImage imageNamed:@"property_minus.png"] forState:UIControlStateNormal];
    }
    [btn_plus release];
    [btn_min release];

    [__power_size_cell release];
}

#pragma mark - current demand caculation method -
- (void)creatCurrentDemandCaculationMethod
{
    UIView *__current_demand = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                                        + Property_Cell_Heght * 2,
                                                                         Property_Cell_Width,
                                                                         Property_Cell_Heght)];
    __current_demand.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__current_demand];
    __current_demand.tag = Value_Bg_Tag + 2;

    ///title
    [self titleLabelOnView:__current_demand title:kCurrentDemandCalculationMethodKey index:2];
    [self valueViewOnView:__current_demand empty:NO frame:CGRectMake(369, 15, 561, 45) placeholder:[[[_mdict_current_values objectForKey:kCurrentDemandCalculationMethodKey] allKeys] lastObject] index:2];

    [__current_demand release];
}

#pragma mark - current demand window size -
- (void)creatCurrentDemandWindowSize
{
    UIView *__current_demand_window = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                                               + Property_Cell_Heght * 3,
                                                                               Property_Cell_Width,
                                                                               Property_Cell_Heght)];
    __current_demand_window.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__current_demand_window];
    __current_demand_window.tag = Value_Bg_Tag + 3;

    ///title
    [self titleLabelOnView:__current_demand_window title:kCurrentDemandWindowSizeKey index:3];
    [self valueViewOnView:__current_demand_window empty:YES frame:CGRectMake(314, 15, 616, 45) placeholder:[[[_mdict_current_values objectForKey:kCurrentDemandWindowSizeKey] allKeys] lastObject] index:3];

    [__current_demand_window release];
}

#pragma mark - power demand method -
- (void)creatPowerDemandMethod
{
    UIView *__power_demand_method = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                                             + Property_Cell_Heght * 4,
                                                                               Property_Cell_Width,
                                                                               Property_Cell_Heght)];
    __power_demand_method.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__power_demand_method];
    __power_demand_method.tag = Value_Bg_Tag + 4;

    ///title
    [self titleLabelOnView:__power_demand_method title:kPowerDemandMethodKey index:4];
    [self valueViewOnView:__power_demand_method empty:NO frame:CGRectMake(258, 15, 671, 45) placeholder:[[[_mdict_current_values objectForKey:kPowerDemandMethodKey] allKeys] lastObject] index:4];

    [__power_demand_method release];
}

#pragma mark - power demand size -
- (void)creatPowerDemandSize
{
    UIView *__power_demand_size = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                                           + Property_Cell_Heght * 5,
                                                                             Property_Cell_Width,
                                                                             Property_Cell_Heght)];
    __power_demand_size.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__power_demand_size];
    __power_demand_size.tag = Value_Bg_Tag + 5;

    ///title
    [self titleLabelOnView:__power_demand_size title:kPowerDemandSizeKey index:5];
    [self valueViewOnView:__power_demand_size empty:NO frame:CGRectMake(228, 15, 701, 45) placeholder:[[[_mdict_current_values objectForKey:kPowerDemandSizeKey] allKeys] lastObject] index:5];

    [__power_demand_size release];
}

#pragma mark - M2C -
- (void)creatM2C
{
    UIView *__m2c = [[UIView alloc] initWithFrame:CGRectMake(0, Property_Device_Cell_Height
                                                             + Property_Cell_Heght * 6,
                                                                Property_Cell_Width,
                                                                Property_Cell_Heght)];
    __m2c.backgroundColor = [UIColor clearColor];
    [_vImg_property addSubview:__m2c];
    __m2c.tag = Value_Bg_Tag + 6;

    ///title
    [self titleLabelOnView:__m2c title:kM2CKey index:6];

    ///m2c realy
    UIButton *btn_box = [[UIButton alloc] initWithFrame:CGRectMake(98, 15, 220, 45)];
    btn_box.tag = Value_Btn_Tag + 6;
    [btn_box setBackgroundImage:[[UIImage imageNamed:@"property_box.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:0] forState:UIControlStateNormal];
    [btn_box addTarget:self action:@selector(showOptionsViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [__m2c addSubview:btn_box];
    
    NSString *strTitle = [[[_mdict_current_values objectForKey:kM2CRelayKey] allKeys] lastObject];
    [btn_box setTitle:strTitle forState:UIControlStateNormal];
    btn_box.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [btn_box setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_box release];
    
    //m2c event
    UILabel *lbl_title = [[UILabel alloc] initWithFrame:CGRectMake(98 + 230, 15, 70, 45)];
    lbl_title.backgroundColor = [UIColor clearColor];
    lbl_title.textColor = Property_Font_Color;
    lbl_title.font = [UIFont boldSystemFontOfSize:24];
    lbl_title.text = @"event";
    [__m2c addSubview:lbl_title];
    [lbl_title release];
    
    btn_box = [[UIButton alloc] initWithFrame:CGRectMake(98 + 285 + 20, 15, 220, 45)];
    btn_box.tag = Value_Btn_Tag + 7;
    [btn_box setBackgroundImage:[[UIImage imageNamed:@"property_box.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:0] forState:UIControlStateNormal];
    [btn_box addTarget:self action:@selector(showOptionsViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [__m2c addSubview:btn_box];
    
    int realy = [strTitle intValue];
    strTitle = nil;
    NSArray *arrayEvent = [_mdict_current_values objectForKey:kM2CEventKey];
    if ([arrayEvent count] > realy) {
        strTitle = [[[arrayEvent objectAtIndex:realy] allKeys] lastObject];
        
    }

    [btn_box setTitle:strTitle forState:UIControlStateNormal];
    btn_box.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [btn_box setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_box release];

    //m2c mode
    lbl_title = [[UILabel alloc] initWithFrame:CGRectMake(98 + 285 + 40 + 210, 15, 70, 45)];
    lbl_title.backgroundColor = [UIColor clearColor];
    lbl_title.textColor = Property_Font_Color;
    lbl_title.font = [UIFont boldSystemFontOfSize:24];
    lbl_title.text = @"mode";
    [__m2c addSubview:lbl_title];
    [lbl_title release];
    
    btn_box = [[UIButton alloc] initWithFrame:CGRectMake(98 + 285 + 40 + 240 + 45, 15, 220, 45)];
    btn_box.tag = Value_Btn_Tag + 8;
    [btn_box setBackgroundImage:[[UIImage imageNamed:@"property_box.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:0] forState:UIControlStateNormal];
    [btn_box addTarget:self action:@selector(showOptionsViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [__m2c addSubview:btn_box];
    
    NSArray *array = [_mdict_current_values objectForKey:kM2CModeKey];
    strTitle = nil;
    if ([array count] > realy) {
        strTitle = [[[array objectAtIndex:realy] allKeys] lastObject];

    }
    [btn_box setTitle:strTitle forState:UIControlStateNormal];
    btn_box.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [btn_box setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_box release];

    [__m2c release];
}

#pragma mark - _modbus -
- (void)getCurrentProductSettingData
{
    [self getFirstData];
}

- (void)getFirstData
{
    NSLog(@"%@",getUIObjectForKey(Default_Device) );
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
        if (!_mdict_current_values) {
            _mdict_current_values = [[NSMutableDictionary alloc] init];
        }
        NSDictionary *_dic_systemType = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:31],@"3Wires 3Cts not connected VN", nil];
        [_mdict_current_values setValue:_dic_systemType forKey:kProSystemTypeSettingKey];
        [_dic_systemType release];
        
          NSDictionary *_dic_powerSign = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Bottomfed", nil];
       [ _mdict_current_values setValue:_dic_powerSign forKey:kPowerSignKey];
        [_dic_powerSign release];
        
        
        NSDictionary *_dic_CurrentDemandCalculationMethod = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Thermal; sliding", nil];
        [ _mdict_current_values setValue:_dic_CurrentDemandCalculationMethod forKey:kCurrentDemandCalculationMethodKey];
        [_dic_CurrentDemandCalculationMethod release];
        
        NSDictionary *_dic_CurrentDemandWindowSizeKey = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"5", nil];
        [ _mdict_current_values setValue:_dic_CurrentDemandWindowSizeKey forKey:kCurrentDemandWindowSizeKey];
        [_dic_CurrentDemandWindowSizeKey release];
        
        NSDictionary *_dic_PowerDemandMethod = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Thermal; sliding", nil];
        [ _mdict_current_values setValue:_dic_PowerDemandMethod forKey:kPowerDemandMethodKey];
        [_dic_PowerDemandMethod release];
        
        NSDictionary *_dic_PowerDemandSize = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"5", nil];
        [ _mdict_current_values setValue:_dic_PowerDemandSize forKey:kPowerDemandSizeKey];
        [_dic_PowerDemandSize release];
        
        
        
        NSDictionary *_dic_M2CRelay= [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Realy 1", nil];
        [ _mdict_current_values setValue:_dic_M2CRelay forKey:kM2CRelayKey];
        [_dic_M2CRelay release];
        
         NSMutableArray *event = [[NSMutableArray alloc] init];
        [event addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
         [event addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
        [ _mdict_current_values setValue:event forKey:kM2CEventKey];
        [event release];
       
        
        NSMutableArray *mode = [[NSMutableArray alloc] init];
        [mode addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
        [mode addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
        [ _mdict_current_values setValue:mode forKey:kM2CModeKey];
        [mode release];
        
        _dict_source_values = [[NSDictionary alloc] initWithDictionary:_mdict_current_values];
        
        [self initUserInterface];
        
        }
    else{
    
    [_obj_modbus readRegistersFrom:3313
                             count:42
                           success:^(NSArray *array){
                               [self processFirstData:array];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
    }
    
    
}

- (void)currentValue:(int)value forKey:(NSString *)key
{
    NSArray *arrayValues = [_mdict_operation_values objectForKey:key];
    for (NSDictionary *dict in arrayValues) {
        if ([[[dict allValues] lastObject] intValue] == value) {
            [_mdict_current_values setValue:dict forKey:key];
        }
    }
}

- (void)processFirstData:(NSArray *)array
{
    if (!_mdict_current_values) {
        _mdict_current_values = [[NSMutableDictionary alloc] init];
    }
    
    int system = [[array objectAtIndex:0] intValue];
    [self currentValue:system forKey:kProSystemTypeSettingKey];
    
    ///power sign
    int power_sign = [[array objectAtIndex:2] intValue];
    [self currentValue:power_sign forKey:kPowerSignKey];
    
    ///current demand calculation method
    int cdcm = [[array objectAtIndex:37] intValue];
    [self currentValue:cdcm forKey:kCurrentDemandCalculationMethodKey];
    
    ///current demand window
    int cdw = [[array objectAtIndex:38] intValue];
    [self currentValue:cdw forKey:kCurrentDemandWindowSizeKey];
    
    ///power demand calculation method
    int pdcm = [[array objectAtIndex:40] intValue];
    [self currentValue:pdcm forKey:kPowerDemandMethodKey];
    
    ///power demand calculation window
    int pdcw = [[array objectAtIndex:41] intValue];
    [self currentValue:pdcw forKey:kPowerDemandSizeKey];
    
    [self getSecondData];
}

- (void)getSecondData
{
    [_obj_modbus readRegistersFrom:9801
                             count:13
                           success:^(NSArray *array){
                               [self processSecondData:array];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

- (void)processSecondData:(NSArray *)array
{
    [self currentValue:0 forKey:kM2CRelayKey];
    ///event 1
    int event1 = [[array objectAtIndex:5] intValue];
    ///event 2
    int event2 = [[array objectAtIndex:12] intValue];
    ///mode  1
    int mode1 = [[array objectAtIndex:0] intValue];
    ///mode  2
    int mode2 = [[array objectAtIndex:6] intValue];
    NSMutableArray *event = [[NSMutableArray alloc] init];
    NSMutableArray *mode = [[NSMutableArray alloc] init];
    
    NSArray *arrayValues = [_mdict_operation_values objectForKey:kM2CEventKey];
    
    if (event1 == 32768) {
        [event addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
    } else {
        for (NSDictionary *dict in arrayValues) {
            if ([[[dict allValues] lastObject] intValue] == event1) {
                [event addObject:dict];
            }
        }
    }
    
    if (event2 == 32768) {
        [event addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
    } else {
        for (NSDictionary *dict in arrayValues) {
            if ([[[dict allValues] lastObject] intValue] == event2) {
                [event addObject:dict];
            }
        }
    }
    
    
    ///mode
    NSArray *arrayMode = [_mdict_operation_values objectForKey:kM2CModeKey];
    if (mode1 == 32768) {
        [mode addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
    } else {
        for (NSDictionary *dict in arrayMode) {
            if ([[[dict allValues] lastObject] intValue] == mode1) {
                [mode addObject:dict];
            }
        }
    }
    
    if (mode2 == 32768) {
        [mode addObject:[NSDictionary dictionaryWithObject:@"-1" forKey:@"Non"]];
    } else {
        for (NSDictionary *dict in arrayMode) {
            if ([[[dict allValues] lastObject] intValue] == mode2) {
                [mode addObject:dict];
            }
        }
    }

    [_mdict_current_values setValue:event forKey:kM2CEventKey];
    [_mdict_current_values setValue:mode forKey:kM2CModeKey];
    
    _dict_source_values = [[NSDictionary alloc] initWithDictionary:_mdict_current_values];
    
    [self initUserInterface];
}

#pragma mark - write values to device -
- (int)registOfKey:(NSString *)str
{
    int result = 0;
    if ([str isEqualToString:kPowerSignKey]) {
        result = 3315;
    } else if ([str isEqualToString:kCurrentDemandCalculationMethodKey]) {
        result = 3350;
    } else if ([str isEqualToString:kCurrentDemandWindowSizeKey]) {
        result = 3351;
    } else if ([str isEqualToString:kPowerDemandMethodKey]) {
        result = 3353;
    } else if ([str isEqualToString:kPowerDemandSizeKey]) {
        result = 3354;
    } else if ([str isEqualToString:kProSystemTypeSettingKey]) {
        result = 3313;
    }
    return result;
}

- (void)setValueToDevice
{
    NSArray *arrayKeys = [_mdict_current_values allKeys];
    
    NSMutableArray *marrayWrite = [[NSMutableArray alloc] init];
    for (NSString *strKey in arrayKeys) {
        if ([strKey isEqualToString:kM2CEventKey]) {
            NSArray *cur_event = [_mdict_current_values objectForKey:kM2CEventKey];
            NSArray *sou_event = [_dict_source_values objectForKey:kM2CEventKey];
            for (int i = 0; i < [cur_event count]; i ++) {
                if ([[[[cur_event objectAtIndex:i] allValues] lastObject] intValue] !=
                    [[[[sou_event objectAtIndex:i] allValues] lastObject] intValue]) {
                    int int_register = i ? 9813 : 9806;
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [[[cur_event objectAtIndex:i] allValues] lastObject], @"value",
                                          [NSNumber numberWithInt:int_register], @"register",nil];
                    [marrayWrite addObject:dict];
                    [dict release];
                }
            }
        } else if ([strKey isEqualToString:kM2CModeKey]) {
            NSArray *cur_event = [_mdict_current_values objectForKey:kM2CModeKey];
            NSArray *sou_event = [_dict_source_values objectForKey:kM2CModeKey];
            for (int i = 0; i < [cur_event count]; i ++) {
                if ([[[[cur_event objectAtIndex:i] allValues] lastObject] intValue] !=
                    [[[[sou_event objectAtIndex:i] allValues] lastObject] intValue]) {
                    int int_register = i ? 9807 : 9801;
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [[[cur_event objectAtIndex:i] allValues] lastObject], @"value",
                                          [NSNumber numberWithInt:int_register], @"register",nil];
                    [marrayWrite addObject:dict];
                    [dict release];
                }
            }
        } else {
            if ([[[[_mdict_current_values objectForKey:strKey] allValues] lastObject] intValue] !=
                [[[[_dict_source_values objectForKey:strKey] allValues] lastObject] intValue]) {
                ///changed
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [[[_mdict_current_values objectForKey:strKey] allValues] lastObject],@"value",
                                      [NSNumber numberWithInt:[self registOfKey:strKey]], @"register",nil];
                [marrayWrite addObject:dict];
                [dict release];
            }
        }
    }
    self.array_modify_values = marrayWrite;
    [marrayWrite release];
    _write_index = 0;
    
    [self loadingView:@"Writing Register..."];
    [self writeValueToRegiste];
}

- (void)writeValueToRegiste
{
    if (_write_index < [self.array_modify_values count]) {
        [_obj_modbus writeRegister:[[[_array_modify_values objectAtIndex:_write_index] objectForKey:@"register"] intValue]
                                to:[[[_array_modify_values objectAtIndex:_write_index] objectForKey:@"value"] intValue]
                           success:^(void) {
                               NSDictionary *dict = [_array_modify_values objectAtIndex:_write_index];
                               if ([[dict objectForKey:@"register"] intValue] == 3313) {
                                   ///system type
                                   [self modifySystemType:[[dict objectForKey:@"value"] intValue]];
                               }
                               NSLog(@"write success");
                               _write_index ++;
                               [self writeValueToRegiste];
                           }
                           failure:^(NSError *error) {
                               NSLog(@"write %d value error",[[[_array_modify_values objectAtIndex:_write_index] objectForKey:@"register"] intValue]);
                               _write_index ++;
                               [self writeValueToRegiste];
                           }];
    } else {
        [_dict_source_values release];
        _dict_source_values = [[NSDictionary alloc] initWithDictionary:_mdict_current_values];
        [self showLoadingView:NO];
    }
}

- (void)modifySystemType:(int)type
{
    NSMutableArray *marrayPosition = [[NSMutableArray alloc] initWithArray:[_system_manager devicePositionInfo]];
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:[marrayPosition objectAtIndex:_int_device_position]];
    NSMutableDictionary *mdictInfo = [[NSMutableDictionary alloc] initWithDictionary:[mdict objectForKey:kDeviceInfoKey]];
    [mdictInfo setObject:[NSNumber numberWithInt:type] forKey:kDeviceSystemTypeSettingKey];
    [mdict setObject:mdictInfo forKey:kDeviceInfoKey];
    [marrayPosition replaceObjectAtIndex:_int_device_position withObject:mdict];

    [_system_manager setMarrayDevicePositionInfo:marrayPosition];
    [mdictInfo release];
    [marrayPosition release];
    [mdict release];

    [_system_manager save];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
