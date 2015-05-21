//
//  Global.m
//  DaiGou
//
//  Created by user on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Global.h"

BOOL B_IOS_6_0(void)
{
    BOOL result = NO;
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0)
    {
        result = YES;
    }
    return result;
}

NSString * urlEncodedParaString(NSString *str)
{
    if (str) {
        CFStringRef strEncode = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (CFStringRef)str,
                                                                        NULL,
                                                                        CFSTR("!*'();:@+$,&=/?%#[]"),
                                                                        kCFStringEncodingUTF8);
        NSString *result=[(NSString *)strEncode retain];
        CFRelease(strEncode);
        [result autorelease];
        return result;
    }
    return nil;
}

void errorMessageAlert(NSString *str, NSString *error)
{
    return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ descrption_%@",str,error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

NSInteger textAlignmentCenter()
{
    return B_IOS_6_0 ? NSTextAlignmentCenter:UITextAlignmentCenter;
}

void saveUDObject(id object, NSString *saveKey)
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:object forKey:saveKey];
    [userDefaults synchronize];
}

id  getUIObjectForKey(NSString *saveKey)
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:saveKey];
}

BOOL isCorrenctIP(NSString *strIP)
{
    NSString *strRegExp = @"^(([1-9]|([1-9]\\d)|(1\\d\\d)|(2([0-4]\d|5[0-5])))\\.)(([1-9]|([1-9]\\d)|(1\\d\\d)|(2([0-4]\\d|5[0-5])))\\.){2}([1-9]|([1-9]\\d)|(1\\d\\d)|(2([0-4]\\d|5[0-5])))$";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegExp];
    return [ipTest evaluateWithObject:strIP];
}

#define DEFAULT_VOID_COLOR [UIColor whiteColor]
UIColor * colorWithHexString(NSString *stringToConvert) 
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
        if ([cString length] != 6)
            return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

NSArray *alarmparseAsc(NSNumber *resp)
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    int intResp = [resp intValue];
    ///dec - > asc
    char *buf = &intResp;
    buf ++;
    char c[2];
    for(int i=0;i < 2;i++){
        c[i] = *buf;
        buf--;
    }
    [marray addObject:[NSNumber numberWithChar:c[0]]];
    [marray addObject:[NSNumber numberWithBool:c[1]]];
    return [marray autorelease];
}

