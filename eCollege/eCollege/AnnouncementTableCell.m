//
//  AnnouncementTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "AnnouncementTableCell.h"
#import "UIColor+Boost.h"

@interface AnnouncementTableCell ()

@property (nonatomic, retain) Announcement* announcement;
@property (nonatomic, retain) UILabel* subjectLabel;
@property (nonatomic, retain) UILabel* descLabel;

@end

@implementation AnnouncementTableCell

@synthesize announcement;
@synthesize subjectLabel;
@synthesize descLabel;

- (void)setData:(Announcement*)announcementValue {
    if (announcementValue) {
        self.announcement = announcementValue;
        self.subjectLabel.text = announcementValue.subject;
        self.descLabel.text = announcementValue.text;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        disclosureIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(298, 21, 9, 13)];
        disclosureIndicatorImageView.image = [UIImage imageNamed:@"list_arrow_icon.png"];
        [self addSubview:disclosureIndicatorImageView];
        
        subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 18)];
        subjectLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
        subjectLabel.textColor = HEXCOLOR(0x006199);
        [self.contentView addSubview:subjectLabel];
        
        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,subjectLabel.frame.origin.y + subjectLabel.frame.size.height + 2, 280, 15)];
        descLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        descLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:descLabel];        
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
    self.subjectLabel = nil;
    self.descLabel = nil;
    self.announcement = nil;
    [super dealloc];
}

@end
