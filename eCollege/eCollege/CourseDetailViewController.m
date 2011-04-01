//
//  CourseDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailViewController.h"

@interface CourseDetailViewController ()

@property (nonatomic, retain) BlockingActivityView* blockingActivityView;

@end

@implementation CourseDetailViewController

@synthesize course;
@synthesize blockingActivityView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        instructorsFetcher = [[CourseFetcher alloc] initWithDelegate:self responseSelector:@selector(loadedInstructors:)];
    }
    return self;
}

- (void)setupView {
    
}

- (void)loadedInstructors:(id)obj {
    if ([obj isKindOfClass:[NSError class]]) {
        NSLog(@"Error loading instructor for class: %@", course);
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSLog(@"Received some instructors for course %@: %@", course, obj);
        course.instructors = obj;
    }
    [self setupView];
}

- (void)dealloc
{
    [instructorsFetcher cancel];
    [instructorsFetcher release];
    instructorsFetcher = nil;
    
    self.course = nil;
    
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
    // instructors may already have been fetched another time this view was shown
    if (course && !course.instructors) {
        [instructorsFetcher fetchInstructorsForCourseWithId:course.courseId];
    } else {
        [self setupView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
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
