//
//  CourseDiscussionsViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDiscussionsViewController.h"
#import "UIColor+Boost.h"
#import "UserDiscussionTopic.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"
#import "TopicTableCell.h"
#import "TopicResponsesViewController.h"
#import "ECClientConfiguration.h"
#import "GreyTableHeader.h"
#import <QuartzCore/CoreAnimation.h>
#import "CourseDiscussionsViewController.h"

@interface CourseDiscussionsViewController ()

@property (nonatomic, retain) UserDiscussionTopicFetcher* userDiscussionTopicFetcher;
@property (nonatomic, retain) NSMutableArray* orderedUnitTopics;
@property (nonatomic, retain) NSMutableDictionary* unitTopicsByUnitName;
@property (nonatomic, retain) NSMutableArray* unitNames;
@property (nonatomic, retain) UIPickerView* picker;
@property (nonatomic, retain) UIView* filterView;
@property (nonatomic, retain) IBOutlet UILabel* tableTitle;
@property (nonatomic, retain) UIView* blockingModalView;

- (void)loadData;
- (void)prepareData;
- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath;
- (void)loadingComplete;
- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)filterDoneButtonTapped:(id)sender;
- (void)applyFilter;
- (void)filterAppearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;
- (void)filterDisappearAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished context:(void*)context;
- (IBAction)refreshWithModalSpinner;

@end

@implementation CourseDiscussionsViewController

@synthesize userDiscussionTopicFetcher;
@synthesize topics;
@synthesize lastUpdateTime;
@synthesize orderedUnitTopics;
@synthesize unitTopicsByUnitName;
@synthesize unitNames;
@synthesize picker;
@synthesize filterView;
@synthesize tableTitle;
@synthesize blockingModalView;
@synthesize courseId;
@synthesize courseName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedFilterRow = -1;
        self.userDiscussionTopicFetcher = [[UserDiscussionTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyTopicsHandler:)];    
    }
    return self;
}

- (void)dealloc
{
    self.blockingModalView = nil;
    self.filterView = nil;
    self.topics = nil;
    self.tableTitle = nil;
    self.lastUpdateTime = nil;
    self.unitNames = nil;
    [self.userDiscussionTopicFetcher cancel];
    self.userDiscussionTopicFetcher = nil;
    self.orderedUnitTopics = nil;
    self.unitTopicsByUnitName = nil;
    self.picker = nil;
    self.courseId = nil;
    self.courseName = nil;
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
        // "ALL UNITS" was selected
        selectedFilterRow = -1; 
    } else {
        selectedFilterRow = row - 1;
    }    
    self.tableTitle.text = [self.unitNames objectAtIndex:row];
    [self applyFilter];
}

- (void)applyFilter {
    [self.table reloadData];
}

