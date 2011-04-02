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


@implementation GradientCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef darkColor = [HEXCOLOR(0x00244C) CGColor];
    CGColorRef lightColor = [HEXCOLOR(0x00629D) CGColor];
    
    CGRect paperRect = self.bounds;
    
    drawLinearGradient(context, paperRect, lightColor, darkColor);
}

- (void)dealloc
{
    [super dealloc];
}

@end
