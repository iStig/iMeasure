//
//  SMRotaryWheel.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>

@protocol SMRotaryProtocol <NSObject>

- (void) wheelDidChangeValue:(NSString *)newValue;

@end

@interface SMRotaryWheel : UIControl
{
    NSArray *_arrayDescription;
}

@property (nonatomic,retain) NSArray *arrayDescription;
@property (nonatomic,assign) id <SMRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, retain) NSMutableArray *cloves;
@property int currentValue;


- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber;


@end
