//
//  DiscussionsViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DiscussionsViewController.h"
#import "UIColor+Boost.h"
#import "UserDiscussionTopic.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"
#import "TopicTableCell.h"
#import "TopicResponsesViewController.h"
#import "ECClientConfiguration.h"
#import "GreyTableHeader.h"
#import <QuartzCore/CoreAnimation.h>

NSInteger topicInfoSort(NSDictionary* obj1, NSDictionary* obj2, void *context)
{
    Course* c1 = [obj1 objectForKey:@"course"];
    Course* c2 = [obj1 objectForKey:@"course"];
    
    if( !c2 || !c2.title) {
        if( !c1 || !c1.title ) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    } else if( !c1 || !c1.title ) {
        return NSOrderedDescending;
    }
    
    NSString* name1 = c1.title;
    NSString* name2 = c2.title;
    
    return [name1 caseInsensitiveCompare:name2];
}

@interface DiscussionsViewController ()

@property (nonatomic, retain) UserDiscussionTopicFetcher* userDiscussionTopicFetcher;
@property (nonatomic, retain) NSMutableArray* orderedCourseInfo;
@property (nonatomic, retain) NSMutableDictionary* courseInfoByCourseId;
@property (nonatomic, retain) NSMutableArray* courseNames;
@property (nonatomic, retain) UIPickerView* picker;
@property (nonatomic, retain) UIView* filterView;
@property (nonatomic, retain) IBOutlet UILabel* tableTitle;
@property (nonatomic, retain) UIView* blockingModalView;

- (void)loadData;
- (void)prepareData;
- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath;
- (void)registerForCoursesNotifications;
- (void)unregisterForCoursesNotifications;
- (void)handleCoursesRefreshSuccess:(NSNotification*)notification;
- (void)handleCoursesRefreshFailure:(NSNotification*)notification;
- (void)loadingComplete;
- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)filterDoneButtonTapped:(id)sender;
- (void)applyFilter;
- (void)filterAppearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;
- (void)filterDisappearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;
- (IBAction)refreshWithModalSpinner;

@end

@implementation DiscussionsViewController

@synthesize userDiscussionTopicFetcher;
@synthesize topics;
@synthesize lastUpdateTime;
@synthesize orderedCourseInfo;
@synthesize courseInfoByCourseId;
@synthesize courseNames;
@synthesize picker;
@synthesize filterView;
@synthesize tableTitle;
@synthesize blockingModalView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedFilterRow = -1;
        self.userDiscussionTopicFetcher = [[UserDiscussionTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyTopicsHandler:)];    
        [self registerForCoursesNotifications];
    }
    return self;
}

- (void)dealloc
{
    self.blockingModalView = nil;
    self.filterView = nil;
    [self unregisterForCoursesNotifications];
    self.topics = nil;
    self.tableTitle = nil;
    self.lastUpdateTime = nil;
    self.courseNames = nil;
    [self.userDiscussionTopicFetcher cancel];
    self.userDiscussionTopicFetcher = nil;
    self.orderedCourseInfo = nil;
    self.courseInfoByCourseId = nil;
    self.picker = nil;
    [blockingActivityView release];
    [super dealloc];
}

- (IBAction)filterButtonTapped:(id)sender {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.blockingModalView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.filterView];

    // make sure the choices are set correctly in the filter picker
    [picker reloadAllComponents];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(filterAppearAnimationStopped:finished:context:)];    
    CGRect filterViewFrame = filterView.frame;
    filterViewFrame.origin.y = 0;
    filterView.frame = filterViewFrame;
    blockingModalView.alpha = 0.45;
    [UIView commitAnimations];
}

- (IBAction)filterDoneButtonTapped:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(filterDisappearAnimationStopped:finished:context:)];    
    CGRect filterViewFrame = filterView.frame;
    filterViewFrame.origin.y = 480;
    filterView.frame = filterViewFrame;
    blockingModalView.alpha = 0;
    [UIView commitAnimations];
}

