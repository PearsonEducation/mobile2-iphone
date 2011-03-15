//
//  GradebookDetailViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "GradebookItemGradeDetailViewController.h"
#import "GradebookItemGrade.h"

@interface GradebookItemGradeDetailViewController ()

@property (nonatomic, retain) GradebookItemGradeFetcher* gradebookItemGradeFetcher;

- (void)gradebookItemGradeLoaded:(id)gradebookItemGrade;

@end

@implementation GradebookItemGradeDetailViewController

@synthesize item;
@synthesize gradebookItemGradeFetcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gradebookItemGradeFetcher = [[GradebookItemGradeFetcher alloc] initWithDelegate:self responseSelector:@selector(gradebookItemGradeLoaded:)];
    }
    return self;
}

- (void)loadGradebookItemGrade {
    if (!item) {
        NSLog(@"ERROR: no ActivityStreamItem has been set; cannot load grade.");
    } if (!item.target) {
        NSLog(@"ERROR: ActivityStreamItem has no target object; cannot load grade.");
    } else {
        NSInteger courseId = item.target.courseId;
        NSString* guid = item.target.referenceId;
        [gradebookItemGradeFetcher loadGradebookItemGradeForCourseId:courseId andGradebookGuid:guid];
    }
}

- (void)gradebookItemGradeLoaded:(id)gradebookItemGrade {
    if ([gradebookItemGrade isKindOfClass:[NSError class]]) {
        NSLog(@"ERROR: Received an error when looking up a grade.");
    } else if([gradebookItemGrade isKindOfClass:[GradebookItemGrade class]]) {
        NSLog(@"Received a gradebookItemGrade");
    } else {
        NSLog(@"ERROR: Received an object of type %@ from gradebook item grade lookup service", [gradebookItemGrade class]);
    }
}

- (void)setItem:(ActivityStreamItem *)value {
    if (value != item) {
        [item release];
    }
    if (value) {
        item = [value retain];
        if (value) {
            if (value.object && value.object.id && ![value.object.id isEqualToString:@""]) {
                [self loadGradebookItemGrade];                
            } else {
                NSLog(@"Error: need a valid ActivityStreamItem, ActivityStreamObject, and ActivityStreamObject.id in order to load a GradebookItemGrade");
                return;
            }
        }
    } else {
        item = nil;
    }
}

- (void)dealloc
{
    self.gradebookItemGradeFetcher = nil;
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
    // Do any additional setup after loading the view from its nib.
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
