//
//  ModbusAuxiliary.m
//  Schneider
//
//  Created by GongXuehan on 13-4-19.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ModbusAuxiliary.h"

#pragma mark - device model method -
register_str device_model()
{
    register_str device_model;
    device_model.start_address = 8739;
    device_model.register_count = 2;
    return device_model;
}

///product settings
register_str system_type_setting()
{
    register_str system_type;
    system_type.start_address = 3313;
    system_type.register_count = 1;
    return system_type;
}

NSArray *parseAsc(NSArray *respond)
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    for (int index = 0;index < [respond count]; index ++) {
        int intResp = [[respond objectAtIndex:index] intValue];
        ///dec - > asc
        char *buf = &intResp;
        buf ++;
        char c[2];
        for(int i=0;i < 2;i++){
            c[i] = *buf;
            buf--;
        }
        [marray addObject:
         [NSArray arrayWithObjects:[NSNumber numberWithChar:c[0]],
                           [NSNumber numberWithChar:c[1]], nil]];
    }
    return [marray autorelease];
}

NSString *parseModelRespond(NSArray *modelRespond)
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    NSArray *arrayModel = parseAsc(modelRespond);
    for (int i = 0; i < [arrayModel count]; i ++) {
        if (!i) {
            [mstr appendFormat:@"%c.%c",[[[arrayModel objectAtIndex:i] objectAtIndex:0] charValue],
             [[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
        } else if (i == 1) {
            [mstr appendFormat:@"%c",[[[arrayModel objectAtIndex:i] objectAtIndex:1] charValue]];
        }
    }
    NSLog(@"mstr %@",mstr);
    return [mstr autorelease];
}

#pragma mark - ialarm method -
register_str alarm_recorded()
{
    /*
     The total number of the trip recorded.
     Register 9098: the total number stored in product
     Register 9099: the position of the newest one recorded
     */
    register_str alarm;
    alarm.start_address = 9097;
    alarm.register_count = 2;
    return alarm;
}

/*
    record 0 
 */
register_str alarm_list()
{
    register_str alarm_list;
    alarm_list.start_address = 9099;
    alarm_list.register_count = 20;
    return alarm_list;
}

/*
    battery capactity
 */
register_str battery_capacity()
{
    register_str battery;
    battery.start_address = 8842;
    battery.register_count = 1;
    return battery;
}

#pragma mark - icheck method -
register_str circuit_breaker_current()
{
    /*
        Type of output module:  8749
        default value: 100A
     */
    register_str current;
    current.start_address = 8749;
    current.register_count = 1;
    return current;
}

register_str output_module()
{
    /*
        Type of output module:  R9843
        0:none
        2:m2c
        6:m6c
     */
    register_str output;
    output.start_address = 9842;
    output.register_count = 1;
    return output;
}

#pragma mark - iSetting method -
///protection setting
register_str protection_setting()
{
    register_str protection_setting;
    protection_setting.start_address = 30005;
    protection_setting.register_count = 10;
    return protection_setting;
}

register_str power_sign()
{
    register_str m2c_setting;
    m2c_setting.start_address = 3315;
    m2c_setting.register_count = 1;
    return m2c_setting;
}

#pragma mark - iControl method -
register_str step_1()
{
    /*
        7715 must different than 0
     */
    register_str step_1;
    step_1.start_address = 7714;
    step_1.register_count = 1;
    return step_1;
}

register_str step_2()
{
    register_str step_2;
    step_2.start_address = 552;
    step_2.register_count = 1;
    return step_2;
}

register_str step_3()
{
    register_str step_3;
    step_3.start_address = 7719;
    step_3.register_count = 5;
    return step_3;
}

register_str step_4()
{
    register_str step_4;
    step_4.start_address = 7716;
    step_4.register_count = 2;
    return step_4;
}

register_str step_5()
{
    register_str step_5;
    step_5.start_address = 7718;
    step_5.register_count = 1;
    return step_5;
}

register_str step_6()
{
    register_str step_6;
    step_6.start_address = 7719;
    step_6.register_count = 5;
    return step_6;
}

register_str step_7()
{
    register_str step_7;
    step_7.start_address = 7716;
    step_7.register_count = 2;
    return step_7;
}

register_str step_8()
{
    register_str step_8;
    step_8.start_address = 7718;
    step_8.register_count = 1;
    return step_8;
}

register_str step_9()
{
    register_str step_9;
    step_9.start_address = 7719;
    step_9.register_count = 5;
    return step_9;
}

register_str step_10()
{
    register_str step_10;
    step_10.start_address = 7716;
    step_10.register_count = 2;
    return step_10;
}

register_str step_11()
{
    register_str step_11;
    step_11.start_address = 7718;
    step_11.register_count = 1;
    return step_11;
}

#pragma mark - iMeasurement method -
///current group -----------------------------------A [for A, E, P]
/*
 1016 to 1019 RMScurrent on phase 1~3 and netural
 */
register_str current_group()
{
    register_str current_group;
    current_group.start_address = 1015;
    current_group.register_count = 4;
    return current_group;
}

/*
 1021 ground-fault current
 */
register_str ground_fault_current()
{
    register_str ground_fault_current;
    ground_fault_current.start_address = 1020;
    ground_fault_current.register_count = 1;
    return ground_fault_current;
}
/*
 maximum values of current group
 1600:  R1000
 1617:  maximum current of phase 2
 1618:  maximum current of phase 3
 1619:  maximum current of neutral phase
 1621:  maximum current of ground fault
 */

register_str r()
{
    register_str r;
    r.start_address = 1599;
    r.register_count = 1;
    return  r;
}

register_str max_current_group()
{
    register_str max_current_group;
    max_current_group.start_address = 1616;
    max_current_group.register_count = 4;
    return  max_current_group;
}

///voltage group -----------------------------------V [only for E, P]
/*
 •	Phase voltage: 3 values only for 4 wires system
 •	Line-Line voltage: 3 values
 •	Unbalance values for each phase : 3 values only for 4 wires system
 */

/*
 1.phase to phase voltage
 1000    1001    1002
 V12     V23     V31
 */
register_str voltage_p_to_p()
{
    register_str result;
    result.start_address = 999;
    result.register_count = 3;
    return result;
}

/*
 2.phase to neutral voltage
 1003    1004    1005
 V1N     V2N     V3N
 */
register_str voltage_p_to_n()
{
    register_str result;
    result.start_address = 1002;
    result.register_count = 3;
    return result;
}

/*
 3.unbalance of phase to neutral
 */
register_str voltage_unbalance_p_to_n()
{
    register_str result;
    result.start_address = 1010;
    result.register_count = 3;
    return result;
}

/// Maximum values of voltages group [only for E, P] ------------------------MV
/*
 •	RMS phase-to-phase voltage V12
 •	RMS phase-to-phase voltage V23
 •	RMS phase-to-phase voltage V31
 •	Maximum RMS phase-to-neutral voltage V1N. [only for 4 wires]
 •	Maximum RMS phase-to-neutral voltage V2N. [only for 4 wires]
 •	Maximum RMS phase-to-neutral voltage V3N. [only for 4 wires]
 */
/*
 
 */


///Frequency -----------------------------------频率 [only for P]
/*
 1054 system frequency
 1055 duration of the interval (about 1s)
 */
register_str frequency()
{
    register_str result;
    result.start_address = 1053;
    result.register_count = 2;
    return result;
}


///power group -----------------------------------P [only for E, P]
/*
 4 wires system:
 •	Active Power (each phase and total): 4 values
 •	Reactive power (each phase and total): 4 values
 •	Apparent power(each phase and total): 4 values
 3 wires system:
 •	Total active power;
 •	Total reactive power
 •	Total apparent power
 */

/*
 1.active power
 1034 ~ 1036  p1~p3
 1037         total active
 */
register_str active_power()
{
    register_str result;
    result.start_address = 1033;
    result.register_count = 4;
    return result;
}

/*
 2.reactive power
 1038 ~ 1040 p1 ~ p3
 1041        total reactive
 */
register_str reactive_power()
{
    register_str result;
    result.start_address = 1037;
    result.register_count = 4;
    return result;
}

/*
 3.apparent power
 1042 ~ 1044 p1 ~ p3 with 3 wattmeters
 1045        total apparent power
 */
register_str apparent_power()
{
    register_str result;
    result.start_address = 1041;
    result.register_count = 4;
    return result;
}


///Energy group ----------------------------------- E
/*
 •	Total active energy [only for E, P] : 1 value
 •	Total Reactive energy [only for E, P] : 1 value
 •	Total apparent energy [only for E, P] : 1 value
 •	Active energy counted positively [only for P] : 1 value
 •	Active energy counted negatively [only for P] : 1 value
 •	Reactive energy counted positively [only for P] : 1 value
 •	Reactive energy counted negatively[only for P] : 1 value
 */

/*
 2000 ~ 2024
 2000,2004,2024  total  [E,P]
 2008 ~ 2020     other  [P]
 */
register_str energy_group()
{
    register_str result;
    result.start_address = 1999;
    result.register_count = 28;
    return result;
}


///Current Demand group [only for E, P] -----------------------------------AD
/*
 •	Current demand on phase 1 : I1 Dmd
 •	Current demand on phase 2 : I2 Dmd
 •	Current demand on phase 3 : I3 Dmd
 •	Current demand on the neutral* : IN Dmd
 */

/*
 2200 ~ 2203 p1 ~ p3 & netural
 tip:1.value not accessible when the configuration register 3314 selects 31 or 40
 2.only the thermal algorithm is available with micrologic E, while micrologic p/h have both the thermal and arithmetical mean algorithms
 */
register_str current_demand_group()
{
    register_str result;
    result.start_address = 2199;
    result.register_count = 4;
    return result;
}

///Power demand group -----------------------------------PD
/*
 •	Total active demand [only for E, P] : 1 value
 •	Total reactive demand [only for P] : 1 value
 •	Total apparent demand [only for P] : 1 value
 */

/*
 2224 total active power demand
 2225 active power demand maximum since the last reset
 2236 total apparent power
 */
register_str active_demand_group()
{
    register_str result;
    result.start_address = 2223;
    result.register_count = 2;
    return result;
}

register_str apparent_demand_total()
{
    register_str result;
    result.start_address = 2225;
    result.register_count = 1;
    return result;
}

///	Power factor group [only for E, P] : 1 value
/*
 •	Power factor on phase 1 : PF1 [only for 4 wires]
 •	Power factor on phase 2 : PF2 [only for 4 wires]
 */

/*
 1046 ~ 1049  p1 ~ p3  & total
 */
register_str power_factor()
{
    register_str result;
    result.start_address = 1045;
    result.register_count = 4;
    return result;
}