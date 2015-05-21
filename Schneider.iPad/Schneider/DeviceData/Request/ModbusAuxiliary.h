//
//  ModbusAuxiliary.h
//  Schneider
//
//  Created by GongXuehan on 13-4-19.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    int     start_address;
    int     register_count;
    BOOL    empty_command;
}register_str;

NSArray *parseAsc(NSArray *respond);

#pragma mark - device model method -
register_str device_model();

/*
    pares respond of device model
 */
NSString *parseModelRespond(NSArray *modelRespond);

#pragma mark - ialarm method -
register_str alarm_recorded();
register_str alarm_list();
register_str battery_capacity();

#pragma mark - iCheck method -
/*
    Type of output module
 */
register_str output_module();

/*
    Rated circuit-breaker current
    额定断路器电流
 */
register_str circuit_breaker_current();

#pragma mark - iSetting method -
register_str protection_setting();

///product setting
register_str system_type_setting();
//TODO: gxh 可以设置 0,1
register_str power_sign();
///window size 5~60

#pragma mark - iControl method -
register_str step_1();
register_str step_2();
register_str step_3();
register_str step_4();
register_str step_5();
register_str step_6();
register_str step_7();
register_str step_8();
register_str step_9();
register_str step_10();
register_str step_11();

#pragma mark - iMeasurement method -
///current group -----------------------------------A [for A, E, P]
/*
     1016 to 1019 RMScurrent on phase 1~3 and netural
 */
register_str current_group();

/*
    1021 ground-fault current
 */
register_str ground_fault_current();

/*
    maximum values of current group
    1600:  R1000
    1617:  maximum current of phase 2
    1618:  maximum current of phase 3
    1619:  maximum current of neutral phase
    1621:  maximum current of ground fault
 */
register_str r();
register_str max_current_group();

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
register_str voltage_p_to_p();

/*
    2.phase to neutral voltage
        1003    1004    1005
         V1N     V2N     V3N
*/
register_str voltage_p_to_n();

/*
    3.unbalance of phase to neutral
 */
register_str voltage_unbalance_p_to_n();

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
register_str frequency();


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
register_str active_power();

/*
    2.reactive power
    1038 ~ 1040 p1 ~ p3
    1041        total reactive
*/
register_str reactive_power();

/*
    3.apparent power
    1042 ~ 1044 p1 ~ p3 with 3 wattmeters
    1045        total apparent power
 */
register_str apparent_power();


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
register_str energy_group();


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
register_str current_demand_group();

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
register_str active_demand_group();
register_str apparent_demand_total();

///	Power factor group [only for E, P] : 1 value
/*
 •	Power factor on phase 1 : PF1 [only for 4 wires]
 •	Power factor on phase 2 : PF2 [only for 4 wires]
*/

/*
    1046 ~ 1049  p1 ~ p3  & total
 */
register_str power_factor();