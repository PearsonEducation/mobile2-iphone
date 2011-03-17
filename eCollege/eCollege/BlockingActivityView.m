//
//  BlockingActivityView.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/11/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "BlockingActivityView.h"
#import <QuartzCore/CoreAnimation.h>

@implementation BlockingActivityView

- (id)initWithWithView:(UIView*)v {
    if ((self = [super init]) != nil) {
        view = v;
        count = 0;
    }
    return self;
}

- (void)show {
    if (!view) {
        return;
    }
    count += 1;
    if (count == 1) {
        
        // create the view the prevents the user from touching whatever is behind the activitiy viewer
        blockingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.width)];
        
        // create the rounded grey box
        int width = 125;
        int height = 125;
        float x = (view.bounds.size.width/2) - (width/2);
        float y = (view.bounds.size.height/2) - (height/2);
        UIView* activityView = [[UIView alloc] initWithFrame: CGRectMake(x, y, width, height)];
        activityView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        CALayer *layer = activityView.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 20.0;
        
        // create the actual activity spinner
        UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(activityView.bounds.size.width / 2 - 12, activityView.bounds.size.height / 2 - 12, 24, 24)];
        activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [activityWheel startAnimating];
        
        // add the spinner to the grey box, the grey box to the blocking view, and the blocking view to the window
        [activityView addSubview:activityWheel];
        [blockingView addSubview:activityView];
        [view addSubview:blockingView];
        
        // clean up some memory
        [activityWheel release];
        [activityView release];
        [blockingView release];
    }
}

-(void)hide {
    if (!view || count == 0) {
        return;
    }
    count -= 1;
    if (count == 0) {
        [blockingView removeFromSuperview];
    }    
}


- (void)dealloc {
    [view release];
    [super dealloc];
}

@end
