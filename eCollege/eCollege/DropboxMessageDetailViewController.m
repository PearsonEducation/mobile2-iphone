//
//  DropboxMessageDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DropboxMessageDetailViewController.h"
#import "DropboxMessage.h"
#import "DropboXBasket.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSDateUtilities.h"
#import "DateCalculator.h"
#import "DropboxAttachment.h"
#import "ECClientConfiguration.h"


@interface DropboxMessageDetailViewController ()

@property (nonatomic, retain) DropboxMessageFetcher* dropboxMessageFetcher;
@property (nonatomic, retain) DropboxBasketFetcher* dropboxBasketFetcher;
@property (nonatomic, retain) NSString* basketId;
@property (nonatomic, retain) NSString* messageId;
@property (nonatomic, retain) id dropboxMessage;
@property (nonatomic, retain) id dropboxBasket;
@property (nonatomic, retain) BlockingActivityView* blockingActivityView;
@property (nonatomic, assign) NSInteger courseId;
@property (nonatomic, retain) UIScrollView* scrollView;

- (void)dropboxMessageLoaded:(id)dropboxMsg;
- (void)setupView;
- (void)serviceCallComplete;
- (void)handleErrors;

@end

@implementation DropboxMessageDetailViewController

@synthesize scrollView;
@synthesize dropboxMessageFetcher;
@synthesize dropboxBasketFetcher;
@synthesize courseId;
@synthesize basketId;
@synthesize messageId;
@synthesize dropboxMessage;
@synthesize dropboxBasket;
@synthesize blockingActivityView;

- (id)initWithCourseId:(NSInteger)cId basketId:(NSString*)bId messageId:(NSString*)mId {
    if ((self = [super init]) != nil) {
        self.courseId = cId;
        self.basketId = bId;
        self.messageId = mId;
        self.dropboxMessageFetcher = [[DropboxMessageFetcher alloc] initWithDelegate:self responseSelector:@selector(dropboxMessageLoaded:)];
        self.dropboxBasketFetcher = [[DropboxBasketFetcher alloc] initWithDelegate:self responseSelector:@selector(dropboxBasketLoaded:)];
    }
    return self;
}

- (void)loadDropboxMessage {
    if (self.messageId && ![self.messageId isEqualToString:@""] && self.basketId && ![self.basketId isEqualToString:@""] && self.courseId > 0) {
        [blockingActivityView show];
        [dropboxMessageFetcher fetchDropboxMessageForCourseId:courseId andBasketId:basketId andMessageId:messageId];
    } else {
        NSLog(@"ERROR: Must have a messageId, basketId, and courseId in order to load a dropbox message.");
        dropboxMessage = NSLocalizedString(@"Must have a messageId, basketId, and courseId in order to load a dropbox message.",@"");
        [self serviceCallComplete];
    }
}

- (void)loadDropboxBasket {
    if (self.basketId && ![self.basketId isEqualToString:@""] && self.courseId > 0) {
        [blockingActivityView show];
        [dropboxBasketFetcher fetchDropboxBasketForCourseId:courseId andBasketId:basketId];
    } else {
        NSLog(@"ERROR: Must have a basketId and courseId in order to load a dropbox basket.");
        dropboxBasket = NSLocalizedString(@"Must have a basketId and courseId in order to load a dropbox basket.",@"");
        [self serviceCallComplete];
    }    
}
                                                                                     
- (void)dropboxMessageLoaded:(id)dropboxMsg {
    [blockingActivityView hide];
    if (!dropboxMsg) {
        dropboxMsg = NSLocalizedString(@"Error loading dropbox message", @"Error loading dropbox message");
    }
    self.dropboxMessage = dropboxMsg;
    [self serviceCallComplete];   
}

- (void)dropboxBasketLoaded:(id)dropboxBskt {
    [blockingActivityView hide];
    if (!dropboxBskt) {
        dropboxBskt = NSLocalizedString(@"Error loading dropbox basket", @"Error loading dropbox basket");
    }
    self.dropboxBasket = dropboxBskt;
    [self serviceCallComplete];   
}

