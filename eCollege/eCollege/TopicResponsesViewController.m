//
//  TopicResponsesViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "TopicResponsesViewController.h"
#import "UserDiscussionTopic.h"
#import "UserDiscussionTopicFetcher.h"
#import "UserDiscussionResponseFetcher.h"
#import "TopicHeaderTableCell.h"

@implementation TopicResponsesViewController


- (NSString*)getTitleOfRootItem {
    return ((UserDiscussionTopic*)rootItem).topic.title;
}

- (BOOL)isValidRootItemObject:(id)value {
    return value && [value isKindOfClass:[UserDiscussionTopic class]];
}

- (BOOL)isValidResponsesObject:(id)value {
    return value && [value isKindOfClass:[NSArray class]];
}

- (void)fetchRootItem {
    [(UserDiscussionTopicFetcher*)rootItemFetcher fetchDiscussionTopicById:self.rootItemId];        
}

- (void)fetchResponses {
    UserDiscussionResponseFetcher* fetcher = (UserDiscussionResponseFetcher*)self.responsesFetcher;
    UserDiscussionTopic* udt = (UserDiscussionTopic*)self.rootItem;
    DiscussionTopic* dt = udt.topic;
    NSInteger dtid = dt.discussionTopicId;    
    [fetcher fetchUserDiscussionResponsesForTopicId:[NSString stringWithFormat:@"%d",dtid]];
}

- (void)setupFetchers {    
    self.rootItemFetcher = [[UserDiscussionTopicFetcher alloc] initWithDelegate:self responseSelector:@selector(rootItemFetchedHandler:)];
    self.responsesFetcher = [[UserDiscussionResponseFetcher alloc] initWithDelegate:self responseSelector:@selector(responsesFetchedHandler:)];
}

- (UITableViewCell*)getHeaderTableCell {
    UserDiscussionTopic* topic = (UserDiscussionTopic*)self.rootItem;
    NSString* ident = @"TopicHeaderTableCell";
    UITableViewCell* cell;
    cell = [table dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:ident owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [(TopicHeaderTableCell*)cell setData:topic];
    return cell;
}

@end