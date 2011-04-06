//
//  eCollegeAppDelegate.m
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "eCollegeAppDelegate.h"
#import "LogInViewController.h"
#import "ECSession.h"
#import "NSDateUtilities.h"
#import "DateCalculator.h"
#import "ECConstants.h"
#import "BlockingActivityView.h"
#import "ECClientConfiguration.h"

@interface eCollegeAppDelegate ()

// Private properties
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) HomeViewController* homeViewController;
@property (nonatomic, retain) ProfileViewController* profileViewController;
@property (nonatomic, retain) PeopleViewController* peopleViewController;
@property (nonatomic, retain) CoursesViewController* coursesViewController;
@property (nonatomic, retain) DiscussionsViewController* discussionsViewController;
@property (nonatomic, retain) CourseFetcher* courseFetcher;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;


// Private methods
- (void) showTabBar;
- (void) showLoginView;
- (void) showTabsIfMeAndCoursesLoaded;

@end

NSString* courseLoadSuccess = @"courseLoadSuccess";
NSString* courseLoadFailure = @"courseLoadFailure";
int coursesRefreshInterval = 43200; // 12 hours = 43200 seconds

@implementation eCollegeAppDelegate

@synthesize window=window;
@synthesize logInViewController=logInViewController;
@synthesize tabBarController=tabBarController;
@synthesize homeViewController=homeViewController;
@synthesize profileViewController=profileViewController;
@synthesize peopleViewController=peopleViewController;
@synthesize coursesViewController=coursesViewController;
@synthesize discussionsViewController=discussionsViewController;
@synthesize coursesArray=coursesArray;
@synthesize courseFetcher=courseFetcher;
@synthesize coursesLastUpdated=coursesLastUpdated;
@synthesize currentUser=currentUser;
@synthesize blockingActivityView=blockingActivityView;

+ (eCollegeAppDelegate *) delegate {
	return (eCollegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)generalServiceCallback:(id)obj {    
    
    if ([obj isKindOfClass:[NSError class]]) {
        
        NSError* error = (NSError*)obj;
        NSDictionary* dict = error.userInfo;
        
        // for some reason ASIHTTPRequest throws an NSError when you manually cancel
        // a request.  make sure not to respond to these errors.
        NSString* desc = [dict objectForKey:@"NSLocalizedDescription"];
        if ([desc isEqualToString:@"The request was cancelled"]) {
            return;
        }
    
        NSString* message = [dict objectForKey:@"message"];

        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease];

        if (error.code == AUTHENTICATION_ERROR) {
            NSLog(@"Authentication error");
            alert.message = NSLocalizedString(@"Your authentication credentials have expired. Please login again.", nil);
            [self showLoginView];
        } else if ([message isEqualToString:@"unauthorized_client"]) {
            NSLog(@"Invalid username/password");
            alert.message = NSLocalizedString(@"Invalid username or password. Please try again.", nil);
            if (!loginShowing) {
                [self showLoginView];
            }
        }
        
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"CANCEL");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ECAuthenticatedFetcher setGeneralDelegate:self andSelector:@selector(generalServiceCallback:)];
    
	ECSession *session = [ECSession sharedSession];
	if ([session hasActiveAccessToken] || [session hasActiveGrantToken]) {
		userFetcher = [[UserFetcher alloc] initWithDelegate:self responseSelector:@selector(userLoaded:)];
        [userFetcher fetchMe];        
		[self refreshCourseList];
		[self showGlobalLoader];
	} else {
		logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInView" bundle:nil];
        self.window.rootViewController = self.logInViewController;
        loginShowing = YES;
	}
	[self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)shouldRefreshCourses {
    if (!coursesLastUpdated) {
        return YES;
    } else {
        int diff = [coursesLastUpdated timeIntervalSinceNow];
        // diff will be a negative number; if last refresh were
        // 5 minutes ago, diff will be: -60 * 5 = -300
        return ((diff + coursesRefreshInterval) < 0);
    }
}

- (void) setCoursesArray:(NSArray *)value {
    if (value != coursesArray) {
        if (coursesArray) {
            [coursesArray release];
            [coursesDictionary release];
        }
        coursesArray = [value retain];
        coursesDictionary = [[NSMutableDictionary alloc] init];
        for (Course* course in coursesArray) {
            [coursesDictionary setValue:course forKey:[NSString stringWithFormat:@"%d",course.courseId]];
        }
    }
}

- (Course*) getCourseHavingId:(NSInteger)courseId {
    return [coursesDictionary objectForKey:[NSString stringWithFormat:@"%d",courseId]];
}

- (NSArray*) getAllCourseIds {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:[self.coursesArray count]];
    for(Course* course in self.coursesArray) {
        [arr addObject:[NSNumber numberWithInt:[course courseId]]];
    }
    return [arr autorelease];
}

- (void) dismissLoginView {
//	[UIView transitionWithView:self.window
//					  duration:0.75
//					   options:UIViewAnimationOptionTransitionFlipFromRight // wheeee!!!
//					animations:^{
//                        [self showTabBar];
//					}
//					completion:NULL];
	
    [self showTabBar];
    loginShowing = NO;
}

- (void) showLoginView {
    
    self.logInViewController.passwordText.text = @"";
    self.logInViewController.usernameText.text = @"";
    
//    // transition to the login controller
//	[UIView transitionWithView:self.window
//					  duration:0.75
//					   options:UIViewAnimationOptionTransitionFlipFromLeft // wheeee!!!
//					animations:^{
//                        self.window.rootViewController = self.logInViewController;
//                        self.tabBarController = nil;
//					}
//					completion:NULL];
    
    self.window.rootViewController = self.logInViewController;
    loginShowing = YES;
}

