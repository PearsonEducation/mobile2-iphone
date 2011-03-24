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

@interface ResponsesViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
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
    
    int contentHeight;
    UIWebView* webView;
    int actualContentHeight;
}

// The only reason these things are public properties is so they're accessible
// to child classes, who cannot see them if they're declared in the .m file. Ugly!  
@property (nonatomic, retain) NSString* rootItemId;;
@property (nonatomic, retain) ECAuthenticatedFetcher* rootItemFetcher;
@property (nonatomic, retain) ECAuthenticatedFetcher* responsesFetcher;
@property (nonatomic, retain) NSDate* lastUpdated;
@property (nonatomic, retain) DateCalculator* dateCalculator;
@property (nonatomic, retain) id rootItem;
@property (nonatomic, retain) id responses;

- (void)rootItemFetchedHandler:(id)result;
- (void)responsesFetchedHandler:(id)result;
- (void)fetchData;
- (void)fetchRootItem;
- (void)fetchResponses;
- (BOOL)isValidRootItemObject:(id)value;
- (BOOL)isValidResponsesObject:(id)value;
- (void)fetchingComplete;
- (BOOL)isHeaderCell:(NSIndexPath*)indexPath;
- (BOOL)isRootItemContentCell:(NSIndexPath*)indexPath;
- (BOOL)isDataEntryCell:(NSIndexPath*)indexPath;
- (BOOL)isResponseCell:(NSIndexPath*)indexPath;
- (UITableViewCell*)getHeaderTableCell;
- (NSString*)getTitleOfRootItem;
- (NSString*)getHtmlContentString;

@end
