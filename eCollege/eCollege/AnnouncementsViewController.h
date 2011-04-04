//
//  AnnouncementsViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnouncementFetcher.h"
#import "BlockingActivityView.h"
#import "PullRefreshTableViewController.h"

@interface AnnouncementsViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSInteger courseId;
    NSString* courseName;
    NSArray* announcements;
    AnnouncementFetcher* announcementsFetcher;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
    BOOL currentlyLoading;
    BOOL announcementsLoadFailure;
    BOOL forceUpdateOnViewWillAppear;
}

- (IBAction)refreshWithModalSpinner;

@property (nonatomic, retain) NSArray* announcements;
@property (nonatomic, retain) NSDate* lastUpdateTime;
@property (nonatomic, assign) NSInteger courseId;
@property (nonatomic, retain) NSString* courseName;

@end
