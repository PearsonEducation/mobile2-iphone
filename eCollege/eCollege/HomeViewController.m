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

@interface HomeViewController ()

@property (nonatomic, retain) ActivityStreamFetcher* activityStreamFetcher;
@property (nonatomic, retain) IBOutlet UITableView* table;

- (void)sortActivityItemsByDate;
- (void)infoButtonTapped:(id)sender;
- (void)cancelButtonClicked:(id)sender;

@end

@implementation HomeViewController

@synthesize activityStreamFetcher;
@synthesize activityStream;
@synthesize activityItemsForLater;
@synthesize activityItemsForToday;
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
    self.activityItemsForLater = nil;
    self.activityItemsForToday = nil;
    self.activityStream = nil;
    [self.activityStreamFetcher cancel];
    self.activityStreamFetcher = nil;
    self.table = nil;
    [dropboxSubmissionImage release];
    [examSubmissionImage release];
    [gradeImage release];
    [remarkImage release];
    [threadPostImage release];
    [threadTopicImage release];
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
    
    if (!self.activityStreamFetcher) {
        self.activityStreamFetcher = [[ActivityStreamFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedMyActivityStreamHandler:)];    
    } else {
        // we don't want any existing requests to go through
        [self.activityStreamFetcher cancel];
    }
    
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
    
    // grab all activities
    [activityStreamFetcher fetchMyActivityStream];
    
    // load the various images that are used in the table view
    dropboxSubmissionImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_dropbox_submission" ofType:@"png"]];
    examSubmissionImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_exam_submission" ofType:@"png"]];
    gradeImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_grade" ofType:@"png"]];
    remarkImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_remark" ofType:@"png"]];
    threadPostImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_thread_post" ofType:@"png"]];
    threadTopicImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_thread_topic" ofType:@"png"]];

}

- (void)loadedMyActivityStreamHandler:(ActivityStream*)loadedActivityStream {
    if ([loadedActivityStream isKindOfClass:[NSError class]]) {
        // handle errors
    } else {
        self.activityStream = loadedActivityStream;
        [self sortActivityItemsByDate];
    }
    // since we've updated the buckets of data, we must now reload the table
    [self.table reloadData];
}

- (void)sortActivityItemsByDate {
    // create new buckets for items sorted by time
    self.activityItemsForToday = [[NSMutableArray alloc] init];
    self.activityItemsForLater = [[NSMutableArray alloc] init];
    
    // if there's no activity stream, return.
    if (!self.activityStream || !self.activityStream.items || ([self.activityStream.items count] == 0)) {
        return;
    }
    
    // sort the activity stream items by date
    NSDate *today = [NSDate date];
    for  (ActivityStreamItem* item in self.activityStream.items) {
        // DEBUG CODE: service was returning all objects before the current date,
        // so randomly push some forward awhile...
        int x = arc4random() % 100;
        if (x > 50) {
            item.postedTime = [item.postedTime addDays:100];
        }
        if ([item.postedTime is:0 fromDate:today]) {
            [self.activityItemsForToday addObject:item];
            NSLog(@"Today");
        } else {
            [self.activityItemsForLater addObject:item];
            NSLog(@"After");            
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return ([self.activityItemsForToday count] > 0) ? [self.activityItemsForToday count] : 1;
            break;
        case 1:
            return ([self.activityItemsForLater count] > 0) ? [self.activityItemsForLater count] : 1;
            break;
        default:
            return 0;
            break;
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
    
    // Configure the cell...
    ActivityStreamItem* item = (indexPath.section == 0) ? [self.activityItemsForToday objectAtIndex:indexPath.row] : [self.activityItemsForLater objectAtIndex:indexPath.row];    
    [(ActivityTableCell*)cell setData:item];
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
    if (section == 0) {
        return NSLocalizedString(@"Today",@"The word meaning 'today'");
    } else {
        return NSLocalizedString(@"Later",@"The word meaning 'later'");
    }
}

@end