- (IBAction)pickerButtonPressed {
    NSInteger row = [picker selectedRowInComponent:0];
    NSLog(@"Selected: %@", [unitNames objectAtIndex:row]);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [unitNames count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [unitNames objectAtIndex:row];
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
    [self.userDiscussionTopicFetcher cancel];
    [self.userDiscussionTopicFetcher fetchDiscussionTopicsForCourseIds:[NSArray arrayWithObject:self.courseId]];        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // don't want the gear icon on this view, since this view is a "drill-in" and we'll need the
    // navigation button on th left
    self.navigationItem.leftBarButtonItem = nil;
    
    // Don't want the image in the middle here, since this view controller will be drilled into,
    // and should display the course name on top
    self.navigationItem.titleView = nil;
    self.title = self.courseName;
    self.tableTitle.text = NSLocalizedString(@"All Units", nil);
    
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
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self refreshWithModalSpinner];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedMyTopicsHandler:(NSArray*)loadedTopics {
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
    if (topicsLoadFailure) {
        NSLog(@"Load failure");
    } else {
        [self.table reloadData];
    }
    
    // tells the "pull to refresh" header to go away (if necessary)
    [self stopLoading];
    
    // tell the modal loading spinner to go away (if necessary)
    [blockingActivityView hide];        
    
    // no longer loading
    currentlyLoading = NO;
    topicsLoadFailure = NO;
}

- (NSMutableArray*)getTopicsForUnitName:(NSString*)unitName {
    return [unitTopicsByUnitName objectForKey:unitName];
}


- (NSMutableArray*)createTopicsForUnitArray:(NSString*)unitName {
    NSMutableArray* topicsForUnit = [[[NSMutableArray alloc] init] autorelease];    
    [orderedUnitTopics addObject:topicsForUnit];
    [unitTopicsByUnitName setValue:topicsForUnit forKey:unitName];
    return topicsForUnit;
}

- (void)categorizeTopic:(UserDiscussionTopic*)topic {
    
    NSString* unitTitle = [topic getUnitTitle];    
    if (!unitTitle) {
        NSLog(@"ERROR: topic %@ does not have a unit title", topic);
        return;
    }
    
    NSMutableArray* topicsForUnit = [self getTopicsForUnitName:unitTitle];
    if (!topicsForUnit) {
        topicsForUnit = [self createTopicsForUnitArray:unitTitle];
        if (!topicsForUnit) {
            NSLog(@"ERROR: Unable to categorize topic %@",topic);
        }
    }
    
    [topicsForUnit addObject:topic];
}

- (NSInteger)filteredSection:(NSInteger)section {
    int sectionToUse;
    // if there's a filter applied, then indexPath isn't accurate...
    if (selectedFilterRow != -1) {
        sectionToUse = selectedFilterRow;
    } else {
        sectionToUse = section;
    }    
    return sectionToUse;
}

- (void)setupUnitNamesArray {
    // Create a new array...
    self.unitNames = [[[NSMutableArray alloc] initWithCapacity:[self.orderedUnitTopics count]+1] autorelease];
    // Add an "All Units" element...
    [unitNames addObject:NSLocalizedString(@"All Units", nil)];
    // Populate the array with unit names, in the same order as in the ordered unit info box
    for (NSMutableArray* tmp in self.orderedUnitTopics) {
        if ([tmp count] > 0) {
            UserDiscussionTopic* topic = [tmp objectAtIndex:0];
            if (topic) {
                [unitNames addObject:[topic getUnitTitle]];
            }
        }
    }
}

- (void)prepareData {
    // hold a dictionary of information for each course
    self.orderedUnitTopics = [[[NSMutableArray alloc] init] autorelease];
    // create a dictionary linking course ID -> course info
    self.unitTopicsByUnitName = [[[NSMutableDictionary alloc] init] autorelease];
    // store the topics appropriately
    for (UserDiscussionTopic* topic in self.topics) {        
        [self categorizeTopic:topic];
    }
    // sort the course info
    // self.orderedCourseInfo = [[self.orderedCourseInfo sortedArrayUsingFunction:topicInfoSort context:NULL] mutableCopy];
    [self setupUnitNamesArray];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (selectedFilterRow == -1) {
        return [self.orderedUnitTopics count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    section = [self filteredSection:section];
    NSMutableArray* arr = [self.orderedUnitTopics objectAtIndex:section];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0;
}

- (NSMutableArray*)topicsForSection:(NSInteger)section {  
    section = [self filteredSection:section];
    if ([orderedUnitTopics count] > section) {
        return [orderedUnitTopics objectAtIndex:section];
    } else {
        return nil;
    }
}

- (NSString*)unitNameForSection:(NSInteger)section {
    section = [self filteredSection:section];
    NSMutableArray* tmp = [self topicsForSection:section];
    if (tmp && [tmp count] > 0) {
        UserDiscussionTopic* topic = [tmp objectAtIndex:0];
        if ([topic isKindOfClass:[UserDiscussionTopic class]]) {
            return [topic getUnitTitle];
        }
    }
    return nil;
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
    }
    return cell;
}

- (UserDiscussionTopic*)getTopicForIndexPath:(NSIndexPath*)indexPath {
    int sectionToUse = [self filteredSection:indexPath.section];    
    UserDiscussionTopic* returnValue = nil;
    if ([orderedUnitTopics count] > sectionToUse) {
        NSMutableArray* tmp = [orderedUnitTopics objectAtIndex:sectionToUse];
        if (tmp && [tmp count] > indexPath.row) {
            returnValue = [tmp objectAtIndex:indexPath.row];                
        } else {
            NSLog(@"ERROR: can't find topic at index %d in CourseDiscussionsViewController",indexPath.row);
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
    } else {
        NSLog(@"ERROR: unable to find a topic for indexPath (%@) in CourseDiscussionsViewController", indexPath);
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (selectedFilterRow != -1) {
		return nil; // will hide the section header when the table is filtered
    }
    return [[[GreyTableHeader alloc] initWithText:[self unitNameForSection:section]] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 30.0;
}

@end
