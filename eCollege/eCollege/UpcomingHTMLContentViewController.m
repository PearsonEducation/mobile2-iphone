//
//  UpcomingHTMLContentViewController.m
//  eCollege
//
//  Created by Tony Hillerson on 4/27/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "UpcomingHTMLContentViewController.h"
#import "DetailHeader.h"
#import "BlockingActivityView.h"
#import "TextMultimediaFetcher.h"
#import "ECClientConfiguration.h"
#import "UpcomingEventItem.h"
#import "Course.h"
#import "eCollegeAppDelegate.h"

@implementation UpcomingHTMLContentViewController
@synthesize item, courseName;

- (void) dealloc {
	[detailHeader release]; detailHeader = nil;
	[blockingActivityView release]; blockingActivityView = nil;
	[multimediaFetcher release]; multimediaFetcher = nil;
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

- (void) htmlLoaded:(NSString *)html {
	[blockingActivityView hide];
	[webView loadHTMLString:html baseURL:nil];
}

#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[blockingActivityView show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[blockingActivityView hide];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[blockingActivityView hide];
}


#pragma mark - View Methods

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
	
	multimediaFetcher = [[TextMultimediaFetcher alloc] initWithDelegate:self responseSelector:@selector(htmlLoaded:)];
	[multimediaFetcher fetchHTMLContentForCourseId:self.item.courseId contentId:self.item.multimediaId];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	detailHeader.courseName = self.courseName;
	detailHeader.itemType = self.item.title;
	detailHeader.thirdHeaderText = self.item.dateString;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
