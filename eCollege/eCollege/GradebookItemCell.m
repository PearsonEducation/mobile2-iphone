//
//  GradebookItemCell.m
//  eCollege
//
//  Created by Tony Hillerson on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "GradebookItemCell.h"
#import "ECClientConfiguration.h"

@implementation GradebookItemCell
@synthesize gradeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_arrow_icon.png"]];
		self.gradeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		
		ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
		self.textLabel.font = [config cellHeaderFont];
		self.textLabel.textColor = [config secondaryColor];
		
		self.detailTextLabel.font = [config cellFont];
		
		self.gradeLabel.font = [config cellHeaderFont];
		self.gradeLabel.textColor = [config greyColor];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	CGRect cellFrame = self.frame;
	self.gradeLabel.frame = CGRectMake(cellFrame.size.width - 80, cellFrame.size.height/2 - 15, 50, 30);
	self.gradeLabel.textAlignment = UITextAlignmentRight;
	[self.contentView addSubview:self.gradeLabel];
}

- (void)dealloc {
	self.gradeLabel = nil;
    [super dealloc];
}

@end
