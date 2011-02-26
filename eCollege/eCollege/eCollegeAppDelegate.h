//
//  eCollegeAppDelegate.h
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LogInViewController;

@interface eCollegeAppDelegate : NSObject <UIApplicationDelegate> {

}

+ (eCollegeAppDelegate *) delegate;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LogInViewController *logInViewController;

- (void) dismissLoginView;

@end
