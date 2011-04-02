//
//  CourseDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "CourseDetailHeaderTableCell.h"
#import "HighlightedAnnouncementTableCell.h"

@interface CourseDetailViewController ()

@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, retain) CourseDetailHeaderTableCell* headerCell;

@end

@implementation CourseDetailViewController

@synthesize course;
@synthesize blockingActivityView;
@synthesize announcements;
@synthesize instructors;
@synthesize headerCell;

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
    
    [table reloadData];

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
    self.headerCell = nil;
    
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
    if (indexPath.row == 0) {
        // the header cell resizes its height depending on how long the text it contains is. so,
        // create the actual cell here so that we know how tall it will ultimately be.
        if (self.course && self.instructors) {
            self.headerCell = [CourseDetailHeaderTableCell cellForCourse:self.course andInstructors:self.instructors];
            return self.headerCell.frame.size.height;
        } else {
            return 55.0;
        }
    } 
    else {
        return 55.0;
    }
    
}

- (UITableViewCell*)getBasicTableViewCell:(UITableView*)tableView {
    NSString *ident = @"CourseDetailBasicTableCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!instructors || !course) {
        return [self getBasicTableViewCell:tableView];
    }
    
    // header cell
    if (indexPath.row == 0) {
        return self.headerCell;
    } 
    
    // announcement cell
    else if (indexPath.row == 1 && [self.announcements count] > 0) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HighlightedAnnouncementTableCell"];
        if (cell == nil) {
            cell = [[HighlightedAnnouncementTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HighlightedAnnouncementTableCell"];
        }
        ((HighlightedAnnouncementTableCell*)cell).announcement = [self.announcements objectAtIndex:0];
        return cell;
    }
    
    else {
        return [self getBasicTableViewCell:tableView];        
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}



@end
