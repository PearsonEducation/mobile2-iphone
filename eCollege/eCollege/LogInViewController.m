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

@implementation LogInViewController

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Control callbacks

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == clientStringText) {
		[usernameText becomeFirstResponder];
	} else if (textField == usernameText) {
		[passwordText becomeFirstResponder];
	} else if (textField == passwordText) {
		[self logInClicked:passwordText];
	}
	return YES;
}

- (IBAction) logInClicked:(id)caller {
	ECSession *session = [ECSession sharedSession];
	session.authenticationDelegate = self;
	NSString *clientId = [[ECClientConfiguration currentConfiguration] clientId];
	NSString *clientString = [[ECClientConfiguration currentConfiguration] clientString];
	NSString *username = usernameText.text;
	NSString *password = passwordText.text;
	[session authenticateWithClientId:clientId
						 clientString:clientString
							 username:username
							 password:password];
}

#pragma mark - Authentication Complete

- (void) sessionDidAuthenticate:(ECSession *)aSession {
}

@end
