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
#import "DateCalculator.h"
#import "BlockingActivityView.h"
#import "PullRefreshTableViewController.h"

@interface HomeViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource> {
    ActivityStream* activityStream;
    ActivityStreamFetcher* activityStreamFetcher;
    NSMutableArray* todayActivityItems;
    NSMutableArray* earlierActivityItems;
    DateCalculator* dateCalculator;
    NSDate* today;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
}

-(IBAction)refreshWithModalSpinner;

@property (nonatomic, retain) ActivityStream* activityStream;
@property (nonatomic, retain) NSMutableArray* todayActivityItems;
@property (nonatomic, retain) NSMutableArray* earlierActivityItems;
@property (nonatomic, retain) NSDate* lastUpdateTime;

@end
