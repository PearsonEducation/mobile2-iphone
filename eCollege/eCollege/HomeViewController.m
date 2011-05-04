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
#import "DropboxMessageDetailViewController.h"
#import "ResponseResponsesViewController.h"
#import "TopicResponsesViewController.h"
#import "ECSession.h"
#import "ECClientConfiguration.h"
#import "GreyTableHeader.h"
#import "UpcomingEventItem.h"
#import "UpcomingEventItemTableCell.h"
#import "ThreadTopicsViewController.h"
#import "UpcomingHTMLContentViewController.h"

#define ACTIVITY_STREAM 0
#define UPCOMING_EVENTS 1

@interface HomeViewController ()

@property (nonatomic, retain) ActivityStreamFetcher* activityStreamFetcher;
@property (nonatomic, retain) UpcomingEventItemsFetcher* upcomingEventItemsFetcher;

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

// ACTIVITY STREAM
@synthesize activityStreamFetcher;
@synthesize activityStream;
@synthesize earlierActivityItems;
@synthesize todayActivityItems;
@synthesize activityStreamLastUpdateTime;

// UPCOMING EVENTS
@synthesize upcomingEventItemsFetcher;
@synthesize upcomingEvents;
@synthesize todayUpcomingEvents;
@synthesize tomorrowUpcomingEvents;
@synthesize twoDaysUpcomingEvents;
@synthesize threeDaysUpcomingEvents;
@synthesize fourDaysUpcomingEvents;
@synthesize fiveDaysUpcomingEvents;
@synthesize laterUpcomingEvents;
@synthesize upcomingEventsLastUpdateTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.activityStreamFetcher = [[ActivityStreamFetcher alloc] initWithDelegate:self responseSelector:@selector(itemsLoadedHandler:)];    
        self.upcomingEventItemsFetcher = [[UpcomingEventItemsFetcher alloc] initWithDelegate:self responseSelector:@selector(itemsLoadedHandler:)];        
        blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
        [self registerForCoursesNotifications];

    }
    return self;
}

- (void)dealloc
{
    // ACTIVITY STREAM items
    self.earlierActivityItems = nil;
    self.todayActivityItems = nil;
    self.activityStream = nil;
    [activityStreamFetcher cancel];
    self.activityStreamFetcher = nil;
    self.activityStreamLastUpdateTime = nil;    
 
    // UPCOMING EVENT items
    self.upcomingEvents = nil;
    self.todayActivityItems = nil;
    self.tomorrowUpcomingEvents = nil;
    self.twoDaysUpcomingEvents = nil;
    self.threeDaysUpcomingEvents = nil;
    self.fourDaysUpcomingEvents = nil;
    self.fiveDaysUpcomingEvents = nil;
    self.laterUpcomingEvents = nil;
    [upcomingEventItemsFetcher cancel];
    self.upcomingEventItemsFetcher = nil;
    self.upcomingEventsLastUpdateTime = nil;
    
    // OTHER
    [blockingActivityView release];
    [self unregisterForCoursesNotifications];
    
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

    if ([[eCollegeAppDelegate delegate] shouldRefreshCourses]) {
        courseRefreshInProgress = YES;
        [[eCollegeAppDelegate delegate] refreshCourseList];
    }
  
    itemsRefreshInProgress = YES;
    filter.enabled = NO;
    
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        [activityStreamFetcher cancel];        
        [activityStreamFetcher fetchMyActivityStream];    
    } else {
        [upcomingEventItemsFetcher cancel];
        [upcomingEventItemsFetcher fetchMyUpcomingEventItems];
    }
}

- (void)executeAfterHeaderClose {
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        self.activityStreamLastUpdateTime = [NSDate date];
    } else {
        self.upcomingEventsLastUpdateTime = [NSDate date];
    }
}