- (void)filterAppearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context {
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDidStopSelector:nil];
}

- (void)filterDisappearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context {
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDidStopSelector:nil];
    [self.filterView removeFromSuperview];
    [self.blockingModalView removeFromSuperview];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (row == 0) {
        // "ALL COURSES" was selected
        selectedFilterRow = -1; 
    } else {
        selectedFilterRow = row - 1;
    }    

    self.tableTitle.text = [self.courseNames objectAtIndex:row];
    
    [self applyFilter];
}

- (void)applyFilter {
    [self.table reloadData];
}

- (IBAction)pickerButtonPressed {
    NSInteger row = [picker selectedRowInComponent:0];
    NSLog(@"Selected: %@", [courseNames objectAtIndex:row]);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [courseNames count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [courseNames objectAtIndex:row];
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
    if ([[eCollegeAppDelegate delegate] shouldRefreshCourses]) {
        [[eCollegeAppDelegate delegate] refreshCourseList];
    } else {
        [self.userDiscussionTopicFetcher cancel];
        [self.userDiscussionTopicFetcher fetchDiscussionTopicsForCourseIds:[[eCollegeAppDelegate delegate] getAllCourseIds]];        
    }
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
    // if courses were refreshed because we're loading, that means
    // we can potentially immediately update the interface.
    if (currentlyLoading) {
        coursesLoadFailure = NO;
        [self.userDiscussionTopicFetcher cancel];
        [self.userDiscussionTopicFetcher fetchDiscussionTopicsForCourseIds:[[eCollegeAppDelegate delegate] getAllCourseIds]];        
    }
    
    // if courses were refreshed from some other place in the application,
    // force the activities to reload the next time this view appears.
    else {
        forceUpdateOnViewWillAppear = YES;
    }
}

- (void)handleCoursesRefreshFailure:(NSNotification*)notification {
    // if the failure happened passively (this view didn't request an
    // update of the courses), then don't do anything.
    if (currentlyLoading) {
        NSLog(@"ERROR loading courses; can't load topics.");
        coursesLoadFailure = YES;
        [self loadingComplete];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    tableTitle.layer.shadowColor = [[UIColor blackColor] CGColor];
    tableTitle.layer.shadowRadius = 1.0;
    tableTitle.layer.shadowOpacity = 0.9;
    tableTitle.layer.shadowOffset = CGSizeMake(0, -1);    

    // get the configuration
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    blockingModalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    blockingModalView.backgroundColor = [UIColor blackColor];
    blockingModalView.alpha = 0;
    
    filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
    filterView.backgroundColor = [UIColor clearColor];
    
    // put a toolbar on top of the filter view
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 220, 320, 44)];
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(filterDoneButtonTapped:)] autorelease];    
    NSArray* buttons = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    [toolBar setItems:buttons];
    toolBar.tintColor = [config secondaryColor];
    [filterView addSubview:toolBar];
	[toolBar release];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 264, 320, 216)];
    picker.showsSelectionIndicator = YES;
    picker.dataSource = self;
    picker.delegate = self;
    [filterView addSubview:picker];


    // Do any additional setup after loading the view from its nib.
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the topics again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self refreshWithModalSpinner];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedMyTopicsHandler:(NSArray*)loadedTopics {
    // check to see if we received an error; if not, save off the data and prep it.
    if ([loadedTopics isKindOfClass:[NSError class]]) {
        topicsLoadFailure = YES;
    } else {
        topicsLoadFailure = NO;
        self.topics = loadedTopics;
        [self prepareData];
    }
    
    [self loadingComplete];
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

- (NSMutableDictionary*)getInfoForCourseId:(NSString*)courseId {
    return [courseInfoByCourseId objectForKey:courseId];
}

- (NSMutableDictionary*)createInfoForCourseId:(NSString*)courseId {
    Course* c = [[eCollegeAppDelegate delegate] getCourseHavingId:[courseId integerValue]];
    
    // it wasn't found, so create it
    NSMutableDictionary* tmp = [[[NSMutableDictionary alloc] initWithCapacity:3] autorelease];
    [tmp setValue:c forKey:@"course"];
    [tmp setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"active_topics"];
    [tmp setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"inactive_topics"];
    [orderedCourseInfo addObject:tmp];
    [courseInfoByCourseId setValue:tmp forKey:[NSString stringWithFormat:@"%@",c.courseId]];
    
    return tmp;
}

- (void)storeTopic:(UserDiscussionTopic*)topic {
    
    NSString* courseId = nil;
    if (topic && topic.topic && topic.topic.containerInfo) {
        courseId = [NSString stringWithFormat:@"%d",topic.topic.containerInfo.courseId];
    }

    if (!courseId) {
        NSLog(@"ERROR: cannot store topic %@; has an invalid courseId", topic);
        return;
    }

    NSMutableDictionary* dict = [self getInfoForCourseId:courseId];
    if (!dict) {
        dict = [self createInfoForCourseId:courseId];
    }
    
    if ([topic isActive]) {
        NSMutableArray* activeTopics = [dict objectForKey:@"active_topics"];
        [activeTopics addObject:topic];
        return;
    } else {
        NSMutableArray* inactiveTopics = [dict objectForKey:@"inactive_topics"];
        [inactiveTopics addObject:topic];
        return;
    } 
}

- (NSMutableArray*)getActiveTopicsForCourseId:(NSString*)courseId {
    NSDictionary* tmp = [self getInfoForCourseId:courseId];
    if (tmp) {
        return [tmp objectForKey:@"active_topics"];
    } else {
        return nil;
    }
}

- (NSMutableArray*)getInactiveTopicsForCourseId:(NSString*)courseId {
    NSDictionary* tmp = [self getInfoForCourseId:courseId];
    if (tmp) {
        return [tmp objectForKey:@"inactive_topics"];
    } else {
        return nil;
    }
}

- (void)setupCourseNamesArray {
    
    // Create a new array...
    self.courseNames = [[[NSMutableArray alloc] initWithCapacity:[self.orderedCourseInfo count]+1] autorelease];
    
    // Add an "All Courses" element...
    [courseNames addObject:NSLocalizedString(@"All Courses", nil)];
    
    // Populate the array with course names, in the same order as in the ordered course info box
    for (NSDictionary* tmp in self.orderedCourseInfo) {
        Course* course = [tmp objectForKey:@"course"];
        if (course) {
            [courseNames addObject:course.title];
        }
    }

}

- (void)prepareData {
    
    NSInteger numCourses = [[[eCollegeAppDelegate delegate] getAllCourseIds] count];
    
    // hold a dictionary of information for each course
    self.orderedCourseInfo = [[[NSMutableArray alloc] initWithCapacity:numCourses] autorelease];
    
    // create a dictionary linking course ID -> course info
    self.courseInfoByCourseId = [[[NSMutableDictionary alloc] initWithCapacity:numCourses] autorelease];
    
    // store the topics appropriately
    for (UserDiscussionTopic* topic in self.topics) {        
        [self storeTopic:topic];
    }
    
    // sort the course info
    self.orderedCourseInfo = [[self.orderedCourseInfo sortedArrayUsingFunction:topicInfoSort context:NULL] mutableCopy];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (selectedFilterRow == -1) {
        return [self.orderedCourseInfo count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if there's a filter applied, then we need to override which section
    // we're providing data bout.
    if (selectedFilterRow != -1) {
        section = selectedFilterRow;
    }
        
    NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:section];
    NSArray* array = [dict objectForKey:@"active_topics"];
    if (array) {
        int cnt = [array count];
        if (cnt == 0) {
            // no data row / tap-to-see-inactive cell
            return 1;
        } else {
            // all active cells + the tap-to-see-inactive cell
            return cnt + 1;
        }
    } else {
        NSLog(@"ERROR: No array for section %d",section);
        // no data row
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self getTopicForIndexPath:indexPath]) {
        return 71.0;
    } else {
        return 50.0;
    }
}

- (BOOL)hasInactiveTopicsForSection:(NSInteger)section {
    NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:section];
    NSString* courseId = [dict objectForKey:@"courseId"];
    NSMutableDictionary* d = [self getInfoForCourseId:courseId];
    id ary = [d objectForKey:@"inactive_topics"];
    return (ary && [ary isKindOfClass:[NSArray class]] && [ary count] > 0);
}

