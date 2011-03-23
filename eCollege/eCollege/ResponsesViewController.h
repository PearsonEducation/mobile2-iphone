//
//  ResponsesViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECAuthenticatedFetcher.h"
#import "DateCalculator.h"
#import "PullRefreshTableViewController.h"

@interface ResponsesViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate> {
    ECAuthenticatedFetcher* rootItemFetcher;
    ECAuthenticatedFetcher* responsesFetcher;
    
    // rootItem will either be a UserDiscussionTopic or a UserDiscussionResponse,
    // depending on which subclass is being used
    id rootItem;
    NSString* rootItemId;
    BOOL errorFetchingRootItem;
    
    NSArray* responses;
    BOOL errorFetchingResponses;

    NSDate* lastUpdated;
    
    DateCalculator* dateCalculator;
    
    BOOL currentlyRefreshing;
    
    BOOL forceUpdateOnViewWillAppear;
}

@property (nonatomic, retain) NSString* rootItemId;;

@end
