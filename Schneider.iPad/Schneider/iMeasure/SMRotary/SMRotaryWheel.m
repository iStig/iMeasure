//
//  SMRotaryWheel.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import "SMRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>
#import "SMCLove.h"

@interface SMRotaryWheel()
    - (void)drawWheel;
    - (float) calculateDistanceFromCenter:(CGPoint)point;
    - (void) buildClovesEven;
    - (void) buildClovesOdd;
    - (UIImageView *) getCloveByValue:(int)value;
    - (NSString *) getCloveName:(int)position;
@end

static float deltaAngle;
static float minAlphavalue = 0.6;
static float maxAlphavalue = 1.0;

@implementation SMRotaryWheel

@synthesize delegate, container, numberOfSections, startTransform, cloves, currentValue;
@synthesize arrayDescription = _arrayDescription;

- (void)dealloc
{
    [_arrayDescription release];
    [cloves release];
    [container release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber {
    
    if ((self = [super initWithFrame:frame])) {
        self.currentValue = 0;
        self.numberOfSections = sectionsNumber;
        self.delegate = del;
		//[self drawWheel];
	}
    return self;
}

- (void)setArrayDescription:(NSArray *)arrayDescription
{
    [_arrayDescription release];
    _arrayDescription =  [arrayDescription retain];
    
    [self drawWheel];
}

- (void) drawWheel {

    container = [[UIView alloc] initWithFrame:self.bounds];
        
    CGFloat angleSize = 2*M_PI/numberOfSections;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        /*
            tan 18 = x / r
            x = r * tan 18
         */
        CGFloat height =floorf((self.frame.size.width / 2) * tan(angleSize / 2) * 2);
        
        UIImageView *im = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, height)];
        im.image = [UIImage imageNamed:@"round_36_1.png"];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5);
        im.layer.position = CGPointMake(container.bounds.size.width/2.0-container.frame.origin.x, 
                                        container.bounds.size.height/2.0-container.frame.origin.y); 
        im.transform = CGAffineTransformMakeRotation(M_PI + angleSize*i);
        im.alpha = minAlphavalue;
        im.tag = i;
    
        if (i == 0) {
            im.alpha = maxAlphavalue;
        }
        
        //UIImageView *cloveImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 40, 40)];
        //cloveImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%i.png", i]];
        //[im addSubview:cloveImage];
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 150, 30)];
        lblTitle.textAlignment = UITextAlignmentCenter;
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.transform = CGAffineTransformMakeRotation(M_PI);
        if (i < [_arrayDescription count]) {
            lblTitle.text = [_arrayDescription objectAtIndex:i];
        }
        [im addSubview:lblTitle];
        [lblTitle release];

        [container addSubview:im];
    }
    
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    
    cloves = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    
    //UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    //bg.image = [UIImage imageNamed:@"bg.png"];
    //[self addSubview:bg];
    
    //UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    //mask.image =[UIImage imageNamed:@"centerButton.png"] ;
    //mask.center = self.center;
    //mask.center = CGPointMake(mask.center.x, mask.center.y+3);
    //[self addSubview:mask];
    
    if (numberOfSections % 2 == 0) {
        
        [self buildClovesEven];
        
    } else {
        
        [self buildClovesOdd];
        
    }
    
    [self.delegate wheelDidChangeValue:[self getCloveName:currentValue]];

    
}


- (UIImageView *) getCloveByValue:(int)value {

    UIImageView *res;
    
    NSArray *views = [container subviews];
    
    for (UIImageView *im in views) {
        
        if (im.tag == value)
            res = im;
        
    }
    
    return res;
    
}

- (void) buildClovesEven {
    
    CGFloat fanWidth = M_PI*2/numberOfSections;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        
        if (clove.maxValue-fanWidth < - M_PI) {
            
            mid = M_PI;
            clove.midValue = mid;
            clove.minValue = fabsf(clove.maxValue);
            
        }
        
        mid -= fanWidth;
        
        
        NSLog(@"cl is %@", clove);
        
        [cloves addObject:clove];
        
    }
    
}


- (void) buildClovesOdd {
    
    CGFloat fanWidth = M_PI*2/numberOfSections;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        mid -= fanWidth;
        
        if (clove.minValue < - M_PI) {
            
            mid = -mid;
            mid -= fanWidth; 
            
        }
        
                
        [cloves addObject:clove];
        
        NSLog(@"cl is %@", clove);
        
    }
    
}

- (float) calculateDistanceFromCenter:(CGPoint)point {
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx*dx + dy*dy);
    
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self calculateDistanceFromCenter:touchPoint];
    
    if (dist < 0 || dist > self.frame.size.width / 2)
    {
        // forcing a tap to be on the ferrule
        NSLog(@"ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    
	float dx = touchPoint.x - container.center.x;
	float dy = touchPoint.y - container.center.y;
	deltaAngle = atan2(dy,dx); 
    
    startTransform = container.transform;
    
    UIImageView *im = [self getCloveByValue:currentValue];
    im.alpha = minAlphavalue;
    
    return YES;
    
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
        
	CGPoint pt = [touch locationInView:self];
    
    float dist = [self calculateDistanceFromCenter:pt];
    
    if (dist < 0 || dist > self.frame.size.width / 2) 
    {
        // a drag path too close to the center
        NSLog(@"drag path too close to the center (%f,%f)", pt.x, pt.y);
        
        // here you might want to implement your solution when the drag 
        // is too close to the center
        // You might go back to the clove previously selected
        // or you might calculate the clove corresponding to
        // the "exit point" of the drag.

    }
	
	float dx = pt.x  - container.center.x;
	float dy = pt.y  - container.center.y;
	float ang = atan2(dy,dx);
    
    float angleDifference = deltaAngle - ang;
    
    container.transform = CGAffineTransformRotate(startTransform, -angleDifference);
    
    return YES;
	
}

- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    
    CGFloat newVal = 0.0;
    
    for (SMClove *c in cloves) {
        
        if (c.minValue > 0 && c.maxValue < 0) { // anomalous case
            
            if (c.maxValue > radians || c.minValue < radians) {
                
                if (radians > 0) { // we are in the positive quadrant
                    
                    newVal = radians - M_PI;
                    
                } else { // we are in the negative one
                    
                    newVal = M_PI + radians;                    
                    
                }
                currentValue = c.value;
                
            }
            
        }
        
        else if (radians > c.minValue && radians < c.maxValue) {
            
            newVal = radians - c.midValue;
            currentValue = c.value;
            
        }
        
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    
    [UIView commitAnimations];
    
    [self.delegate wheelDidChangeValue:[self getCloveName:currentValue]];
    
    UIImageView *im = [self getCloveByValue:currentValue];
    im.alpha = maxAlphavalue;
    
}

- (NSString *) getCloveName:(int)position {
    return [_arrayDescription objectAtIndex:position];
}



@end
