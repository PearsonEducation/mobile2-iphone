//
//  ActivityTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ActivityTableCell.h"
#import "ActivityStreamItem.h"
#import "eCollegeAppDelegate.h"
#import "Course.h"
#import "ECClientConfiguration.h"
#import "UIImageUtilities.h"
#import "NSString+stripHTML.h"

@interface ActivityTableCell ()

@property (nonatomic, retain) UIImageView* imageView;

@end

@implementation ActivityTableCell

@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)awakeFromNib {
    ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
    title.font = [config cellHeaderFont];
    title.textColor = [config secondaryColor];
    description.font = [config cellFont];
    description.textColor = [config blackColor];
    courseName.font = [config cellItalicsFont];
    courseName.textColor = [config blackColor];
    friendlyDate.font = [config cellDateFont];
    friendlyDate.textColor = [config greyColor];
    arrowView.image = [[UIImage imageNamed:[config listArrowFileName]] imageWithOverlayColor:[config secondaryColor]];
}

-(void)setData:(ActivityStreamItem*)item {
	if(item) { 
        friendlyDate.text = item.friendlyDate;
        title.text = [[item getTitle] stripHTML];
        Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:item.object.courseId];
        courseName.text = course.title;
        description.text = [[item getDescription] stripHTML];
        if (item.object) {
            NSString* imgName;
            NSString* objType = item.object.objectType;
            
            ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
            if ([objType isEqualToString:@"dropbox-submission"]) {
                imgName = [config dropboxIconFileName];
            } else if ([objType isEqualToString:@"exam-submission"]) {
                imgName = [config examIconFileName];
            } else if ([objType isEqualToString:@"grade"]) {
                imgName = [config gradeIconFileName];
            } else if ([objType isEqualToString:@"thread-post"]) {
                imgName = [config responseIconFileName];
            } else if ([objType isEqualToString:@"thread-topic"]) {
                imgName = [config topicIconFileName];
            }
            
            // it's important to use the imageNamed: method because it
            // loads cached images.  on a table cell, we definitely don't
            // want to be loading and reloading images all the time.
            self.imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]] autorelease];
            [self.imageView setContentMode:UIViewContentModeScaleAspectFit];      
            CGRect f = imageView.frame;
            f.origin.x = 8;
            f.origin.y = 8;
            f.size.height = 25;
            f.size.width = 25;
            imageView.frame = f;
            [self addSubview:imageView];            
        }
    }
}

- (void)dealloc {
    self.imageView = nil;
    [super dealloc];
}

@end
