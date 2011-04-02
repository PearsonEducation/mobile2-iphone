//
//  CourseDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "CourseDetailHeaderTableCell.h"

@interface CourseDetailViewController ()

@property (nonatomic, retain) BlockingActivityView* blockingActivityView;

@end

@implementation CourseDetailViewController

@synthesize course;
@synthesize blockingActivityView;
@synthesize announcements;
@synthesize instructors;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        instructorsFetcher = [[CourseFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedInstructors:)];
        announcementFetcher = [[AnnouncementFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedAnnouncements:)];
    }
    return self;
}

- (void)setupView {
    // make sure both instructors and announcements have loaded
    if (!self.instructors || !self.announcements) {
        return;
    }

    NSLog(@"Instructors: %@", self.instructors);
    NSLog(@"Announcements: %@", self.announcements);
}

- (void)loadedInstructors:(id)obj {
    self.instructors = obj;
    // if we got a good response, save it on the object to prevent needing
    // to load the next time.
    if (![self.instructors isKindOfClass:[NSError class]]) {
        course.instructors = self.instructors;
    }
    [self setupView];
}

- (void)loadedAnnouncements:(id)obj {
    self.announcements = obj;
    [self setupView];
}

- (void)dealloc
{
    [instructorsFetcher cancel];
    [instructorsFetcher release];
    instructorsFetcher = nil;
    
    self.course = nil;
    self.announcements = nil;
    self.instructors = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (course) {
        // fetch the announcements for the course
        [announcementFetcher fetchAnnouncementsForCourseWithId:course.courseId];
        
        // instructors may already have been fetched another time this view was shown...
        // if it was never fetched, or if an NSError was returned, fetch it again.
        instructors = course.instructors;
        if (!instructors) {
            [instructorsFetcher fetchInstructorsForCourseWithId:course.courseId];
        }
        [table reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // HEADER cell
    if (indexPath.row == 0) {
        // TODO: calculate the height of the header cell based on the heights of all labels
        return 99.0;
    } 
    
    // All other cells
    else {
        // Featured announcement cell and "normal" cells have the same height
        return 51.0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    // determine what kind of cell to make
    static NSString *CellIdentifier;
    if (indexPath.row == 0) {
        CellIdentifier = @"CourseDetailHeaderTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CourseDetailHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        CGRect f = CGRectMake(0, 0, 320, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        cell.frame = f;
        cell.contentView.frame = f;
        [(CourseDetailHeaderTableCell*)cell setCourse:self.course andInstructors:self.instructors];
    } else {
        CellIdentifier = @"CourseDetailBasicTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    // configure the cell if necessary
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}



@end
