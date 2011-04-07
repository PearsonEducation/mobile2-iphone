//
//  HomeViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityStream.h"
#import "ActivityStreamFetcher.h"
#import "BlockingActivityView.h"
#import "ECPullRefreshTableViewController.h"
#import "GradientCellBackground.h"

@interface HomeViewController : ECPullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource> {
    ActivityStream* activityStream;
    ActivityStreamFetcher* activityStreamFetcher;
    NSMutableArray* todayActivityItems;
    NSMutableArray* earlierActivityItems;
    NSDate* today;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
    IBOutlet GradientCellBackground* segmentedControlBackground;
    IBOutlet UISegmentedControl* filter;
    
    BOOL currentlyLoading;
    BOOL activitiesLoadFailure;
    BOOL coursesLoadFailure;        
    BOOL courseRefreshInProgress;
    BOOL activitiesRefreshInProgress;
    BOOL forceUpdateOnViewWillAppear;
}

-(IBAction)refreshWithModalSpinner;

@property (nonatomic, retain) ActivityStream* activityStream;
@property (nonatomic, retain) NSMutableArray* todayActivityItems;
@property (nonatomic, retain) NSMutableArray* earlierActivityItems;
@property (nonatomic, retain) NSDate* lastUpdateTime;

@end
