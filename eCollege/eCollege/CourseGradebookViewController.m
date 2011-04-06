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

@implementation CourseGradebookViewController
@synthesize gradebookItems, courseId;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) gradebookItemsFetched:(NSArray *)items {
	self.gradebookItems = items;
	[self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Gradebook", @"Gradebook title");
	fetcher = [[GradebookItemFetcher alloc] initWithDelegate:self
											responseSelector:@selector(gradebookItemsFetched:)];
	[fetcher fetchMyUserGradebookItemsForCourseId:courseId];
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
	
    cell.textLabel.text = gradebookItem.title;
	cell.detailTextLabel.text = gradeDate;
	if ([grade isGraded]) {
		if (grade.points) {
			cell.gradeLabel.text = [NSString stringWithFormat:@"%@/%@", [formatter stringFromNumber:grade.points], [formatter stringFromNumber:gradebookItem.pointsPossible]];
		} else {
			cell.gradeLabel.text = grade.letterGrade;
		}
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
	GradebookItem *gradebookItem = userGradebookItem.gradebookItem;
	Grade *grade = [userGradebookItem grade];
	GradebookItemGradeDetailViewController* gradebookItemGradeDetailViewController = [[GradebookItemGradeDetailViewController alloc] initWithCourseId:courseId gradebookItem:gradebookItem grade:grade];
	[self.navigationController pushViewController:gradebookItemGradeDetailViewController animated:YES];
	[gradebookItemGradeDetailViewController release];        
}

@end
