//
//  SystemCell.h
//  Schneider
//
//  Created by GongXuehan on 13-4-11.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SystemCellDelegate;

@interface SystemCell : UITableViewCell
{
    id<SystemCellDelegate> _delegate;
    BOOL                   _isSelected;
    
    NSDictionary           *_device_information;
    NSInteger              _device_id;
}

@property (nonatomic, assign) BOOL                   isSelected;
@property (nonatomic, assign) id<SystemCellDelegate> delegate;
@property (nonatomic, retain) NSDictionary           *device_information;
@property (nonatomic, assign) NSInteger              device_id;

@end

@protocol SystemCellDelegate <NSObject>

- (void)systemCellTouchesBegan:(SystemCell *)cell atPoint:(CGPoint)point;
- (void)systemCellTouchesMoved:(SystemCell *)cell toPoint:(CGPoint)point;
- (void)systemCellTouchesEnded:(SystemCell *)cell atPoint:(CGPoint)point;

@end
