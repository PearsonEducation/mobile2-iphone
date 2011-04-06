//
//  UIImageUtilities.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/6/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "UIImageUtilities.h"


@implementation UIImage (UIImageUtilities)

// from: http://stackoverflow.com/questions/1223340/iphone-how-do-you-color-an-image

- (UIImage *)imageWithOverlayColor:(UIColor *)color
{        
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = self.scale;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    [self drawInRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
