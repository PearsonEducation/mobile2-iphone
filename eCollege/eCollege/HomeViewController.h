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

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    ActivityStream* activityStream;
    ActivityStreamFetcher* activityStreamFetcher;
    NSMutableArray* activityItemsForToday;
    NSMutableArray* activityItemsForLater;
    UITableView* table;
}

@property (nonatomic, retain) ActivityStream* activityStream;
@property (nonatomic, retain) NSMutableArray* activityItemsForToday;
@property (nonatomic, retain) NSMutableArray* activityItemsForLater;

@end
