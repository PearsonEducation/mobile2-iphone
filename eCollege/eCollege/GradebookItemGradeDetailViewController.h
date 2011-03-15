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

@interface GradebookItemGradeDetailViewController : UIViewController {
    ActivityStreamItem* item;
    GradebookItemGradeFetcher* gradebookItemGradeFetcher;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* courseNameLabel;
    IBOutlet UILabel* numericGradeLabel;
    IBOutlet UILabel* commentsLabel;
    IBOutlet UILabel* lastUpdateLabel;
}

@property (nonatomic, retain) ActivityStreamItem* item;

@end
