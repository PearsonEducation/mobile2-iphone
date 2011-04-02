//
//  CourseDetailTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/2/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "CourseDetailTableCell.h"
#import "UIColor+Boost.h"

@implementation CourseDetailTableCell

@synthesize arrowImageView;
@synthesize unreadCountLabel;
@synthesize countBubbleImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(298, 21, 9, 13)];
        arrowImageView.image = [UIImage imageNamed:@"list_arrow_icon.png"];
        [self addSubview:arrowImageView];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        self.textLabel.textColor = HEXCOLOR(0x006199);
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
    self.arrowImageView = nil;
    [super dealloc];
}

@end
