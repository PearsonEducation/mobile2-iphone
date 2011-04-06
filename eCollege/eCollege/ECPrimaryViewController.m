//
//  ECPrimaryViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/6/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ECPrimaryViewController.h"
#import "InfoTableViewController.h"

@implementation ECPrimaryViewController

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIImage *navBarLogoImage = [UIImage imageNamed:@"image_logo_small"];
	UIImageView *navBarLogoView = [[[UIImageView alloc] initWithImage:navBarLogoImage] autorelease];
	self.navigationItem.titleView = navBarLogoView;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn release];
}

- (void)infoButtonTapped:(id)sender {
    InfoTableViewController* infoTableViewController = [[InfoTableViewController alloc] initWithNibName:@"InfoTableViewController" bundle:nil];
    infoTableViewController.cancelDelegate = self;
    UINavigationController *infoNavController = [[UINavigationController alloc] initWithRootViewController:infoTableViewController];
    [self presentModalViewController:infoNavController animated:YES];
    [infoNavController release];
    [infoTableViewController release];
}

- (void)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
