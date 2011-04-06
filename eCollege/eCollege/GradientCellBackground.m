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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef darkColor = [[midColor colorDarkerByPercent:25] CGColor];
    CGColorRef lightColor = [[midColor colorBrighterByPercent:25] CGColor];
    CGRect paperRect = self.bounds;
    //    CGColorRef darkColor = [HEXCOLOR(0x00244C) CGColor];
    //    CGColorRef lightColor = [HEXCOLOR(0x00629D) CGColor];
    drawLinearGradient(context, paperRect, lightColor, darkColor);
}

- (void)dealloc
{
    self.midColor = nil;
    [super dealloc];
}

@end
