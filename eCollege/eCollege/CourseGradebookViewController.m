//
//  CourseGradebookViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseGradebookViewController.h"
#import "GradebookItemFetcher.h"
#import "UserGradebookItem.h"
#import "GradebookItem.h"
#import "Grade.h"
#import "GradebookItemCell.h"
#import "GradebookItemGradeDetailViewController.h"
#import "NSDateUtilities.h"
#import "eCollegeAppDelegate.h"

@interface CourseGradebookViewController (Private)
- (void) loadData;
- (void) loadingComplete;
@end

@implementation CourseGradebookViewController
@synthesize gradebookItems, courseId;

- (void)dealloc {
	self.courseId = nil;
	[fetcher release]; fetcher = nil;
	self.gradebookItems = nil;
	[lastUpdateTime release]; lastUpdateTime = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) gradebookItemsFetched:(NSArray *)items {
	if ([items class] != [NSError class]) {
		self.gradebookItems = items;
	}
	[self loadingComplete];
}

- (void)refresh {
    [self loadData];
}

- (void)loadData {
    
    if (currentlyLoading) {
        return;
    }
    
    currentlyLoading = YES;
    
    [fetcher cancel];
	[fetcher fetchMyUserGradebookItemsForCourseId:courseId];
}

- (void)executeAfterHeaderClose {
    lastUpdateTime = [[NSDate date] retain];
	[self updateLastUpdatedLabel];
}

- (void)updateLastUpdatedLabel {
    if (lastUpdateTime) {
        NSString* prettyTime = [lastUpdateTime friendlyString];
        if (![prettyTime isEqualToString:@""] || [self.lastUpdatedLabel.text isEqualToString:@""]) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last update", @"Last update"), prettyTime];
        }
    } else {
        self.lastUpdatedLabel.text = NSLocalizedString(@"Last update: unknown",nil);
    }
}

- (void)loadingComplete {
    [self.table reloadData];
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
    
    // no longer loading
    currentlyLoading = NO;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Gradebook", @"Gradebook title");
	fetcher = [[GradebookItemFetcher alloc] initWithDelegate:self
											responseSelector:@selector(gradebookItemsFetched:)];
	[self forcePullDownRefresh];
	//	[self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [fetcher cancel];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[fetcher release]; fetcher = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (gradebookItems) ? [gradebookItems count] : 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UserGradebookItem *userGradebookItem = (UserGradebookItem *)[gradebookItems objectAtIndex:indexPath.row];
	Grade *grade = userGradebookItem.grade;
	return ([grade isGraded]) ? indexPath : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    GradebookItemCell *cell = (GradebookItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GradebookItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	UserGradebookItem *userGradebookItem = (UserGradebookItem *)[gradebookItems objectAtIndex:indexPath.row];
	GradebookItem *gradebookItem = userGradebookItem.gradebookItem;
	Grade *grade = userGradebookItem.grade;
	NSString *gradeDate = ([grade isGraded]) ? [grade.updatedDate friendlyString] : NSLocalizedString(@"Not Graded", nil);
	
	cell.selectionStyle = ([grade isGraded]) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.textLabel.text = gradebookItem.title;
	cell.detailTextLabel.text = gradeDate;
	if ([grade isGraded]) {
		cell.gradeLabel.text = [userGradebookItem displayedGrade];
		cell.accessoryView.hidden = NO;
	} else {
		cell.gradeLabel.text = nil;
		cell.accessoryView.hidden = YES;
	}
	
	[formatter release];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UserGradebookItem *userGradebookItem = (UserGradebookItem *)[gradebookItems objectAtIndex:indexPath.row];
	GradebookItemGradeDetailViewController* gradebookItemGradeDetailViewController = [[GradebookItemGradeDetailViewController alloc] initWithCourseId:courseId userGradebookItem:userGradebookItem];
	[self.navigationController pushViewController:gradebookItemGradeDetailViewController animated:YES];
	[gradebookItemGradeDetailViewController release];        
}

@end
