//
//  GradebookItemGradeDetailViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityStreamItem.h"
#import "GradebookItemGradeFetcher.h"
#import "Grade.h"
#import "GradebookItem.h"
#import "BlockingActivityView.h"

@interface GradebookItemGradeDetailViewController : UIViewController {
    ActivityStreamItem* item;
    GradebookItemGradeFetcher* gradebookItemGradeFetcher;
    Grade* grade;
	NSInteger courseId;
	NSString *assignmentName;
	NSNumber *points;
	NSNumber *pointsPossible;
	NSDate *postedTime;
    BlockingActivityView* blockingActivityView;
    UIScrollView* scrollView;
}

- (id)initWithItem:(ActivityStreamItem*)value;
- (id)initWithCourseId:(NSInteger)courseId gradebookItem:(GradebookItem *)gradebookItem grade:(Grade *)grade;

@property (nonatomic, retain) ActivityStreamItem* item;

@end
