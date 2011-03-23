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
@property (nonatomic, retain) NSMutableArray* courseIdsAndTopicArrays;
@property (nonatomic, retain) NSMutableArray* courseNames;
@property (nonatomic, retain) UIPickerView* picker;
@property (nonatomic, retain) UIView* filterView;
@property (nonatomic, retain) IBOutlet UILabel* tableTitle;
@property (nonatomic, retain) UIView* blockingModalView;

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
- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)filterDoneButtonTapped:(id)sender;
- (void)applyFilter;
- (void)filterAppearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;
- (void)filterDisappearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;


@end

@implementation DiscussionsViewController

@synthesize userDiscussionTopicFetcher;
@synthesize topics;
@synthesize lastUpdateTime;
@synthesize today;
@synthesize courseIdsAndTopicArrays;
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
    self.blockingModalView = nil;
    self.filterView = nil;
    [self unregisterForCoursesNotifications];
    self.topics = nil;
    self.tableTitle = nil;
    self.lastUpdateTime = nil;
    self.courseNames = nil;
    [self.userDiscussionTopicFetcher cancel];
    self.userDiscussionTopicFetcher = nil;
    self.courseIdsAndTopicArrays = nil;
    self.picker = nil;
    [blockingActivityView release];
    [dateCalculator release];
    [today release];
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
    blockingModalView.alpha = 0.25;
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


- (void)infoButtonTapped:(id)sender {
    InfoTableViewController* infoTableViewController = [[InfoTableViewController alloc] initWithNibName:@"InfoTableViewController" bundle:nil];
    infoTableViewController.cancelDelegate = self;
    UINavigationController *infoNavController = [[UINavigationController alloc] initWithRootViewController:infoTableViewController];
    [self presentModalViewController:infoNavController animated:YES];
    [infoNavController release];
    [infoTableViewController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        NSLog(@"Apply");
    } else {
        NSLog(@"Cancel");
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    blockingModalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    blockingModalView.backgroundColor = [UIColor blackColor];
    blockingModalView.alpha = 0;
    
    filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
    filterView.backgroundColor = [UIColor clearColor];
    
    // put a toolbar on top of the filter view
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 220, 320, 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(filterDoneButtonTapped:)];    
    NSArray* buttons = [[NSArray alloc] initWithObjects:flexibleSpace, doneButton, nil];
    [toolBar setItems:buttons];
    [filterView addSubview:toolBar];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 264, 320, 216)];
    picker.showsSelectionIndicator = YES;
    picker.dataSource = self;
    picker.delegate = self;
    [filterView addSubview:picker];


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

- (void)prepareData {
    
    if (!self.topics || ([self.topics count] == 0)) {
        return;
    }
    
    NSArray* courseIds = [[eCollegeAppDelegate delegate] getAllCourseIds];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:[courseIds count]];
    
    // make an array for each courseID, to hold its topics; store that array in a dictionary
    for (NSNumber* courseIdNumber in courseIds) {
        NSMutableArray* arrayOfTopics = [[[NSMutableArray alloc] init] autorelease];
        [dict setValue:arrayOfTopics forKey:[courseIdNumber stringValue]];
    }
    
    // add all topics to the appropriate array
    for (UserDiscussionTopic* topic in self.topics) {
        // get the course ID
        int cid;
        if (topic && topic.topic && topic.topic.containerInfo) {
            cid = topic.topic.containerInfo.courseId;
        } else {
            NSLog(@"ERROR: topic %@ does not have a courseId",topic);
            continue;
        }
        NSString* scid = [NSString stringWithFormat:@"%d",cid];
        
        // get the array associated with that course id from dict
        NSMutableArray* topicsForCourseId = [dict objectForKey:scid];
        if (!topicsForCourseId) {
            NSLog(@"ERROR: shouldn't have a new courseID at this point...");
            continue;
        }
        
        // add the topic to that array
        [topicsForCourseId addObject:topic];
    }
    
    // make an array, one slot per course.  each slot will contain a dictionary with two
    // tuples: courseId -> value, topics -> value
    self.courseIdsAndTopicArrays = nil;
    self.courseNames = [[[NSMutableArray alloc] initWithCapacity:[courseIds count]+1] autorelease];
    [self.courseNames addObject:NSLocalizedString(@"All Courses", nil)];
    courseIdsAndTopicArrays = [[NSMutableArray alloc] initWithCapacity:[courseIds count]];
    for (NSString* key in [dict allKeys]) {
        Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:[key integerValue]];
        if (course) {
            NSLog(@"Adding course: %@", course.title);
            [courseNames addObject:course.title];
        } else {
            NSLog(@"ERROR: no course for id %d",[key integerValue]);
        }
        NSMutableDictionary* tmp = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
        [tmp setValue:key forKey:@"courseId"];
        [tmp setValue:[dict valueForKey:key] forKey:@"topics"];
        [self.courseIdsAndTopicArrays addObject:tmp];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (selectedFilterRow == -1) {
        NSLog(@"NUMBER OF SECTIONS: %d",[self.courseIdsAndTopicArrays count]);
        return [self.courseIdsAndTopicArrays count];
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
        
    NSDictionary* dict = [self.courseIdsAndTopicArrays objectAtIndex:section];
    NSArray* array = [dict objectForKey:@"topics"];
    if (array) {
        int cnt = [array count];
        if (cnt == 0) {
            // no data row
            return 1;
        } else {
            return cnt;
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
        return 30.0;        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDiscussionTopic* topic = [self getTopicForIndexPath:indexPath];
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
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = NSLocalizedString(@"No topics for this class",nil);
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

- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath {
    
    int sectionToUse;
    // if there's a filter applied, then indexPath isn't accurate...
    if (selectedFilterRow != -1) {
        sectionToUse = selectedFilterRow;
    } else {
        sectionToUse = indexPath.section;
    }
    
    UserDiscussionTopic* returnValue = nil;
    if (indexPath.section < [self.courseIdsAndTopicArrays count]) {
        NSDictionary* dict = [self.courseIdsAndTopicArrays objectAtIndex:sectionToUse];
        if (dict) {
            NSArray* ary = [dict objectForKey:@"topics"];
            if (ary && (indexPath.row < [ary count])) {
                returnValue = [ary objectAtIndex:indexPath.row];
            }
        }
    }
    return returnValue;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (selectedFilterRow != -1) {
        section = selectedFilterRow;
    }
    
    NSDictionary* dict = [self.courseIdsAndTopicArrays objectAtIndex:section];
    NSString* courseId = [dict objectForKey:@"courseId"];
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:[courseId integerValue]];
    if (course) {
        return course.title;
    } else {
        NSLog(@"Error: no course returned for id %@",courseId);
        return @"";
    }
}

@end
