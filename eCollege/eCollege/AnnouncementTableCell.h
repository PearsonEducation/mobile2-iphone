//
//  CourseTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Announcement.h"

@interface AnnouncementTableCell : UITableViewCell {
    IBOutlet UIImageView* disclosureIndicatorImageView;
    Announcement* course;
    UILabel* subjectLabel;
    UILabel* descLabel;
}

- (void)setData:(Announcement*)course;

@end
