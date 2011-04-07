//
//  PeopleViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonDetailViewController.h"
#import "PersonTableCell.h"
#import "UIColor+Boost.h"
#import "RosterUser.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"
#import "ECClientConfiguration.h"
#import "GreyTableHeader.h"

#define EVERYONE 0
#define CLASSMATES 1
#define INSTRUCTORS 2

@interface PeopleViewController ()

@property (nonatomic, retain) UserFetcher* userFetcher;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, assign) BOOL currentlyLoading;
@property (nonatomic, assign) BOOL peopleLoadFailure;
@property (nonatomic, assign) BOOL forceUpdateOnViewWillAppear;
@property (nonatomic, retain) NSMutableDictionary* namesByLetter;
@property (nonatomic, retain) NSMutableArray* sortedKeys;
@property (nonatomic, retain) UISegmentedControl* filterControl;

- (void)loadData;
- (void)sortData;
- (RosterUser*)getUserForIndexPath:(NSIndexPath*)indexPath;
- (void)loadingComplete;
- (void)refreshTable;
- (void)filterData;
- (BOOL)filterExcludesUser:(RosterUser*)user;

@end

@implementation PeopleViewController

@synthesize courseId;
@synthesize people;
@synthesize lastUpdateTime;
@synthesize userFetcher;
@synthesize blockingActivityView;
@synthesize currentlyLoading;
@synthesize peopleLoadFailure;
@synthesize forceUpdateOnViewWillAppear;
@synthesize namesByLetter;
@synthesize sortedKeys;
@synthesize filterControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userFetcher = [[UserFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedPeopleHandler:)];    
    }
    return self;
}

- (void)dealloc
{    
    self.people = nil;
    self.lastUpdateTime = nil;
    self.userFetcher = nil;
    self.blockingActivityView = nil;
    self.namesByLetter = nil;
    self.sortedKeys = nil;
    self.filterControl = nil;
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
    [self.userFetcher cancel];
    [self.userFetcher fetchRosterForCourseWithId:self.courseId];    
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

- (IBAction)filterSelectionChanged {
    if (!currentlyLoading) {
        [self refreshTable];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	filterBackground.midColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
	self.filterControl.tintColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
	
    // Do any additional setup after loading the view from its nib.
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
    [filterControl setTitle:NSLocalizedString(@"Everyone", nil) forSegmentAtIndex:EVERYONE];
    [filterControl setTitle:NSLocalizedString(@"Classmates", nil) forSegmentAtIndex:CLASSMATES];
    [filterControl setTitle:NSLocalizedString(@"Instructors", nil) forSegmentAtIndex:INSTRUCTORS];
    filterControl.selectedSegmentIndex = EVERYONE;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"People",nil);
    
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the topics again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)loadedPeopleHandler:(NSArray*)loadedPeople {
    // check to see if we received an error; if not, save off the data and prep it.
    if ([loadedPeople isKindOfClass:[NSError class]]) {
        peopleLoadFailure = YES;
    } else {
        peopleLoadFailure = NO;
        self.people = loadedPeople;
        [self sortData];
        [self filterData];
    }
    
    [self loadingComplete];
}

- (void)refreshTable {
    [self filterData];
    [table reloadData];
}

- (void)loadingComplete {
    if (peopleLoadFailure) {
        NSLog(@"Load failure");
    } else {
        // since we've updated the buckets of data, we must now reload the table
        [self refreshTable];
    }
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
    
    // tell the modal loading spinner to go away (if it's present)
    [blockingActivityView hide];        
    
    // no longer loading
    currentlyLoading = NO;
    peopleLoadFailure = NO;
}

- (void)sortData {
    // sort by full name
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"fullNameString" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray* descriptors = [[NSArray alloc] initWithObjects:sd,nil];
    self.people = [self.people sortedArrayUsingDescriptors:descriptors];
    [descriptors release];
    [sd release];
}

- (BOOL)filterExcludesUser:(RosterUser*)user {
    return ((filterControl.selectedSegmentIndex == CLASSMATES && [user isInstructor]) || (filterControl.selectedSegmentIndex == INSTRUCTORS && [user isStudent]));
}

- (void)filterData {
    self.sortedKeys = [[NSMutableArray alloc] init];    

    // index the names by first letter (they're already sorted; no more sorting required)
    namesByLetter = [[NSMutableDictionary alloc] init];
    for (RosterUser* ru in people) {
        // filter out users we don't want
        if ([self filterExcludesUser:ru]) {
            continue;
        }
        NSString* firstLetter = [[ru.fullNameString substringToIndex:1] uppercaseString];
        NSMutableArray* namesForLetter = [namesByLetter objectForKey:firstLetter];
        if (namesForLetter) {
            [namesForLetter addObject:ru];
        } else {
            namesForLetter = [[NSMutableArray alloc] initWithObjects:ru, nil];
            [namesByLetter setValue:namesForLetter forKey:firstLetter];
            [sortedKeys addObject:firstLetter];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sortedKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (sortedKeys) {
        NSString* letter = [sortedKeys objectAtIndex:section];
        NSArray* namesForLetter = [namesByLetter objectForKey:letter];
        if (namesForLetter) {
            return [namesForLetter count];
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RosterUser* user = [self getUserForIndexPath:indexPath];
    if (user) {
        static NSString *CellIdentifier = @"PersonTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[PersonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonTableCell"] autorelease];
        }
        [(PersonTableCell*)cell setData:user];        
    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = NSLocalizedString(@"No people",nil);
    }
    return cell;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (sortedKeys) {
        return [[GreyTableHeader alloc] initWithText:(NSString*)[sortedKeys objectAtIndex:section]];    
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 30.0;
}


- (RosterUser*)getUserForIndexPath:(NSIndexPath *)indexPath {
    if (sortedKeys) {
        NSString* letter = [sortedKeys objectAtIndex:indexPath.section];
        NSArray* namesForLetter = [namesByLetter objectForKey:letter];
        if (namesForLetter) {
            return [namesForLetter objectAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (void)forceFutureRefresh {    
    forceUpdateOnViewWillAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [userFetcher cancel];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RosterUser* user = [self getUserForIndexPath:indexPath];
    if (user) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PersonDetailViewController *pdvc = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
        NSLog(@"Initializing PersonDetailViewController controller with user id: %d", user.rosterUserId);
        pdvc.user = user;
        pdvc.courseId = self.courseId;
        pdvc.hidesBottomBarWhenPushed = YES;
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:pdvc animated:YES];
        [pdvc release];
    }
}



@end
