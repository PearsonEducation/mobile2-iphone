//
//  DiscussionsViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DiscussionsViewController.h"
#import "UIColor+Boost.h"
#import "InfoTableViewController.h"
#import "UserDiscussionTopic.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"
#import "TopicTableCell.h"

@interface DiscussionsViewController ()

@property (nonatomic, retain) UserDiscussionTopicFetcher* userDiscussionTopicFetcher;
@property (nonatomic, retain) NSDate* today;
@property (nonatomic, retain) NSArray* courseIds;

- (void)loadData;
- (void)prepareData;
- (void)infoButtonTapped:(id)sender;
- (void)cancelButtonClicked:(id)sender;
- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath;
- (void)registerForCoursesNotifications;
- (void)unregisterForCoursesNotifications;
- (void)handleCoursesRefreshSuccess:(NSNotification*)notification;
- (void)handleCoursesRefreshFailure:(NSNotification*)notification;
- (void)loadingComplete;

@end

@implementation DiscussionsViewController

@synthesize userDiscussionTopicFetcher;
@synthesize topics;
@synthesize lastUpdateTime;
@synthesize today;
@synthesize courseIds;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
        dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian];
        [gregorian release];
        self.today = [dateCalculator midnight:0 fromDate:[NSDate date]];
        [self registerForCoursesNotifications];
    }
    return self;
}

- (void)dealloc
{
    self.courseIds = nil;
    [self unregisterForCoursesNotifications];
    self.topics = nil;
    self.lastUpdateTime = nil;
    [self.userDiscussionTopicFetcher cancel];
    self.userDiscussionTopicFetcher = nil;
    [blockingActivityView release];
    [dateCalculator release];
    [today release];
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
    
    // if course data is stale, refresh it.
    if ([[eCollegeAppDelegate delegate] shouldRefreshCourses]) {
        courseRefreshInProgress = YES;
        [[eCollegeAppDelegate delegate] refreshCourseList];
    }
    
    // fetch topics
    if (!self.userDiscussionTopicFetcher) {
        self.userDiscussionTopicFetcher = [[UserDiscussionTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyTopicsHandler:)];    
    } else {
        [self.userDiscussionTopicFetcher cancel];
    }
    
    topicsRefreshInProgress = YES;
    // TODO: filtering
    [self.userDiscussionTopicFetcher fetchDiscussionTopicsForCourseIds:[[eCollegeAppDelegate delegate] getAllCourseIds]];
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

- (void)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Notification handlers & related code

- (void)registerForCoursesNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCoursesRefreshSuccess:) name:courseLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCoursesRefreshFailure:) name:courseLoadFailure object:nil];
}

- (void)unregisterForCoursesNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:courseLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:courseLoadFailure object:nil];
}

- (void)handleCoursesRefreshSuccess:(NSNotification*)notification {
    courseRefreshInProgress = NO;
    
    // if courses were refreshed because we're loading, that means
    // we can potentially immediately update the interface.
    if (currentlyLoading) {
        coursesLoadFailure = NO;
        if (topicsRefreshInProgress) {
            // need to wait for activities refresh to finish
            return;
        } else {
            // everything has been loaded
            [self loadingComplete];
        }
    }
    
    // if courses were refreshed from some other place in the application,
    // force the activities to reload the next time this view appears.
    else {
        forceUpdateOnViewWillAppear = YES;
    }
}

- (void)handleCoursesRefreshFailure:(NSNotification*)notification {
    courseRefreshInProgress = NO;
    NSLog(@"ERROR loading courses; can't move past login screen.");
    
    // if the failure happened passively (this view didn't request an
    // update of the courses), then don't do anything.
    if (currentlyLoading) {
        topicsLoadFailure = YES;
        if (topicsRefreshInProgress) {
            return;
        } else {
            [self loadingComplete];
        }
    }
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

- (void)viewWillAppear:(BOOL)animated {
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the activities again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedMyTopicsHandler:(NSArray*)loadedTopics {
    topicsRefreshInProgress = NO;
    
    // check to see if we received an error; if not, save off the data and prep it.
    if ([loadedTopics isKindOfClass:[NSError class]]) {
        topicsLoadFailure = YES;
    } else {
        topicsLoadFailure = NO;
        self.topics = loadedTopics;
        [self prepareData];
    }
    
    // is there another load in progress?  if so, wait; if not, be done loading.
    if (courseRefreshInProgress) {
        return;
    } else {
        [self loadingComplete];
    }
}

- (void)loadingComplete {
    if (topicsLoadFailure || coursesLoadFailure) {
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
    topicsLoadFailure = NO;
    coursesLoadFailure = NO;
}

- (void)prepareData {
    
    // debug code to make sure we have some items for today and yesterday
    //    for  (ActivityStreamItem* aitem in self.activityStream.items) {
    //        int x = arc4random() % 100;
    //        if (x > 50) {
    //            aitem.postedTime = today;
    //        }
    //        if (x > 75) {
    //            aitem.postedTime = [dateCalculator addDays:-1 toDate:today];
    //        }
    //    }
    
    // if there's no topics, return.
    if (!self.topics || ([self.topics count] == 0)) {
        return;
    }
    
    // TODO: sorting topics
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
    // TODO: hook this up to the number of returned courses
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: hook this up to the actual number of rows for the course
    return [self.topics count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopicTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TopicTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    UserDiscussionTopic* topic = [self getTopicForIndexPath:indexPath];
    [(TopicTableCell*)cell setData:topic];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath {
    // TODO: get the item for the right course (as specified by the index path)
    return [topics objectAtIndex:indexPath.row];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Section header";
}



@end
