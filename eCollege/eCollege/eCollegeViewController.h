//
//  eCollegeViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 2/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSession.h"

@interface eCollegeViewController : UIViewController {
    IBOutlet UITextField *clientStringText;
	IBOutlet UITextField *usernameText;
	IBOutlet UITextField *passwordText;
	IBOutlet UIButton *logInButton;
}

@end
