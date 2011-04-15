//
//  DetailHeader.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DetailHeader.h"
#import "ECClientConfiguration.h"

#define EDGE_MARGIN 0
#define VERTICAL_GAP 0

@interface DetailHeader ()

@property (nonatomic, retain) UILabel* courseNameLabel;
@property (nonatomic, retain) UILabel* itemTypeLabel;

@end

@implementation DetailHeader

@synthesize courseName;
@synthesize courseNameLabel;

@synthesize itemType;
@synthesize itemTypeLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        self.backgroundColor = [UIColor clearColor];
        
        self.courseNameLabel = [[[UILabel alloc] init] autorelease];
        courseNameLabel.backgroundColor = [UIColor clearColor];
        courseNameLabel.numberOfLines = 0;
        courseNameLabel.font = [config detailHeaderCourseNameFont];
        courseNameLabel.textColor = [config greyColor];
        courseNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:courseNameLabel];
        
        self.itemTypeLabel = [[[UILabel alloc] init] autorelease];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        itemTypeLabel.numberOfLines = 0;
        itemTypeLabel.font = [config detailHeaderItemTypeFont];
        itemTypeLabel.textColor = [config primaryColor];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:itemTypeLabel];
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
        courseNameLabel.frame = CGRectMake(textLeftEdge, nextElementY, courseNameLabelSize.width, courseNameLabelSize.height);
        nextElementY = courseNameLabel.frame.origin.y + courseNameLabel.frame.size.height + VERTICAL_GAP;
    }
    
    // title
    if (itemType) {
        CGSize itemTypeLabelSize = [itemType sizeWithFont:itemTypeLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
        itemTypeLabel.text = itemType;
        itemTypeLabel.frame = CGRectMake(textLeftEdge, nextElementY, itemTypeLabelSize.width, itemTypeLabelSize.height);
        nextElementY = itemTypeLabel.frame.origin.y + itemTypeLabel.frame.size.height + VERTICAL_GAP;
    }

    // set the frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, nextElementY + VERTICAL_GAP);
}

- (void)dealloc
{
    self.courseName = nil;
    self.courseNameLabel = nil;
    self.itemType = nil;
    self.itemTypeLabel = nil;
    [super dealloc];
}

@end
