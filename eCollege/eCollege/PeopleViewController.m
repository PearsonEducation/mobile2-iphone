//
//  PeopleViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "PeopleViewController.h"
// #import "AnnouncementDetailViewController.h"
// #import "AnnouncementTableCell.h"
#import "UIColor+Boost.h"
#import "User.h"
#import "eCollegeAppDelegate.h"
#import "NSDateUtilities.h"

@interface PeopleViewController ()

@property (nonatomic, retain) UserFetcher* userFetcher;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, assign) BOOL currentlyLoading;
@property (nonatomic, assign) BOOL peopleLoadFailure;
@property (nonatomic, assign) BOOL forceUpdateOnViewWillAppear;

- (void)loadData;
- (void)prepareData;
- (User*)getUserForIndexPath:(NSIndexPath*)indexPath;
- (void)loadingComplete;

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
        [self prepareData];
    }
    
    [self loadingComplete];
}

- (void)loadingComplete {
    if (peopleLoadFailure) {
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
    peopleLoadFailure = NO;
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
    if (self.peopleLoadFailure) {
        int cnt = [self.people count];
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
//    User* user = [self getUserForIndexPath:indexPath];
    UITableViewCell *cell;
//    if (user) {
//        static NSString *CellIdentifier = @"UserTableCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[[UserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserTableCell"] autorelease];
//        }
//        [(UserTableCell*)cell setData:user];        
//    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = NSLocalizedString(@"No people",nil);
//    }
    return cell;
}

- (User*)getUserForIndexPath:(NSIndexPath *)indexPath {
    User* returnValue = nil;
    if (indexPath.row < [self.people count]) {
        returnValue = [self.people objectAtIndex:indexPath.row];
    }
    return returnValue;
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
//    User* user = [self getUserForIndexPath:indexPath];
//    if (user) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        PersonDetailViewController* pdvc = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
//        NSLog(@"Initializing PersonDetailViewController controller with user id: %d", user.userId);
//        pdvc.personId = user.userId;
//        pdvc.hidesBottomBarWhenPushed = YES;
//        [self.table deselectRowAtIndexPath:indexPath animated:YES];
//        [self.navigationController pushViewController:pdvc animated:YES];
//        [pdvc release];
//    }
}

@end
