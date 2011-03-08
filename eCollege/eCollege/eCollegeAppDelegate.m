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

@interface eCollegeAppDelegate ()

// Private properties
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) HomeViewController* homeViewController;
@property (nonatomic, retain) ProfileViewController* profileViewController;
@property (nonatomic, retain) PeopleViewController* peopleViewController;
@property (nonatomic, retain) CoursesViewController* coursesViewController;
@property (nonatomic, retain) DiscussionsViewController* discussionsViewController;


// Private methods
- (void) showTabBar;

@end

@implementation eCollegeAppDelegate

@synthesize window=window;
@synthesize logInViewController=logInViewController;
@synthesize tabBarController=tabBarController;
@synthesize homeViewController=homeViewController;
@synthesize profileViewController=profileViewController;
@synthesize peopleViewController=peopleViewController;
@synthesize coursesViewController=coursesViewController;
@synthesize discussionsViewController=discussionsViewController;

+ (eCollegeAppDelegate *) delegate {
	return (eCollegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	ECSession *session = [ECSession sharedSession];
	if ([session hasUnexpiredAccessToken] || [session hasUnexpiredGrantToken]) {
		[self showTabBar];
	} else {
		logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInView" bundle:nil];
		[self.window addSubview:self.logInViewController.view];
	}
	[self.window makeKeyAndVisible];
    return YES;
}

- (void) dismissLoginView {
	[UIView transitionWithView:self.window
					  duration:0.75
					   options:UIViewAnimationOptionTransitionCurlUp // wheeee!!!
					animations:^{
						[self.logInViewController.view removeFromSuperview];
					}
					completion:nil];
	[self showTabBar];
}

- (void)showTabBar {
    // instantiate the tab bar
    self.tabBarController = [[UITabBarController alloc] init];
    
    // create an array to hold the tabs
    NSMutableArray* allTabs = [[NSMutableArray alloc] initWithCapacity:5];

    UIImage* img;

    // Create the view controllers for the tabs
    self.homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"53-house" ofType:@"png"]];
    [self.homeViewController.tabBarItem initWithTitle:NSLocalizedString(@"Home", @"Label on the tab bar for the 'home' section") image:img tag:0];
    UINavigationController* homeNav = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    [allTabs addObject:homeNav];
    [homeNav release];
    [img release];

    self.discussionsViewController = [[DiscussionsViewController alloc] initWithNibName:@"DiscussionsViewController" bundle:nil];
    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"08-chat" ofType:@"png"]];
    [self.discussionsViewController.tabBarItem initWithTitle:NSLocalizedString(@"Discussions", @"Label on the tab bar for the 'discussions' section") image:img tag:0];
    UINavigationController* discussionsNav = [[UINavigationController alloc] initWithRootViewController:self.discussionsViewController];
    [allTabs addObject:discussionsNav];
    [discussionsViewController release];
    [img release];

    self.coursesViewController = [[CoursesViewController alloc] initWithNibName:@"CoursesViewController" bundle:nil];
    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"96-book" ofType:@"png"]];
    [self.coursesViewController.tabBarItem initWithTitle:NSLocalizedString(@"Courses", @"Label on the tab bar for the 'courses' section") image:img tag:0];
    UINavigationController* coursesNav = [[UINavigationController alloc] initWithRootViewController:self.coursesViewController];
    [allTabs addObject:coursesNav];
    [coursesNav release];
    [img release];

    self.peopleViewController = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"112-group" ofType:@"png"]];
    [self.peopleViewController.tabBarItem initWithTitle:NSLocalizedString(@"People", @"Label on the tab bar for the 'people' section") image:img tag:0];
    UINavigationController* peopleNav = [[UINavigationController alloc] initWithRootViewController:self.peopleViewController];
    [allTabs addObject:peopleNav];
    [peopleNav release];
    [img release];

    self.profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"123-id-card" ofType:@"png"]];
    [self.profileViewController.tabBarItem initWithTitle:NSLocalizedString(@"Profile", @"Label on the tab bar for the 'profile' section") image:img tag:0];
    UINavigationController* profileNav = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    [allTabs addObject:profileNav];
    [profileNav release];
    [img release];

    // Add the view controllers as children of the tab bar controller
    self.tabBarController.viewControllers = allTabs;
    
    // Add the tab bar controller to the window
    [window addSubview:self.tabBarController.view];
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
	[window release];
	[logInViewController release];
    self.tabBarController = nil;
    self.homeViewController = nil;
    [super dealloc];
}

@end