- (void)serviceCallComplete {
    if (dropboxBasket && dropboxMessage) {
        // service calls are complete
        if ([dropboxBasket isKindOfClass:[DropboxBasket class]] && [dropboxMessage isKindOfClass:[DropboxMessage class]]) {
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
    UIFont* errorFont = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    NSString* error = NSLocalizedString(@"Error loading dropbox item",@"Statement that there is an error loading a dropbox item.");
    CGSize maximumSize = CGSizeMake(320, 1000);
    CGSize errorSize = [error sizeWithFont:errorFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - errorSize.width/2, self.view.frame.size.height/2 - errorSize.height/2, errorSize.width, errorSize.height)];
    [errorLabel setTextColor:HEXCOLOR(0x151848)];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.text = error;
    errorLabel.textAlignment = UITextAlignmentCenter;    
    [self.view addSubview:errorLabel];
    [errorLabel release];
}

- (void)setupView {
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.scrollEnabled = YES;
    [self.view addSubview:scrollView];
    
    DropboxBasket* basket = (DropboxBasket*)self.dropboxBasket;
    DropboxMessage* message = (DropboxMessage*)self.dropboxMessage;
    
    // set up some colors
    UIColor *headerFontColor = HEXCOLOR(0x151848);
    UIColor *normalTextColor = HEXCOLOR(0x262626);
    
    // set up some fonts
    UIFont* courseNameFont = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    UIFont* titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    UIFont* commentsFont = [UIFont fontWithName:@"Helvetica" size:13];
    UIFont* dateFont = [UIFont fontWithName:@"Helvetica-Oblique" size:12];
    
    // set up the course name label
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:courseId];
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
    [self.scrollView addSubview:courseNameLabel];
    
    // set up the assignment title label
    NSString* assignmentName = basket.title;
    CGSize assignmentNameSize = [assignmentName sizeWithFont:titleFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* assignmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, courseNameLabel.frame.origin.y + courseNameLabel.frame.size.height + 5, assignmentNameSize.width, assignmentNameSize.height)];
    assignmentLabel.font = titleFont;
    assignmentLabel.textColor = headerFontColor;
    assignmentLabel.lineBreakMode = UILineBreakModeWordWrap;
    assignmentLabel.text = assignmentName;
    assignmentLabel.backgroundColor =  [UIColor clearColor];
    assignmentLabel.numberOfLines = 0;
    [self.scrollView addSubview:assignmentLabel];
    
    // set up the white box in the background, with rounded corners and drop shadow (arbitrary initial height, will change that later)
    UIView* whiteBox = [[UIView alloc] initWithFrame:CGRectMake(9, assignmentLabel.frame.origin.y + assignmentLabel.frame.size.height + 10, 303, 500)];
    whiteBox.backgroundColor = [UIColor whiteColor];
    whiteBox.layer.cornerRadius = 10.0;
    whiteBox.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    whiteBox.layer.shadowRadius = 1.0;
    whiteBox.layer.shadowOpacity = 0.8;
    whiteBox.layer.shadowOffset = CGSizeMake(0, 2);
    [self.scrollView addSubview:whiteBox];
    
    // set up the image
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    img.image = [UIImage imageNamed:[config dropboxIconFileName]];
    [whiteBox addSubview:img];    
    
    // set up the 'Posted By' label
    NSString* postedByText = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Posted by",nil), [message nameOfSubmissionStudent]];
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
    int numDays = [dateCalculator datesFrom:[NSDate date] to:message.date];
    NSString* dateString = [message.date friendlyDateWithTimeFor:numDays];
    CGSize dateSize = [dateString sizeWithFont:dateFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, postedByLabel.frame.origin.y + postedByLabel.frame.size.height + 5, dateSize.width, dateSize.height)];
    dateLabel.font = dateFont;
    dateLabel.textColor = normalTextColor;
    dateLabel.text = dateString;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.numberOfLines = 0;
    [whiteBox addSubview:dateLabel];
    
    // set up the comments label
    NSString* comments = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Comments",nil), message.comments];
    maximumSize = CGSizeMake(243, 2000);
    CGSize commentsSize = [comments sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, dateLabel.frame.origin.y + dateLabel.frame.size.height + 5, commentsSize.width, commentsSize.height)];
    commentsLabel.font = commentsFont;
    commentsLabel.textColor = normalTextColor;
    commentsLabel.text = comments;
    commentsLabel.backgroundColor = [UIColor clearColor];
    commentsLabel.numberOfLines = 0;
    [whiteBox addSubview:commentsLabel];

// [BSU, 3/29/2011] 
// Taking this out for now, so that in the future we can add them back in with quick look / preview
//
// set up a button for each attachment
//    int count = 0;
//    UIButton* btn = nil;
//    
//    while (count < [message.attachments count]) {
//        
//        // grab the attachment
//        DropboxAttachment *attachment = [message.attachments objectAtIndex:count];
//        
//        // figure out the y coordinate of the new button we're making
//        int y;
//        if (count == 0) {
//            y = commentsLabel.frame.origin.y + commentsLabel.frame.size.height + 20;
//        } else {
//            y = btn.frame.origin.y + btn.frame.size.height + 10;
//        }
//        
//        // if this isn't the first iteration through the loop, release the previous button
//        if (btn) {
//            [btn release];
//        }
//        
//        // make the new button
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(45, y, 242, 30)];
//        btn.titleLabel.font = buttonFont;
//        [btn setTitle:attachment.name forState:UIControlStateNormal];
//        [btn setTitleColor:buttonTextColor forState:UIControlStateNormal];
//        btn.backgroundColor = HEXCOLOR(0xE9E9E9);
//        btn.layer.cornerRadius = 3.0;
//        btn.layer.borderWidth = 1.0;
//        btn.layer.borderColor = [HEXCOLOR(0xC0C0C0) CGColor];
//        [btn setTag:count];
//        [whiteBox addSubview:btn];
//        count += 1;
//    }
    
    // set the height of the white box
    CGRect boxFrame = whiteBox.frame;
//    if (btn) {
//        boxFrame.size.height = btn.frame.origin.y + btn.frame.size.height + 16; 
//    } else {
        boxFrame.size.height = commentsLabel.frame.origin.y + commentsLabel.frame.size.height + 16;
//    }
    whiteBox.frame = boxFrame;
    
    scrollView.contentSize = CGSizeMake(320,whiteBox.frame.origin.y + whiteBox.frame.size.height + 100);
    
    // memory management
//    [btn release];
    [img release];
    [commentsLabel release];
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
    self.blockingActivityView = [[[BlockingActivityView alloc] initWithWithView:self.view] autorelease];
}


- (void)dealloc
{
    self.scrollView = nil;
    self.dropboxBasket = nil;
    self.dropboxMessage = nil;
    self.blockingActivityView = nil;
    self.messageId = nil;
    self.basketId = nil;
    
    if (self.dropboxMessageFetcher) {
        [self.dropboxMessageFetcher cancel];
    }
    self.dropboxMessageFetcher = nil;
    
    if (self.dropboxBasketFetcher) {
        [self.dropboxBasketFetcher cancel];
    }
    self.dropboxBasketFetcher = nil;

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

- (void)viewDidAppear:(BOOL)animated {
    [self loadDropboxMessage];    
    [self loadDropboxBasket];
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
