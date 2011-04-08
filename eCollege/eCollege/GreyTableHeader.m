//
//  GreyTableHeader.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/7/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "GreyTableHeader.h"
#import "ECClientConfiguration.h"
#import "GradientCellBackground.h"
#import "UIColor+Boost.h"
#import "DrawGradient.h"
#import <QuartzCore/CoreAnimation.h>

@implementation GreyTableHeader

- (id)initWithText:(NSString*)text {
    self = [super init];
    if (self) {
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];

        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(13, 0, 297, 30)] autorelease];
        label.textAlignment = UITextAlignmentLeft;
        label.font = [config mediumBoldFont];
        label.textColor = [config whiteColor];
        label.backgroundColor = [UIColor clearColor];        
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0, -1);    
        label.text = text;
        [self addSubview:label];
                
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	drawLinearGradient(
					   context,
					   self.bounds,
					   [HEXCOLOR(0x555555) CGColor],
					   [HEXCOLOR(0x838383) CGColor]);
	
	CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [HEXCOLOR(0x838383) CGColor]);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(context);
	CGContextRestoreGState(context);

	CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [HEXCOLOR(0x656565) CGColor]);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);
	CGContextRestoreGState(context);
}

@end
