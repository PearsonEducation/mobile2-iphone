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
    NSInteger announcementId;
    BlockingActivityView* blockingActivityView;
    NSString* courseName;
}

- (void)setAnnouncementId:(NSInteger)announcementIdValue andCourseId:(NSInteger)courseIdValue andCourseName:(NSString*)courseName;

@end
