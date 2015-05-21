//
//  SystemDeviceView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-19.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "SystemDeviceView.h"
#import "SystemManager.h"
#import "ModbusAuxiliary.h"

@interface SystemDeviceView ()
{
    UILabel                     *_lbl_device_name;
    UILabel                     *_lbl_connected;
    UILabel                     *_lbl_system_type_setting;
    ConnectState                _connect_state;
    UIImageView                 *_backImageView;
}

@property (nonatomic, assign) ConnectState connect_state;

@end

@implementation SystemDeviceView
@synthesize connect_state = _connect_state;

- (void)dealloc
{
    [_backImageView release];
    [_modbusObj disconnect];
    [_modbusObj release];
    [_lbl_connected release];
    [_lbl_device_name release];
    [_lbl_system_type_setting release];
    [super dealloc];
}

- (id)initWithStartFrame:(CGRect)frame
             targetFrame:(NSArray *)targetFrame
                modbusIp:(NSString *)ipAddress
                    port:(NSInteger)port
               device_id:(NSInteger)device_id
{
    self = [super initWithStartFrame:frame targetFrame:targetFrame];
    if (self) {
        self.device_id = device_id;
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_backImageView setUserInteractionEnabled:YES];
        [self addSubview:_backImageView];
        // Initialization code
        _lbl_device_name = [[UILabel alloc] initWithFrame:CGRectMake(58, 15, 125, 15)];
        _lbl_device_name.font = [UIFont boldSystemFontOfSize:15.0f];
        _lbl_device_name.textColor = colorWithHexString(@"666666");
        _lbl_device_name.backgroundColor = [UIColor clearColor];
        _lbl_device_name.text = @"Mic 6.0 E";
        [self addSubview:_lbl_device_name];
        
        _lbl_connected = [[UILabel alloc] initWithFrame:CGRectMake(58, 30, 125, 15)];
        _lbl_connected.backgroundColor = [UIColor clearColor];
        _lbl_connected.textColor = colorWithHexString(@"999999");
        _lbl_connected.font = [UIFont boldSystemFontOfSize:12.0f];
        [self addSubview:_lbl_connected];
        
        _lbl_system_type_setting = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, frame.size.width - 20, 20)];
        _lbl_system_type_setting.backgroundColor = [UIColor clearColor];
        _lbl_system_type_setting.font = [UIFont systemFontOfSize:18];
        //[self addSubview:_lbl_system_type_setting];

        //self.connect_state = kUnknownState;
        //_modbusObj = [[ObjectiveLibModbus alloc] initWithTCP:ipAddress port:port device:device_id];
        //[self checkDeviceConnect];
    }
    return self;
}

- (NSString *)connectState:(ConnectState)state
{
    NSString *result = nil;
    switch (state) {
        case kUnknownState:
        {
            result = @"Unknow State";
        }
            break;
        case kNotConnectState:
        {
            result = @"Not connect";
        }
            break;
        case kConnectState:
        {
            result = @"Is connected";
        }
            break;
        default:
            break;
    }
    return result;
}

- (void)setDevice_information:(NSDictionary *)device_information
{
    [super setDevice_information:device_information];
    self.device_id = [[device_information objectForKey:kDeviceIdKey] intValue];
    _backImageView.image = [UIImage imageNamed:[device_information objectForKey:kNorImageKey]];
    _lbl_device_name.text = [NSString stringWithFormat:@"Mic %@ %@",
                             [device_information objectForKey:kDeviceModelKey],[device_information objectForKey:kDeviceVersionKey]];
    _lbl_connected.text = [NSString stringWithFormat:@"Device id:%d",[[device_information objectForKey:kDeviceIdKey] intValue]];
}

- (void)setConnect_state:(ConnectState)connect_state
{
    _connect_state = connect_state;
}

#pragma mark - modbus method -
- (void)checkDeviceConnect
{
    NSLog(@"%d",self.device_id);
    if (self.device_id != 31) return;
    [_modbusObj connect:^{
        self.connect_state = kConnectState;
        [self getDeviceModel];
    } failure:^(NSError *error) {
        NSLog(@"device_%d is not opend",self.device_id);
        self.connect_state = kNotConnectState;
    }];
}

- (void)getSystemTypeSetting
{
    [_modbusObj readRegistersFrom:system_type_setting().start_address
                            count:system_type_setting().register_count
                          success:^(NSArray *array){
                              [_device_information setValue:
                               [NSNumber numberWithInt:[[array lastObject] intValue]]
                                                     forKey:kDeviceSystemTypeSettingKey];
                              _lbl_system_type_setting.text =
                              [NSString stringWithFormat:@"%d",
                               [[_device_information objectForKey:kDeviceSystemTypeSettingKey] intValue]];
                          } failure:^(NSError *error){
                              
                          }];
}


#pragma mark - device model -
- (void)parseModelRespond:(NSArray *)modelRespond
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    NSArray *arrayModel = parseAsc(modelRespond);
    for (int i = 0; i < [arrayModel count]; i ++) {
        if (!i) {
            NSString *str_version = [NSString stringWithFormat:@"%c.%c",
                                     [[[arrayModel objectAtIndex:i] objectAtIndex:0] charValue],
                                     [[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
            [_device_information setValue:str_version forKey:kDeviceVersionKey];
            [mstr appendString:str_version];
        } else if (i == 1) {
            NSString *strModel = [NSString stringWithFormat:@"%c",
                                  [[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
            [_device_information setValue:strModel forKey:kDeviceModelKey];
            [mstr appendString:strModel];
        }
    }
    _lbl_device_name.text = mstr;
    [mstr release];
}

- (void)getDeviceModel
{
    if (_connect_state == kConnectState) {
        ///device is connect
        register_str regist = device_model();
        
        [_modbusObj readRegistersFrom:regist.start_address
                                count:regist.register_count
                              success:^(NSArray *array) {
                                  [self parseModelRespond:array];
                                  [self getSystemTypeSetting];
                              }
                              failure:^(NSError *error){
                                  NSLog(@"get device %d model failed ",self.device_id);
                                  NSLog(@"%@",error);
                              }];
    } else {
        NSLog(@"device %d is not connect",self.device_id);
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    _backImageView.image = [UIImage imageNamed:[_device_information objectForKey:kSelImageKey]];
    [self showDeviceInformation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _backImageView.image = [UIImage imageNamed:[_device_information objectForKey:kNorImageKey]];
    if (self.target_index != -1) {
        [self hideDeviceInformation];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    _backImageView.image = [UIImage imageNamed:[_device_information objectForKey:kNorImageKey]];
    if (self.target_index != -1) {
        [self hideDeviceInformation];
    }
}

- (void)showDeviceInformation
{
    _backImageView.hidden = NO;
    _lbl_connected.hidden = NO;
    _lbl_device_name.hidden = NO;
}

- (void)hideDeviceInformation
{
    _backImageView.hidden = YES;
    _lbl_connected.hidden = YES;
    _lbl_device_name.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
