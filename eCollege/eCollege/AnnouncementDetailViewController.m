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
        announcementValue = NSLocalizedString(@"Error loading announcement", @"Error loading announcement");
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.scrollEnabled = YES;
    [self.view addSubview:scrollView];
 
    // set up some colors
    UIColor *headerFontColor = HEXCOLOR(0x151848);
    UIColor *normalTextColor = HEXCOLOR(0x262626);
    
    // set up some fonts
    UIFont* courseNameFont = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    UIFont* titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    UIFont* commentsFont = [UIFont fontWithName:@"Helvetica" size:13];
    
    // set up the course name label
    CGSize maximumSize = CGSizeMake(284.0, 1000.0);
    CGSize courseNameSize = [self.courseName sizeWithFont:courseNameFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap]; // 18px left, right margins, so 284.0 width
    UILabel* courseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 16, courseNameSize.width, courseNameSize.height)];
    courseNameLabel.font = courseNameFont;
    courseNameLabel.textColor = headerFontColor;
    courseNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    courseNameLabel.text = courseName;
    courseNameLabel.backgroundColor = [UIColor clearColor];
    courseNameLabel.numberOfLines = 0;
    [scrollView addSubview:courseNameLabel];
    
    // set up the assignment title label
    NSString* subject = a.subject;
    CGSize subjectSize = [subject sizeWithFont:titleFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, courseNameLabel.frame.origin.y + courseNameLabel.frame.size.height + 5, subjectSize.width, subjectSize.height)];
    subjectLabel.font = titleFont;
    subjectLabel.textColor = headerFontColor;
    subjectLabel.lineBreakMode = UILineBreakModeWordWrap;
    subjectLabel.text = subject;
    subjectLabel.backgroundColor =  [UIColor clearColor];
    subjectLabel.numberOfLines = 0;
    [scrollView addSubview:subjectLabel];
    
    // set up the white box in the background, with rounded corners and drop shadow (arbitrary initial height, will change that later)
    UIView* whiteBox = [[UIView alloc] initWithFrame:CGRectMake(9, subjectLabel.frame.origin.y + subjectLabel.frame.size.height + 10, 303, 500)];
    whiteBox.backgroundColor = [UIColor whiteColor];
    whiteBox.layer.cornerRadius = 10.0;
    whiteBox.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    whiteBox.layer.shadowRadius = 1.0;
    whiteBox.layer.shadowOpacity = 0.8;
    whiteBox.layer.shadowOffset = CGSizeMake(0, 2);
    [scrollView addSubview:whiteBox];
    
    // set up the image
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    img.image = [UIImage imageNamed:@"clock.png"];
    [whiteBox addSubview:img];    
    
    // set up the 'Posted By' label
    NSString* postedByText = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Posted by",nil), a.submitter];
    CGSize postedBySize = [postedByText sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* postedByLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 16, postedBySize.width, postedBySize.height)];
    postedByLabel.font = commentsFont;
    postedByLabel.textColor = normalTextColor;
    postedByLabel.text = postedByText;
    postedByLabel.backgroundColor = [UIColor clearColor];
    postedByLabel.numberOfLines = 0;
    [whiteBox addSubview:postedByLabel];
    
    // set up the comments label
    NSString* comments = [a.text stripHTML];
    maximumSize = CGSizeMake(243, 2000);
    CGSize commentsSize = [comments sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, postedByLabel.frame.origin.y + postedByLabel.frame.size.height + 5, commentsSize.width, commentsSize.height)];
    commentsLabel.font = commentsFont;
    commentsLabel.textColor = normalTextColor;
    commentsLabel.text = comments;
    commentsLabel.backgroundColor = [UIColor clearColor];
    commentsLabel.numberOfLines = 0;
    [whiteBox addSubview:commentsLabel];
    
    // set the height of the white box
    CGRect boxFrame = whiteBox.frame;
    boxFrame.size.height = commentsLabel.frame.origin.y + commentsLabel.frame.size.height + 16;
    whiteBox.frame = boxFrame;
    
    
    scrollView.contentSize = CGSizeMake(320, whiteBox.frame.origin.y + whiteBox.frame.size.height + 100);

    // memory management
    [img release];
    [commentsLabel release];
    [postedByLabel release];
    [subjectLabel release];
    [courseNameLabel release];
    [whiteBox release];
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
