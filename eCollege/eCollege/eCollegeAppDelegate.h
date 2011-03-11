//
//  eCollegeAppDelegate.h
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "PeopleViewController.h"
#import "CoursesViewController.h"
#import "DiscussionsViewController.h"

@class LogInViewController;

@interface eCollegeAppDelegate : NSObject <UIApplicationDelegate> {
    UITabBarController* tabBarController;
    HomeViewController* homeViewController;
    ProfileViewController* profileViewController;
    PeopleViewController* peopleViewController;
    CoursesViewController* coursesViewController;
    DiscussionsViewController* discussionsViewController;
}

+ (eCollegeAppDelegate *) delegate;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LogInViewController *logInViewController;

- (void)dismissLoginView;

@end
