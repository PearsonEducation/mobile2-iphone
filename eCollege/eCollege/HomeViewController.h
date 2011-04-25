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
#import "UpcomingEventItemsFetcher.h"
#import "UpcomingEventItem.h"

@interface HomeViewController : ECPullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource> {
    // ACTIVITY STREAM
    ActivityStreamFetcher* activityStreamFetcher;
    ActivityStream* activityStream;
    NSMutableArray* todayActivityItems;
    NSMutableArray* earlierActivityItems;
    NSDate* activityStreamLastUpdateTime;
    
    // UPCOMING EVENTS
    UpcomingEventItemsFetcher* upcomingEventItemsFetcher;
    NSArray* upcomingEvents;
    NSMutableArray* todayUpcomingEvents;
    NSMutableArray* tomorrowUpcomingEvents;
    NSMutableArray* twoToFiveDaysUpcomingEvents;
    NSMutableArray* laterUpcomingEvents;
    NSDate* upcomingEventsLastUpdateTime;

    // INTERFACE BUILDER
    IBOutlet GradientCellBackground* segmentedControlBackground;
    IBOutlet UISegmentedControl* filter;

    // OTHER
    BlockingActivityView* blockingActivityView;
    BOOL currentlyLoading;
    BOOL itemsLoadFailure;
    BOOL coursesLoadFailure;        
    BOOL courseRefreshInProgress;
    BOOL itemsRefreshInProgress;
    BOOL forceUpdateOnViewWillAppear;
}

-(IBAction)refreshWithModalSpinner;

// ACTIVITY STREAM
@property (nonatomic, retain) ActivityStream* activityStream;
@property (nonatomic, retain) NSMutableArray* todayActivityItems;
@property (nonatomic, retain) NSMutableArray* earlierActivityItems;
@property (nonatomic, retain) NSDate* activityStreamLastUpdateTime;

// UPCOMING EVENTS
@property (nonatomic, retain) NSArray* upcomingEvents;
@property (nonatomic, retain) NSMutableArray* todayUpcomingEvents;
@property (nonatomic, retain) NSMutableArray* tomorrowUpcomingEvents;
@property (nonatomic, retain) NSMutableArray* twoToFiveDaysUpcomingEvents;
@property (nonatomic, retain) NSMutableArray* laterUpcomingEvents;
@property (nonatomic, retain) NSDate* upcomingEventsLastUpdateTime;

@end
