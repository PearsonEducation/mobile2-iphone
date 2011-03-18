//
//  DropboxMessageDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DropboxMessageDetailViewController.h"
#import "DropboxMessage.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSDateUtilities.h"
#import "DateCalculator.h"


@interface DropboxMessageDetailViewController ()

@property (nonatomic, retain) DropboxMessageFetcher* dropboxMessageFetcher;
@property (nonatomic, retain) ActivityStreamItem* item;

- (void)dropboxMessageLoaded:(id)dropboxMsg;
- (void)setupView;

@end

@implementation DropboxMessageDetailViewController

@synthesize dropboxMessageFetcher;
@synthesize item;

- (id)initWithItem:(ActivityStreamItem*)value {
    if ((self = [super init]) != nil) {
        self.item = value;
        self.dropboxMessageFetcher = [[DropboxMessageFetcher alloc] initWithDelegate:self responseSelector:@selector(dropboxMessageLoaded:)];
    }
    return self;
}

- (void)loadDropboxMessage {
    if (!item) {
        NSLog(@"ERROR: no ActivityStreamItem has been set; cannot load dropbox message.");
    } if (!item.target) {
        NSLog(@"ERROR: ActivityStreamItem has no target object; cannot load dropbox message.");
    } else {
        //[blockingActivityView show];
        NSInteger courseId = item.object.courseId;
        NSString* basketId = item.target.referenceId;
        NSString* messageId = item.object.referenceId;
        [dropboxMessageFetcher fetchDropboxMessageForCourseId:courseId andBasketId:basketId andMessageId:messageId];

    }
}

- (void)dropboxMessageLoaded:(id)dropboxMsg {
    //[blockingActivityView hide];
    if ([dropboxMsg isKindOfClass:[NSError class]]) {
        NSLog(@"ERROR: Received an error when loading a dropbox message: %@",(NSError*)dropboxMsg);
    } else if([dropboxMsg isKindOfClass:[DropboxMessage class]]) {
        NSLog(@"Received a dropbox message");
        dropboxMsg = [dropboxMsg retain];
        [self setupView];
    } else {
        NSLog(@"ERROR: Received an object of type %@ from dropbox message lookup service", [dropboxMsg class]);
    }

}

