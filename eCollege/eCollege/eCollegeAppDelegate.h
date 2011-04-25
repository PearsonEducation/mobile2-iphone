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
#import "Course.h"
#import "CourseFetcher.h"
#import "User.h"
#import "BlockingActivityView.h"
#import "UserFetcher.h"

@class LogInViewController, SingleSignOnViewController;

extern NSString* courseLoadSuccess;
extern NSString* courseLoadFailure;
extern int coursesRefreshInterval;

@interface eCollegeAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UITabBarController* tabBarController;
    HomeViewController* homeViewController;
    ProfileViewController* profileViewController;
    PeopleViewController* peopleViewController;
    CoursesViewController* coursesViewController;
    DiscussionsViewController* discussionsViewController;
	SingleSignOnViewController *ssoViewController;
    NSDictionary* coursesDictionary;
    NSArray* coursesArray;
    CourseFetcher* courseFetcher;
    NSDate* coursesLastUpdated;
    User* currentUser;
    BOOL loginShowing;
    BlockingActivityView* blockingActivityView;
}

+ (eCollegeAppDelegate *) delegate;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSArray* coursesArray;
@property (nonatomic, retain) NSDate* coursesLastUpdated;
@property (nonatomic, retain) User* currentUser;

- (void)dismissLoginView;
- (void) singleSignOnComplete;
- (Course*)getCourseHavingId:(NSInteger)courseId;
- (void)refreshCourseList;
- (BOOL)shouldRefreshCourses;
- (NSArray*) getAllCourseIds;
- (void)showGlobalLoader;
- (void)hideGlobalLoader;
- (void) authenticationComplete;
- (void) signOut;

@end
