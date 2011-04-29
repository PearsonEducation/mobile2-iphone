//
//  AnnouncementDetailViewcontroller.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/17/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockingActivityView.h"
#import "AnnouncementFetcher.h"
#import "Announcement.h"

@interface AnnouncementDetailViewController : UIViewController {
    AnnouncementFetcher *announcementFetcher;
    id announcement;
    BlockingActivityView* blockingActivityView;
    NSString* courseName;
    UIScrollView* scrollView;
}

- (void)setAnnouncementId:(NSNumber *)announcementIdValue andCourseId:(NSNumber *)courseIdValue andCourseName:(NSString*)courseName;

@end
