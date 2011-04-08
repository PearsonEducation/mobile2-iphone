//
//  SplashScreenViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/7/11.
//	Uses code inspired by iOS Recipes, copyright 2011 Pragmatic Programmers
//

#import "SplashScreenViewController.h"
#import "SplashScreenDelegate.h"

@implementation SplashScreenViewController
@synthesize splashImage, showsStatusBarOnDismissal, hidesImmediately, delegate;

- (void)loadView {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:self.splashImage];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.contentMode = UIViewContentModeCenter;
	self.view = imageView;
	[imageView release];
}

- (void)viewDidLoad {
	self.splashImage = nil;
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([delegate respondsToSelector:@selector(splashScreenDidAppear:)]) {
		[delegate splashScreenDidAppear:self];
	}
	if (self.hidesImmediately) [self hide];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([delegate respondsToSelector:@selector(splashScreenWillDisappear:)]) {
		[delegate splashScreenWillDisappear:self];
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if ([delegate respondsToSelector:@selector(splashScreenDidDisappear:)]) {
		[delegate splashScreenDidDisappear:self];
	}
}

- (void)viewDidUnload {
	self.splashImage = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) hide {
	if (self.showsStatusBarOnDismissal) {
		UIApplication *app = [UIApplication sharedApplication];
		[app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (UIImage *) splashImage {
	if (nil == splashImage) {
		splashImage = [[UIImage imageNamed:@"Default.png"] retain];
	}
	return splashImage;
}

@end
