//
//  ISystemViewController.h
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemCell.h"
#import "BaseViewController.h"
#import "DeviceManagerView.h"
#import "CommunicationManager.h"

@interface ISystemViewController : BaseViewController <UIScrollViewDelegate, SystemCellDelegate,
                                                        DeviceConnecteDelected,DeviceManagerViewDelegate>

@end
