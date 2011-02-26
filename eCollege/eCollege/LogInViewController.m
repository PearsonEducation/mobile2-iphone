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

@implementation LogInViewController

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void) viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector (keyboardDidShow:)
												 name: UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector (keyboardDidHide:)
												 name: UIKeyboardDidHideNotification object:nil];
	scrollView.contentSize = self.view.frame.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		scrollView.frame = CGRectMake(0, 0, scrollViewSizeWhenKeyboardIsHidden.width, scrollViewSizeWhenKeyboardIsHidden.height);
		scrollView.contentOffset = scrollViewOffsetWhenKeyboardIsHidden;
	[UIView commitAnimations];

	keyboardIsShowing = NO;
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
	NSString *clientId = [[ECClientConfiguration currentConfiguration] clientId];
	NSString *clientString = [[ECClientConfiguration currentConfiguration] clientString];
	NSString *username = usernameText.text;
	NSString *password = passwordText.text;
	BOOL keepLoggedIn = keepLoggedInSwitch.on;
	ECSession *session = [ECSession sharedSession];
	[session authenticateWithClientId:clientId
						 clientString:clientString
							 username:username
							 password:password
					 keepUserLoggedIn:keepLoggedIn
							 delegate:self
							 callback:@selector(sessionDidAuthenticate)];
}

#pragma mark - Authentication Complete

- (void) sessionDidAuthenticate {
	[[eCollegeAppDelegate delegate] dismissLoginView];
}

@end
