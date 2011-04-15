//
//  AnnouncementDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "AnnouncementDetailViewController.h"
#import "DropboxMessage.h"
#import "DropboXBasket.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSDateUtilities.h"
#import "DateCalculator.h"
#import "DropboxAttachment.h"
#import "NSString+stripHTML.h"
#import "ECClientConfiguration.h"
#import "DetailHeader.h"
#import "DetailBox.h"

@interface AnnouncementDetailViewController ()

@property (nonatomic, retain) AnnouncementFetcher* announcementFetcher;
@property (nonatomic, retain) id announcement;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, assign) NSInteger announcementId;
@property (nonatomic, assign) NSInteger courseId;
@property (nonatomic, retain) NSString* courseName;
@property (nonatomic, retain) UIScrollView* scrollView;;

- (void)announcementLoaded:(id)announcementValue;
- (void)setupView;
- (void)serviceCallComplete;
- (void)handleErrors;

@end

@implementation AnnouncementDetailViewController

@synthesize announcementFetcher;
@synthesize announcement;
@synthesize blockingActivityView;
@synthesize announcementId;
@synthesize courseId;
@synthesize courseName;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.announcementFetcher = [[AnnouncementFetcher alloc] initWithDelegate:self responseSelector:@selector(announcementLoaded:)];
    }
    return self;
}

- (void)setAnnouncementId:(NSInteger)announcementIdValue andCourseId:(NSInteger)courseIdValue andCourseName:(NSString *)courseNameValue {
    self.announcementId = announcementIdValue;
    self.courseId = courseIdValue;
    self.courseName = courseNameValue;
}

- (void)loadAnnouncement {
    if (self.announcementId > 0 && courseId > 0) {
        [blockingActivityView show];
        [announcementFetcher fetchAnnouncementWithId:self.announcementId forCourseId:self.courseId];
    } else {
        NSLog(@"ERROR: Must have an announcementId and courseId in order to load an announcement.");
        announcement = NSLocalizedString(@"Must have an announcementId and courseId in order to load an announcement",nil);
        [self serviceCallComplete];
    }
}

- (void)announcementLoaded:(id)announcementValue {
    [blockingActivityView hide];
    if (!announcementValue) {
        announcement = NSLocalizedString(@"Error loading announcement", @"Error loading announcement");
    } else {
        announcement = announcementValue;
    }
    [self serviceCallComplete];   
}

- (void)serviceCallComplete {
    if (announcement) {
        // service calls are complete
        if ([announcement isKindOfClass:[Announcement class]]) {
            [self setupView];
        } else {
            [self handleErrors];
        }
    } else {
        // more service calls pending
        return;
    }
}

- (void)handleErrors {
    NSLog(@"Errors loading dropbox basket / dropbox message");
}

- (void)setupView {
    Announcement* a = (Announcement*)self.announcement;
    if (!a) {
        NSLog(@"ERROR: no announcement to display in detail view");
        return;
    }

    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:courseId];
    if (!course) {
        NSLog(@"ERROR: no course to display in detail view");
        return;
    }
    
    // Grab some needed values
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        
    // SCROLL VIEW
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.scrollEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    // HEADER
    DetailHeader* detailHeader = [[DetailHeader alloc] initWithFrame:CGRectMake(20, 10, 280, 500)]; // height is arbitrary; copmonent will change it
    detailHeader.courseName = course.title;
    detailHeader.itemType = NSLocalizedString(@"Announcement", nil);    
    [scrollView addSubview:detailHeader];
    [detailHeader layoutIfNeeded]; // force it to set its frame (in layoutSubviews) before we position other components relative to it
    
    // WHITE BOX
    DetailBox* detailBox = [[DetailBox alloc] initWithFrame:CGRectMake(10, detailHeader.frame.origin.y + detailHeader.frame.size.height + 7, 300, 500)]; // height is arbitrary; component will change it
    detailBox.iconFileName = [config announcementIconFileName];
    detailBox.title = a.subject;
    detailBox.comments = [a.text stripHTML];    
    detailBox.smallIconFileName = [config smallPersonIconFileName];
    detailBox.smallIconDescription = a.submitter;
    [scrollView addSubview:detailBox];
    [detailBox layoutIfNeeded]; // force it to set its frame (in layoutSubviews) before we use it to size the scroll view
    
    // Update the scroll view contentSize
    CGFloat contentHeight = detailHeader.frame.origin.y + detailBox.frame.size.height + 100;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    // Cleanup
    [detailBox release];
    [detailHeader release];
}

- (void)loadView {
    UIColor *backgroundColor = HEXCOLOR(0xEFE8D8);
    
    // background view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 65, 320, 415)];
    self.view.backgroundColor = backgroundColor;
    self.blockingActivityView = [[[BlockingActivityView alloc] initWithWithView:self.view] autorelease];
}


- (void)dealloc
{
    self.scrollView = nil;
    [self.announcementFetcher cancel];
    self.courseName = nil;
    self.announcementFetcher = nil;
    self.announcement = nil;
    self.blockingActivityView = nil;
    [super dealloc];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadAnnouncement];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.announcementFetcher cancel];
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

@end
