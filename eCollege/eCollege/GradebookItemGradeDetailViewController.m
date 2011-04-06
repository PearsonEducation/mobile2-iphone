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

@interface GradebookItemGradeDetailViewController ()

@property (nonatomic, retain) GradebookItemGradeFetcher* gradebookItemGradeFetcher;

- (void)gradebookItemGradeLoaded:(id)gradebookItemGrade;
- (void)setupView;

@end

@implementation GradebookItemGradeDetailViewController

@synthesize item;
@synthesize gradebookItemGradeFetcher;

- (id)initWithItem:(ActivityStreamItem*)value {
    if ((self = [super init]) != nil) {
        self.item = [value retain];
		assignmentName = [item.target.title copy];
		points = [self.item.object.pointsAchieved copy];
		pointsPossible = [self.item.target.pointsPossible copy];
		postedTime = [self.item.postedTime retain];
        courseId = item.target.courseId;
        self.gradebookItemGradeFetcher = [[GradebookItemGradeFetcher alloc] initWithDelegate:self responseSelector:@selector(gradebookItemGradeLoaded:)];
    }
    return self;
}

- (id)initWithCourseId:(NSInteger)cid gradebookItem:(GradebookItem *)gi grade:(Grade *)g {
    if ((self = [super init]) != nil) {
		assignmentName = [gi.title copy];
		grade = [g retain];
		points = [g.points copy];
		pointsPossible = [gi.pointsPossible copy];
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
    [self.view addSubview:courseNameLabel];
    
    // set up the assignment title label
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
    img.image = [UIImage imageNamed:@"ic_grade.png"];
    [whiteBox addSubview:img];
    
    NSString* gradeText = [NSString stringWithFormat:@"%@: %@/%@", NSLocalizedString(@"Grade", @"The word for 'Grade'"), points, pointsPossible];
    UILabel* gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 16, 243, 16)];
    gradeLabel.font = subheaderFont;
    gradeLabel.textColor = subheaderFontColor;
    gradeLabel.text = gradeText;
    gradeLabel.backgroundColor = [UIColor clearColor];
    [whiteBox addSubview:gradeLabel];
    
    // set up the comments label
    NSString* comments = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Comments", @"The word meaning 'Comments'"), grade.comments];
    maximumSize = CGSizeMake(243, 2000);
    CGSize commentsSize = [comments sizeWithFont:commentsFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 37, commentsSize.width, commentsSize.height)];
    commentsLabel.font = commentsFont;
    commentsLabel.textColor = normalTextColor;
    commentsLabel.text = comments;
    commentsLabel.backgroundColor = [UIColor clearColor];
    commentsLabel.numberOfLines = 0;
    [whiteBox addSubview:commentsLabel];
        
    // set up the date label
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone defaultTimeZone]];
    DateCalculator* dateCalculator = [[DateCalculator alloc] initWithCalendar:gregorian];
    [gregorian release];
    int numDays = [dateCalculator datesFrom:[NSDate date] to:postedTime];
    NSString* dateString = [postedTime friendlyDateWithTimeFor:numDays];
    CGSize dateSize = [dateString sizeWithFont:dateFont constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, commentsLabel.frame.origin.y + commentsLabel.frame.size.height + 5, dateSize.width, dateSize.height)];
    dateLabel.font = dateFont;
    dateLabel.textColor = normalTextColor;
    dateLabel.text = dateString;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.numberOfLines = 0;
    [whiteBox addSubview:dateLabel];
    
	if (item) { // Only show "view all button if viewed as detail from activity stream.
		// set up the "view all grades for this course" button
		UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(45, dateLabel.frame.origin.y + dateLabel.frame.size.height + 20, 242, 30)];
		button.titleLabel.font = buttonFont;
		[button setTitle:NSLocalizedString(@"View all grades for this course", @"View all grades for this course") forState:UIControlStateNormal];
		[button setTitleColor:buttonTextColor forState:UIControlStateNormal];
		button.backgroundColor = HEXCOLOR(0xE9E9E9);
		button.layer.cornerRadius = 3.0;
		button.layer.borderWidth = 1.0;
		button.layer.borderColor = [HEXCOLOR(0xC0C0C0) CGColor];
		[whiteBox addSubview:button];
		// set the height of the white box
		CGRect boxFrame = whiteBox.frame;
		boxFrame.size.height = button.frame.origin.y + button.frame.size.height + 16; 
		whiteBox.frame = boxFrame;
		[button release];
	} else {
		CGRect boxFrame = whiteBox.frame;
		boxFrame.size.height = dateLabel.frame.origin.y + dateLabel.frame.size.height + 16; 
		whiteBox.frame = boxFrame;
	}
    
    [img release];
    [courseNameLabel release];
    [assignmentLabel release];
    [gradeLabel release];
    [commentsLabel release];
    [dateLabel release];
    [whiteBox release];
    [dateCalculator release];

}

- (void)loadView {
    UIColor *backgroundColor = HEXCOLOR(0xEFE8D8);

    // background view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 65, 320, 415)];
    self.view.backgroundColor = backgroundColor;
    blockingActivityView = [[BlockingActivityView alloc] initWithWithView:self.view];    
}

- (void)dealloc {
	[grade release]; grade = nil;
	[assignmentName release]; assignmentName = nil;
	[points release];
	[pointsPossible release];
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
