//
//  eCollegeViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "LogInViewController.h"
#import "ECSession.h"
#import "ECClientConfiguration.h"
#import "eCollegeAppDelegate.h"
#import "CourseFetcher.h"

@interface LogInViewController ()

- (void)handleCoursesRefreshSuccess:(NSNotification*)notification;
- (void)handleCoursesRefreshFailure:(NSNotification*)notification;
- (void)registerForCoursesNotifications;
- (void)unregisterForCoursesNotifications;
- (void)sessionDidAuthenticate:(id)obj;
- (void)authenticate;

@end

@implementation LogInViewController

@synthesize usernameText;
@synthesize passwordText;

- (void)dealloc {
    self.usernameText = nil;
    self.passwordText = nil;
    [blockingActivityView release];
    [self unregisterForCoursesNotifications];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewDidLoad {
	scrollView.contentSize = self.view.frame.size;
    
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
}

- (void) viewDidAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector (keyboardDidShow:)
												 name: UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector (keyboardDidHide:)
												 name: UIKeyboardDidHideNotification object:nil];
    
}

- (void) viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notification handlers and related code

- (void)registerForCoursesNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCoursesRefreshSuccess:) name:courseLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCoursesRefreshFailure:) name:courseLoadFailure object:nil];
}

- (void)unregisterForCoursesNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:courseLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:courseLoadFailure object:nil];
}

- (void)handleCoursesRefreshSuccess:(NSNotification*)notification {
    [self unregisterForCoursesNotifications];
    [blockingActivityView hide];
    [[eCollegeAppDelegate delegate] dismissLoginView];
}

- (void)handleCoursesRefreshFailure:(NSNotification*)notification {
    NSLog(@"ERROR loading courses; can't move past login screen.");
    [self unregisterForCoursesNotifications];
    [blockingActivityView hide];
}

#pragma mark - Control callbacks and view logic

- (void) keyboardDidShow:(NSNotification *)notification {
	if (keyboardIsShowing) {
		return; //apparently we can sometimes get too many notifications
	}
	
	NSDictionary *info = [notification userInfo];
	NSValue *keyboardBoundsEndValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGSize keyboardSize = [keyboardBoundsEndValue CGRectValue].size;
	scrollViewOffsetWhenKeyboardIsHidden = scrollView.contentOffset;
	scrollViewSizeWhenKeyboardIsHidden = scrollView.frame.size;
	
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		CGRect viewFrame = scrollView.frame;
		viewFrame.size.height -= keyboardSize.height;
		scrollView.frame = viewFrame;
		
		//TODO: some magic numbers here... clean them up
		scrollView.contentOffset = CGPointMake(0, usernameText.frame.origin.y - 40);
	[UIView commitAnimations];

	keyboardIsShowing = YES;
}

- (void) keyboardDidHide:(NSNotification *)notification {
	if (!keyboardIsShowing) {
		return; //apparently we can sometimes get too many notifications
	}
    
    [self authenticate];
    
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		scrollView.frame = CGRectMake(0, 0, scrollViewSizeWhenKeyboardIsHidden.width, scrollViewSizeWhenKeyboardIsHidden.height);
		scrollView.contentOffset = scrollViewOffsetWhenKeyboardIsHidden;
	[UIView commitAnimations];

	keyboardIsShowing = NO;
}

- (void)authenticate {
    NSString *clientId = [[ECClientConfiguration currentConfiguration] clientId];
	NSString *clientString = [[ECClientConfiguration currentConfiguration] clientString];
	NSString *username = usernameText.text;
	NSString *password = passwordText.text;
	BOOL keepLoggedIn = keepLoggedInSwitch.on;
    [blockingActivityView show];
	ECSession *session = [ECSession sharedSession];
	[session authenticateWithClientId:clientId
						 clientString:clientString
							 username:username
							 password:password
					 keepUserLoggedIn:keepLoggedIn
							 delegate:self
							 callback:@selector(sessionDidAuthenticate:)];    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameText) {
		[passwordText becomeFirstResponder];
	} else if (textField == passwordText) {
		[passwordText resignFirstResponder];
	}
	return YES;
}

- (IBAction) logInClicked:(id)caller {
    if ([usernameText isFirstResponder] || [passwordText isFirstResponder]) {
        [usernameText resignFirstResponder];
        [passwordText resignFirstResponder];        
    } else {
        [self authenticate];
    }
    
}

#pragma mark - Authentication Complete

- (void) sessionDidAuthenticate:(id)obj {
    if (![obj isKindOfClass:[NSError class]]) {
        userFetcher = [[UserFetcher alloc] initWithDelegate:self responseSelector:@selector(userLoaded:)];
        [userFetcher fetchMe];        
    } else {
        [blockingActivityView hide];
    }
}

- (void) userLoaded:(id)response {
    if ([response isKindOfClass:[User class]]) {
        NSLog(@"User load successful; ID = %d", ((User*)response).userId);
        [eCollegeAppDelegate delegate].currentUser = (User*)response;
        [self registerForCoursesNotifications];
        [[eCollegeAppDelegate delegate] refreshCourseList];            
    } else {
        NSLog(@"ERROR: unable to load user; cannot move past login screen");
        [blockingActivityView hide];
    }
}

@end
