//
//  ResponsesViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponsesViewController.h"
#import "NSDateUtilities.h"
#import "UserDiscussionTopic.h"
#import "UserDiscussionResponseFetcher.h"
#import "UserDiscussionTopicFetcher.h"
#import "DiscussionTopic.h"
#import "UserDiscussionResponse.h"
#import "TopicHeaderTableCell.h"
#import "DataEntryTableCell.h"
#import "ResponseTableCell.h"
#import "ResponseResponsesViewController.h"
#import "NoResponsesTableCell.h"
#import "ResponseContentTableCell.h"
#import "eCollegeAppDelegate.h"

@interface ResponsesViewController () 

- (void)refreshWithModalSpinner;
- (void)setPrompts;
- (void)reduceTableSizeBy:(CGRect)rect animated:(BOOL)animated;
- (void)increaseTableSizeBy:(CGRect)rect animated:(BOOL)animated;
@end

@implementation ResponsesViewController

@synthesize rootItemId;
@synthesize rootItemFetcher;
@synthesize responsesFetcher;
@synthesize postFetcher;
@synthesize lastUpdateTime;
@synthesize rootItem;
@synthesize responses;
@synthesize parent;
@synthesize markAsReadFetcher;
@synthesize responseContentTableCell;
@synthesize blockingActivityView;
@synthesize dataEntryTableCell;

# pragma mark - Construction, destruction, memory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        actualContentHeight = -1;
        minimizedContentHeight = 100;
        contentIsMinimized = YES;
        
        actualDataEntryHeight = 135.0;
        minimizedDataEntryHeight = 39.0;
        dataEntryIsMinimized = YES;
		
        [self setupFetchers];
    }
    return self;
}

- (void)dealloc {
    self.dataEntryTableCell = nil;
    self.blockingActivityView = nil;
    self.responseContentTableCell = nil;
    self.parent = nil;
    self.rootItemId = nil;
    self.rootItemFetcher = nil;
    self.responsesFetcher = nil;
    self.postFetcher = nil;
    self.markAsReadFetcher = nil;
	self.lastUpdateTime = nil;
    [super dealloc];
}


# pragma mark Methods to override in child classes

- (void)forceFutureRefresh {    
    forceUpdateOnViewWillAppear = YES;
    if (parent && [parent respondsToSelector:@selector(forceFutureRefresh)]) {
        [parent forceFutureRefresh];
    }
}

- (BOOL)isValidRootItemObject:(id)value {
    return NO;
}

- (BOOL)isValidResponsesObject:(id)value {
    return NO;
}

- (void)fetchRootItem {
}

- (void)fetchResponses {
    return;
}

