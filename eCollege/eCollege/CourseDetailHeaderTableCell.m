//
//  CourseDetailHeaderTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailHeaderTableCell.h"
#import <QuartzCore/QuartzCore.h>

@interface CourseDetailHeaderTableCell ()

@property (nonatomic, retain) UILabel *courseTitleLabel;
@property (nonatomic, retain) UILabel *professorNameLabel;
@property (nonatomic, retain) UIImageView *professorIcon;
@property (nonatomic, retain) UIImageView *courseIcon;
@property (nonatomic, retain) UIView* courseIconBackground;

@end

@implementation CourseDetailHeaderTableCell

@synthesize instructors;
@synthesize course;
@synthesize courseTitleLabel;
@synthesize professorNameLabel;
@synthesize professorIcon;
@synthesize courseIcon;
@synthesize courseIconBackground;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // size the content correctly
        self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

        // create a few labels (without sizes), add them to the contentView; will
        // size these up in layoutSubviews
        courseTitleLabel = [[UILabel alloc] init];
        professorIcon = [[UIImageView alloc] init];
        professorNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:courseTitleLabel];
        [self.contentView addSubview:professorIcon];
        [self.contentView addSubview:professorNameLabel];

        // this is always in the same place, so no need to put it in layoutSubviews
        courseIconBackground = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 39, 39)];
        courseIconBackground.backgroundColor = [UIColor whiteColor];
        courseIconBackground.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        courseIconBackground.layer.borderWidth = 1.0;
        [self.contentView addSubview:courseIconBackground];
        
        // this is always in the same place, so need to put it in layoutSubviews
        courseIcon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 4, 25, 30)];
        courseIcon.image = [UIImage imageNamed:@"course_icon.png"];
        [courseIconBackground addSubview:courseIcon];
        
        CGRect selfFrame = self.frame;
        CGRect contentViewFrame = self.contentView.frame;
        
        // set the background image
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]]; 
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)setCourse:(Course*)courseValue andInstructors:(NSArray*)instructorsValue {
    self.instructors = instructorsValue;
    self.course = courseValue;    
    [self setNeedsLayout];
}

- (void)layoutSubviews {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}

- (void)dealloc
{
    self.course = nil;
    [super dealloc];
}

@end
