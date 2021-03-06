
//
//  ResponseResponsesViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseResponsesViewController.h"
#import "UserDiscussionResponse.h"
#import "UserDiscussionResponseFetcher.h"
#import "ResponseHeaderTableCell.h"

@implementation ResponseResponsesViewController

- (NSString*)getHtmlContentString {
    return [[(UserDiscussionResponse*)rootItem response] description];
}

- (BOOL)isValidRootItemObject:(id)value {
    return value && [value isKindOfClass:[UserDiscussionResponse class]];
}

- (BOOL)isValidResponsesObject:(id)value {
    return value && [value isKindOfClass:[NSArray class]];
}

- (NSString*)getTitleOfRootItem {
    return ((UserDiscussionResponse*)rootItem).response.title;
}

- (void)fetchRootItem {
    [(UserDiscussionResponseFetcher*)rootItemFetcher fetchUserDiscussionResponseByUserResponseId:self.rootItemId];        
}

- (void)fetchResponses {
    UserDiscussionResponseFetcher* fetcher = (UserDiscussionResponseFetcher*)self.responsesFetcher;
    UserDiscussionResponse* udr = (UserDiscussionResponse*)self.rootItem;
    DiscussionResponse* dr = udr.response;
    [fetcher fetchDiscussionResponsesForResponseId:[dr.discussionResponseId stringValue]];
}

- (void)setupFetchers {    
    [super setupFetchers];
    self.rootItemFetcher = [[[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(rootItemFetchedHandler:)] autorelease];
    self.responsesFetcher = [[[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(responsesFetchedHandler:)] autorelease];
}

- (UITableViewCell*)getHeaderTableCell {
    UserDiscussionResponse* response = (UserDiscussionResponse*)self.rootItem;
    NSString* ident = @"ResponseHeaderTableCell";
    UITableViewCell* cell;
    cell = [table dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [(ResponseHeaderTableCell*)cell setData:response];
    return cell;
}

- (void)postResponse {
    if (parent) {
        [parent forceFutureRefresh];
    }
    UserDiscussionResponse* udr = (UserDiscussionResponse*)self.rootItem;
    [self.postFetcher postResponseToResponseWithId:[NSString stringWithFormat:@"%d",udr.response.discussionResponseId] andTitle:textField.text andText:textView.text];
}

- (void)markAsRead {
    UserDiscussionResponse* udr = (UserDiscussionResponse*)self.rootItem;
    if (!udr.markedAsRead) {
        NSLog(@"Marking response %@ as read", udr.response.discussionResponseId);
        [self.markAsReadFetcher markResponseId:[udr.response.discussionResponseId stringValue] asRead:YES];
    }
}

@end
