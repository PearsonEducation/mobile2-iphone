//
//  SplashScreenViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/7/11.
//  
//	Uses code inspired by iOS Recipes, copyright 2011 Pragmatic Programmers
//

#import <UIKit/UIKit.h>
#import "SplashScreenDelegate.h"

@interface SplashScreenViewController : UIViewController {
    
}

@property (nonatomic, retain) UIImage *splashImage;
@property (nonatomic, assign) BOOL showsStatusBarOnDismissal;
@property (nonatomic, assign) BOOL hidesImmediately;
@property (nonatomic, assign) IBOutlet id <SplashScreenDelegate> delegate;

- (void)hide;

@end