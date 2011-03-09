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

@interface HomeViewController ()

@property (nonatomic, retain) ActivityStreamFetcher* activityStreamFetcher;
@property (nonatomic, retain) IBOutlet UITableView* table;

- (void)prepareData;
- (void)infoButtonTapped:(id)sender;
- (void)cancelButtonClicked:(id)sender;

@end

@implementation HomeViewController

@synthesize activityStreamFetcher;
@synthesize activityStream;
@synthesize earlierActivityItems;
@synthesize todayActivityItems;
@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.earlierActivityItems = nil;
    self.todayActivityItems = nil;
    self.activityStream = nil;
    [self.activityStreamFetcher cancel];
    self.activityStreamFetcher = nil;
    self.table = nil;
    if (dateCalculator) {
        [dateCalculator release];
    }
    if (today) {
        [today release];
    }
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

- (void)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a super view.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    
    // create the date calculator for later use
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
    today = [[NSDate date] retain];
    dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian andTodayDate:today];
    [gregorian release];

    // fetch activities
    if (!self.activityStreamFetcher) {
        self.activityStreamFetcher = [[ActivityStreamFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyActivityStreamHandler:)];    
    } else {
        [self.activityStreamFetcher cancel];
    }
    [activityStreamFetcher fetchMyActivityStream];
    
}

- (void)loadedMyActivityStreamHandler:(ActivityStream*)loadedActivityStream {
    if ([loadedActivityStream isKindOfClass:[NSError class]]) {
        // handle errors
    } else {
        self.activityStream = loadedActivityStream;
        [self prepareData];
    }

    // since we've updated the buckets of data, we must now reload the table
    [self.table reloadData];
}

- (void)prepareData {

    for  (ActivityStreamItem* aitem in self.activityStream.items) {
        int x = arc4random() % 100;
        if (x > 50) {
            aitem.postedTime = today;
        }
        if (x > 75) {
            aitem.postedTime = [dateCalculator addDays:-1 toDate:today];
        }
    }

    
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
            //NSLog(@"Today: %@; numDays = %d; desc = %@", [item.postedTime iso8601DateString], numDays, item.object.title);
        } else {
            [self.earlierActivityItems addObject:item];
            //NSLog(@"Earlier: %@; numDays = %d; desc = %@", [item.postedTime iso8601DateString], numDays, item.object.title);            
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
    if ([self hasEarlierItems] > 0) {
        cnt++;
    } 
    return cnt;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && [self hasTodayItems]) {
        return [self.todayActivityItems count];
    } else {
        return [self.earlierActivityItems count];
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
    ActivityStreamItem* item;
    if (indexPath.section == 0 && [self hasTodayItems]) {
        item = [self.todayActivityItems objectAtIndex:indexPath.row];            
    } else {
        item = [self.earlierActivityItems objectAtIndex:indexPath.row];                
    }

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self hasTodayItems]) {
        return NSLocalizedString(@"Today",@"The word meaning 'today'");
    } else {
        return NSLocalizedString(@"Earlier",@"The word meaning 'earlier'");
    }
}

@end
