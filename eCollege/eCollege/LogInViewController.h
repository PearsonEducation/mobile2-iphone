//
//  eCollegeViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSession.h"
#import "CourseFetcher.h"
#import "BlockingActivityView.h"
#import "UserFetcher.h"

@interface LogInViewController : UIViewController<UITextFieldDelegate> {
	IBOutlet UITextField *usernameText;
	IBOutlet UITextField *passwordText;
    IBOutlet UILabel* userNameLabel;
    IBOutlet UILabel* passwordLabel;
    IBOutlet UILabel* keepMeLoggedInLabel;
    IBOutlet UIButton* signInButton;
	IBOutlet UISwitch *keepLoggedInSwitch;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIImageView* formBackgroundImageView;
	IBOutlet UIActivityIndicatorView* progressIndicator;
	
	BOOL hidesLoginAffordances;
	
	BOOL keyboardIsShowing;
    
	CGPoint scrollViewOffsetWhenKeyboardIsHidden;
	CGSize scrollViewSizeWhenKeyboardIsHidden;
    
    BlockingActivityView* blockingActivityView;
    
    UserFetcher* userFetcher;
}

@property (nonatomic, retain) IBOutlet UITextField* usernameText;
@property (nonatomic, retain) IBOutlet UITextField* passwordText;
@property (nonatomic, assign) BOOL hidesLoginAffordances;

- (IBAction) logInClicked:(id)caller;
- (void) loadUserAndCourses;

@end
