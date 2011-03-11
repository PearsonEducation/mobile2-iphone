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

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    ActivityStream* activityStream;
    ActivityStreamFetcher* activityStreamFetcher;
    NSMutableArray* todayActivityItems;
    NSMutableArray* earlierActivityItems;
    IBOutlet UITableView* table;
    DateCalculator* dateCalculator;
    NSDate* today;
    BlockingActivityView* blockingActivityView;
}

@property (nonatomic, retain) ActivityStream* activityStream;
@property (nonatomic, retain) NSMutableArray* todayActivityItems;
@property (nonatomic, retain) NSMutableArray* earlierActivityItems;

@end
