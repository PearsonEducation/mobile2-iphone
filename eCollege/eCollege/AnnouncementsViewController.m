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
#import "InfoTableViewController.h"
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
- (void)infoButtonTapped:(id)sender;
- (Announcement*)getTopicForIndexPath:(NSIndexPath*)indexPath;
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.announcementsFetcher = [[AnnouncementFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedAnnouncementsHandler:)];    
    }
    return self;
}

- (void)dealloc
{
    self.announcements = nil;
    self.announcementsFetcher = nil;
    self.blockingActivityView = nil;
    self.lastUpdateTime = nil;
    [super dealloc];
}

- (void)infoButtonTapped:(id)sender {
    InfoTableViewController* infoTableViewController = [[InfoTableViewController alloc] initWithNibName:@"InfoTableViewController" bundle:nil];
    infoTableViewController.cancelDelegate = self;
    UINavigationController *infoNavController = [[UINavigationController alloc] initWithRootViewController:infoTableViewController];
    [self presentModalViewController:infoNavController animated:YES];
    [infoNavController release];
    [infoTableViewController release];
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
        NSString* prettyTime = [self.lastUpdateTime niceAndConcise];
        if (![prettyTime isEqualToString:@""] || [self.lastUpdatedLabel.text isEqualToString:@""]) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last update: %@", prettyTime];
        }
    } else {
        self.lastUpdatedLabel.text = @"";
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

- (void)viewWillAppear:(BOOL)animated {
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
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    Announcement* announcement = [self getAnnouncementForIndexPath:indexPath];
    UITableViewCell *cell;
    if (announcement) {
        static NSString *CellIdentifier = @"AnnouncementTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Announcement* announcement = [self getAnnouncementForIndexPath:indexPath];
    if (announcement) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        AnnouncementDetailViewController* announcementDetailViewController = [[AnnouncementDetailViewController alloc] initWithNibName:@"AnnouncementDetailViewController" bundle:nil];
        NSLog(@"Initializing AnnouncementDetailViewController controller with announcement ID: %d",announcement.announcementId);
        announcementDetailViewController.announcementId = announcement.announcementId;
        topicResponsesViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topicResponsesViewController animated:YES];
        [announcementDetailViewController release];
    }
}

@end
