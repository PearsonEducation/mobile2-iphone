//
//  HomeViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "HomeViewController.h"
#import "NSDateUtilities.h"
#import "ActivityStreamItem.h"
#import "UIColor+Boost.h"
#import "ActivityTableCell.h"
#import "ActivityStreamItem.h"
#import "ActivityStreamObject.h"
#import "eCollegeAppDelegate.h"
#import "GradebookItemGradeDetailViewController.h"
#import "NSDateUtilities.h"
#import "DropboxMessageDetailViewController.h"
#import "ResponseResponsesViewController.h"
#import "TopicResponsesViewController.h"
#import "ECSession.h"
#import "ECClientConfiguration.h"

@interface HomeViewController ()

@property (nonatomic, retain) ActivityStreamFetcher* activityStreamFetcher;

- (void)loadData;
- (void)prepareData;
- (ActivityStreamItem*)getItemForIndexPath:(NSIndexPath*)indexPath;
- (void)registerForCoursesNotifications;
- (void)unregisterForCoursesNotifications;
- (void)handleCoursesRefreshSuccess:(NSNotification*)notification;
- (void)handleCoursesRefreshFailure:(NSNotification*)notification;
- (void)loadingComplete;

@end

@implementation HomeViewController

@synthesize activityStreamFetcher;
@synthesize activityStream;
@synthesize earlierActivityItems;
@synthesize todayActivityItems;
@synthesize lastUpdateTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // activity view
        blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
        [self registerForCoursesNotifications];

    }
    return self;
}

