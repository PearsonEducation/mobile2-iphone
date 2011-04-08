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
#import "UserGradebookItem.h"
#import "BlockingActivityView.h"

@interface GradebookItemGradeDetailViewController : UIViewController {
    ActivityStreamItem* item;
    GradebookItemGradeFetcher* gradebookItemGradeFetcher;
    Grade* grade;
	NSInteger courseId;
	NSString *assignmentName;
	NSString *displayedGrade;
	NSDate *postedTime;
    BlockingActivityView* blockingActivityView;
    UIScrollView* scrollView;
}

- (id)initWithItem:(ActivityStreamItem*)value;
- (id)initWithCourseId:(NSInteger)cid userGradebookItem:(UserGradebookItem *)ugi;

@property (nonatomic, retain) ActivityStreamItem* item;

@end
