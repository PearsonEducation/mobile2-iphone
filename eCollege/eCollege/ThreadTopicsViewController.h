//
//  ThreadTopicsViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/26/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UpcomingEventItem, DetailHeader;

@interface ThreadTopicsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
	DetailHeader *detailHeader;
}

@property(nonatomic, retain) UpcomingEventItem *item;
@property(nonatomic, readonly) NSString *courseName;

@end
