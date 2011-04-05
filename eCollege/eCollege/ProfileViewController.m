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

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

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

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn release];
	
	[signOutButton setTitle:NSLocalizedString(@"Sign Out", @"Sign Out label")
				   forState:UIControlStateNormal];
	tableTitleLable.text = NSLocalizedString(@"My Courses", @"Profile courses table title");
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	User *currentUser = [eCollegeAppDelegate delegate].currentUser;
	studentNameLabel.text = [currentUser fullName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
