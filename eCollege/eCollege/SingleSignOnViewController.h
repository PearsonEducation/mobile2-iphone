//
//  SingleSignOnViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SingleSignOnViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *reloadButton;
	IBOutlet UIActivityIndicatorView *progressIndicator;
}

- (IBAction) backPressed;
- (IBAction) reloadPressed;

@end
