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
    NSInteger drid = dr.discussionResponseId;    
    [fetcher fetchDiscussionResponsesForResponseId:[NSString stringWithFormat:@"%d",drid]];
}

- (void)setupFetchers {    
    self.rootItemFetcher = [[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(rootItemFetchedHandler:)];
    self.responsesFetcher = [[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(responsesFetchedHandler:)];
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

@end
