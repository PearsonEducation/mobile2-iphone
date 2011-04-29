//
//  DropboxMessageDetailViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxMessageFetcher.h"
#import "DropboxBasketFetcher.h"
#import "BlockingActivityView.h"

@interface DropboxMessageDetailViewController : UIViewController {
    id dropboxMessage;
    id dropboxBasket;
    DropboxMessageFetcher* dropboxMessageFetcher;
    DropboxBasketFetcher* dropboxBasketFetcher;
    BlockingActivityView* blockingActivityView;
    NSNumber *courseId;
    NSString* basketId;
    NSString* messageId;
    UIScrollView* scrollView;
}

- (id)initWithCourseId:(NSNumber*)courseId basketId:(NSString*)basketId messageId:(NSString*)messageId;

@end
