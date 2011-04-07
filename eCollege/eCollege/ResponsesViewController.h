//
//  ResponsesViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECAuthenticatedFetcher.h"
#import "PullRefreshTableViewController.h"
#import "UserDiscussionResponseFetcher.h"
#import "ResponseContentTableCell.h"

@interface ResponsesViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIWebViewDelegate, UITextViewDelegate> {
    ECAuthenticatedFetcher* rootItemFetcher;
    ECAuthenticatedFetcher* responsesFetcher;
    UserDiscussionResponseFetcher* postFetcher;
    UserDiscussionResponseFetcher* markAsReadFetcher;
    
    ResponseContentTableCell* responseContentTableCell;
    
    // rootItem will either be a UserDiscussionTopic or a UserDiscussionResponse,
    // depending on which subclass is being used
    id rootItem;
    NSString* rootItemId;
    BOOL errorFetchingRootItem;
    
    NSArray* responses;
    BOOL errorFetchingResponses;

    NSDate* lastUpdated;
    
    BOOL currentlyRefreshing;
    
    BOOL forceUpdateOnViewWillAppear;
    
    float minimizedContentHeight;
    float actualContentHeight;
    BOOL contentIsMinimized;
    
    UIWebView* webView;
    UIButton* collapseButton;
    UITextField* textField;
    UITextView* textView;
    
    float minimizedDataEntryHeight;
    float actualDataEntryHeight;
    BOOL dataEntryIsMinimized;    
    
    UILabel* responsePromptLabel;
    
    id parent;
}

// The only reason these things are public properties is so they're accessible
// to child classes, who cannot see them if they're declared in the .m file. Ugly!  
@property (nonatomic, retain) NSString* rootItemId;;
@property (nonatomic, retain) ECAuthenticatedFetcher* rootItemFetcher;
@property (nonatomic, retain) ECAuthenticatedFetcher* responsesFetcher;
@property (nonatomic, retain) UserDiscussionResponseFetcher* postFetcher;
@property (nonatomic, retain) UserDiscussionResponseFetcher* markAsReadFetcher;
@property (nonatomic, retain) NSDate* lastUpdated;
@property (nonatomic, retain) id rootItem;
@property (nonatomic, retain) id responses;
@property (nonatomic, retain) id parent;
@property (nonatomic, retain) ResponseContentTableCell* responseContentTableCell;

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
- (void)cancelButtonClicked:(id)sender;
- (void)doneButtonClicked:(id)sender;
- (void)showCancelButton;
- (void)showDoneButton;
- (void)hideCancelButton;
- (void)hideDoneButton;
- (void)moveTableViewTo:(float)y;
- (float)tableOffsetForDataEntryView;
- (void)animateTableCellHeightChanges;
- (void)toggleViewOfFullDataEntryCell;
- (void)postResponse;
- (void)postResponseCompleteHandler:(id)obj;
- (void)setupFetchers;
- (void)forceFutureRefresh;
- (void)markAsRead;
- (void)markAsReadCompleteHandler:(id)obj;

@end
