//
//  DrawDiagram.m
//  Schneider
//
//  Created by GongXuehan on 13-6-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "DrawDiagram.h"
#import "ProtectionGraphView.h"

#define Left_Margin 0
#define Bottom_Margin 0

#define Custom_Height_Offset -300
#define I_Count 20
#define T_Count 100
#define Chart_Content_Frame CGRectMake(105, 26, 647, 498)
#define Content_Width(d) (105 + (d))
#define Content_Height(d) ((d))

#define Content_Origin_y 26.0f
#define Dotted_Offset -70

@interface DrawDiagram()
{
    CGFloat      _x_step;
    CGFloat      _y_step;
    CGFloat      _version;
    
    NSArray      *_array_color;
    
    NSMutableArray *_marray_values;
}

@property (nonatomic, retain) NSArray *array_color;
@end

@implementation DrawDiagram
@synthesize dict_chart_info = _dict_chart_info;
@synthesize array_color = _array_color;

- (void)dealloc
{
    [_marray_values release];
    [_array_color release];
    [_dict_chart_info release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
         chart_info:(NSDictionary *)dict
            version:(NSString *)version
            color:(NSArray *)array_color_values
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dict_chart_info = dict;
        _marray_values = [[NSMutableArray alloc] init];
        _version = [[[version componentsSeparatedByString:@"_"] objectAtIndex:1] floatValue];
        self.array_color = array_color_values;
        
        _x_step = Chart_Content_Frame.size.width / I_Count;
        _y_step = Chart_Content_Frame.size.height / T_Count;
    }
    return self;
}

#pragma mark - Long time protection -
- (NSArray *)calculationCoordinates
{
    CGFloat Ir = [[_dict_chart_info objectForKey:kIrKey] floatValue];
    CGFloat Isd = [[_dict_chart_info objectForKey:kIsdKey] floatValue];
    CGFloat Tr = [[_dict_chart_info objectForKey:kTrKey] floatValue];
     
    ///根据公式推算坐标
    /*
        t = tr/ [(I/Ir)*(I/Ir)] - 1
     */
    NSMutableArray *marrayPoint = [[NSMutableArray alloc] init];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    for (float i = Ir + 0.05; i < Isd * Ir + 0.05; i += 0.05) {
        CGPoint point = CGPointZero;	
        point.x = i;
        point.y = (-Tr / 0.029) * (log10f(1 - (1 / ((i / Ir) * (i / Ir)))));//Tr / ((i / Ir) * (i / Ir) - 1);
        
        [marray addObject:[NSValue valueWithCGPoint:point]];
        
        CGPoint real_point = CGPointZero;
        real_point.x = point.x * _x_step;
        real_point.y = self.frame.size.height - point.y * _y_step + Custom_Height_Offset;
        [marrayPoint addObject:[NSValue valueWithCGPoint:real_point]];
    }
    return [marrayPoint autorelease];
}

- (void)setChartColor:(CGContextRef)context
{
    CGContextSetRGBStrokeColor(context, [[_array_color objectAtIndex:0] floatValue],
                               [[_array_color objectAtIndex:1] floatValue],
                               [[_array_color objectAtIndex:2] floatValue], 1);
}

- (void)drawDottedLineFrom:(CGPoint)start to:(CGPoint)end context:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1.0);
    [self setChartColor:context];
    CGFloat dashArray[] = {2,6,4,2};
    CGContextSetLineDash(context, 3, dashArray, 1);//跳过3个再画虚线，所以刚开始有6-（3-2）=5个虚点
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddQuadCurveToPoint(context, end.x, end.y, end.x, end.y);
    CGContextStrokePath(context);
}

- (void)showTitle:(BOOL)show
{
    for (UIImageView *vImg in _marray_values) {
        if (show) {
            vImg.hidden = NO;
        } else {
            vImg.hidden = YES;
        }
    }
}

- (void)drawTitle:(NSString *)title atFrame:(CGPoint)center font:(UIFont *)font
{
    UIImage *img = [UIImage imageNamed:@"lbl_value_bg.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(center.x - img.size.width / 2, center.y, img.size.width, img.size.height)];
    imgView.image = img;
    [self addSubview:imgView];
    [_marray_values addObject:imgView];
    [imgView release];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:imgView.bounds];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = title;
    [imgView addSubview:lbl];
    [lbl release];
}

