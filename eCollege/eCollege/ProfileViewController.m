//
//  ProfileViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ProfileViewController.h"
#import "InfoTableViewController.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import "User.h"
#import "Course.h"
#import "CourseTableCell.h"
#import "ECClientConfiguration.h"
#import "IBButton.h"

@implementation ProfileViewController

#pragma mark - Actions

- (IBAction) signOutPressed:(id)sender {
	[[eCollegeAppDelegate delegate] signOut];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[eCollegeAppDelegate delegate].coursesArray count];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *c = [[eCollegeAppDelegate delegate].coursesArray objectAtIndex:indexPath.row];
    UITableViewCell* cell = nil;
    if (c) {
        static NSString *CellIdentifier = @"CourseTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
			cell.textLabel.font = [config cellHeaderFont];
			cell.textLabel.textColor = [config secondaryColor];
			cell.detailTextLabel.font = [config cellFont];
        }
    } else {
        NSLog(@"ERROR: Could not find a course at row %d", indexPath.row);
    }
	
	cell.textLabel.text = c.title;
	cell.detailTextLabel.text = c.displayCourseCode;
	
    return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
	IBButton *signOutButton = [IBButton glossButtonWithTitle:NSLocalizedString(@"Sign Out", @"Sign Out label") color:[config secondaryColor]];
	signOutButton.titleLabel.font = [config secondaryButtonFont];
	signOutButton.titleLabel.shadowColor = [config greyColor];
	signOutButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    signOutButton.frame = CGRectMake(self.view.frame.size.width - 85, studentNameLabel.frame.origin.y, 75, 30);
    [signOutButton addTarget:self action:@selector(signOutPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.view addSubview:signOutButton];
	
	studentNameLabel.font = [config headerFont];
	studentNameLabel.textColor = [config primaryColor];

	tableTitleLable.text = NSLocalizedString(@"My Courses", @"Profile courses table title");
	textureImageView.backgroundColor = [[ECClientConfiguration currentConfiguration] texturedBackgroundColor];
	textureImageView.opaque = NO;
	self.view.backgroundColor = [[ECClientConfiguration currentConfiguration] tertiaryColor];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	User *currentUser = [eCollegeAppDelegate delegate].currentUser;
	studentNameLabel.text = [currentUser fullName];
}

@end
