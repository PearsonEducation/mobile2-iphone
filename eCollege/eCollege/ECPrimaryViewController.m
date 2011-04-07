//
//  ECPrimaryViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/6/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ECPrimaryViewController.h"
#import "InfoTableViewController.h"
#import "ECClientConfiguration.h"

@implementation ECPrimaryViewController

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIImage *navBarLogoImage = [UIImage imageNamed:@"image_logo_small"];
	UIImageView *navBarLogoView = [[[UIImageView alloc] initWithImage:navBarLogoImage] autorelease];
	navBarLogoView.frame = CGRectMake(0, 0, 164, 25);
	self.navigationItem.titleView = navBarLogoView;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *image = [UIImage imageNamed:@"gear.png"];
	[btn setImage:image forState:UIControlStateNormal];
	btn.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [btn addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
}

- (void)infoButtonTapped:(id)sender {
    InfoTableViewController* infoTableViewController = [[InfoTableViewController alloc] initWithNibName:@"InfoTableViewController" bundle:nil];
    infoTableViewController.cancelDelegate = self;
    UINavigationController *infoNavController = [[UINavigationController alloc] initWithRootViewController:infoTableViewController];
	infoNavController.navigationBar.tintColor = [[ECClientConfiguration currentConfiguration] primaryColor];
    [self presentModalViewController:infoNavController animated:YES];
    [infoNavController release];
    [infoTableViewController release];
}

- (void)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
