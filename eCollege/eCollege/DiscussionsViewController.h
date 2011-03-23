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
#import "PullRefreshTableViewController.h"
#import "DateCalculator.h"

@interface DiscussionsViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray* topics;
    UserDiscussionTopicFetcher* userDiscussionTopicFetcher;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
    DateCalculator* dateCalculator;
    NSDate* today;
    BOOL currentlyLoading;
    BOOL topicsLoadFailure;
    BOOL coursesLoadFailure;
    BOOL forceUpdateOnViewWillAppear;
    NSMutableArray* courseIdsAndTopicArrays;
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
