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
#import "CourseDetailTableCell.h"
#import "AnnouncementsViewController.h"
#import "AnnouncementDetailViewController.h"
#import "PeopleViewController.h"
#import "CourseGradebookViewController.h"

@interface CourseDetailViewController ()

@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, retain) CourseDetailHeaderTableCell* headerCell;

- (BOOL)haveAnnouncements;
- (BOOL)isHeaderCell:(NSIndexPath*)indexPath;
- (BOOL)isHighlightedAnnouncementCell:(NSIndexPath*)indexPath;
- (BOOL)isAnnouncementsCell:(NSIndexPath*)indexPath;
- (BOOL)isGradebookCell:(NSIndexPath*)indexPath;
- (BOOL)isPeopleCell:(NSIndexPath*)indexPath;

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

- (void)viewWillAppear:(BOOL)animated {
    self.title = self.course.title;
}

- (void)viewWillDisappear:(BOOL)animated {
    [instructorsFetcher cancel];
    [announcementFetcher cancel];
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
    if ([self haveAnnouncements]) {
        return 5;
    } else {
        return 4;
    }
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident] autorelease];
    }
    return cell;
}

- (BOOL)haveAnnouncements {
    return self.announcements && [self.announcements isKindOfClass:[NSArray class]] && [self.announcements count] > 0;
}

- (BOOL)isHeaderCell:(NSIndexPath*)indexPath {
    return indexPath.row == 0;
}

- (BOOL)isHighlightedAnnouncementCell:(NSIndexPath*)indexPath {
    return (indexPath.row == 1 && [self haveAnnouncements]);
}

- (BOOL)isAnnouncementsCell:(NSIndexPath*)indexPath {
    if ([self haveAnnouncements]) {
        return indexPath.row == 2;
    } else {
        return indexPath.row == 1;
    }
}

- (BOOL)isGradebookCell:(NSIndexPath*)indexPath {
    if ([self haveAnnouncements]) {
        return indexPath.row == 3;
    } else {
        return indexPath.row == 2;
    }
}

- (BOOL)isPeopleCell:(NSIndexPath*)indexPath {
    if ([self haveAnnouncements]) {
        return indexPath.row == 4;
    } else {
        return indexPath.row == 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!instructors || !course) {
        return [self getBasicTableViewCell:tableView];
    }
    
    // header cell
    if ([self isHeaderCell:indexPath]) {
        return self.headerCell;
    } 
    
    // announcement cell
    else if ([self isHighlightedAnnouncementCell:indexPath]) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HighlightedAnnouncementTableCell"];
        if (cell == nil) {
            cell = [[[HighlightedAnnouncementTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HighlightedAnnouncementTableCell"] autorelease];
        }
        ((HighlightedAnnouncementTableCell*)cell).announcement = [self.announcements objectAtIndex:0];
        return cell;
    }
    
    else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CourseDetailTableCell"];
        if (cell == nil) {
            cell = [[[CourseDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CourseDetailTableCell"] autorelease];
        }
        if ([self isAnnouncementsCell:indexPath]) {
            cell.textLabel.text = NSLocalizedString(@"Announcements",nil);
        } else if ([self isGradebookCell:indexPath]) {
            cell.textLabel.text = NSLocalizedString(@"Gradebook",nil);
        } else if ([self isPeopleCell:indexPath]) {
            cell.textLabel.text = NSLocalizedString(@"People",nil);
        }
        return cell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isAnnouncementsCell:indexPath]) {
        AnnouncementsViewController* avc = [[AnnouncementsViewController alloc] initWithNibName:@"AnnouncementsViewController" bundle:nil];
        avc.courseId = self.course.courseId;
        avc.courseName = self.course.title;        
        [self.navigationController pushViewController:avc animated:YES];
        [avc release];
    } else if ([self isHighlightedAnnouncementCell:indexPath]) {
        AnnouncementDetailViewController* advc = [[AnnouncementDetailViewController alloc] initWithNibName:@"AnnouncementsDetailViewController" bundle:nil];
        Announcement* announcement = [announcements objectAtIndex:0];
        [advc setAnnouncementId:announcement.announcementId andCourseId:self.course.courseId andCourseName:self.course.title];
        advc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:advc animated:YES];
        [advc release];
    } else if ([self isPeopleCell:indexPath]) {
        PeopleViewController* pvc = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
        pvc.courseId = self.course.courseId;
        pvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pvc animated:YES];
        [pvc release];
    } else if ([self isGradebookCell:indexPath]) {
        CourseGradebookViewController *cgvc = [[CourseGradebookViewController alloc] initWithNibName:@"CourseGradebookViewController" bundle:nil];
		cgvc.courseId = self.course.courseId;
        cgvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cgvc animated:YES];
        [cgvc release];
	}
}

@end
