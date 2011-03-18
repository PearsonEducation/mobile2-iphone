//
//  DropboxMessageDetailViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxMessage.h"
#import "DropboxMessageFetcher.h"
#import "ActivityStreamItem.h"
#import "BlockingActivityView.h"

@interface DropboxMessageDetailViewController : UIViewController {
    ActivityStreamItem* item;
    DropboxMessage* dropboxMessage;
    DropboxMessageFetcher* dropboxMessageFetcher;
    BlockingActivityView* blockingActivityView;
}

- (id)initWithItem:(ActivityStreamItem*)value;

@end
