//
//  ActivityTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ActivityTableCell.h"
#import "ActivityStreamItem.h"
#import "GTMNSString+HTML.h"

@implementation ActivityTableCell

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

-(void)setData:(ActivityStreamItem*)item {
	if(item) { 
        friendlyDate.text = [item.friendlyDate gtm_stringByUnescapingFromHTML];
        title.text = [item.object.title gtm_stringByUnescapingFromHTML];
        courseName.text = @"Course name goes here";
        description.text = [item.object.summary gtm_stringByUnescapingFromHTML];
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 25, 25)];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];           
        }
        if (item.object) {
            NSString* imgName;
            NSString* objType = item.object.objectType;
            if ([objType isEqualToString:@"dropbox-submission"]) {
                imgName = @"ic_dropbox_submission.png";
            } else if ([objType isEqualToString:@"exam-submission"]) {
                imgName = @"ic_exam_submission.png";
            } else if ([objType isEqualToString:@"grade"]) {
                imgName = @"ic_grade.png";
            } else if ([objType isEqualToString:@"thread-post"]) {
                imgName = @"ic_thread_post.png";
            } else if ([objType isEqualToString:@"thread-topic"]) {
                imgName = @"ic_thread_topic.png";
            }
            
            // it's important to use the imageNamed: method because it
            // loads cached images.  on a table cell, we definitely don't
            // want to be loading and reloading images all the time.
            imageView.image = [UIImage imageNamed:imgName];;
            [self addSubview:imageView];            
        }
    }
}

- (void)dealloc {
    if (imageView) {
        [imageView release];
    }
    [super dealloc];
}

@end