- (BOOL)hasActiveTopicsForSection:(NSInteger)section {
    NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:section];
    NSString* courseId = [dict objectForKey:@"courseId"];
    NSMutableDictionary* d = [self getInfoForCourseId:courseId];
    id ary = [d objectForKey:@"active_topics"];
    return (ary && [ary isKindOfClass:[NSArray class]] && [ary count] > 0);
}

- (Course*)courseForSection:(NSInteger)section {
    NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:section];
    NSString* courseId = [dict objectForKey:@"courseId"];
    if (courseId && ![courseId isEqualToString:@""]) {
        return [[eCollegeAppDelegate delegate] getCourseHavingId:[courseId integerValue]];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDiscussionTopic* topic = [self getTopicForIndexPath:indexPath];
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    UITableViewCell *cell;
    if (topic) {
        static NSString *CellIdentifier = @"TopicTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TopicTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [(TopicTableCell*)cell setData:topic];
    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }

        cell.textLabel.font = [config cellItalicsFont];
        cell.textLabel.textColor = [config greyColor];

        Course* c = [self courseForSection:indexPath.section];
        NSString* title = c ? c.title : @"error";
        if ([self hasInactiveTopicsForSection:indexPath.section]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"All topics for",nil), title];
        } else {
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"No active or inactive topics for",nil), title];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"No inactive topics for",nil), title];
            }
        }
    }
    return cell;
}

- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath {
    
    int sectionToUse;
    // if there's a filter applied, then indexPath isn't accurate...
    if (selectedFilterRow != -1) {
        sectionToUse = selectedFilterRow;
    } else {
        sectionToUse = indexPath.section;
    }
    
    UserDiscussionTopic* returnValue = nil;
    if (sectionToUse < [self.orderedCourseInfo count]) {
        NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:sectionToUse];
        if (dict) {
            NSArray* ary = [dict objectForKey:@"active_topics"];
            if (ary && (indexPath.row < [ary count])) {
                returnValue = [ary objectAtIndex:indexPath.row];
            }
        }
    }
    return returnValue;
}

- (void)forceFutureRefresh {    
    forceUpdateOnViewWillAppear = YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDiscussionTopic* topic = [self getTopicForIndexPath:indexPath];
    if (topic) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        TopicResponsesViewController* topicResponsesViewController = [[TopicResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
        NSLog(@"Initializing Topic Responses view controller with root item ID: %@",topic.userDiscussionTopicId);
        topicResponsesViewController.rootItemId = topic.userDiscussionTopicId;
        topicResponsesViewController.hidesBottomBarWhenPushed = YES;
        topicResponsesViewController.parent = self;
        [self.navigationController pushViewController:topicResponsesViewController animated:YES];
        [topicResponsesViewController release];
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (selectedFilterRow != -1) {
		return nil; // will hide the section header when the table is filtered
    }

    NSDictionary* dict = [self.orderedCourseInfo objectAtIndex:section];
    NSString* courseId = [dict objectForKey:@"courseId"];
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:[courseId integerValue]];
    if (course) {
        return [[[GreyTableHeader alloc] initWithText:course.title] autorelease];
    } else {
        NSLog(@"Error: no course returned for id %@",courseId);
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 30.0;
}

@end
