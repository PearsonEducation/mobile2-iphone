//
//  FourColorGradientView.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "FourColorGradientView.h"
#import "UIColor+Boost.h"
#import "DrawGradient.h"
#import "UIColor+Boost.h"

@implementation FourColorGradientView

@synthesize midColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set a default (make it obvious)
        self.midColor = [UIColor yellowColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGColorRef darkColor = [[midColor colorDarkerByPercent:55] CGColor];
    CGColorRef darkMidColor = [[midColor colorDarkerByPercent:2] CGColor];
    CGColorRef lightMidColor = [midColor CGColor];
    CGColorRef lightColor = [[midColor colorBrighterByPercent:55] CGColor];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect paperRect = self.bounds;
    
    //drawLinearGradient(context, paperRect, lightColor, darkColor);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 0.5, 0.5, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)lightColor, (id)lightMidColor, (id)darkMidColor, (id)darkColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(paperRect), CGRectGetMinY(paperRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(paperRect), CGRectGetMaxY(paperRect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, paperRect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)dealloc
{
    self.midColor = nil;
    [super dealloc];
}

@end