- (void)updateLastUpdatedLabel {
    NSDate* date;
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        date = activityStreamLastUpdateTime;
    } else {
        date = upcomingEventsLastUpdateTime;
    }
    
    if (date) {
        NSString* prettyTime = [date friendlyString];
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
        if (itemsRefreshInProgress) {
            // need to wait for items refresh to finish
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
    [upcomingEventItemsFetcher cancel];
    [blockingActivityView hide];
}

- (void)handleCoursesRefreshFailure:(NSNotification*)notification {
    courseRefreshInProgress = NO;
    
    // if the failure happened passively (this view didn't request an
    // update of the courses), then don't do anything.
    if (currentlyLoading) {
        coursesLoadFailure = YES;
        if (itemsRefreshInProgress) {
            return;
        } else {
            [self loadingComplete];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    segmentedControlBackground.midColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
    filter.tintColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
}

- (void)viewWillAppear:(BOOL)animated {    
    NSDate* date;
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        date = activityStreamLastUpdateTime;
    } else {
        date = upcomingEventsLastUpdateTime;
    }
    
    if (!date || [date timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)itemsLoadedHandler:(id)data {
    itemsRefreshInProgress = NO;
    
    if ([data isKindOfClass:[ActivityStream class]]) {
        itemsLoadFailure = NO;
        self.activityStream = data;
        [self prepareData];
    } else if ([data isKindOfClass:[NSArray class]]) {
        itemsLoadFailure = NO;
        self.upcomingEvents = data;
        [self prepareData];
    } else {
        itemsLoadFailure = YES;
    }
    
    if (courseRefreshInProgress) {
        return;
    } else {
        [self loadingComplete];
    }
}

- (void)loadingComplete {
    if (itemsLoadFailure || coursesLoadFailure) {
        NSLog(@"Load failure");
    } else {
        [self.table reloadData];
    }
    
    filter.enabled = YES;
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
    
    // tell the modal loading spinner to go away (if it's present)
    [blockingActivityView hide];        

    // no longer loading
    currentlyLoading = NO;
    itemsLoadFailure = NO;
    coursesLoadFailure = NO;
}

/*
/ Set up the buckets into which items (ActivityStreamItem, UpcomingEventItem) will be sorted;
/ These buckets are then used as sections for the table.  Also sort the items so they appear
/ such that the most recent items are on top of each section.
*/
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

    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        // initialize buckets to put activity stream items into
        self.todayActivityItems = [[NSMutableArray alloc] init];
        self.earlierActivityItems = [[NSMutableArray alloc] init];
        if (!activityStream || !activityStream.items || ([activityStream.items count] == 0)) {
            return;
        }
        
        // sort all activity stream items
        NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"postedTime" ascending:NO selector:@selector(compare:)];
        NSArray* descriptors = [[NSArray alloc] initWithObjects:sd,nil];
        activityStream.items = [activityStream.items sortedArrayUsingDescriptors:descriptors];        
        [descriptors release];
        [sd release];
        
        // put sorted activity stream items into buckets
        for  (ActivityStreamItem* item in self.activityStream.items) {
            item.friendlyDate = [item.postedTime friendlyString];
            if ([item.postedTime isToday]) {
                [self.todayActivityItems addObject:item];
            } else {
                [self.earlierActivityItems addObject:item];            
            }
        }
    } else {
        // initialize buckets to put upcoming events into
        self.todayUpcomingEvents = [[NSMutableArray alloc] init];
        self.tomorrowUpcomingEvents = [[NSMutableArray alloc] init];
        self.twoDaysUpcomingEvents = [[NSMutableArray alloc] init];
        self.threeDaysUpcomingEvents = [[NSMutableArray alloc] init];
        self.fourDaysUpcomingEvents = [[NSMutableArray alloc] init];
        self.fiveDaysUpcomingEvents = [[NSMutableArray alloc] init];
        self.laterUpcomingEvents = [[NSMutableArray alloc] init];
        if (!upcomingEvents || [upcomingEvents count] == 0) {
            return;
        }
        
        // sort all upcoming events
        NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"when.time" ascending:NO selector:@selector(compare:)];
        NSArray* descriptors = [[NSArray alloc] initWithObjects:sd,nil];
        self.upcomingEvents = [upcomingEvents sortedArrayUsingDescriptors:descriptors];        
        [descriptors release];
        [sd release];
        
        // put sorted upcoming events into buckets
        NSDate* today = [NSDate date];
        for (UpcomingEventItem* eventItem in upcomingEvents) {
            if (eventItem.when && eventItem.when.time) {
                NSDate* date = eventItem.when.time;
                eventItem.dateString = [date friendlyDateTimeString];
                int numDates = [today datesUntil:date];                
                if (numDates >= 6) {
                    [laterUpcomingEvents addObject:eventItem];
                } else {
                    switch (numDates) {
                        case 0:
                            [todayUpcomingEvents addObject:eventItem];
                            break;
                        case 1:
                            [tomorrowUpcomingEvents addObject:eventItem];
                            break;
                        case 2:
                            [twoDaysUpcomingEvents addObject:eventItem];
                            break;
                        case 3:
                            [threeDaysUpcomingEvents addObject:eventItem];
                            break;
                        case 4:
                            [fourDaysUpcomingEvents addObject:eventItem];
                            break;
                        case 5:
                            [fiveDaysUpcomingEvents addObject:eventItem];
                            break;
                        default:
                            break;
                    }                    
                }
            } else {
                eventItem.dateString = @"";
            }
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSArray*)getSections {
    NSMutableArray* tmp = [[[NSMutableArray alloc] init] autorelease];
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        if ([todayActivityItems count] > 0) {
            [tmp addObject:todayActivityItems];
        }
        if ([earlierActivityItems count] > 0) {
            [tmp addObject:earlierActivityItems];
        }
    } else {
        if ([todayUpcomingEvents count] > 0) {
            [tmp addObject:todayUpcomingEvents];
        }
        if ([tomorrowUpcomingEvents count] > 0) {
            [tmp addObject:tomorrowUpcomingEvents];
        }
        if ([twoDaysUpcomingEvents count] > 0) {
            [tmp addObject:twoDaysUpcomingEvents];
        }
        if ([threeDaysUpcomingEvents count] > 0) {
            [tmp addObject:threeDaysUpcomingEvents];
        }
        if ([fourDaysUpcomingEvents count] > 0) {
            [tmp addObject:fourDaysUpcomingEvents];
        }
        if ([fiveDaysUpcomingEvents count] > 0) {
            [tmp addObject:fiveDaysUpcomingEvents];
        }
        if ([laterUpcomingEvents count] > 0) {
            [tmp addObject:laterUpcomingEvents];
        }        
    }
    return tmp;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray* tmp = [self getSections];
    if (tmp) {
        return [tmp count];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* tmp = [self getSections];
    if (section < [tmp count]) {
        NSArray* arr = [tmp objectAtIndex:section];
        return [arr count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  70.0;
}

- (id)getItemForIndexPath:(NSIndexPath*)indexPath {
    NSArray* sections = [self getSections];
    if (indexPath.section < [sections count]) {
        NSArray* itemsForSection = [sections objectAtIndex:indexPath.section];
        if (indexPath.row < [itemsForSection count]) {
            return [itemsForSection objectAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self getItemForIndexPath:indexPath];
    if (!item) {
        return nil;
    }

    UITableViewCell* cell;
    static NSString *CellIdentifier;
    
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        CellIdentifier = @"ActivityTableCell";
    } else {
        CellIdentifier = @"UpcomingEventItemTableCell";
    }

    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([cell isKindOfClass:[ActivityTableCell class]]) {
        [(ActivityTableCell*)cell setData:(ActivityStreamItem*)item];
    } else {
        [(UpcomingEventItemTableCell*)cell setData:(UpcomingEventItem*)item];
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    id obj = [self getItemForIndexPath:indexPath];
    if (!obj) {
        NSLog(@"ERROR: unable to find item for selected row.");
        return;
    }
    
    if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
        ActivityStreamItem* item = (ActivityStreamItem*)obj;        
        NSString* itemType = [item getType];
        if (!itemType) {
            NSLog(@"ERROR: item for selected row does not have an objectType.");
            return;
        }
                
        // based on the type of the activity stream item, push a view controller.
        if ([itemType isEqualToString:@"thread-topic"]) {
            NSNumber* userId = [[[eCollegeAppDelegate delegate] currentUser] userId];
            NSString* refId = item.object.referenceId;
            TopicResponsesViewController* trvc = [[TopicResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
            trvc.rootItemId = [NSString stringWithFormat:@"%d-%@",userId,refId];
            NSLog(@"Setting ID on TopicResponsesViewController to: %@", trvc.rootItemId);
            trvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:trvc animated:YES];
            [trvc release];
        } else if ([itemType isEqualToString:@"thread-post"]) {
            NSNumber* userId = [[[eCollegeAppDelegate delegate] currentUser] userId];
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
    } else {
        UpcomingEventItem *event = (UpcomingEventItem *)obj;
		UpcomingEventType eventType = event.eventType;
		UIViewController *vc = nil;
		ThreadTopicsViewController *ttvc = nil;
		UpcomingHTMLContentViewController *htmlvc = nil;
		switch (eventType) {
			case Html:
				htmlvc = [[UpcomingHTMLContentViewController alloc] initWithNibName:@"UpcomingHTMLContentViewController" bundle:nil];
				htmlvc.item = event;
				vc = htmlvc;
				break;
			case QuizExamTest:
				// do nothing - quizzes aren't selectable
				break;
			case Thread:
				ttvc = [[ThreadTopicsViewController alloc] initWithNibName:@"ThreadTopicsViewController" bundle:nil];
				ttvc.item = event;
				vc = ttvc;
				break;
			case Ignored:
				// Ignore the Ignored.
				break;
		}
		if (vc) [self.navigationController pushViewController:vc animated:YES];
		[vc release];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    NSString *str = nil;
    NSArray *sections = [self getSections];
    if (section < [sections count]) {
        NSArray *itemsForSection = [sections objectAtIndex:section];
        // This if statement isn't strictly necessary; just throwing it in for minor performance savings
        if (filter.selectedSegmentIndex == ACTIVITY_STREAM) {
            if (itemsForSection == todayActivityItems) {
                str = NSLocalizedString(@"Today",nil);
            } else if (itemsForSection == earlierActivityItems) {
                str = NSLocalizedString(@"Earlier",nil);
            } else {
                str = @"Error: unknown section";
            }
        } else {
            if (itemsForSection == todayUpcomingEvents) {
                str = NSLocalizedString(@"Today",nil);                
            } else if (itemsForSection == tomorrowUpcomingEvents) {
                str = NSLocalizedString(@"Tomorrow",nil);
            } else if (itemsForSection == twoDaysUpcomingEvents) {
                str = NSLocalizedString(@"In two days", nil);
            }  else if (itemsForSection == threeDaysUpcomingEvents) {
                str = NSLocalizedString(@"In three days", nil);
            }  else if (itemsForSection == fourDaysUpcomingEvents) {
                str = NSLocalizedString(@"In four days", nil);
            }  else if (itemsForSection == fiveDaysUpcomingEvents) {
                str = NSLocalizedString(@"In five days", nil);
            } else if (itemsForSection == laterUpcomingEvents) {
                str = NSLocalizedString(@"Later", nil);
            } else {
                str = @"Error: unknown section";
            }
        }
    }
    return [[[GreyTableHeader alloc] initWithText:str] autorelease];        
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 30.0;
}

@end
