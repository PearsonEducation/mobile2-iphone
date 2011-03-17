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
#import "InfoTableViewController.h"
#import "UIColor+Boost.h"
#import "ActivityTableCell.h"
#import "ActivityStreamItem.h"
#import "ActivityStreamObject.h"
#import "DateCalculator.h"
#import "eCollegeAppDelegate.h"
#import "GradebookItemGradeDetailViewController.h"
#import "NSDateUtilities.h"

@interface HomeViewController ()

@property (nonatomic, retain) ActivityStreamFetcher* activityStreamFetcher;

- (void)loadData;
- (void)prepareData;
- (void)infoButtonTapped:(id)sender;
- (void)cancelButtonClicked:(id)sender;
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
        // date calculator
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
        dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian];
        [gregorian release];
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

- (void)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        int numDays = [dateCalculator datesFrom:today to:item.postedTime];
        item.friendlyDate = [item.postedTime friendlyDateFor:numDays];
        if (numDays == 0) {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 51.0;
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
    
    // based on the type of the activity stream item, push a view controller.
    if ([itemType isEqualToString:@"thread-topic"]) {
        return;
    } else if ([itemType isEqualToString:@"thread-post"]) {
        return;
    } else if ([itemType isEqualToString:@"grade"]) {
        GradebookItemGradeDetailViewController* gradebookItemGradeDetailViewController = [[GradebookItemGradeDetailViewController alloc] initWithItem:item];
        gradebookItemGradeDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gradebookItemGradeDetailViewController animated:YES];
        [gradebookItemGradeDetailViewController release];        
    } else if ([itemType isEqualToString:@"dropbox-submission"]) {
        return;
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
