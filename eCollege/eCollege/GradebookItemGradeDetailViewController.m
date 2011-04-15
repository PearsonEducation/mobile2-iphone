//
//  GradebookDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "GradebookItemGradeDetailViewController.h"
#import "Grade.h"
#import "UIColor+Boost.h"
#import "eCollegeAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSDateUtilities.h"
#import "DateCalculator.h"
#import "ECClientConfiguration.h"
#import "GradebookItem.h"
#import "UserGradebookItem.h"
#import "NSString+stripHTML.h"
#import "DetailHeader.h"
#import "DetailBox.h"

@interface GradebookItemGradeDetailViewController ()

@property (nonatomic, retain) GradebookItemGradeFetcher* gradebookItemGradeFetcher;
@property (nonatomic, retain) UIScrollView* scrollView;

- (void)gradebookItemGradeLoaded:(id)gradebookItemGrade;
- (void)setupView;

@end

@implementation GradebookItemGradeDetailViewController

@synthesize item;
@synthesize gradebookItemGradeFetcher;
@synthesize scrollView;

- (id)initWithItem:(ActivityStreamItem*)value {
    if ((self = [super init]) != nil) {
        self.item = [value retain];
		assignmentName = [item.target.title copy];
		displayedGrade = [[NSString stringWithFormat:@"%@/%@", self.item.object.pointsAchieved, self.item.target.pointsPossible] retain];
		postedTime = [self.item.postedTime retain];
        courseId = item.target.courseId;
        self.gradebookItemGradeFetcher = [[[GradebookItemGradeFetcher alloc] initWithDelegate:self responseSelector:@selector(gradebookItemGradeLoaded:)] autorelease];
    }
    return self;
}

- (id)initWithCourseId:(NSInteger)cid userGradebookItem:(UserGradebookItem *)ugi {
    if ((self = [super init]) != nil) {
		GradebookItem *gi = ugi.gradebookItem;
		Grade *g = [ugi grade];
		assignmentName = [gi.title copy];
		grade = [g retain];
		displayedGrade = [[ugi displayedGrade] retain];
		postedTime = [[grade updatedDate] retain];
        courseId = cid;
		[self setupView];
    }
    return self;
}

- (void)loadGradebookItemGrade {
    if (!item) {
        NSLog(@"ERROR: no ActivityStreamItem has been set; cannot load grade.");
    } if (!item.target) {
        NSLog(@"ERROR: ActivityStreamItem has no target object; cannot load grade.");
    } else {
        NSString* guid = item.target.referenceId;
        [gradebookItemGradeFetcher loadGradebookItemGradeForCourseId:courseId andGradebookGuid:guid];
    }
}

- (void)gradebookItemGradeLoaded:(id)gradebookItemGrade {
    if ([gradebookItemGrade isKindOfClass:[NSError class]]) {
        NSLog(@"ERROR: Received an error when looking up a grade: %@",(NSError*)gradebookItemGrade);
    } else if([gradebookItemGrade isKindOfClass:[Grade class]]) {
        NSLog(@"Received a gradebookItemGrade");
        grade = [gradebookItemGrade retain];
        [self setupView];
    } else {
        NSLog(@"ERROR: Received an object of type %@ from gradebook item grade lookup service", [gradebookItemGrade class]);
    }
}

- (void)setupView {
    
    // Grab some needed values
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:courseId];
    if (!course) {
        NSLog(@"ERROR: no course to display in grade detail view");
        return;
    }
    
    if (!grade) {
        NSLog(@"ERROR: no grade to display in grade detail view");
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
    detailHeader.itemType = NSLocalizedString(@"Grade", nil);    
    [scrollView addSubview:detailHeader];
    [detailHeader layoutIfNeeded]; // force it to set its frame (in layoutSubviews) before we position other components relative to it

    // WHITE BOX
    DetailBox* detailBox = [[DetailBox alloc] initWithFrame:CGRectMake(10, detailHeader.frame.origin.y + detailHeader.frame.size.height + 7, 300, 500)]; // height is arbitrary; component will change it
    detailBox.iconFileName = [config gradeIconFileName];
    detailBox.title = assignmentName;
    detailBox.dateString = [postedTime friendlyString];
    if ([item getNumericGrade] != nil) {
        detailBox.boldText2 = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Numeric Grade", nil), [item getNumericGrade]];
    }
    if ([item getLetterGrade] != nil) {
        detailBox.boldText1 = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Letter Grade", nil), [item getLetterGrade]];
    }
    detailBox.comments = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Comments", @"The word meaning 'Comments'"), [grade.comments stripHTML]];    
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
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];    
}

- (void)dealloc {
    self.scrollView = nil;
	self.gradebookItemGradeFetcher = nil;
	[grade release]; grade = nil;
	[assignmentName release]; assignmentName = nil;
	[displayedGrade release];
	[postedTime release]; postedTime = nil;
	[blockingActivityView release]; blockingActivityView = nil;
	self.item = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (item && item.object.id && ![item.object.id isEqualToString:@""]) {
        [self loadGradebookItemGrade];                
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self.gradebookItemGradeFetcher cancel];
	self.gradebookItemGradeFetcher = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
