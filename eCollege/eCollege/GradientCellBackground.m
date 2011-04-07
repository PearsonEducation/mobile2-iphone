//
//  GradientCellBackground.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "GradientCellBackground.h"
#import "UIColor+Boost.h"
#import "DrawGradient.h"
#import "UIColor+Boost.h"


@implementation GradientCellBackground

@synthesize lightColor;
@synthesize midColor;
@synthesize darkColor;

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
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGColorRef cgDarkColor;
    CGColorRef cgLightColor;

    if (!lightColor) {
        cgLightColor = [[midColor colorBrighterByPercent:25] CGColor];        
    } else {
        cgLightColor = [lightColor CGColor];
    }
    
    if (!darkColor) {
        cgDarkColor = [[midColor colorDarkerByPercent:25] CGColor];
    } else {
        cgDarkColor = [darkColor CGColor];
    }
    
    CGRect paperRect = self.bounds;
    drawLinearGradient(context, paperRect, cgLightColor, cgDarkColor);
}

- (void)dealloc
{
    self.lightColor = nil;
    self.midColor = nil;
    self.darkColor = nil;
    [super dealloc];
}

@end
