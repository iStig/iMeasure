//
//  CheckInfoViewController.m
//  Schneider
//
//  Created by GongXuehan on 13-6-4.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "CheckInfoViewController.h"
#import "SystemManager.h"
#import <QuartzCore/QuartzCore.h>

/*
 @"Circuit Break Name",@"Trip Unit Name", @"In" ,
 @"Serial No.",@"Firmware Version",@"Have M2C",
 @"System Type",@"Operaction Counter",
 @"Operaction Since Reset", @"SD Counter",
 @"SDE Counter",@"Contact Wear Rate",@"Load Profile" nil];
 */

NSString *const kCircuitBreakNameKey = @"Circuit Break Name";
NSString *const kTripUnitNameKey = @"Trip Unit Name";
NSString *const kAssetInKey = @"In";
NSString *const kSerialNoKey = @"Serial No.";
NSString *const kFirmwareVersionKey = @"Firmware Version";
NSString *const kHaveM2CKey = @"Have M2C";
NSString *const kSystemTypeKey = @"System Type";
NSString *const kOperactionCounterKey = @"Operaction Counter";
NSString *const kOperactionSinceResetKey = @"Operaction Since Reset";
NSString *const kSDCounterKey = @"SD Counter";
NSString *const kSDECounterKey = @"SDE Counter";
NSString *const kContactWearRateKey = @"Contact Wear Rate";
NSString *const kLoadProfileKey = @"Load Profile";


@interface CheckInfoViewController ()<UIScrollViewDelegate>
{
    UIImageView *_vimg_device;
    NSMutableDictionary *_mdict_info_data;
    SystemManager   *_system_manager;
    
    NSArray         *_array_check_keys;
    NSArray         *_array_check_docs;
    UIScrollView    *_scroll_check_info;
 
}
@end

@implementation CheckInfoViewController
@synthesize obj_modbus = _obj_modbus;
@synthesize int_device_position = _int_device_position;
@synthesize doc_scroll;

- (void)dealloc
{
    [_scroll_check_info release];
    [_array_check_docs release];
    [_array_check_keys release];
    [_system_manager release];
    [_mdict_info_data release];
    [_obj_modbus release];
    [_vimg_device release];
    [doc_scroll release];
    [super dealloc];
}

