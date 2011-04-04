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

@interface AnnouncementDetailViewcontroller : UIViewController {
    AnnouncementFetcher *announcementFetcher;
    id announcement;
    NSInteger announcementId;
    BlockingActivityView* blockingActivityView;
}

- (id)initWithAnnouncementId:(NSInteger)announcementId andCourseId:(NSInteger)courseId;

@end
