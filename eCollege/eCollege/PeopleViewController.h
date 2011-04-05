//
//  PeopleViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFetcher.h"
#import "BlockingActivityView.h"
#import "PullRefreshTableViewController.h"

@interface PeopleViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSInteger courseId;
    NSArray* people;
    UserFetcher* peopleFetcher;
    BlockingActivityView* blockingActivityView;
    NSDate* lastUpdateTime;
    BOOL currentlyLoading;
    BOOL peopleLoadFailure;
    BOOL forceUpdateOnViewWillAppear;
}

- (IBAction)refreshWithModalSpinner;

@property (nonatomic, retain) NSArray* people;
@property (nonatomic, retain) NSDate* lastUpdateTime;
@property (nonatomic, assign) NSInteger courseId;

@end
