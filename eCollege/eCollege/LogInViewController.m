//
//  eCollegeViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "LogInViewController.h"
#import "ECSession.h"

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

- (IBAction) logInClicked:(id)caller {
	ECSession *session = [ECSession sharedSession];
	session.authenticationDelegate = self;
	[session authenticateWithClientId:@"30bb1d4f-2677-45d1-be13-339174404402"
						 clientString:@"ctstate"
							 username:@"veronicastudent3"
							 password:@"veronicastudent3"];
}

- (void) sessionDidAuthenticate:(ECSession *)aSession {
}

@end
