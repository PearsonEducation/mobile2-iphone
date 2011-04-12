//
//  DiscussionsViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDiscussionTopicFetcher.h"
#import "BlockingActivityView.h"
#import "ECPullRefreshTableViewController.h"

@interface DiscussionsViewController : ECPullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray* topics;
    UserDiscussionTopicFetcher* userDiscussionTopicFetcher;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
    BOOL currentlyLoading;
    BOOL topicsLoadFailure;
    BOOL coursesLoadFailure;
    BOOL forceUpdateOnViewWillAppear;
    NSMutableArray* orderedCourseInfo;
    NSMutableDictionary* courseInfoByCourseId;
    NSMutableArray* courseNames;
    UIPickerView* picker;
    UIView* filterView;
    int selectedFilterRow;
    IBOutlet UILabel* tableTitle;
    UIView* blockingModalView;
}

- (IBAction)refreshWithModalSpinner;

@property (nonatomic, retain) NSArray* topics;
@property (nonatomic, retain) NSDate* lastUpdateTime;

@end
