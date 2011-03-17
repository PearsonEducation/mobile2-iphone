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
#import "GradebookItemGrade.h"
#import "BlockingActivityView.h"

@interface GradebookItemGradeDetailViewController : UIViewController {
    ActivityStreamItem* item;
    GradebookItemGradeFetcher* gradebookItemGradeFetcher;
    GradebookItemGrade* grade;
    BlockingActivityView* blockingActivityView;
    
}

- (id)initWithItem:(ActivityStreamItem*)value;

@property (nonatomic, retain) ActivityStreamItem* item;

@end
