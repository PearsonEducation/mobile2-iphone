//
//  SingleSignOnViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/22/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "SingleSignOnViewController.h"
#import "ECClientConfiguration.h"

#define SSO_REDIRECT_HOST @"localhost"
#define SSO_REDIRECT_RELATIVE_PATH @"/redirect_and_catch.html"

@implementation SingleSignOnViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	NSString *ssoURL = [[ECClientConfiguration currentConfiguration] ssoURL];
	NSString *ssoURLWithRedirect = [NSString stringWithFormat:@"%@?redirect_url=http://%@%@", ssoURL, SSO_REDIRECT_HOST, SSO_REDIRECT_RELATIVE_PATH];
	NSURL *earl = [NSURL URLWithString:ssoURLWithRedirect];
	NSURLRequest *ssoRequest = [NSURLRequest requestWithURL:earl];
	[webView loadRequest:ssoRequest];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) backPressed {
	[webView goBack];
}

- (IBAction) reloadPressed {
	[webView reload];
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
		NSURL *earl = [request URL];
		NSString *host = [earl host];
		NSString *relativePath = [earl relativePath];
		if ([host isEqualToString:SSO_REDIRECT_HOST] && [relativePath isEqualToString:SSO_REDIRECT_RELATIVE_PATH]) {
			NSString *queryString = [earl query];
			NSArray *components = [queryString componentsSeparatedByString:@"="];
			NSString *token = [components lastObject];
			
		}
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[progressIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[progressIndicator stopAnimating];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	[webView loadHTMLString:NSLocalizedString(@"Unable to load sign in page. Please make sure you have a network connection and try again later.", @"HTML To load if Single Sign On url fails to load") baseURL:nil];
}

@end