- (void)setupFetchers { 
    self.postFetcher = [[[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(postResponseCompleteHandler:)] autorelease];
    self.markAsReadFetcher = [[[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(markAsReadCompleteHandler:)] autorelease];
}

- (void)postResponse {
}

- (void)postResponseCompleteHandler:(id)obj {
    [[eCollegeAppDelegate delegate] hideGlobalLoader];
    if ([obj isKindOfClass:[NSError class]]) {
        [textView becomeFirstResponder];
    } else {
		textView.text = @"";
		textField.text = @"";
        [self hideDoneButton];
        [self hideCancelButton];
        self.table.scrollEnabled = YES;
        [self toggleViewOfFullDataEntryCell];
        [self refreshWithModalSpinner];
    }
}

- (NSString*)getTitleOfRootItem {
    return nil;
}

- (UITableViewCell*)getHeaderTableCell {
    return nil;
}

- (NSString*)getHtmlContentString {
    return nil;
}

- (void)markAsRead {
}

# pragma mark PullRefreshTableViewController methods

- (void)refreshWithModalSpinner {
    [blockingActivityView show];
    [self refresh];
}

- (void)refresh {
    [self fetchData];
}

- (void)executeAfterHeaderClose {
    self.lastUpdateTime = [NSDate date];
}

- (void)updateLastUpdatedLabel {
    if (self.lastUpdateTime) {
        NSString* prettyTime = [self.lastUpdateTime friendlyString];
        if (![prettyTime isEqualToString:@""] || [self.lastUpdatedLabel.text isEqualToString:@""]) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last update",nil), prettyTime];
        }
    } else {
        self.lastUpdatedLabel.text = NSLocalizedString(@"Last update: unknown",nil);
    }
}




#pragma mark - Other methods

- (void)webViewDidFinishLoad:(UIWebView *)w {
    // now that the data is loaded in the web view, it can be sized.
    [w sizeToFit];
    
    // capture how big the web view actually is with the data
    actualContentHeight = w.frame.size.height;
    
    // reduce the minimum if necessary
    if (actualContentHeight <= minimizedContentHeight) {
        minimizedContentHeight = actualContentHeight;
        collapseButton.hidden = YES;
    } else {
        collapseButton.hidden = NO;
    }
    
    // update the table cells
    if (!currentlyRefreshing) {
        [self animateTableCellHeightChanges];
    }
}

- (void)rootItemFetchedHandler:(id)result {
    if ([self isValidRootItemObject:result]) {
        self.rootItem = result;
        errorFetchingRootItem = NO;
        [self fetchResponses];
    } else {
        NSLog(@"ERROR: problem loading root item");
        errorFetchingRootItem = YES;
        [self fetchingComplete];
    }
}

- (void)responsesFetchedHandler:(id)result {
    if ([self isValidResponsesObject:result]) {
        self.responses = result;
        errorFetchingResponses = NO;
    } else {
        NSLog(@"ERROR: problem loading responses");
        errorFetchingResponses = YES;
    }
    [self fetchingComplete];
}

- (void)fetchData {
    if (currentlyRefreshing) {
        return;
    } else {
        if (self.rootItemId && ![self.rootItemId isEqualToString:@""]) {
            errorFetchingRootItem = NO;
            errorFetchingResponses = NO;
            currentlyRefreshing = YES;
            [self fetchRootItem];
        } else {
            errorFetchingRootItem = YES;
            [self fetchingComplete];
        }
    }
}

- (void)fetchingComplete {
    currentlyRefreshing = NO;
    self.title = [self getTitleOfRootItem];
    if (errorFetchingRootItem || errorFetchingResponses) {
        NSLog(@"ERROR: Problems fetching data.");
    } else {
        // call the service to mark this item as read
        // (note: this method is overridden by child classes)
        [self markAsRead];
        
        // since we've updated the buckets of data, we must now reload the table
        [self.table reloadData];
    }
    
    // if this was being used, hide it
    [blockingActivityView hide];
    
    // tell the "pull to refresh" loading header to go away (if it's present)
    [self stopLoading];
}

- (void)markAsReadCompleteHandler:(id)obj {
    NSLog(@"Mark as read complete.");
    if (parent) {
        // force parent counts to update
        [parent forceFutureRefresh];
    }
}

- (void)showCancelButton {
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    // setting the left bar button item will automatically hide the "back" button
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
}

- (void)showDoneButton {
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

- (void)hideCancelButton {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)hideDoneButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) keyboardDidShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = [(NSValue *)[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self reduceTableSizeBy:keyboardRect animated:YES];
}

- (void) keyboardDidHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = [(NSValue *)[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	[self increaseTableSizeBy:keyboardRect animated:YES];
}

- (void) increaseTableSizeBy:(CGRect)rect animated:(BOOL)animated {
	if (animated) [UIView beginAnimations:@"table_increase_size_for_keyboard" context:NULL];
	CGRect convertedRect = [self.view convertRect:rect fromView:self.view.window];
    CGRect f = self.table.frame;        
    f.size.height += convertedRect.size.height;
    self.table.frame = f;
    if (animated) [UIView commitAnimations];
}

- (void) reduceTableSizeBy:(CGRect)rect animated:(BOOL)animated {
	if (animated) [UIView beginAnimations:@"table_decrease_size_for_keyboard" context:NULL];
	CGRect convertedRect = [self.view convertRect:rect fromView:self.view.window];
    CGRect f = self.table.frame;        
    f.size.height -= convertedRect.size.height;
    self.table.frame = f;
    if (animated) [UIView commitAnimations];
}

- (float)tableOffsetForDataEntryView {
    // get the rect for the input row...
    CGRect inputRect = [self.table rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    CGPoint contentOffset = [self.table contentOffset];
    
    // think of contentOffset as the amount of content that has already scrolled off the screen
    float inputBoxScreenY = inputRect.origin.y - contentOffset.y;
    // TODO: don't use a magic number here, calculate it based on the keyboard frame (somehow)
    float targetScreenY = 66;
    return inputBoxScreenY - targetScreenY;
}

- (void)animateTableCellHeightChanges {
    [table beginUpdates];
    [table endUpdates];
}

- (void)toggleViewOfFullDataEntryCell {
    dataEntryIsMinimized = !dataEntryIsMinimized;
    [self animateTableCellHeightChanges];
    [self setPrompts];
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textFieldValue {
    
    if (currentlyRefreshing) {
        return NO;
    }
    
    // for some reason, when using the simulator and pressing tab to
    // move OUT of the title field and IN to the body field,
    // this method fires again, which is weird.  So, wrapping
    // it in the isFirstResponder call below prevents weirdness.
    if (![textFieldValue isFirstResponder]) {
        // if the user taps from the body back into the header,
        // we don't want to toggle the full view again of the data entry 
        // cell, move the dable, or show the buttons again... that has
        // already been done.
        if (dataEntryIsMinimized) {
            [self showCancelButton];
            [self showDoneButton];
            [self toggleViewOfFullDataEntryCell];
			[self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textView becomeFirstResponder];
    return YES;
}

# pragma mark - UITextView delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)tv {
    responsePromptLabel.hidden = ![tv.text isEqualToString:@""];
}

# pragma mark Methods to use when posting / cancelling

- (void)cancelButtonClicked:(id)sender {
    textView.text = @"";
    textField.text = @"";
    [textView resignFirstResponder];
    [textField resignFirstResponder];
    [self toggleViewOfFullDataEntryCell];
    [self hideCancelButton];
    [self hideDoneButton];
    self.table.scrollEnabled = YES;
}

- (void)doneButtonClicked:(id)sender {
    NSLog(@"Done button clicked");
    [[eCollegeAppDelegate delegate] showGlobalLoader];
    [textView resignFirstResponder];
    [textField resignFirstResponder];
    [self postResponse];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.blockingActivityView = [[[BlockingActivityView alloc] initWithWithView:self.view] autorelease];
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector (keyboardDidShow:)
												 name: UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector (keyboardDidHide:)
												 name: UIKeyboardDidHideNotification object:nil];
    // if activities have never been updated or the last update was more than an hour ago,
    // fetch the topics again.
    if (!self.lastUpdateTime || [self.lastUpdateTime timeIntervalSinceNow] < -3600 || forceUpdateOnViewWillAppear) {
        [self refreshWithModalSpinner];
        forceUpdateOnViewWillAppear = NO;
    }    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentlyRefreshing) {
        return 0;
    } else if (responses && ([responses count] > 0)) {
        // Return the number of rows in the section, plus three:
        //   1. header cell
        //   2. content of the root item (topic or response)
        //   3. data entry cell
        // ... and then all the responses
        return [responses count] + 3;
    } else {
        // the three above, plus a no data cell
        return 4;
    }
}

- (BOOL)isHeaderCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row == 0;
}

- (BOOL)isRootItemContentCell:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row == 1;
}

- (BOOL)isDataEntryCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row == 2;
}

