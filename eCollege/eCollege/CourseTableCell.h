//
//  CourseTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"


@interface CourseTableCell : UITableViewCell {
    IBOutlet UIImageView* iconImageView;
    IBOutlet UILabel* courseNameLabel;
    IBOutlet UILabel* courseDescriptionLabel;
    IBOutlet UIImageView* disclosureIndicatorImageView;
    Course* course;
}

- (void)setData:(Course*)course;

@end
