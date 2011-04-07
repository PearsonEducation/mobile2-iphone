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
#import <QuartzCore/CoreAnimation.h>

@implementation GreyTableHeader

- (id)initWithText:(NSString*)text {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 30)];
    if (self) {
        // Initialization code
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        
        GradientCellBackground* headerView = [[[GradientCellBackground alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
        headerView.darkColor = HEXCOLOR(0x838383);
        headerView.lightColor = HEXCOLOR(0x555555);

        UIView* bottomStroke = [[[UIView alloc] initWithFrame:CGRectMake(0, 30, 320, 1)] autorelease];
        bottomStroke.backgroundColor = HEXCOLOR(0x656565);
        [headerView addSubview:bottomStroke];
        
        UIView* topStroke = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, 320, 1)] autorelease];
        topStroke.backgroundColor = HEXCOLOR(0x838383);
        [headerView addSubview:topStroke];

        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(13, 0, 297, 30)] autorelease];
        label.textAlignment = UITextAlignmentLeft;
        label.font = [config mediumBoldFont];
        label.textColor = [config whiteColor];
        label.backgroundColor = [UIColor clearColor];        
        label.layer.shadowColor = [[UIColor blackColor] CGColor];
        label.layer.shadowRadius = 1.0;
        label.layer.shadowOpacity = 0.9;
        label.layer.shadowOffset = CGSizeMake(0, -1);    
        label.text = text;
        [headerView addSubview:label];
                
        [self addSubview:headerView];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