- (BOOL)isResponseCell:(NSIndexPath*)indexPath {
    return indexPath.section == 0 && indexPath.row >= 3 && self.responses && ([self.responses count] > 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isHeaderCell:indexPath]) {
        return 70.0;
    } else if ([self isRootItemContentCell:indexPath]) {
        if (contentIsMinimized) {
            return minimizedContentHeight;
        } else {
            return actualContentHeight;
        }
    } else if ([self isDataEntryCell:indexPath]) {
        if (dataEntryIsMinimized) {
            return minimizedDataEntryHeight;
        } else {
            return actualDataEntryHeight;
        }
    } else if ([self isResponseCell:indexPath]) {
        return 113.0;
    } else {
        // no data cell
        return 93.0;
    }
}

- (void)setPrompts {
    if (textField && responsePromptLabel) {        
        
        // placeholder text for the body field is always the same
        responsePromptLabel.text = NSLocalizedString(@"Message",nil);
        
        // placeholder text for the subject field changes depending on minimized state
        if (!dataEntryIsMinimized) {
            textField.placeholder = NSLocalizedString(@"Subject", nil);
        } else {
            NSString* tmp = NSLocalizedString(@"Post a response",nil);
            NSString* title = [self getTitleOfRootItem];
            if (title && ![title isEqualToString:@""]) {
                tmp = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Post a response to", nil), title];
            }
            textField.placeholder = tmp;            
        }
        
    }
}

