//
//  PersonTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "PersonTableCell.h"
#import "UIColor+Boost.h"

@interface PersonTableCell ()

@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UILabel* roleLabel;
@property (nonatomic, retain) UIImageView* icon;
@property (nonatomic, retain) UIImageView* arrowImageView;
@property (nonatomic, retain) RosterUser* person;

@end

@implementation PersonTableCell

@synthesize nameLabel;
@synthesize roleLabel;
@synthesize person;
@synthesize icon;
@synthesize arrowImageView;

- (void)setData:(RosterUser*)personValue {
    if (personValue) {
        self.person = personValue;
        self.nameLabel.text = personValue.fullNameString;
        self.roleLabel.text = [personValue friendlyRole];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // custom disclosure arrow
        arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(298, 21, 9, 13)];
        arrowImageView.image = [UIImage imageNamed:@"list_arrow_icon.png"];
        [self.contentView addSubview:arrowImageView];

        // person icon
        icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 13, 28, 28)];
        icon.image = [UIImage imageNamed:@"person_male_icon.png"];
        [self.contentView addSubview:icon];
        
        // name label
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 9, 240, 18)];
        nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
        nameLabel.textColor = HEXCOLOR(0x006199);
        [self.contentView addSubview:nameLabel];
        
        // role label
        roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, nameLabel.frame.origin.y + nameLabel.frame.size.height + 2, 240, 15)];
        roleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        roleLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:roleLabel];        
        
        // set this cell to be the right height
        CGRect f = self.frame;
        f.size.height = 55.0;
        self.frame = f;
        f = self.contentView.frame;
        f.size.height = 55.0;
        self.contentView.frame = f;
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
    self.nameLabel = nil;
    self.roleLabel = nil;
    self.person = nil;
    self.icon = nil;
    self.arrowImageView = nil;
    [super dealloc];
}

@end
