//
//  DrawDiagram.h
//  Schneider
//
//  Created by GongXuehan on 13-6-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawDiagram : UIView
{
    NSDictionary *_dict_chart_info;
}

@property (nonatomic, retain) NSDictionary *dict_chart_info;

- (id)initWithFrame:(CGRect)frame
         chart_info:(NSDictionary *)dict
            version:(NSString*)version
            color:(NSArray *)array_color_values;

- (void)showTitle:(BOOL)show;

@end