- (void)drawKey:(NSString *)key atFrame:(CGPoint)center font:(UIFont *)font
{
    CGSize size = [key sizeWithFont:font];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(center.x , center.y, size.width, size.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = key;
    [self addSubview:lbl];
    [_marray_values addObject:lbl];
    [lbl release];
}

- (void)drawRect:(CGRect)rect
{

    
    /*
     2 kinds of graph
     */
    if (_version != 2.0) {
        // Drawing code
        UIFont *font = [UIFont systemFontOfSize:22];
        CGContextRef context = UIGraphicsGetCurrentContext();
        NSArray *arrayPoint = [self calculationCoordinates];
        ///1.draw v line at ir
        CGPoint zero_p = [[arrayPoint objectAtIndex:0] CGPointValue];
        
        ////画出Ir - Isd
        CGContextSetLineDash(context, 0, nil, 0);
        CGContextMoveToPoint(context, Content_Width(zero_p.x), Content_Height(zero_p.y));
        [self setChartColor:context];//线条颜色
        CGContextSetLineWidth(context, 2);
        for (int i = 0; i < [arrayPoint count]; i ++) {
            CGPoint point = [[arrayPoint objectAtIndex:i] CGPointValue];
            CGContextAddLineToPoint(context, Content_Width(point.x), Content_Height(point.y));
        }
        CGContextStrokePath(context);

        ///short
        CGFloat Isd = [[_dict_chart_info objectForKey:kIsdKey] floatValue];
        CGFloat Tsd = [[_dict_chart_info objectForKey:kTsdKey] floatValue];
        CGFloat Ir = [[_dict_chart_info objectForKey:kIrKey] floatValue];
        CGFloat In = [[_dict_chart_info objectForKey:kInKey] floatValue];
        CGFloat tr = [[_dict_chart_info objectForKey:kTrKey] floatValue];
        
        ///画虚线 写title
        ///Ir
        [self drawDottedLineFrom:CGPointMake(Content_Width(zero_p.x), 0)
                              to:CGPointMake(Content_Width(zero_p.x), self.frame.size.height+Dotted_Offset)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.0f A",Ir * In]
                atFrame:CGPointMake(Content_Width(zero_p.x), self.frame.size.height+Dotted_Offset)
                   font:font];
        [self drawKey:@"Ir" atFrame:CGPointMake(Content_Width(zero_p.x), self.frame.size.height - 95) font:font];

        ///Isd
        CGPoint last_point = [[arrayPoint lastObject] CGPointValue];
        [self drawDottedLineFrom:CGPointMake(Content_Width(last_point.x), 0)
                              to:CGPointMake(Content_Width(last_point.x), self.frame.size.height+Dotted_Offset)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.0f A",Isd * Ir * In]
                atFrame:CGPointMake(Content_Width(last_point.x), self.frame.size.height+Dotted_Offset)
                   font:font];
        [self drawKey:@"Isd" atFrame:CGPointMake(Content_Width(last_point.x), self.frame.size.height - 95) font:font];

        [self drawDottedLineFrom:CGPointMake(Content_Width(-55), last_point.y / 2)
                              to:CGPointMake(Content_Width(self.frame.size.width), last_point.y / 2)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.1f s",tr]
                atFrame:CGPointMake(Content_Width(-55), last_point.y / 2)
                   font:font];
        [self drawKey:@"Tr" atFrame:CGPointMake(Content_Width(0), last_point.y / 2 - 20) font:font];

               
        CGFloat tsd = Tsd < 0.1 ? Tsd * 10 : Tsd;
        BOOL is_on = Tsd < 0.1 ? NO : YES;
        if (!is_on) {
            Tsd *= 10;
        }
        CGFloat Ix = sqrtf(1.1) * Isd * Ir;
        
        ///short
        CGPoint real_point = CGPointZero;
        if (is_on) {
            ///long
            CGContextSetLineDash(context, 0, nil, 0);
            CGContextMoveToPoint(context, Content_Width(last_point.x),
                                 Content_Height(last_point.y));
            [self setChartColor:context];//线条颜色
            
            CGFloat Ii = [[_dict_chart_info objectForKey:kIiKey] floatValue];
            
            for (CGFloat i = Isd * Ir + 0.05; i < Ii; i += 0.05) {
                CGPoint point = CGPointZero;
                point.x = i;
                CGFloat t = -(tsd / (-log10(1 - (((Isd * Ir) / (11 * Ir)) * ((Isd * Ir) / (11 * Ir)))))) * log10f(1 - (Isd * Ir / i) * (Isd * Ir / i));
                point.y = -t * log10(1 - (Isd*Ir / i) * (Isd*Ir / i));
                real_point.x = point.x * _x_step;
                
                real_point.y = (self.frame.size.height - point.y * _y_step + Custom_Height_Offset / 2);
                CGContextAddLineToPoint(context, Content_Width(real_point.x), Content_Height(real_point.y));
            }
            CGContextSetLineWidth(context, 2);
            CGContextStrokePath(context);
            last_point = real_point;
        } else {
            CGPoint ix_point = CGPointZero;
            ix_point.x = Ix;
            ix_point.y =  Tsd;
            real_point.x = ix_point.x * _x_step;
            real_point.y = last_point.y + Tsd * _y_step;
            
            CGFloat Ii = [[_dict_chart_info objectForKey:kIiKey] floatValue];

            CGContextSetLineWidth(context, 2);
            CGContextSetLineDash(context, 0, nil, 0);
            [self setChartColor:context];//线条颜色
            CGContextMoveToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y));
            CGContextAddLineToPoint(context, Content_Width(last_point.x), Content_Height(real_point.y + 20));
            CGContextAddLineToPoint(context, Content_Width(Ii *_x_step), Content_Height(real_point.y + 20));
            CGContextAddLineToPoint(context, Content_Width(Ii *_x_step), Content_Height(real_point.y + 40));
            CGContextStrokePath(context);
            
            last_point.x = real_point.x;
            last_point.y = real_point.y + 20;
        }
        
        ///Ii 的坐标
        CGFloat Ii = [[_dict_chart_info objectForKey:kIiKey] floatValue];
        last_point.x = Ii *_x_step;
        
        [self drawDottedLineFrom:CGPointMake(Content_Width(-55), last_point.y)
                              to:CGPointMake(Content_Width(self.frame.size.width), last_point.y)
                         context:context];
        
        [self drawTitle:[NSString stringWithFormat:@"%.1f s",tsd]
                atFrame:CGPointMake(Content_Width(-55), last_point.y)
                   font:font];
        [self drawKey:@"Tsd" atFrame:CGPointMake(Content_Width(0), last_point.y - 25) font:font];

        
        
//        CGContextSetLineWidth(context, 2);
//        [self setChartColor:context];//线条颜色
//        CGContextMoveToPoint(context,Content_Width(last_point.x), Content_Height(last_point.y));
//        CGContextAddLineToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y + 20));
//        CGContextStrokePath(context);
//        last_point.y += 20;
        
        
        [self drawDottedLineFrom:CGPointMake(Content_Width(Ii * _x_step), Content_Height(0))
                              to:CGPointMake(Content_Width(Ii * _x_step), self.frame.size.height+Dotted_Offset)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.0f A",Ii * In] atFrame:CGPointMake(Content_Width(Ii * _x_step),
                                                  self.frame.size.height+Dotted_Offset)
                                                    font:font];
        [self drawKey:@"Ii" atFrame:CGPointMake(Content_Width(Ii * _x_step), self.frame.size.height - 95) font:font];

        CGContextSetLineWidth(context, 2);
        [self setChartColor:context];//线条颜色
        CGContextMoveToPoint(context,Content_Width(last_point.x), Content_Height(last_point.y));
        CGContextAddLineToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y + 20));
        CGContextStrokePath(context);
        last_point.y += 20;
        
        CGContextSetLineWidth(context, 2);
        CGContextSetLineDash(context, 0, nil, 0);
        [self setChartColor:context];//线条颜色
        CGContextMoveToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y));
        CGContextAddLineToPoint(context, Content_Width(last_point.x + _x_step), Content_Height(last_point.y));
        CGContextStrokePath(context);
    }
    else if (_version == 2.0) {
        // Drawing code
        UIFont *font = [UIFont systemFontOfSize:22];
        CGContextRef context = UIGraphicsGetCurrentContext();
        NSArray *arrayPoint = [self calculationCoordinates];
        ///1.draw v line at ir
        CGPoint zero_p = [[arrayPoint objectAtIndex:0] CGPointValue];
        
        ////画出Ir - Isd
        CGContextSetLineDash(context, 0, nil, 0);
        CGContextMoveToPoint(context, Content_Width(zero_p.x), Content_Height(zero_p.y));
        [self setChartColor:context];//线条颜色
        CGContextSetLineWidth(context, 2);
        for (int i = 0; i < [arrayPoint count]; i ++) {
            CGPoint point = [[arrayPoint objectAtIndex:i] CGPointValue];
            CGContextAddLineToPoint(context, Content_Width(point.x), Content_Height(point.y));
        }
        
        
        CGContextStrokePath(context);
        ///short
        
        CGFloat Isd = [[_dict_chart_info objectForKey:kIsdKey] floatValue];
        
        CGFloat Ir = [[_dict_chart_info objectForKey:kIrKey] floatValue];
        
        CGFloat In = [[_dict_chart_info objectForKey:kInKey] floatValue];
        
        CGFloat tr = [[_dict_chart_info objectForKey:kTrKey] floatValue];
        
        ///画虚线 写title
        ///Ir
        [self drawDottedLineFrom:CGPointMake(Content_Width(zero_p.x), 0)
                              to:CGPointMake(Content_Width(zero_p.x), self.frame.size.height+Dotted_Offset)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.0f A",Ir * In]
                atFrame:CGPointMake(Content_Width(zero_p.x), self.frame.size.height+Dotted_Offset)
                   font:font];
        
        [self drawKey:@"Ir" atFrame:CGPointMake(Content_Width(zero_p.x), self.frame.size.height - 95) font:font];
        ///Isd
        CGPoint last_point = [[arrayPoint lastObject] CGPointValue];
        [self drawDottedLineFrom:CGPointMake(Content_Width(last_point.x), 0)
                              to:CGPointMake(Content_Width(last_point.x), self.frame.size.height+Dotted_Offset)
                         context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.0f A",Isd * Ir * In]
                atFrame:CGPointMake(Content_Width(last_point.x), self.frame.size.height+Dotted_Offset)
                   font:font];
       [self drawKey:@"Isd" atFrame:CGPointMake(Content_Width(last_point.x), self.frame.size.height - 95) font:font];
        //Tr
       [self drawDottedLineFrom:CGPointMake(Content_Width(-55), last_point.y / 2)
                             to:CGPointMake(Content_Width(self.frame.size.width), last_point.y / 2)
                        context:context];
        [self drawTitle:[NSString stringWithFormat:@"%.1f s",tr]
                atFrame:CGPointMake(Content_Width(-55), last_point.y / 2)
                   font:font];
        [self drawKey:@"Tr" atFrame:CGPointMake(Content_Width(0), last_point.y / 2 - 20) font:font];


        CGContextSetLineDash(context, 0, nil, 0);
        CGContextSetLineWidth(context, 2);
        [self setChartColor:context];//线条颜色
        CGContextMoveToPoint(context,Content_Width(last_point.x), Content_Height(last_point.y));
        CGContextAddLineToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y + 20));
        CGContextStrokePath(context);
        last_point.y += 20;

        CGContextSetLineWidth(context, 2);
        CGContextSetLineDash(context, 0, nil, 0);
        [self setChartColor:context];//线条颜色
        CGContextMoveToPoint(context, Content_Width(last_point.x), Content_Height(last_point.y));
        CGContextAddLineToPoint(context, Content_Width(last_point.x + _x_step), Content_Height(last_point.y));
        CGContextStrokePath(context);

        
    }
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