- (void) signOut {
	[[ECSession sharedSession] forgetCredentials];
	[self showLoginView];
    
}

- (void)showTabBar {
    // instantiate the tab bar
    self.tabBarController = [[UITabBarController alloc] init];
    
    // create an array to hold the tabs
    NSMutableArray* allTabs = [[NSMutableArray alloc] initWithCapacity:5];

    UIImage* img = nil;
	ECClientConfiguration *clientConfiguration = [ECClientConfiguration currentConfiguration];

    // Create the view controllers for the tabs
    self.homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    img = [UIImage imageNamed:@"home_icon.png"];
    [self.homeViewController.tabBarItem initWithTitle:NSLocalizedString(@"Home", @"Label on the tab bar for the 'home' section") image:img tag:0];
    UINavigationController* homeNav = [clientConfiguration newPrimaryNavigationControllerWithRootViewController:self.homeViewController];
    [allTabs addObject:homeNav];

    self.discussionsViewController = [[DiscussionsViewController alloc] initWithNibName:@"DiscussionsViewController" bundle:nil];
    img = [UIImage imageNamed:@"discussions_icon.png"];
    [self.discussionsViewController.tabBarItem initWithTitle:NSLocalizedString(@"Discussions", @"Label on the tab bar for the 'discussions' section") image:img tag:0];
    UINavigationController* discussionsNav = [clientConfiguration newPrimaryNavigationControllerWithRootViewController:self.discussionsViewController];
    [allTabs addObject:discussionsNav];

    self.coursesViewController = [[CoursesViewController alloc] initWithNibName:@"CoursesViewController" bundle:nil];
    img = [UIImage imageNamed:@"courses_icon.png"];
    [self.coursesViewController.tabBarItem initWithTitle:NSLocalizedString(@"Courses", @"Label on the tab bar for the 'courses' section") image:img tag:0];
    UINavigationController* coursesNav = [clientConfiguration newPrimaryNavigationControllerWithRootViewController:self.coursesViewController];
    [allTabs addObject:coursesNav];

//    self.peopleViewController = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
//    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"112-group" ofType:@"png"]];
//    [self.peopleViewController.tabBarItem initWithTitle:NSLocalizedString(@"People", @"Label on the tab bar for the 'people' section") image:img tag:0];
//    UINavigationController* peopleNav = [clientConfiguration newPrimaryNavigationControllerWithRootViewController:self.peopleViewController];
//    [allTabs addObject:peopleNav];
//
    self.profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    img = [UIImage imageNamed:@"my_profile_icon.png"];
    [self.profileViewController.tabBarItem initWithTitle:NSLocalizedString(@"Profile", @"Label on the tab bar for the 'profile' section") image:img tag:0];
    UINavigationController* profileNav = [clientConfiguration newPrimaryNavigationControllerWithRootViewController:self.profileViewController];
    [allTabs addObject:profileNav];

    // Add the view controllers as children of the tab bar controller
    self.tabBarController.viewControllers = allTabs;
    
    // Add the tab bar controller to the window
    self.window.rootViewController = self.tabBarController;
}

- (void)showGlobalLoader {
    if (!self.blockingActivityView) {
        self.blockingActivityView = [[BlockingActivityView alloc] initWithWithView:[UIApplication sharedApplication].keyWindow];
        UIColor* bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
        self.blockingActivityView.backgroundColor = bgColor;
    }
    [self.blockingActivityView show];
}

- (void)hideGlobalLoader {
    [self.blockingActivityView hide];
}

- (void) userLoaded:(id)response {
    if ([response isKindOfClass:[User class]]) {
        NSLog(@"User load successful; ID = %d", ((User*)response).userId);
        self.currentUser = (User*)response;
		[self showTabsIfMeAndCoursesLoaded];
    } // TODO: fail silently? What else should we do?
}

- (void)refreshCourseList {
    // if courses are already being fetched, don't initiate another call.
    if (!self.courseFetcher) {
        self.courseFetcher = [[CourseFetcher alloc] initWithDelegate:self responseSelector:@selector(coursesLoaded:)];
        [courseFetcher fetchMyCurrentCourses];
    }    
}

- (void)coursesLoaded:(id)courses {
    NSString* notificationName;
    [blockingActivityView hide];
    if ([courses isKindOfClass:[NSError class]]) {
        NSLog(@"ERROR: Unable to fetch courses");
        notificationName = courseLoadFailure;
    } else {
        NSLog(@"Course load successful.");
        self.coursesLastUpdated = [NSDate date];
        self.coursesArray = (NSArray*)courses;
        notificationName = courseLoadSuccess;
		[self showTabsIfMeAndCoursesLoaded];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    self.courseFetcher = nil;
}

- (void) showTabsIfMeAndCoursesLoaded {
	if (self.currentUser && self.coursesArray && self.tabBarController == nil) {
		[self hideGlobalLoader];
		[self showTabBar];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

- (void)dealloc {
	[userFetcher release]; userFetcher = nil;
    [coursesDictionary release]; coursesDictionary = nil;
    [logInViewController release]; logInViewController = nil;
    [self.courseFetcher cancel];
    self.courseFetcher = nil;
    self.blockingActivityView = nil;
    self.coursesLastUpdated = nil;
    self.coursesArray = nil;
    self.tabBarController = nil;
    self.homeViewController = nil;
	[window release];
    [super dealloc];
}

@end
