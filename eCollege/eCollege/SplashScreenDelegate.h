//
//  SplashScreenDelegate.h
//  eCollege
//
//  Created by Tony Hillerson on 4/7/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

@class SplashScreenViewController;

@protocol SplashScreenDelegate <NSObject>
@optional
- (void)splashScreenDidAppear:(SplashScreenViewController *)splashScreen;
- (void)splashScreenWillDisappear:(SplashScreenViewController *)splashScreen;
- (void)splashScreenDidDisappear:(SplashScreenViewController *)splashScreen;
@end

