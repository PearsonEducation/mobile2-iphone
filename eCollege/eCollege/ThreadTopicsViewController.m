//
//  ThreadTopicsViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/26/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ThreadTopicsViewController.h"
#import "UpcomingEventItem.h"
#import "DetailHeader.h"
#import "ECClientConfiguration.h"
#import "eCollegeAppDelegate.h"
#import "Course.h"
#import "ThreadTopicFetcher.h"
#import "TopicTableCell.h"
#import "TopicResponsesViewController.h"

@implementation ThreadTopicsViewController
@synthesize item, courseName, threadTopics;

- (void) dealloc {
	self.item = nil;
	self.threadTopics = nil;
	[threadTopicFetcher release]; threadTopicFetcher = nil;
	[blockingActivityView release]; blockingActivityView = nil;
	[courseName release]; courseName = nil;
	[detailHeader release]; detailHeader = nil;
	[super dealloc];
}

- (void) setItem:(UpcomingEventItem *)newItem {
	[item release];
	item = [newItem retain];
	self.title = item.title;
}

- (NSString *) courseName {
	if (courseName == nil) {
		if (self.item) {
			Course *course = [[eCollegeAppDelegate delegate] getCourseHavingId:self.item.courseId];
			courseName = course.title;
		}
	}
	return  courseName;
}

- (void) threadTopicsLoaded:(NSArray *)topics {
	[blockingActivityView hide];
	if (![topics isKindOfClass:[NSError class]]) {
		self.threadTopics = topics;
		[tableView reloadData];
	}
}

#pragma mark - Table View Delegate/Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 71.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.threadTopics count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TopicTableCell";
	
	UserDiscussionTopic *topic = [self.threadTopics objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
    }
	[(TopicTableCell*)cell setData:topic];
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UserDiscussionTopic *topic = [self.threadTopics objectAtIndex:indexPath.row];
	TopicResponsesViewController* topicResponsesViewController = [[TopicResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
	topicResponsesViewController.rootItemId = topic.userDiscussionTopicId;
	topicResponsesViewController.parent = self;
	[self.navigationController pushViewController:topicResponsesViewController animated:YES];
	[topicResponsesViewController release];
}

#pragma mark - View

- (void) viewDidLoad {
	[super viewDidLoad];
	
	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
	self.view.backgroundColor = [config tertiaryColor];
	
	texturedView.backgroundColor = [config texturedBackgroundColor];
	texturedView.opaque = NO;
	
	detailHeader = [[DetailHeader alloc] initWithFrame:CGRectMake(20, 10, 280, 500)];
	[self.view addSubview:detailHeader];
	
	blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];
	[blockingActivityView show];
	
	threadTopicFetcher = [[ThreadTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(threadTopicsLoaded:)];
	[threadTopicFetcher fetchDiscussionTopicsForCourseId:self.item.courseId threadId:self.item.threadId];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	detailHeader.courseName = self.courseName;
	detailHeader.itemType = NSLocalizedString(@"Thread Topic", @"Thread Topic");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
