//
//  ProtectionGraphView.m
//  Schneider
//
//  Created by GongXuehan on 13-4-28.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "ProtectionGraphView.h"

NSString *const kIrKey = @"Ir";
NSString *const kTrKey = @"Tr";
NSString *const kIsdKey = @"Isd";
NSString *const kTsdKey = @"Tsd";
NSString *const kIiKey = @"Ii";
NSString *const kInKey = @"In";

#define Left_Margin 30
#define Bottom_Margin 50

#define Custom_Height_Offset -50
#define Custom_Width_Offset -10
#define I_Count 10
#define T_Count 10

@interface ProtectionGraphView()
{
    NSDictionary *_dict_values;
    CGFloat      _version;
    CGFloat      _x_step;
    CGFloat      _y_step;
}
@property (nonatomic, retain) NSDictionary *dict_values;

@end

@implementation ProtectionGraphView
@synthesize dict_values = _dict_values;

- (void)dealloc
{
    [_dict_values release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
             values:(NSDictionary *)values
            version:(CGFloat)version
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dict_values = values;
        _version = version;
        self.backgroundColor = [UIColor grayColor];
        
        _x_step = (self.frame.size.width - Left_Margin * 2) / I_Count;
        _y_step = (self.frame.size.height - Bottom_Margin * 2) / T_Count;
    }
    return self;
}

#pragma mark - Long time protection -
- (NSArray *)calculationCoordinates
{
    CGFloat Ir = [[_dict_values objectForKey:kIrKey] floatValue];
    CGFloat Isd = [[_dict_values objectForKey:kIsdKey] floatValue];
    CGFloat Tsd = [[_dict_values objectForKey:kTsdKey] floatValue];
    
    BOOL is_on = YES;
    if (Tsd < 0.1) {
        is_on = NO;
        Tsd *= 10;
    }
    
    ///根据公式推算坐标
    NSMutableArray *marrayPoint = [[NSMutableArray alloc] init];
    for (float i = Ir + 0.005; i < Isd * Ir; i += 0.005) {
        CGPoint point = CGPointZero;
        point.x = i;
        point.y = Tsd / ((i / Ir + 1) * (i / Ir - 1));
        
        CGPoint real_point = CGPointZero;
        real_point.x = Left_Margin + point.x * _x_step;
        real_point.y = (self.frame.size.height - Bottom_Margin) - point.y * _y_step * 10 + Custom_Height_Offset;
        [marrayPoint addObject:[NSValue valueWithCGPoint:real_point]];
    }
    return [marrayPoint autorelease];
}

- (void)drawDottedLineFrom:(CGPoint)start to:(CGPoint)end context:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGFloat dashArray[] = {2,6,4,2};
    CGContextSetLineDash(context, 3, dashArray, 4);//跳过3个再画虚线，所以刚开始有6-（3-2）=5个虚点
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddQuadCurveToPoint(context, end.x, end.y, end.x, end.y);
    CGContextStrokePath(context);
}

