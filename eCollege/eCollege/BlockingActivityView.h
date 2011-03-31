//
//  BlockingActivityView.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/11/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockingActivityView : NSObject {
    UIView* view;
    int count;
    UIView* blockingView;
    UIColor* backgroundColor;
}

@property (nonatomic, retain) UIColor* backgroundColor;

- (id)initWithWithView:(UIView*)view;
- (void)show;
- (void)hide;

@end
