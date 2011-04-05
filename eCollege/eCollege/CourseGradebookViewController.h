//
//  CourseGradebookViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradebookItemFetcher.h"

@interface CourseGradebookViewController : UITableViewController {
    GradebookItemFetcher *fetcher;
	NSArray *gradebookItems;
	NSInteger courseId;
}

@property(nonatomic, retain) NSArray *gradebookItems;
@property(nonatomic, assign) NSInteger courseId;

@end
