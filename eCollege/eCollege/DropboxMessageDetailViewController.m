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
#import "NSString+stripHTML.h"
#import "DetailHeader.h"
#import "DetailBox.h"


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
    // Grab some needed values
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:courseId];
    if (!course) {
        NSLog(@"ERROR: no course for display in detail view");
        return;
    }
    
    DropboxBasket* basket = (DropboxBasket*)self.dropboxBasket;
    if (!basket) {
        NSLog(@"ERROR: no dropbox basket for display in detail view");
        return;
    }
    
    DropboxMessage* message = (DropboxMessage*)self.dropboxMessage;
    if (!message) {
        NSLog(@"ERROR: no dropbox message for display in detail view");
        return;
    }

    // SCROLL VIEW
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.scrollEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    // HEADER
    DetailHeader* detailHeader = [[DetailHeader alloc] initWithFrame:CGRectMake(20, 10, 280, 500)]; // height is arbitrary; copmonent will change it
    detailHeader.courseName = course.title;
    detailHeader.itemType = NSLocalizedString(@"Dropbox", nil);
    [scrollView addSubview:detailHeader];
    [detailHeader layoutIfNeeded]; // force it to set its frame (in layoutSubviews) before we position other components relative to it
    
    // WHITE BOX
    DetailBox* detailBox = [[DetailBox alloc] initWithFrame:CGRectMake(10, detailHeader.frame.origin.y + detailHeader.frame.size.height + 7, 300, 500)]; // height is arbitrary; component will change it
    detailBox.iconFileName = [config dropboxIconFileName];
    detailBox.title = basket.title;
    detailBox.dateString = [message.date friendlyString];
    NSString* comments = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Comments",nil), [message.comments stripHTML]];
    detailBox.comments = comments;
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