- (id)initWithModbusObject:(CustomObjectModbus *)obj
{
    self = [super init];
    if (self) {
        self.obj_modbus = obj;
        _system_manager = [SystemManager shareManager];
        _array_check_keys = [[NSArray alloc] initWithObjects:kCircuitBreakNameKey,kTripUnitNameKey,kAssetInKey,
                             kSerialNoKey,kFirmwareVersionKey,kHaveM2CKey,kSystemTypeKey,kOperactionCounterKey,
                             kOperactionSinceResetKey,kSDCounterKey,kSDECounterKey,kContactWearRateKey,kLoadProfileKey, nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setTitleImage:@"iasset_title.png"];
    
    NSDictionary *dict = [[_system_manager deviceInfomationOfPosition:_int_device_position] objectForKey:kDeviceInfoKey];
    ///product name
    if ( [[[[dict objectForKey:kDeviceVersionKey] componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"0"] ) {
        
    _array_check_docs = [[NSArray alloc] initWithObjects:@"Masterpact MT产品样本",@"Masterpact MT通讯手册",@"Masterpact  Micrologic  A,E 用户手册", nil];
    }
    else{
    
     _array_check_docs = [[NSArray alloc] initWithObjects:@"Compact NSX产品样本",@"Compact NSX Mic 5,6用户手册",@"Compact NSX  Modbus用户手册", nil];
    
    
    }
    
    

    
//    NSString *strPathPdf = nil;
//    if ([[dict objectForKey:kDeviceModelKey] isEqualToString:@"P"]) {
//        strPathPdf = @"ELP-04443726aa";
//    } else if ([[dict objectForKey:kDeviceModelKey] isEqualToString:@"A"] ||
//               [[dict objectForKey:kDeviceModelKey] isEqualToString:@"E"]) {
//        strPathPdf = @"Micrologic A and E control units";
//    } else if ([[dict objectForKey:kDeviceModelKey] isEqualToString:@"H"]) {
//        strPathPdf = @"ELH";
//    }
//    _array_check_docs = [[NSArray alloc] initWithObjects:strPathPdf,
//                         @"Micrologic_Certification_asefa_109-05bt",@"Catalog-lvped208008en (web)", nil];
    
    
    
	// Do any additional setup after loading the view.
    [self initLeftDeviceImageView];
    [self loadRightInformationData];
    [self initDocumentList];
    
    
    if (![getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
       [self loadingView:@"Loading..."];
    }
    

}

- (void)initLeftDeviceImageView
{
    UIImageView *vimg_device_bg = [[UIImageView alloc] initWithFrame:CGRectMake(29, 36, 290, 595)];
    vimg_device_bg.image = [UIImage imageNamed:@"device_pic_bg.png"];
    [_contentView addSubview:vimg_device_bg];
    
    NSDictionary *dict = [[_system_manager deviceInfomationOfPosition:_int_device_position] objectForKey:kDeviceInfoKey];
    _vimg_device = [[UIImageView alloc] initWithFrame:CGRectMake(71, 84, 126, 432)];
    _vimg_device.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%.1f.png",[dict objectForKey:kDeviceModelKey],[[dict objectForKey:kDeviceVersionKey] floatValue]]];
    [vimg_device_bg addSubview:_vimg_device];
    [vimg_device_bg release];
}

- (void)initRightInformationView
{
    
    if (![getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
    
    [self showLoadingView:NO];
    }
    _scroll_check_info = [[UIScrollView alloc] initWithFrame:CGRectMake(342, 18, 637, 522)];
    _scroll_check_info.backgroundColor = [UIColor clearColor];
    _scroll_check_info.layer.cornerRadius = 10.0f;
    _scroll_check_info.layer.borderColor = colorWithHexString(@"cccccc").CGColor;
    _scroll_check_info.layer.borderWidth = 1.0f;
    [_contentView addSubview:_scroll_check_info];
    
    for (int i = 0; i < [_array_check_keys count]; i ++) {
        NSString *strKey = [_array_check_keys objectAtIndex:i];
        CGRect vImg_bg_rect = CGRectZero;
        if ([strKey isEqualToString:kContactWearRateKey]) {
            vImg_bg_rect = CGRectMake(10, 10 + 64 * i, 617, 54 * 2);
        } else if ([strKey isEqualToString:kLoadProfileKey]) {
            vImg_bg_rect = CGRectMake(10, 10 + 64 * i + 54, 617, 54 * 4);
        } else {
            vImg_bg_rect = CGRectMake(10, 10 + 64 * i, 617, 54);
        }
        
        ///background
        UIImageView *imgInfoBg = [[UIImageView alloc] initWithFrame:vImg_bg_rect];
        imgInfoBg.image = [[UIImage imageNamed:@"check_info_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
        [_scroll_check_info addSubview:imgInfoBg];
        [imgInfoBg release];
        
        UILabel *lbl_key = [[UILabel alloc] initWithFrame:CGRectMake(29, 0, 210, 54)];
        lbl_key.backgroundColor = [UIColor clearColor];
        lbl_key.font = [UIFont boldSystemFontOfSize:18.0f];
        lbl_key.textColor = colorWithHexString(@"9fa0a4");
        lbl_key.text = strKey;
        [imgInfoBg addSubview:lbl_key];
        [lbl_key release];

        ///custom view
        if ([strKey isEqualToString:kContactWearRateKey]) {
            NSArray *array_wear = [_mdict_info_data objectForKey:kContactWearRateKey];
            NSArray *array_wear_sub_keys = [NSArray  arrayWithObjects:@"A",@"B",@"C",@"N", nil];
            for (int j = 0; j < [array_wear count]; j ++) {
                int int_value = [[array_wear objectAtIndex:j] intValue];
                NSString *str_value = (int_value == Undisplay_num) ? @"N/A" : [NSString stringWithFormat:@"%d",int_value];
                UILabel *lbl_value = [[UILabel alloc] initWithFrame:CGRectMake(360, 27 * j, 244, 27)];
                lbl_value.backgroundColor = [UIColor clearColor];
                lbl_value.font = [UIFont boldSystemFontOfSize:18.0f];
                lbl_value.textColor = colorWithHexString(@"484643");
                lbl_value.text = [NSString stringWithFormat:@"%@:   %@",
                                  [array_wear_sub_keys objectAtIndex:j],str_value];
                [imgInfoBg addSubview:lbl_value];
                [lbl_value release];
            }
        } else if ([strKey isEqualToString:kLoadProfileKey]) {
            UIImageView *profile_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_profile.png"]];
            profile_bg.center = CGPointMake(imgInfoBg.frame.size.width / 2, imgInfoBg.frame.size.height - 15);
            [imgInfoBg addSubview:profile_bg];
            [profile_bg release];
            
            NSArray *array = [_mdict_info_data objectForKey:kLoadProfileKey];
            long max_num = 0;
            UILabel *lbl_unit = [[UILabel alloc] initWithFrame:CGRectMake(29, 36, 100, 15)];
            lbl_unit.backgroundColor = [UIColor clearColor];
            lbl_unit.textColor = colorWithHexString(@"9fa0a4");
            lbl_unit.font = [UIFont boldSystemFontOfSize:15.0f];
            lbl_unit.text = @"(hours)";
            [imgInfoBg addSubview:lbl_unit];
            [lbl_unit release];
            
            for (int i = 0 ; i < [array count]; i ++) {
                max_num = MAX(max_num, [[array objectAtIndex:i] intValue]);
                UILabel *lbl_value = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
                lbl_value.center = CGPointMake(170 + 128 * i, 40);
                lbl_value.backgroundColor = [UIColor clearColor];
                lbl_value.font = [UIFont boldSystemFontOfSize:18];
                lbl_value.textAlignment = UITextAlignmentCenter;
                lbl_value.textColor = colorWithHexString(@"484643");
                lbl_value.text = [NSString stringWithFormat:@"%ld",[[array objectAtIndex:i] longValue]];
                [imgInfoBg addSubview:lbl_value];
                [lbl_value release];
            }
            
            CGFloat top_margin  = 56.0f;
            CGFloat draw_height = 137.0f;
            CGFloat step_width = draw_height / max_num;
            
            for (int i = 0; i < [array count]; i ++) {
                CGFloat height = step_width * [[array objectAtIndex:i] longValue];
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, top_margin + (draw_height - height), 40, height)];
                img.center = CGPointMake(170 + 128 * i, img.center.y);
                img.backgroundColor = colorWithHexString(@"4fa600");
                [imgInfoBg addSubview:img];
                [img release];
            }
        } else {
            UILabel *lbl_value = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 244, 54)];
            lbl_value.backgroundColor = [UIColor clearColor];
            lbl_value.font = [UIFont boldSystemFontOfSize:18.0f];
            lbl_value.textColor = colorWithHexString(@"484643");
            lbl_value.text = [_mdict_info_data objectForKey:strKey];
            [imgInfoBg addSubview:lbl_value];
            [lbl_value release];
        }
    }
    _scroll_check_info.contentSize = CGSizeMake(_scroll_check_info.frame.size.width, 64 * [_array_check_keys count] + 54 * 4 + 10);
}

#pragma mark - document list -

- (void)initDocumentList
{
    UIImageView *imgDocListBg = [[UIImageView alloc] initWithFrame:CGRectMake(342, 555, 638, 102)];
    imgDocListBg.image = [UIImage imageNamed:@"check_doc_bg_change.png"];
    [imgDocListBg setUserInteractionEnabled:YES];
    
    
    
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(34, 6, 300, 34)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont boldSystemFontOfSize:18.0f];
    lbl.textColor = colorWithHexString(@"9fa0a4");
    lbl.text = @"Documentation";
    [imgDocListBg addSubview:lbl];
    [lbl release];
    [_contentView addSubview:imgDocListBg];
    
    doc_scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(2, 49,634, 50)];
    doc_scroll.backgroundColor=[UIColor clearColor];
    doc_scroll.delegate=self;
    doc_scroll.clipsToBounds=YES;
    doc_scroll.pagingEnabled=YES;
    [imgDocListBg addSubview:doc_scroll];
    [imgDocListBg release];
    
    float startX = 0.0f;
    float widgetWidth = self.doc_scroll.frame.size.width;
    float widgetHeight =self.doc_scroll.frame.size.height;
    
    for (int i = 0; i < [_array_check_docs count]; i ++ ) {
          UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventPush:)];
        UIImageView *img_view_1 = [[UIImageView alloc] initWithFrame:CGRectMake(startX, 0.0f, widgetWidth,widgetHeight)];
        img_view_1.userInteractionEnabled = YES;
        img_view_1.contentMode=UIViewContentModeScaleAspectFill;
        img_view_1.tag = i + 1;
        [img_view_1 addGestureRecognizer:tapGes];
        [self.doc_scroll addSubview:img_view_1];
        
        UIImageView *pdfImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 35)];
        pdfImage.image = [UIImage imageNamed:@"document_pdf.png"];
        [img_view_1 addSubview:pdfImage];
        
        UILabel *doc_name = [[UILabel alloc] initWithFrame:CGRectMake(60, 7, 450 , 35)];
        doc_name.text = [_array_check_docs objectAtIndex:i];
        doc_name.backgroundColor = [UIColor clearColor];
        doc_name.textAlignment = UITextAlignmentLeft;
        doc_name.font = [UIFont boldSystemFontOfSize:18.0f];
        [img_view_1 addSubview:doc_name];

        [self.doc_scroll addSubview:img_view_1];
        [img_view_1 release];
        [pdfImage release];
        [doc_name release];
        startX += img_view_1.frame.size.width;
    }
    
    self.doc_scroll.contentSize = CGSizeMake(startX, self.doc_scroll.frame.size.height);
    

}
-(void)eventPush:(UITapGestureRecognizer*)sender{
   UIView* v = sender.view;
    
    [self openDocument:(v.tag-1)];

}
- (void)openDocument:(int)index
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:[_array_check_docs objectAtIndex:index] ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:strPath];
    UIDocumentInteractionController* controller = [[UIDocumentInteractionController interactionControllerWithURL:url] retain];
    controller.name = [_array_check_docs objectAtIndex:index];
    controller.delegate = self;
    BOOL ret = [controller presentPreviewAnimated:NO];
    
    if (!ret)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Open PDF Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        [self dismissModalViewControllerAnimated:NO];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_check_docs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:
                              UITableViewCellStyleDefault reuseIdentifier:@"check_info_identifier"] autorelease];
    cell.imageView.image = [UIImage imageNamed:@"document_pdf.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [_array_check_docs objectAtIndex:indexPath.row];
    return cell;
}

