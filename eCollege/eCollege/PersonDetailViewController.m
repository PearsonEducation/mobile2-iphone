//
//  PersonDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "PersonDetailViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import "Course.h"
#import "ECClientConfiguration.h"

@interface PersonDetailViewController ()
@end

@implementation PersonDetailViewController

@synthesize courseId;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
	
	self.view.backgroundColor = [config tertiaryColor];
	textureImageView.backgroundColor = [config texturedBackgroundColor];
	textureImageView.opaque = NO;
    
    // set up the icon and its bounding box
    iconView.image = [UIImage imageNamed:@"person_male_icon.png"];
    whiteBox.layer.borderWidth = 1;
    whiteBox.layer.borderColor = [HEXCOLOR(0xC1C1C1) CGColor];
    whiteBox.backgroundColor = [UIColor whiteColor];

    // set up the labels if we can
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:self.courseId];
    if (course) {
        courseNameLabel.text = course.title;
    }
    if (user) {
        roleLabel.text = [user friendlyRole];
        nameLabel.text = [user fullName];
    }
}

- (void)dealloc
{
    self.user = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
