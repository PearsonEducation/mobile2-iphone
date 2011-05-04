//
//  UpcomingEventItemTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "UpcomingEventItemTableCell.h"
#import "UpcomingEventItem.h"
#import "eCollegeAppDelegate.h"
#import "Course.h"
#import "ECClientConfiguration.h"
#import "UIImageUtilities.h"
#import "NSString+stripHTML.h"

@interface UpcomingEventItemTableCell ()

@property (nonatomic, retain) UIImageView* imageView;

@end

@implementation UpcomingEventItemTableCell

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
    title.minimumFontSize = title.font.pointSize;
    
    courseName.font = [config cellItalicsFont];
    courseName.textColor = [config blackColor];
    friendlyDate.font = [config cellDateFont];
    friendlyDate.textColor = [config greyColor];
    arrowView.image = [[UIImage imageNamed:[config listArrowFileName]] imageWithOverlayColor:[config secondaryColor]];
}

-(void)setData:(UpcomingEventItem*)item {
	if(item) { 
        title.text = [item.title stripHTML];
        
        Course* course = [[eCollegeAppDelegate delegate] getCourseHavingId:item.courseId];
        if (!course) {
            return;
        }
        courseName.text = course.title;
        
        CategoryType catType = item.categoryType;
        UpcomingEventType eventType = item.eventType;
        if (catType == Start) {
            friendlyDate.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Starts", nil), item.dateString];
        } else if (catType == End) {
            friendlyDate.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Ends", nil), item.dateString];            
        } else if (catType == Due) {
            friendlyDate.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Due", nil), item.dateString];            
        }        
        
        NSString* imgName = nil;
        
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        arrowView.hidden = YES;
        
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        if (eventType == Html) {
            imgName = [config dropboxIconFileName];
            arrowView.hidden = NO;
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else if (eventType == QuizExamTest) {
            imgName = [config examIconFileName];
        } else if (eventType == Thread) {
            arrowView.hidden = NO;
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
            imgName = [config responseIconFileName];
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

- (void)dealloc {
    self.imageView = nil;
    [super dealloc];
}

@end