- (void)openDocumentButtonClicked:(UIButton *)btn
{
    [self openDocument:btn.tag - 21111];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self openDocument:indexPath.row];
}

- (void)openDocument:(int)index
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:[_array_check_docs objectAtIndex:index] ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:strPath];
    UIDocumentInteractionController* controller = [[UIDocumentInteractionController interactionControllerWithURL:url] retain];
    controller.name = [_array_check_docs objectAtIndex:index];
    controller.delegate = self;
    BOOL ret = [controller presentPreviewAnimated:NO];
    
    if (!ret)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Open PDF Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        [self dismissModalViewControllerAnimated:NO];
    }
}
*/


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [controller autorelease];
    controller.delegate = nil;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{
    return YES;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{
    return YES;
}

#pragma mark - modbus method -
- (NSString *)systemType:(int)int_type
{
    NSString *strResult = nil;
    switch (int_type) {
        case 30:
            strResult = @"4Wires 4Cts";
        case 31:
            strResult = @"3Wires 3Cts";
            break;
        case 40:
            strResult = @"4Wires 3Cts";
            break;
        case 41:
            strResult = @"4Wires 4Cts";
            break;
        default:
            break;
    }
    return strResult;
}
- (void)loadRightInformationData

{
    _mdict_info_data = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [[_system_manager deviceInfomationOfPosition:_int_device_position] objectForKey:kDeviceInfoKey];
    ///product name
    [_mdict_info_data setValue:[NSString stringWithFormat:@"Micrologic %.1f %@",[[dict objectForKey:kDeviceVersionKey] floatValue] ,[dict objectForKey:kDeviceModelKey]] forKey:kTripUnitNameKey];
    ///system type
    [_mdict_info_data setValue:[self systemType:[[dict objectForKey:kDeviceSystemTypeSettingKey] intValue]] forKey:@"System Type"];
    
    
    
    
    
    [self getSerialNumber];
}

- (void)getSerialNumber
{
    
    
    
    if ([getUIObjectForKey(Default_Device) isEqualToString:@"是"]) {
        
    
        [_mdict_info_data setValue:@"00980852" forKey:@"Serial No."];
        [_mdict_info_data setValue:@"9.990" forKey:@"Firmware Version"];
        [_mdict_info_data setValue:@"100A" forKey:@"In"];
        [_mdict_info_data setValue:@"NO" forKey:@"Have M2C"];
        
        
          [_mdict_info_data setValue:@"N/A" forKey:kCircuitBreakNameKey];
        
          [_mdict_info_data setValue:@"0" forKey:kOperactionCounterKey];
          [_mdict_info_data setValue:@"0" forKey:kOperactionSinceResetKey];
          [_mdict_info_data setValue:@"N/A" forKey:kSDCounterKey];
          [_mdict_info_data setValue:@"0" forKey:kSDECounterKey];
        
        NSMutableArray*contactWear_array= [[NSMutableArray alloc] init];
        
        [contactWear_array addObject:[NSNumber numberWithInt:32768]];
        [contactWear_array addObject:[NSNumber numberWithInt:32768]];
        [contactWear_array addObject:[NSNumber numberWithInt:32768]];
        [contactWear_array addObject:[NSNumber numberWithInt:32768]];
        
        [_mdict_info_data setValue:contactWear_array forKey:kContactWearRateKey];
        [contactWear_array release];
        
        
        
        NSMutableArray*loadProfileKey_array= [[NSMutableArray alloc] init];
        
        [loadProfileKey_array addObject:[NSNumber numberWithLong:0]];
        [loadProfileKey_array addObject:[NSNumber numberWithLong:0]];
        [loadProfileKey_array addObject:[NSNumber numberWithLong:0]];
        [loadProfileKey_array addObject:[NSNumber numberWithLong:13]];

        
        [_mdict_info_data setValue:loadProfileKey_array forKey:kLoadProfileKey];
        [loadProfileKey_array release];
        
        
        
   
        [self initRightInformationView];
      
    }
    else{

    
    [_obj_modbus readRegistersFrom:8699
                             count:20
                           success:^(NSArray *array){
                               [self processSerialNumber:array];
                               NSLog(@"successed");
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
    }
}

- (void)processSerialNumber:(NSArray *)array
{
    NSArray *arraySerial = [[NSArray alloc] initWithArray:[array subarrayWithRange:NSMakeRange(0, 4)]];
    NSArray *arrayFirm = [[NSArray alloc] initWithArray:[array subarrayWithRange:NSMakeRange(10, 1)]];
    NSArray *arraySerAsc = parseAsc(arraySerial);
    NSMutableString *strSerAsc = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < [arraySerAsc count]; i ++) {
        NSArray *arraySub = [arraySerAsc objectAtIndex:i];
        [strSerAsc appendFormat:@"%c%c",[[arraySub objectAtIndex:0] charValue], [[arraySub objectAtIndex:1] charValue]];
    }
    
    CGFloat floatFirm = [[arrayFirm lastObject] intValue] / 1000.0;
    [_mdict_info_data setValue:strSerAsc forKey:@"Serial No."];
    [_mdict_info_data setValue:[NSString stringWithFormat:@"%.3f",floatFirm] forKey:@"Firmware Version"];
    [self getInCurrent];
}

- (void)getInCurrent
{
    [_obj_modbus readRegistersFrom:8749
                             count:1
                           success:^(NSArray *array){
                               NSLog(@"successed");
                               [_mdict_info_data setValue:[NSString stringWithFormat:@"%dA",
                                                           [[array lastObject] intValue]] forKey:@"In"];
                               [self getHaveM2C];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

- (void)getHaveM2C
{
    [_obj_modbus readRegistersFrom:9842
                             count:1
                           success:^(NSArray *array){
                               if ([[array lastObject] intValue] != 2) {
                                   [_mdict_info_data setValue:@"NO" forKey:@"Have M2C"];
                               } else {
                                   [_mdict_info_data setValue:@"YES" forKey:@"Have M2C"];
                               }
                               
                               [self getCircuitBreakName];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

#pragma mark - getCircuitBreakName -
- (void)getCircuitBreakName
{
    [_obj_modbus readRegistersFrom:9845
                             count:8
                           success:^(NSArray *array){
                               NSMutableString *mstr_break_name = [[NSMutableString alloc] init];
                               NSArray *array_asc = parseAsc([array subarrayWithRange:NSMakeRange(2, 6)]);
                               for (int i = 0; i < [array_asc count]; i ++) {
                                   if ([[array objectAtIndex:0] intValue] == Undisplay_num) {
                                       [mstr_break_name appendFormat:@"N/A"];
                                       break;
                                   }
                                   NSArray *sub_value = [array_asc objectAtIndex:i];
                                   [mstr_break_name appendFormat:@"%c%c",
                                    [[sub_value objectAtIndex:0] charValue],
                                    [[sub_value objectAtIndex:1] charValue]];
                               }
                               
                               [_mdict_info_data setValue:mstr_break_name forKey:kCircuitBreakNameKey];
                               [mstr_break_name release];
                               [self getSDECount];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

#pragma mark - SDE Count -
- (void)getSDECount
{
    [_obj_modbus readRegistersFrom:12206
                             count:12
                           success:^(NSArray *array){
                               [self processSDECountData:array];
                           } failure:^(NSError *error){
                               NSLog(@"failed");
                           }];
}

- (void)processSDECountData:(NSArray *)array
{
    for (int i = 0; i < 4; i ++) {
        int int_value = [[array objectAtIndex:i] intValue];
        NSString *str_value = (int_value == Undisplay_num) ? @"N/A" : [NSString stringWithFormat:@"%d",int_value];
        [_mdict_info_data setValue:str_value forKey:[_array_check_keys objectAtIndex:7 + i]];
    }
    
    NSArray *array_wear = [[NSArray alloc] initWithArray:[array subarrayWithRange:NSMakeRange(8, 4)]];
    [_mdict_info_data setValue:array_wear forKey:kContactWearRateKey];
    [array_wear release];
    
    [self loadProfileCounters];
}

- (void)loadProfileCounters
{
    [_obj_modbus readRegistersFrom:29879
                             count:8
                           success:^(NSArray *array){
                               NSLog(@"123");
                               NSMutableArray *marray = [[NSMutableArray alloc] init];
                               for (int i = 0; i < [array count]; i += 2) {
                                   long value = [[array objectAtIndex:i] intValue] * 65536 +
                                                        [[array objectAtIndex:i + 1] intValue];
                                   [marray addObject:[NSNumber numberWithLong:value]];
                               }
                               [_mdict_info_data setValue:marray forKey:kLoadProfileKey];
                               [marray release];
                               
                               [self initRightInformationView];
                           } failure:^(NSError *error){
                               
                           }];
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

@end
