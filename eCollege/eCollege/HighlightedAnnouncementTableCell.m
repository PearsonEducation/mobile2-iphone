//
//  HighlightedAnnouncementTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "HighlightedAnnouncementTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Boost.h"
#import "User.h"
#import "GradientCellBackground.h"
#import "ECClientConfiguration.h"

@interface HighlightedAnnouncementTableCell ()
@end

@implementation HighlightedAnnouncementTableCell

@synthesize titleLabel;
@synthesize textLabel;
@synthesize announcement;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // set the frame
        CGRect f = CGRectMake(0, 0, 55, 320);
        self.frame = f;
        self.contentView.frame = f;
        
        // create the fonts
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
        UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:13.0];
        
        // create the colors
        UIColor* titleColor = [UIColor whiteColor];
        UIColor* textColor = [UIColor whiteColor];
        
        // add the title label
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 9, 294, 13)];
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.font = titleFont;
        titleLabel.textColor = titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        
        // add the text label (relative to the title label)
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, titleLabel.frame.origin.y + titleLabel.frame.size.height + 3, 294, 13)];
        textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        textLabel.font = textFont;
        textLabel.textColor = textColor;
        textLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:textLabel];
        
        // set up the gradient backgrounds
        self.backgroundView = [[[GradientCellBackground alloc] init] autorelease];
		((GradientCellBackground *)self.backgroundView).midColor = [[ECClientConfiguration currentConfiguration] secondaryColor];
        self.selectedBackgroundView = [[[GradientCellBackground alloc] init] autorelease];
		((GradientCellBackground *)self.selectedBackgroundView).midColor = [[ECClientConfiguration currentConfiguration] primaryColor];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (announcement) {
        titleLabel.text = announcement.subject;
        textLabel.text = announcement.text;
    }
}

- (void)setAnnouncement:(Announcement*)value {
    if (announcement != value) {
        if (announcement) {
            [announcement release];
        }
        announcement = [value retain];
    }
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}

- (void)dealloc
{
    self.announcement = nil;
    self.titleLabel = nil;
    self.textLabel = nil;
    [super dealloc];
}

@end
