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

@interface LogInViewController : UIViewController<UITextFieldDelegate> {
	IBOutlet UITextField *usernameText;
	IBOutlet UITextField *passwordText;
	IBOutlet UISwitch *keepLoggedInSwitch;
	IBOutlet UIButton *logInButton;
	IBOutlet UIScrollView *scrollView;
	
	BOOL keyboardIsShowing;
    
	CGPoint scrollViewOffsetWhenKeyboardIsHidden;
	CGSize scrollViewSizeWhenKeyboardIsHidden;
    
    BlockingActivityView* blockingActivityView;
}

- (IBAction) logInClicked:(id)caller;

@end
