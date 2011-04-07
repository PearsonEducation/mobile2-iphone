//
//  CourseDetailHeaderTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailHeaderTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Boost.h"
#import "User.h"
#import "ECClientConfiguration.h"

@interface CourseDetailHeaderTableCell ()


@end

@implementation CourseDetailHeaderTableCell

@synthesize instructors;
@synthesize course;
@synthesize courseTitleLabel;
@synthesize professorNameLabel;
@synthesize professorIcon;
@synthesize courseIconBackground;
@synthesize courseIcon;

+ (CourseDetailHeaderTableCell*)cellForCourse:(Course*)course andInstructors:(NSArray*)instructors {
    
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    CourseDetailHeaderTableCell* cell = [[[CourseDetailHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CourseDetailHeaderTableCell"] autorelease];
    cell.instructors = instructors;
    cell.course = course;
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    // FONTS
    UIFont* courseTitleLabelFont = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    UIFont* professorNameLabelFont = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    
    // COLORS
    UIColor* courseTitleLabelColor = HEXCOLOR(0x14194A);
    UIColor* professorNameLabelColor = HEXCOLOR(0x252525);

    // SIZES
    CGSize maximumCourseTitleLabelSize = CGSizeMake(260, 1000);
    CGSize maximumProfessorNameLabelSize = CGSizeMake(220, 1000);
    CGSize actualLabelSize;
    
    // FRAMES
    CGRect labelFrame;
    
    // courseTitleLabel setup
    cell.courseTitleLabel.textColor = courseTitleLabelColor;
    actualLabelSize = [course.title sizeWithFont:courseTitleLabelFont constrainedToSize:maximumCourseTitleLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    labelFrame = CGRectMake(cell.courseIconBackground.frame.origin.x + cell.courseIconBackground.frame.size.width + 5, cell.courseIcon.frame.origin.y, actualLabelSize.width, actualLabelSize.height);
    cell.courseTitleLabel.font = courseTitleLabelFont;
    cell.courseTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.courseTitleLabel.frame = labelFrame;
    cell.courseTitleLabel.text = course.title;
    cell.courseTitleLabel.numberOfLines = 0;
    cell.courseTitleLabel.backgroundColor = [UIColor clearColor];
    
    // place the professor icon
    cell.professorIcon.image = [UIImage imageNamed:[config smallPersonIconFileName]];
    CGRect iconFrame = CGRectMake(cell.courseTitleLabel.frame.origin.x, cell.courseTitleLabel.frame.origin.y + cell.courseTitleLabel.frame.size.height + 5, 12, 12);
    cell.professorIcon.frame = iconFrame;
    
    // professorNameLabel setup
    cell.professorNameLabel.font = professorNameLabelFont;
    cell.professorNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.professorNameLabel.numberOfLines = 0;
    NSString* allNames = @"";
    if (instructors && [instructors count] > 0) {
        allNames = [(User*)[instructors objectAtIndex:0] fullName];
        int index = 1;
        while (index < [instructors count]) {
            User* u = [instructors objectAtIndex:index];
            allNames = [NSString stringWithFormat:@"%@, %@", allNames, [u fullName]];
            index += 1;
        }
    }
    cell.professorNameLabel.textColor = professorNameLabelColor;
    actualLabelSize = [allNames sizeWithFont:professorNameLabelFont constrainedToSize:maximumProfessorNameLabelSize lineBreakMode:UILineBreakModeWordWrap];
    labelFrame = CGRectMake(cell.professorIcon.frame.origin.x + cell.professorIcon.frame.size.width + 5, cell.professorIcon.frame.origin.y - 1, actualLabelSize.width, actualLabelSize.height);
    cell.professorNameLabel.frame = labelFrame;
    cell.professorNameLabel.text = allNames;
    cell.professorNameLabel.backgroundColor = [UIColor clearColor];
    
    // hide the icon if there's no names
    cell.professorIcon.hidden = [allNames isEqualToString:@""];
    
    // set the size of the cell
    CGRect cellFrame = cell.frame;
    if ([allNames isEqualToString:@""]) {
        cellFrame.size.height = cell.courseTitleLabel.frame.origin.y + cell.courseTitleLabel.frame.size.height + 20;
    } else {
        cellFrame.size.height = cell.professorNameLabel.frame.origin.y + cell.professorNameLabel.frame.size.height + 20;        
    }
    cell.frame = cellFrame;
    cell.contentView.frame = cellFrame;
    
    // return this cell, which is now setup
    return cell;
}

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
        
        // set the background image
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]]; 
        self.backgroundColor = [UIColor redColor];
    }
    return self;
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