- (void)setupView {
    // set up some colors
    UIColor *headerFontColor = HEXCOLOR(0x151848);
    UIColor *subheaderFontColor = HEXCOLOR(0x005B92);
    UIColor *normalTextColor = HEXCOLOR(0x262626);
    UIColor *buttonTextColor = HEXCOLOR(0x5A5A5A);
    
    // set up some fonts
    UIFont* courseNameFont = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    UIFont* titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    UIFont* subheaderFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    UIFont* commentsFont = [UIFont fontWithName:@"Helvetica" size:13];
    UIFont* dateFont = [UIFont fontWithName:@"Helvetica-Oblique" size:12];
    UIFont* buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    
    // set up the course name label
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:item.object.courseId];
    NSString *courseName = course.title;    
    CGSize maximumSize = CGSizeMake(284.0, 1000.0);
    CGSize courseNameSize = [courseName sizeWithFont:courseNameFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap]; // 18px left, right margins, so 284.0 width
    UILabel* courseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 16, courseNameSize.width, courseNameSize.height)];
    courseNameLabel.font = courseNameFont;
    courseNameLabel.textColor = headerFontColor;
    courseNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    courseNameLabel.text = courseName;
    courseNameLabel.backgroundColor = [UIColor clearColor];
    courseNameLabel.numberOfLines = 0;
    [self.view addSubview:courseNameLabel];
    
    // set up the assignment title label
    NSString* assignmentName = item.target.title;
    CGSize assignmentNameSize = [assignmentName sizeWithFont:titleFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* assignmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, courseNameLabel.frame.origin.y + courseNameLabel.frame.size.height + 5, assignmentNameSize.width, assignmentNameSize.height)];
    assignmentLabel.font = titleFont;
    assignmentLabel.textColor = headerFontColor;
    assignmentLabel.lineBreakMode = UILineBreakModeWordWrap;
    assignmentLabel.text = assignmentName;
    assignmentLabel.backgroundColor =  [UIColor clearColor];
    assignmentLabel.numberOfLines = 0;
    [self.view addSubview:assignmentLabel];
    
    // set up the white box in the background, with rounded corners and drop shadow (arbitrary initial height, will change that later)
    UIView* whiteBox = [[UIView alloc] initWithFrame:CGRectMake(9, assignmentLabel.frame.origin.y + assignmentLabel.frame.size.height + 10, 303, 500)];
    whiteBox.backgroundColor = [UIColor whiteColor];
    whiteBox.layer.cornerRadius = 10.0;
    whiteBox.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    whiteBox.layer.shadowRadius = 1.0;
    whiteBox.layer.shadowOpacity = 0.8;
    whiteBox.layer.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:whiteBox];
    
    // set up the image
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    img.image = [UIImage imageNamed:@"clock.png"];
    [whiteBox addSubview:img];    
    
    // set up the 'Posted By' label
    NSString* postedByText = [NSString stringWithFormat:@"%@: %@ (%@)", NSLocalizedString(@"Posted by", @"What follows is the name of a person who posted something"), item.actor.title, [item.actor.role isEqualToString:@"PROF"] ? NSLocalizedString(@"Professor", "The title of the person who teaches a class") : NSLocalizedString(@"Student", @"A person who is taking a class")];
    CGSize postedBySize = [postedByText sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* postedByLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 16, postedBySize.width, postedBySize.height)];
    postedByLabel.font = commentsFont;
    postedByLabel.textColor = normalTextColor;
    postedByLabel.text = postedByText;
    postedByLabel.backgroundColor = [UIColor clearColor];
    postedByLabel.numberOfLines = 0;
    [whiteBox addSubview:postedByLabel];
    
    // set up the date label
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
    DateCalculator* dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian];
    [gregorian release];
    int numDays = [dateCalculator datesFrom:[NSDate date] to:item.postedTime];
    NSString* dateString = [item.postedTime friendlyDateWithTimeFor:numDays];
    CGSize dateSize = [dateString sizeWithFont:dateFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, postedByLabel.frame.origin.y + postedByLabel.frame.size.height + 5, dateSize.width, dateSize.height)];
    dateLabel.font = dateFont;
    dateLabel.textColor = normalTextColor;
    dateLabel.text = dateString;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.numberOfLines = 0;
    [whiteBox addSubview:dateLabel];
                                                
    // set up the comments label
    NSString* summary = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Summary", @"The word meaning 'Summary'"), item.object.summary];
    maximumSize = CGSizeMake(243, 2000);
    CGSize summarySize = [summary sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, dateLabel.frame.origin.y + dateLabel.frame.size.height + 5, summarySize.width, summarySize.height)];
    summaryLabel.font = commentsFont;
    summaryLabel.textColor = normalTextColor;
    summaryLabel.text = summary;
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.numberOfLines = 0;
    [whiteBox addSubview:summaryLabel];
    
    // set up the list of attachments
    NSString* allFiles = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"Files", @"The word meaning 'Files'")];
    for (NSString* attachment in item.object.attachments) {
        allFiles = [NSString stringWithFormat:@"%@\n%@", allFiles, attachment];
    }
    CGSize filesSize = [allFiles sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* filesLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, summaryLabel.frame.origin.y + summaryLabel.frame.size.height + 5, filesSize.width, filesSize.height)];
    filesLabel.font = commentsFont;
    filesLabel.textColor = normalTextColor;
    filesLabel.text = allFiles;
    filesLabel.backgroundColor = [UIColor clearColor];
    filesLabel.numberOfLines = 0;
    [whiteBox addSubview:filesLabel];
    
//    // set up the "view all grades for this course" button
//    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(45, dateLabel.frame.origin.y + dateLabel.frame.size.height + 20, 242, 30)];
//    button.titleLabel.font = buttonFont;
//    [button setTitle:NSLocalizedString(@"View all grades for this course", @"View all grades for this course") forState:UIControlStateNormal];
//    [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
//    button.backgroundColor = HEXCOLOR(0xE9E9E9);
//    button.layer.cornerRadius = 3.0;
//    button.layer.borderWidth = 1.0;
//    button.layer.borderColor = [HEXCOLOR(0xC0C0C0) CGColor];
//    [whiteBox addSubview:button];
//    
    // set the height of the white box
    CGRect boxFrame = whiteBox.frame;
    boxFrame.size.height = filesLabel.frame.origin.y + filesLabel.frame.size.height + 16; 
    whiteBox.frame = boxFrame;

    [img release];
    [filesLabel release];
    [summaryLabel release];
    [dateLabel release];
    [postedByLabel release];
    [assignmentLabel release];
    [courseNameLabel release];
    [whiteBox release];
}

- (void)loadView {
    UIColor *backgroundColor = HEXCOLOR(0xEFE8D8);
    
    // background view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 65, 320, 415)];
    self.view.backgroundColor = backgroundColor;
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];    
}


- (void)dealloc
{
    if (dropboxMessage) {
        [dropboxMessage release];
        dropboxMessage = nil;
    }
    if (blockingActivityView) {
        [blockingActivityView release];
        blockingActivityView = nil;
    }
    if (self.dropboxMessageFetcher) {
        [self.dropboxMessageFetcher cancel];
    }
    self.dropboxMessageFetcher = nil;
    self.item = nil;
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
//    if (item) {
//        [self loadDropboxMessage];
//    }
    [self setupView];
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