- (void)contentButtonTapped:(id)sender {
    [webView sizeToFit];
    contentIsMinimized = !contentIsMinimized;
    [responseContentTableCell rotateButton];
    [self animateTableCellHeightChanges];
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    static NSString *CellIdentifier;
    
    // topic cell
    if ([self isHeaderCell:indexPath]) {
        cell = [self getHeaderTableCell];
    } 
    
    // root item (topic or response) content cell
    else if([self isRootItemContentCell:indexPath]) {
        NSString* ident = @"ResponseContentTableCell";
        UITableViewCell* cell;
        cell = [table dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        ResponseContentTableCell* rctc = (ResponseContentTableCell*)cell;
        self.responseContentTableCell = rctc;
        webView = rctc.webView;
        webView.delegate = self;
        collapseButton = rctc.button;
        [collapseButton addTarget:self action:@selector(contentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rctc loadHtmlString:[self getHtmlContentString]];
        return cell;        
    }
    
    // post box
    else if ([self isDataEntryCell:indexPath]) {
        
        if (self.dataEntryTableCell) {
            cell = self.dataEntryTableCell;
        } else {
            CellIdentifier = @"DataEntryTableCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"DataEntryTableCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            self.dataEntryTableCell = (DataEntryTableCell*)cell;
            textField = ((DataEntryTableCell*)cell).titleTextField;
            textField.delegate = self;
            textView = ((DataEntryTableCell*)cell).contentTextView;
            textView.delegate = self;
            responsePromptLabel = ((DataEntryTableCell*)cell).contentPromptLabel;
        }
        
        if (dataEntryIsMinimized) {
            CGRect f = cell.frame;
            f.size.height = minimizedDataEntryHeight;
            cell.frame = f;
        } else {
            CGRect f = cell.frame;
            f.size.height = actualDataEntryHeight;
            cell.frame = f;
        }
                
        [self setPrompts];
    } 
    
    // response cells
    else if ([self isResponseCell:indexPath]) {
        UserDiscussionResponse* userDiscussionResponse = (UserDiscussionResponse*)[self.responses objectAtIndex:indexPath.row-3];
        NSString* ident = @"ResponseTableCell";
        UITableViewCell* cell;
        cell = [table dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [(ResponseTableCell*)cell setData:userDiscussionResponse];
        return cell;
    }
    
    else {
        NSString* ident = @"NoResponsesTableCell";
        UITableViewCell* cell;
        cell = [table dequeueReusableCellWithIdentifier:ident];
        if (cell == nil) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        return cell;        
    }
    
    return cell;                
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // twirling down the arrow while content is reloading causes the app to crash
    if ([self isRootItemContentCell:indexPath] && !currentlyRefreshing) {
        [self contentButtonTapped:nil];
    }
    
    if ([self isResponseCell:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ResponseResponsesViewController* rrvc = [[ResponseResponsesViewController alloc] initWithNibName:@"ResponsesViewController" bundle:nil];
        UserDiscussionResponse* udr = [self.responses objectAtIndex:indexPath.row-3];
        rrvc.rootItemId = udr.userDiscussionResponseId;
        rrvc.hidesBottomBarWhenPushed = YES;
        rrvc.parent = self;
        [self.navigationController pushViewController:rrvc animated:YES];
        [rrvc release];
    }
}

@end
