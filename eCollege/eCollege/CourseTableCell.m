//
//  CourseTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseTableCell.h"

@interface CourseTableCell ()

@property (nonatomic, retain) Course* course;

@end

@implementation CourseTableCell

@synthesize course;

- (void)setData:(Course*)courseValue {
    if (courseValue) {
        self.course = courseValue;
        courseNameLabel.text = courseValue.title;
        courseDescriptionLabel.text = courseValue.displayCourseCode;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
    iconImageView.image = [UIImage imageNamed:@"course_icon.png"];
    disclosureIndicatorImageView.image = [UIImage imageNamed:@"list_arrow_icon.png"];
}

- (void)dealloc
{
    self.course = nil;
    [super dealloc];
}

@end
