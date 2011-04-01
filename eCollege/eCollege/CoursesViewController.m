//
//  CoursesViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CoursesViewController.h"
#import "InfoTableViewController.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import "CourseTableCell.h"
#import "CourseDetailViewController.h"

@implementation CoursesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    // add the info button, give it a tap handler
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn release];
    
    // add the notifications indicator in the header
    UIView* notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    notificationView.backgroundColor = HEXCOLOR(0xF5FF6F);
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,18,18)];
    label.text = @"3";
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [notificationView addSubview:label];
    UIBarButtonItem* notificationButton = [[UIBarButtonItem alloc] initWithCustomView:notificationView];
    self.navigationItem.rightBarButtonItem = notificationButton;
    [notificationView release];
    [notificationButton release];
    [label release];


}

- (void)viewDidAppear:(BOOL)animated {
    [table reloadData];
}

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

# pragma mark UITableViewDataSource / UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[eCollegeAppDelegate delegate].coursesArray count];
    } else {
        NSLog(@"ERROR: There should only be one section (index 0) on the courses table");        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Course* c = [[eCollegeAppDelegate delegate].coursesArray objectAtIndex:indexPath.row];
    UITableViewCell* cell = nil;
    if (c) {
        static NSString *CellIdentifier = @"CourseTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CourseTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [(CourseTableCell*)cell setData:c];
    } else {
        NSLog(@"ERROR: Could not find a course at row %d", indexPath.row);
    }    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Course* c = [[[eCollegeAppDelegate delegate] coursesArray] objectAtIndex:indexPath.row];
    if (c) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CourseDetailViewController* courseDetailViewController = [[CourseDetailViewController alloc] initWithNibName:@"CourseDetailViewController" bundle:nil];
        courseDetailViewController.hidesBottomBarWhenPushed = YES;
        courseDetailViewController.course = c;
        NSLog(@"Drilling into course detail view for course: %@", c);
        [self.navigationController pushViewController:courseDetailViewController animated:YES];
        [courseDetailViewController release];
    }
}

@end
