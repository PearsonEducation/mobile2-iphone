//
//  AnnouncementsViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "AnnouncementsViewController.h"
#import "AnnouncementDetailViewController.h"
#import "AnnouncementTableCell.h"
#import "UIColor+Boost.h"
#import "Announcement.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"

@interface AnnouncementsViewController ()

@property (nonatomic, retain) AnnouncementFetcher* announcementsFetcher;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, assign) BOOL currentlyLoading;
@property (nonatomic, assign) BOOL announcementsLoadFailure;
@property (nonatomic, assign) BOOL forceUpdateOnViewWillAppear;

- (void)loadData;
- (void)prepareData;
- (void)loadingComplete;
- (Announcement*)getAnnouncementForIndexPath:(NSIndexPath*)indexPath;

@end

@implementation AnnouncementsViewController

@synthesize courseId;
@synthesize announcements;
@synthesize announcementsFetcher;
@synthesize blockingActivityView;
@synthesize lastUpdateTime;
@synthesize currentlyLoading;
@synthesize announcementsLoadFailure;
@synthesize forceUpdateOnViewWillAppear;
@synthesize courseName;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.announcementsFetcher = [[[AnnouncementFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedAnnouncementsHandler:)] autorelease];    
    }
    return self;
}

- (void)dealloc
{
    self.blockingActivityView = nil;
    self.announcements = nil;
    self.announcementsFetcher = nil;
    self.lastUpdateTime = nil;
    self.courseName = nil;
    [super dealloc];
}

// overriding parent method
- (void)refresh {
    [self loadData];
}

- (void)loadData {
    
    if (currentlyLoading) {
        return;
    }
    
    currentlyLoading = YES;
    
    // if course data is stale, refresh it; refresh topics afterward.
    [self.announcementsFetcher cancel];
    [self.announcementsFetcher fetchAnnouncementsForCourseWithId:self.courseId];    
}

- (void)executeAfterHeaderClose {
    self.lastUpdateTime = [NSDate date];
}

- (void)updateLastUpdatedLabel {
    if (self.lastUpdateTime) {
        NSString* prettyTime = [self.lastUpdateTime friendlyString];
        if (![prettyTime isEqualToString:@""] || [self.lastUpdatedLabel.text isEqualToString:@""]) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last update",nil), prettyTime];
        }
    } else {
        self.lastUpdatedLabel.text = NSLocalizedString(@"Last update: unknown",nil);
    }
}


- (IBAction)refreshWithModalSpinner {
    [blockingActivityView show];    
    [self loadData];
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
            
    // Do any additional setup after loading the view from its nib.
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"Announcements",nil);
    
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the topics again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedAnnouncementsHandler:(NSArray*)loadedAnnouncements {
    // check to see if we received an error; if not, save off the data and prep it.
    if ([loadedAnnouncements isKindOfClass:[NSError class]]) {
        announcementsLoadFailure = YES;
    } else {
        announcementsLoadFailure = NO;
        self.announcements = loadedAnnouncements;
        [self prepareData];
    }
    
    [self loadingComplete];
}

- (void)loadingComplete {
    if (announcementsLoadFailure) {
        NSLog(@"Load failure");
    } else {
        // since we've updated the buckets of data, we must now reload the table
        [self.table reloadData];
    }
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
    
    // tell the modal loading spinner to go away (if it's present)
    [blockingActivityView hide];        
    
    // no longer loading
    currentlyLoading = NO;
    announcementsLoadFailure = NO;
}

- (void)prepareData {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.announcements) {
        int cnt = [self.announcements count];
        if (cnt > 0) {
            return cnt;
        } else {
            // no data cell
            return 1;
        }
    } else {
        // still loading
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Announcement* announcement = [self getAnnouncementForIndexPath:indexPath];
    UITableViewCell *cell;
    if (announcement) {
        static NSString *CellIdentifier = @"AnnouncementTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[AnnouncementTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AnnouncementTableCell"] autorelease];
        }
        [(AnnouncementTableCell*)cell setData:announcement];        
    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = NSLocalizedString(@"No announcements",nil);
    }
    return cell;
}

- (Announcement*)getAnnouncementForIndexPath:(NSIndexPath*)indexPath {
    Announcement* returnValue = nil;
    if (indexPath.row < [self.announcements count]) {
        returnValue = [self.announcements objectAtIndex:indexPath.row];
    }
    return returnValue;
}

- (void)forceFutureRefresh {    
    forceUpdateOnViewWillAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [announcementsFetcher cancel];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Announcement* announcement = [self getAnnouncementForIndexPath:indexPath];
    if (announcement) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        AnnouncementDetailViewController* announcementDetailViewController = [[AnnouncementDetailViewController alloc] init];
        NSLog(@"Initializing AnnouncementDetailViewController controller with announcement ID: %d and course ID: %d",announcement.announcementId, self.courseId);
        [announcementDetailViewController setAnnouncementId:announcement.announcementId andCourseId:self.courseId andCourseName:self.courseName];
        announcementDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:announcementDetailViewController animated:YES];
        [announcementDetailViewController release];
    }
}

@end
