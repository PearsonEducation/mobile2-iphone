//
//  CourseDetailHeaderTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"


@interface CourseDetailHeaderTableCell : UITableViewCell {
    NSArray *instructors;
    Course *course;
    UILabel *courseTitleLabel;
    UIImageView *professorIcon;
    UILabel *professorNameLabel;
    UIImageView *courseIcon;
    UIView* courseIconBackground;
}

- (void)setCourse:(Course*)courseValue andInstructors:(NSArray*)instructorsValue;

@property (nonatomic, retain) NSArray* instructors;
@property (nonatomic, retain) Course* course;

@end
