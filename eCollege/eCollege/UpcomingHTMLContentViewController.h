//
//  UpcomingHTMLContentViewController.h
//  eCollege
//
//  Created by Tony Hillerson on 4/27/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailHeader, BlockingActivityView, TextMultimediaFetcher, UpcomingEventItem;

@interface UpcomingHTMLContentViewController : UIViewController {
    IBOutlet UIWebView *webView;
	DetailHeader *detailHeader;
	BlockingActivityView *blockingActivityView;
	TextMultimediaFetcher *multimediaFetcher;
}

@property(nonatomic, retain) UpcomingEventItem *item;
@property(nonatomic, readonly) NSString *courseName;

@end
