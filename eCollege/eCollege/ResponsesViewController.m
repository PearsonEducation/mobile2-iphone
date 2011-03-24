//
//  ResponsesViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponsesViewController.h"
#import "NSDateUtilities.h"
#import "UserDiscussionTopic.h"
#import "UserDiscussionResponseFetcher.h"
#import "UserDiscussionTopicFetcher.h"
#import "DiscussionTopic.h"
#import "UserDiscussionResponse.h"
#import "TopicHeaderTableCell.h"
#import "DataEntryTableCell.h"
#import "ResponseTableCell.h"
#import "ResponseResponsesViewController.h"

@interface ResponsesViewController () 
@end

@implementation ResponsesViewController

@synthesize rootItemId;
@synthesize rootItemFetcher;
@synthesize responsesFetcher;
@synthesize lastUpdated;
@synthesize dateCalculator;
@synthesize rootItem;
@synthesize responses;

# pragma mark Methods to override in child classes

- (BOOL)isValidRootItemObject:(id)value {
    return NO;
}

- (BOOL)isValidResponsesObject:(id)value {
    return NO;
}

- (void)fetchRootItem {
}

- (void)fetchResponses {
    return;
}

- (void)setupFetchers {    
}

- (UITableViewCell*)getHeaderTableCell {
    return nil;
}

# pragma mark PullRefreshTableViewController methods

- (void)refresh {
    [self fetchData];
}

- (void)executeAfterHeaderClose {
    self.lastUpdated = [NSDate date];
}

- (void)updateLastUpdatedLabel {
    if (self.lastUpdated) {
        NSString* prettyTime = [self.lastUpdated niceAndConcise];
        if (![prettyTime isEqualToString:@""] || [self.lastUpdatedLabel.text isEqualToString:@""]) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last update: %@", prettyTime];
        }
    } else {
        self.lastUpdatedLabel.text = @"";
    }
}


# pragma mark Construction, destruction, memory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
        dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian];
        [gregorian release];
        [self setupFetchers];
    }
    return self;
}

- (void)dealloc
{
    self.rootItemId = nil;
    self.rootItemFetcher = nil;
    self.responsesFetcher = nil;
    self.dateCalculator = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Other methods

- (void)rootItemFetchedHandler:(id)result {
    if ([self isValidRootItemObject:result]) {
        NSLog(@"Got a user discussion topic");
        self.rootItem = result;
        errorFetchingRootItem = NO;
        [self fetchResponses];
    } else {
        NSLog(@"ERROR: problem loading root item");
        errorFetchingRootItem = YES;
        [self fetchingComplete];
    }
}

- (void)responsesFetchedHandler:(id)result {
    if ([self isValidResponsesObject:result]) {
        self.responses = result;
        errorFetchingResponses = NO;
    } else {
        NSLog(@"ERROR: problem loading responses");
        errorFetchingResponses = YES;
    }
    [self fetchingComplete];
}

- (void)fetchData {
    if (currentlyRefreshing) {
        return;
    } else {
        if (self.rootItemId && ![self.rootItemId isEqualToString:@""]) {
            errorFetchingRootItem = NO;
            errorFetchingResponses = NO;
            currentlyRefreshing = YES;
            [self fetchRootItem];
        } else {
            errorFetchingRootItem = YES;
            [self fetchingComplete];
        }
    }
}

- (void)fetchingComplete {
    if (errorFetchingRootItem || errorFetchingResponses) {
        NSLog(@"ERROR: Problems fetching data.");
    } else {
        // since we've updated the buckets of data, we must now reload the table
        [self.table reloadData];
    }
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
    currentlyRefreshing = NO;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the topics again.
    if (!self.lastUpdated || [self.lastUpdated timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self forcePullDownRefresh];
        forceUpdateOnViewWillAppear = NO;
    }    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (responses) {
        // Return the number of rows in the section, plus three:
        //   1. header cell
        //   2. content of the root item (topic or response)
        //   3. data entry cell
        return [responses count] + 3;
    } else {
        return 0;
    }
}

- (BOOL)isHeaderCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row == 0;
}

- (BOOL)isRootItemContentCell:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row == 1;
}

- (BOOL)isDataEntryCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row == 2;
}

- (BOOL)isResponseCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row >= 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isHeaderCell:indexPath]) {
        return 70.0;
    } else if ([self isRootItemContentCell:indexPath]) {
        return 49.0;
    } else if ([self isDataEntryCell:indexPath]) {
        return 39.0;
    } else {
        return 113.0;
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    static NSString *CellIdentifier;
    
    // topic cell
    if ([self isHeaderCell:indexPath]) {
        cell = [self getHeaderTableCell];
    } 
    
    // root item (topic or response) content cell
    else if([self isRootItemContentCell:indexPath]) {
        CellIdentifier = @"RootItemContentTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.text = @"Content goes here";
    }
    
    // post box
    else if ([self isDataEntryCell:indexPath]) {
        CellIdentifier = @"DataEntryTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"DataEntryTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    } 
    
    // response cells
    else {
        UserDiscussionResponse* userDiscussionResponse = (UserDiscussionResponse*)[self.responses objectAtIndex:indexPath.row-3];
        NSString* ident = @"ResponseTableCell";
        UITableViewCell* cell;
        cell = [table dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [(ResponseTableCell*)cell setData:userDiscussionResponse];
        return cell;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isResponseCell:indexPath]) {
        ResponseResponsesViewController* rrvc = [[ResponseResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
        UserDiscussionResponse* udr = [self.responses objectAtIndex:indexPath.row-3];
        rrvc.rootItemId = udr.userDiscussionResponseId;
        [self.navigationController pushViewController:rrvc animated:YES];
        [rrvc release];
    }
}

@end
