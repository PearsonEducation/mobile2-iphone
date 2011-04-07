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
    UIImageView *courseIcon;
    UILabel *courseTitleLabel;
    UIImageView *professorIcon;
    UILabel *professorNameLabel;
    UIView* courseIconBackground;
}

+ (CourseDetailHeaderTableCell*)cellForCourse:(Course*)course andInstructors:(NSArray*)instructors;

@property (nonatomic, retain) NSArray* instructors;
@property (nonatomic, retain) Course* course;
@property (nonatomic, retain) UILabel *courseTitleLabel;
@property (nonatomic, retain) UILabel *professorNameLabel;
@property (nonatomic, retain) UIImageView *professorIcon;
@property (nonatomic, retain) UIView* courseIconBackground;
@property (nonatomic, retain) UIImageView *courseIcon;


@end
