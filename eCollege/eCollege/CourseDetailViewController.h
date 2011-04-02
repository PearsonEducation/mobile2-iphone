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
#import "AnnouncementFetcher.h"
#import "CourseDetailHeaderTableCell.h"

@interface CourseDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView* table;
    Course* course;
    BlockingActivityView* blockingActivityView;
    CourseFetcher* instructorsFetcher;
    AnnouncementFetcher* announcementFetcher;
    NSArray* announcements;
    NSArray* instructors;
    CourseDetailHeaderTableCell* headerCell;
}

@property (nonatomic, retain) Course* course;
@property (nonatomic, retain) NSArray* announcements;
@property (nonatomic, retain) NSArray* instructors;

@end