- (void)drawTitle:(NSString *)title atFrame:(CGPoint)center font:(UIFont *)font
{
    CGSize size_0 = [title sizeWithFont:font];
    CGRect zero = CGRectMake(center.x, center.y, size_0.width, size_0.height);
    [title drawInRect:zero withFont:font];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGPoint last_point = CGPointZero;
    UIFont *font = [UIFont systemFontOfSize:22];
    ///画坐标系
    CGPoint  max_y_point = CGPointMake(Left_Margin, Bottom_Margin);
    CGPoint  origin_point = CGPointMake(Left_Margin, rect.size.height - Bottom_Margin);
    CGPoint  max_x_point = CGPointMake(rect.size.width - Left_Margin, origin_point.y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
    CGContextMoveToPoint(context, max_y_point.x, max_y_point.y);
    CGContextAddLineToPoint(context, origin_point.x, origin_point.y);
    CGContextAddLineToPoint(context, max_x_point.x, max_x_point.y);
    CGContextStrokePath(context);
    
    //画上箭头
    UIImage *imageV = [UIImage imageNamed:@"arrow_v.png"];
    CGRect rect_v = CGRectMake(Left_Margin - (imageV.size.width / 2),
                               Bottom_Margin - imageV.size.height,
                               imageV.size.width, imageV.size.height);
    [imageV drawInRect:rect_v];
    
    UIImage *imageH = [UIImage imageNamed:@"arrow_h.png"];
    CGRect rect_h = CGRectMake(max_x_point.x,
                               origin_point.y - imageH.size.height / 2,
                               imageH.size.width, imageH.size.height);
    [imageH drawInRect:rect_h];
    
    ///画坐标系的原点和单位
    NSString *str_0 = @"0";
    CGSize size_0 = [str_0 sizeWithFont:font];
    CGRect zero = CGRectMake(Left_Margin - size_0.width / 2, origin_point.y, size_0.width, size_0.height);
    [str_0 drawInRect:zero withFont:font];
    ///draw unit of y axis
    NSString *str_t = @"t";
    rect_v.origin.x -= [str_t sizeWithFont:font].width;
    [str_t drawInRect:rect_v withFont:font];
    ///draw unit of x axis
    NSString *str_i = @"I";
    rect_h.origin.y += [str_i sizeWithFont:font].height;
    [str_i drawInRect:rect_h withFont:font];
        
    /*
        2 kinds of graph
        _version == 5.0
     */
    if (_version) {
        NSArray *arrayPoint = [self calculationCoordinates];
        
        ///1.draw v line at ir
        CGPoint zero_p = [[arrayPoint objectAtIndex:0] CGPointValue];
        CGContextSetLineWidth(context, 2);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
        CGContextMoveToPoint(context, zero_p.x, zero_p.y);
        CGContextAddLineToPoint(context, zero_p.x, 0);
        CGContextStrokePath(context);
        
        ///画虚线 写title
        ///Ir
        [self drawDottedLineFrom:CGPointMake(zero_p.x, 0)
                              to:CGPointMake(zero_p.x, self.frame.size.height)
                         context:context];
        [self drawTitle:@"Ir"
                atFrame:CGPointMake(zero_p.x, self.frame.size.height - size_0.height)
                   font:font];
        ///Isd
        CGPoint last_point = [[arrayPoint lastObject] CGPointValue];
        [self drawDottedLineFrom:CGPointMake(last_point.x, 0)
                              to:CGPointMake(last_point.x, self.frame.size.height)
                         context:context];
        [self drawTitle:@"Isd"
                atFrame:CGPointMake(last_point.x, self.frame.size.height - size_0.height)
                   font:font];
        
        for (int i = 0; i < [arrayPoint count]; i ++) {
            CGPoint point = [[arrayPoint objectAtIndex:i] CGPointValue];
            CGRect ellipseRect = CGRectMake(point.x - 1, point.y - 1, 2, 2);
            CGContextAddEllipseInRect(context, ellipseRect);
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
            CGContextFillEllipseInRect(context, ellipseRect);
            CGContextStrokeEllipseInRect(context, ellipseRect);
        }
        
        ///short
        CGFloat Isd = [[_dict_values objectForKey:kIsdKey] floatValue];
        CGFloat Tsd = [[_dict_values objectForKey:kTsdKey] floatValue];
        CGFloat Ir = [[_dict_values objectForKey:kIrKey] floatValue];
        BOOL is_on = Tsd < 0.1 ? NO : YES;
        Tsd *= 10;
        CGFloat Ix = sqrtf(1.1) * Isd * Ir;
        ///short
        CGPoint real_point = CGPointZero;
        if (is_on) {
            CGPoint ix_point = CGPointZero;
            ix_point.x = Ix;
            ix_point.y =  Tsd;//(10 * ((Ix / (Isd * Ir) - 1) * (Ix / (Isd * Ir) + 1)));
            real_point.x = ix_point.x * _x_step + Left_Margin;
            real_point.y = last_point.y + Tsd * _y_step;
            
            CGContextSetLineWidth(context, 2);
            CGContextSetLineDash(context, 0, nil, 0);
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
            CGContextMoveToPoint(context, last_point.x, last_point.y);
            CGContextAddLineToPoint(context, last_point.x, real_point.y);
            CGContextAddLineToPoint(context, real_point.x, real_point.y);
            CGContextStrokePath(context);
        } else {
            ///long
            CGPoint ix_point = CGPointZero;
            ix_point.x = Ix;
            ix_point.y =  Tsd;//(10 * ((Ix / (Isd * Ir) - 1) * (Ix / (Isd * Ir) + 1)));
            real_point.x = ix_point.x * _x_step + Left_Margin;
            real_point.y = last_point.y + Tsd * _y_step;
            
            CGContextSetLineWidth(context, 2.0);
            CGContextSetLineDash(context, 0, nil, 0);
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
            CGContextMoveToPoint(context, last_point.x, last_point.y);
            CGContextAddArcToPoint(context, real_point.x,real_point.y, real_point.x + 10,real_point.y, 10);
            CGContextStrokePath(context);
        }
        last_point = real_point;
        
        ///Ii 的坐标
        CGFloat Ii = [[_dict_values objectForKey:kIiKey] floatValue];
        CGContextSetLineWidth(context, 2);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
        CGContextMoveToPoint(context,last_point.x, last_point.y);
        CGContextAddLineToPoint(context, Ii * _x_step + Left_Margin, last_point.y);
        CGContextStrokePath(context);
        
        [self drawDottedLineFrom:CGPointMake(Ii * _x_step + Left_Margin, 0)
                              to:CGPointMake(Ii * _x_step + Left_Margin, self.frame.size.height)
                         context:context];
        [self drawTitle:@"Ii" atFrame:CGPointMake(Ii * _x_step + Left_Margin, self.frame.size.height - size_0.height)
                   font:font];
        
        last_point.x = Ii * _x_step + Left_Margin;
        CGContextSetLineWidth(context, 2);
        CGContextSetLineDash(context, 0, nil, 0);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
        CGContextMoveToPoint(context, last_point.x, last_point.y);
        CGContextAddLineToPoint(context, last_point.x, real_point.y + _y_step);
        CGContextAddLineToPoint(context, last_point.x + _x_step, real_point.y + _y_step);
        CGContextStrokePath(context);
    } else if (_version == 2.0) {
        
    }
}

@end
