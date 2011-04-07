//
//  GradientCellBackground.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GradientCellBackground : UIView {
    UIColor* midColor;
    UIColor* lightColor;
    UIColor* darkColor;
}

@property (nonatomic, retain) UIColor* midColor;
@property (nonatomic, retain) UIColor* lightColor;
@property (nonatomic, retain) UIColor* darkColor;

@end
