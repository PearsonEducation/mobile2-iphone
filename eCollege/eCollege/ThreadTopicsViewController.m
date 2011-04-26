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

@implementation ThreadTopicsViewController
@synthesize item, courseName;

- (void) dealloc {
	self.item = nil;
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

#pragma mark - Table View Delegate/Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark - View

- (void) viewDidLoad {
	[super viewDidLoad];
	
	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
	self.view.backgroundColor = [config texturedBackgroundColor];
	self.view.opaque = NO;
	
	detailHeader = [[DetailHeader alloc] initWithFrame:CGRectMake(20, 10, 280, 500)];
	[self.view addSubview:detailHeader];
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
