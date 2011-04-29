//
//  ThreadTopicsViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/26/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadTopicFetcher.h"

@class UpcomingEventItem, DetailHeader, BlockingActivityView;

@interface ThreadTopicsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
	IBOutlet UIView *texturedView;
	DetailHeader *detailHeader;
	BlockingActivityView *blockingActivityView;
	ThreadTopicFetcher *threadTopicFetcher;
}

@property(nonatomic, retain) UpcomingEventItem *item;
@property(nonatomic, retain) NSArray *threadTopics;
@property(nonatomic, readonly) NSString *courseName;

@end
