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


@interface ResponsesViewController () 

@property (nonatomic, retain) ECAuthenticatedFetcher* rootItemFetcher;
@property (nonatomic, retain) ECAuthenticatedFetcher* responsesFetcher;
@property (nonatomic, retain) NSDate* lastUpdated;
@property (nonatomic, retain) DateCalculator* dateCalculator;
@property (nonatomic, retain) id rootItem;
@property (nonatomic, retain) id responses;

- (void)rootItemFetchedHandler:(id)result;
- (void)responsesFetchedHandler:(id)result;
- (void)fetchData;
- (void)fetchRootItem;
- (void)fetchResponses;

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

- (void)rootItemFetchedHandler:(id)result {
    if ([result isKindOfClass:[UserDiscussionTopic class]]) {
        NSLog(@"Got a user discussion topic");
        self.rootItem = result;
        errorLoadingRootItem = NO;
        [self fetchResponses];
    } else {
        NSLog(@"Got an error");
    }
}

- (void)responsesFetchedHandler:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        self.responses = result;
    }
}

- (void)fetchRootItem {
    if (self.rootItemId && ![self.rootItemId isEqualToString:@""]) {
        [(UserDiscussionTopicFetcher*)rootItemFetcher fetchDiscussionTopicById:self.rootItemId];        
    } else {
        NSLog(@"ERROR: cannot fetch user discussion topic for id %@",self.rootItemId);
    }
}

- (void)fetchResponses {
    if (self.rootItem && [self.rootItem isKindOfClass:[UserDiscussionTopic class]]) {
        UserDiscussionResponseFetcher* fetcher = (UserDiscussionResponseFetcher*)self.responsesFetcher;
        [fetcher fetchUserDicussionResponsesForTopicId:self.rootItemId];
    } else {
        NSLog(@"ERROR: cannot fetch responses for user discussion topic %@",self.rootItem);
    }
}

- (void)setupFetchers {    
    self.rootItemFetcher = [[UserDiscussionTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(rootItemFetchedHandler:)];
    self.responsesFetcher = [[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(responsesFetchedHandler:)];
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

- (void)fetchData {
    if (currentRefreshing) {
        return;
    } else {
        currentRefreshing = YES;
        [self fetchRootItem];
    }
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
