//
//  DetailHeader.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailHeader.h"
#import "ECClientConfiguration.h"

#define EDGE_MARGIN 0
#define VERTICAL_GAP 0

@interface DetailHeader ()

@property (nonatomic, retain) UILabel *courseNameLabel;
@property (nonatomic, retain) UILabel *itemTypeLabel;
@property (nonatomic, retain) UILabel *thirdHeaderLabel;

@end

@implementation DetailHeader

@synthesize courseName, courseNameLabel, itemType, itemTypeLabel, thirdHeaderText, thirdHeaderLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        self.backgroundColor = [UIColor clearColor];
        
        self.courseNameLabel = [[[UILabel alloc] init] autorelease];
        courseNameLabel.numberOfLines = 1;
		courseNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        courseNameLabel.font = [config detailHeaderCourseNameFont];
        courseNameLabel.textColor = [config greyColor];
        courseNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:courseNameLabel];
        
        self.itemTypeLabel = [[[UILabel alloc] init] autorelease];
        itemTypeLabel.numberOfLines = 1;
		itemTypeLabel.lineBreakMode = UILineBreakModeTailTruncation;
        itemTypeLabel.font = [config detailHeaderItemTypeFont];
        itemTypeLabel.textColor = [config primaryColor];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:itemTypeLabel];
		
		self.thirdHeaderLabel = [[[UILabel alloc] init] autorelease];
        thirdHeaderLabel.numberOfLines = 1;
		thirdHeaderLabel.lineBreakMode = UILineBreakModeTailTruncation;
        thirdHeaderLabel.font = [config detailHeaderThirdHeaderNameFont];
        thirdHeaderLabel.textColor = [config greyColor];
        thirdHeaderLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:thirdHeaderLabel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger textLeftEdge = EDGE_MARGIN;
    NSInteger maxTextWidth = self.frame.size.width - 2*EDGE_MARGIN;
    CGSize maximumSize = CGSizeMake(maxTextWidth, 5000);
    NSInteger nextElementY = EDGE_MARGIN;
    
    // title
    if (courseName) {
        CGSize courseNameLabelSize = [courseName sizeWithFont:courseNameLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
        courseNameLabel.text = courseName;
        courseNameLabel.frame = CGRectMake(textLeftEdge, nextElementY, maxTextWidth, courseNameLabelSize.height);
        nextElementY = courseNameLabel.frame.origin.y + courseNameLabel.frame.size.height + VERTICAL_GAP;
    }
    
    // title
    if (itemType) {
        CGSize itemTypeLabelSize = [@"One Line" sizeWithFont:itemTypeLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
        itemTypeLabel.text = itemType;
        itemTypeLabel.frame = CGRectMake(textLeftEdge, nextElementY, maxTextWidth, itemTypeLabelSize.height);
        nextElementY = itemTypeLabel.frame.origin.y + itemTypeLabel.frame.size.height + VERTICAL_GAP;
    }
	
	if (thirdHeaderText) {
        CGSize thirdHeaderLabelSize = [@"One Line" sizeWithFont:thirdHeaderLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
        thirdHeaderLabel.text = thirdHeaderText;
        thirdHeaderLabel.frame = CGRectMake(textLeftEdge, nextElementY, maxTextWidth, thirdHeaderLabelSize.height);
        nextElementY = thirdHeaderLabel.frame.origin.y + thirdHeaderLabel.frame.size.height + VERTICAL_GAP;
	}

    // set the frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, nextElementY + VERTICAL_GAP);
}

- (void)dealloc {
	self.thirdHeaderText = nil;
	self.thirdHeaderLabel = nil;
    self.courseName = nil;
    self.courseNameLabel = nil;
    self.itemType = nil;
    self.itemTypeLabel = nil;
    [super dealloc];
}

@end