- (void)dealloc
{
    [self unregisterForCoursesNotifications];
    self.earlierActivityItems = nil;
    self.todayActivityItems = nil;
    self.activityStream = nil;
    self.lastUpdateTime = nil;
    [self.activityStreamFetcher cancel];
    self.activityStreamFetcher = nil;
    [blockingActivityView release];
    [today release];
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
    
    // if course data is stale, refresh it.
    if ([[eCollegeAppDelegate delegate] shouldRefreshCourses]) {
        courseRefreshInProgress = YES;
        [[eCollegeAppDelegate delegate] refreshCourseList];
    }
  
    // fetch activities
    if (!self.activityStreamFetcher) {
        self.activityStreamFetcher = [[ActivityStreamFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyActivityStreamHandler:)];    
    } else {
        [self.activityStreamFetcher cancel];
    }
    activitiesRefreshInProgress = YES;
    [activityStreamFetcher fetchMyActivityStream];    
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
    [super didReceiveMemoryWarning];
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
        if (activitiesRefreshInProgress) {
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

- (void)viewWillDisappear:(BOOL)animated {
    [activityStreamFetcher cancel];
    [blockingActivityView hide];
}

- (void)handleCoursesRefreshFailure:(NSNotification*)notification {
    courseRefreshInProgress = NO;
    NSLog(@"ERROR loading courses; can't move past login screen.");
    
    // if the failure happened passively (this view didn't request an
    // update of the courses), then don't do anything.
    if (currentlyLoading) {
        coursesLoadFailure = YES;
        if (activitiesRefreshInProgress) {
            return;
        } else {
            [self loadingComplete];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {

    segmentedControlBackground.midColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
    filter.tintColor = [[ECClientConfiguration currentConfiguration] secondaryColor];

    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the activities again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedMyActivityStreamHandler:(ActivityStream*)loadedActivityStream {
    activitiesRefreshInProgress = NO;
    
    // check to see if we received an error; if not, save off the data and prep it.
    if ([loadedActivityStream isKindOfClass:[NSError class]]) {
        activitiesLoadFailure = YES;
    } else {
        activitiesLoadFailure = NO;
        self.activityStream = loadedActivityStream;
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
    if (activitiesLoadFailure || coursesLoadFailure) {
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
    activitiesLoadFailure = NO;
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
    
    // create new buckets for items sorted by time
    self.todayActivityItems = [[NSMutableArray alloc] init];
    self.earlierActivityItems = [[NSMutableArray alloc] init];
    
    // if there's no activity stream, return.
    if (!self.activityStream || !self.activityStream.items || ([self.activityStream.items count] == 0)) {
        return;
    }
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"postedTime" ascending:NO selector:@selector(compare:)];
    NSArray* descriptors = [[NSArray alloc] initWithObjects:sd,nil];
    self.activityStream.items = [self.activityStream.items sortedArrayUsingDescriptors:descriptors];
    
    [descriptors release];
    [sd release];

    
    // sort the activity stream items by date
    for  (ActivityStreamItem* item in self.activityStream.items) {
        item.friendlyDate = [item.postedTime friendlyString];
        if ([item.postedTime isToday]) {
            [self.todayActivityItems addObject:item];
        } else {
            [self.earlierActivityItems addObject:item];            
        }
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (BOOL)hasTodayItems {
    return ([self.todayActivityItems count] > 0);     
}

- (BOOL)hasEarlierItems {
    return ([self.earlierActivityItems count] > 0);         
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int cnt = 0;
    if ([self hasTodayItems]) {
        cnt++;
    } 
    if ([self hasEarlierItems]) {
        cnt++;
    } 
    return cnt;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && [self hasTodayItems]) {
        return [self.todayActivityItems count];
    } else if ([self hasEarlierItems]) {
        return [self.earlierActivityItems count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ActivityTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Find the data for the cell...
    ActivityStreamItem* item = [self getItemForIndexPath:indexPath];

    // set up the cell
    if (item) {
        [(ActivityTableCell*)cell setData:item];

    }
    return cell;
}

- (ActivityStreamItem*)getItemForIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0 && [self hasTodayItems]) {
        if (self.todayActivityItems && [self.todayActivityItems count] > indexPath.row) {
            return [self.todayActivityItems objectAtIndex:indexPath.row];            
        } else {
            return nil;
        }
    } else if ([self hasEarlierItems]) {
        if (self.earlierActivityItems && [self.earlierActivityItems count] > indexPath.row) {
            return [self.earlierActivityItems objectAtIndex:indexPath.row];            
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // get the activity stream item
    ActivityStreamItem* item = [self getItemForIndexPath:indexPath];
    if (!item) {
        NSLog(@"ERROR: unable to find ActivityStreamItem for selected row.");
        return;
    }
    
    // determine the type of the activity stream item
    NSString* itemType = [item getType];
    if (!itemType) {
        NSLog(@"ERROR: item for selected row does not have an objectType.");
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // based on the type of the activity stream item, push a view controller.
    if ([itemType isEqualToString:@"thread-topic"]) {
        NSInteger userId = [[[eCollegeAppDelegate delegate] currentUser] userId];
        NSString* refId = item.object.referenceId;
        TopicResponsesViewController* trvc = [[TopicResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
        trvc.rootItemId = [NSString stringWithFormat:@"%d-%@",userId,refId];
        NSLog(@"Setting ID on TopicResponsesViewController to: %@", trvc.rootItemId);
        trvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:trvc animated:YES];
        [trvc release];
    } else if ([itemType isEqualToString:@"thread-post"]) {
        NSInteger userId = [[[eCollegeAppDelegate delegate] currentUser] userId];
        NSString* refId = item.object.referenceId;
        ResponseResponsesViewController* rrvc = [[ResponseResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
        rrvc.rootItemId = [NSString stringWithFormat:@"%d-%@",userId,refId];
        NSLog(@"Setting ID on ResponseResponsesViewController to: %@", rrvc.rootItemId);
        rrvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rrvc animated:YES];
        [rrvc release];
    } else if ([itemType isEqualToString:@"grade"]) {
        GradebookItemGradeDetailViewController* gradebookItemGradeDetailViewController = [[GradebookItemGradeDetailViewController alloc] initWithItem:item];
        gradebookItemGradeDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gradebookItemGradeDetailViewController animated:YES];
        [gradebookItemGradeDetailViewController release];        
    } else if ([itemType isEqualToString:@"dropbox-submission"]) {
        DropboxMessageDetailViewController* dropboxMessageDetailViewController = [[DropboxMessageDetailViewController alloc] initWithCourseId:item.object.courseId basketId:item.target.referenceId messageId:item.object.referenceId];
        dropboxMessageDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dropboxMessageDetailViewController animated:YES];
        [dropboxMessageDetailViewController release];
    } else if ([itemType isEqualToString:@"exam-submission"]) {
        return;
    } else if ([itemType isEqualToString:@"remark"]) {
        return;
    } else {
        NSLog(@"ERROR: Unknown objectType '%@' on selected ActivityStreamItem", itemType);
        return;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self hasTodayItems]) {
        return NSLocalizedString(@"Today",@"The word meaning 'today'");
    } else if ([self hasEarlierItems]) {
        return NSLocalizedString(@"Earlier",@"The word meaning 'earlier'");
    } else {
        return @"";
    }
}

@end
