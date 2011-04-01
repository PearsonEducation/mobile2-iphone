//
//  CourseDetailViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "BlockingActivityView.h"
#import "CourseFetcher.h"

@interface CourseDetailViewController : UIViewController {
    Course* course;
    BlockingActivityView* blockingActivityView;
    CourseFetcher* instructorsFetcher;
}

@property (nonatomic, retain) Course* course;

@end
