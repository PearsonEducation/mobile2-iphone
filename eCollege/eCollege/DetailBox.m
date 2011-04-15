//
//  DetailBox.m
//  eCollege
//
//  Created by Brad Umbaugh on 4/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DetailBox.h"
#import "ECClientConfiguration.h"
#import <QuartzCore/CoreAnimation.h>

#define ICON_MAX_WIDTH 25
#define ICON_MAX_HEIGHT 25
#define SMALL_ICON_MAX_WIDTH 12
#define SMALL_ICON_MAX_HEIGHT 12
#define EDGE_MARGIN 10
#define ICON_MARGIN 10
#define BG_CORNER_RADIUS 10
#define VERTICAL_GAP 5
#define BOTTOM_MARGIN 20

@interface DetailBox ()

@property (nonatomic, retain) UIImageView* icon;
@property (nonatomic, retain) UILabel* smallIconDescriptionLabel;
@property (nonatomic, retain) UIImageView* smallIcon;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* boldText1Label;
@property (nonatomic, retain) UILabel* boldText2Label;
@property (nonatomic, retain) UILabel* commentsLabel;
@property (nonatomic, retain) UILabel* dateStringLabel;

@end

@implementation DetailBox

@synthesize iconFileName;
@synthesize icon;

@synthesize smallIconFileName;
@synthesize smallIcon;

@synthesize smallIconDescription;
@synthesize smallIconDescriptionLabel;

@synthesize title;
@synthesize titleLabel;

@synthesize boldText1;
@synthesize boldText1Label;

@synthesize boldText2;
@synthesize boldText2Label;

@synthesize comments;
@synthesize commentsLabel;

@synthesize dateString;
@synthesize dateStringLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
        
        self.backgroundColor = [config whiteColor];
        self.layer.cornerRadius = BG_CORNER_RADIUS;
        self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        
        self.icon = [[[UIImageView alloc] init] autorelease];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:icon];
        
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        titleLabel.numberOfLines = 1;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [config detailBoxHeaderFont];
        titleLabel.textColor = [config secondaryColor];
        [self addSubview:titleLabel];
        
        self.smallIcon = [[[UIImageView alloc] init] autorelease];
        smallIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:smallIcon];

        self.smallIconDescriptionLabel = [[[UILabel alloc] init] autorelease];
        smallIconDescriptionLabel.backgroundColor = [UIColor clearColor];
        smallIconDescriptionLabel.numberOfLines = 0;
        smallIconDescriptionLabel.font = [config detailBoxBoldFont];
        smallIconDescriptionLabel.textColor = [config blackColor];
        [self addSubview:smallIconDescriptionLabel];
        
        self.boldText1Label = [[[UILabel alloc] init] autorelease];
        boldText1Label.backgroundColor = [UIColor clearColor];
        boldText1Label.numberOfLines = 1;
        boldText1Label.font = [config detailBoxBoldFont];
        boldText1Label.textColor = [config blackColor];
        [self addSubview:boldText1Label];
        
        self.boldText2Label = [[[UILabel alloc] init] autorelease];
        boldText2Label.backgroundColor = [UIColor clearColor];
        boldText2Label.numberOfLines = 0;
        boldText2Label.font = [config detailBoxBoldFont];
        boldText2Label.textColor = [config blackColor];
        [self addSubview:boldText2Label];
        
        self.commentsLabel = [[[UILabel alloc] init] autorelease];
        commentsLabel.backgroundColor = [UIColor clearColor];
        commentsLabel.numberOfLines = 0;
        commentsLabel.font = [config detailBoxStandardFont];
        commentsLabel.textColor = [config blackColor];
        [self addSubview:commentsLabel];
        
        self.dateStringLabel = [[[UILabel alloc] init] autorelease];
        dateStringLabel.backgroundColor = [UIColor clearColor];
        dateStringLabel.numberOfLines = 0;
        dateStringLabel.font = [config detailBoxItalicsFont];
        dateStringLabel.textColor = [config blackColor];
        [self addSubview:dateStringLabel];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

    NSInteger textLeftEdge = EDGE_MARGIN + ICON_MAX_WIDTH + ICON_MARGIN;
    NSInteger maxTextWidth = self.frame.size.width - (2*EDGE_MARGIN + ICON_MAX_WIDTH + ICON_MARGIN);
    CGSize maximumSize = CGSizeMake(maxTextWidth, 5000);

    // add the icon
    icon.image = [UIImage imageNamed:iconFileName];
    CGRect iconFrame = CGRectMake(EDGE_MARGIN, EDGE_MARGIN, ICON_MAX_WIDTH, ICON_MAX_HEIGHT);
    icon.frame = iconFrame;
    
    // title
    if (title && ![title isEqualToString:@""]) {
        CGSize titleLabelSize = [title sizeWithFont:titleLabel.font forWidth:maxTextWidth lineBreakMode:UILineBreakModeTailTruncation];
        titleLabel.text = title;
        nextElementY = EDGE_MARGIN + ICON_MAX_HEIGHT/2 - titleLabelSize.height/2; // center the label next to the icon
        titleLabel.frame = CGRectMake(textLeftEdge, nextElementY, titleLabelSize.width, titleLabelSize.height);
        nextElementY = titleLabel.frame.origin.y + titleLabel.frame.size.height + VERTICAL_GAP;
    }
    
    // small icon + description
    if (smallIconFileName && ![title isEqualToString:@""] && smallIconDescription && ![smallIconDescription isEqualToString:@""]) {
        smallIcon.image = [UIImage imageNamed:smallIconFileName];
        CGRect smallIconFrame = CGRectMake(textLeftEdge, nextElementY, SMALL_ICON_MAX_WIDTH, SMALL_ICON_MAX_HEIGHT);
        smallIcon.frame = smallIconFrame;
        
        CGFloat smallIconRightMargin = 5;
        smallIconDescriptionLabel.text = smallIconDescription;
        CGFloat smallIconDescriptionTextMaxWidth = maxTextWidth - (SMALL_ICON_MAX_WIDTH + smallIconRightMargin);
        CGSize smallIconDescriptionLabelSize = [smallIconDescription sizeWithFont:smallIconDescriptionLabel.font forWidth:smallIconDescriptionTextMaxWidth lineBreakMode:UILineBreakModeWordWrap];
        
        smallIconDescriptionLabel.frame = CGRectMake(smallIconFrame.origin.x + smallIconFrame.size.width + smallIconRightMargin, nextElementY + (SMALL_ICON_MAX_HEIGHT/2 - smallIconDescriptionLabelSize.height/2), smallIconDescriptionLabelSize.width, smallIconDescriptionLabelSize.height);
        
        CGFloat nextY1 = smallIconDescriptionLabel.frame.origin.y + smallIconDescriptionLabel.frame.size.height + VERTICAL_GAP; 
        CGFloat nextY2 = smallIconFrame.origin.y + smallIconFrame.size.height + VERTICAL_GAP;
        nextElementY = (nextY1 > nextY2) ? nextY1 : nextY2;
    }
        
    // letter grade
    if (boldText1 != nil && ![boldText1 isEqualToString:@""]) {
        boldText1Label.text = boldText1;
        CGSize boldText1LabelSize = [boldText1 sizeWithFont:boldText1Label.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        boldText1Label.frame = CGRectMake(textLeftEdge, nextElementY, boldText1LabelSize.width, boldText1LabelSize.height);
        nextElementY = boldText1Label.frame.origin.y + boldText1Label.frame.size.height + VERTICAL_GAP;
    }
    
    // numeric grade
    if (boldText2 != nil && ![boldText2 isEqualToString:@""]) {
        boldText2Label.text = boldText2;
        CGSize boldText2LabelSize = [boldText2 sizeWithFont:boldText2Label.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        boldText2Label.frame = CGRectMake(textLeftEdge, nextElementY, boldText2LabelSize.width, boldText2LabelSize.height);
        nextElementY = boldText2Label.frame.origin.y + boldText2Label.frame.size.height + VERTICAL_GAP;
    }
    
    // comments
    if (comments && ![comments isEqualToString:@""]) {
        commentsLabel.text = comments;
        CGSize commentsLabelSize = [comments sizeWithFont:commentsLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        commentsLabel.frame = CGRectMake(textLeftEdge, nextElementY, commentsLabelSize.width, commentsLabelSize.height);
        nextElementY = commentsLabel.frame.origin.y + commentsLabel.frame.size.height + VERTICAL_GAP;
    }
    
    // date
    if (dateString && ![dateString isEqualToString:@""]) {
        dateStringLabel.text = dateString;
        CGSize dateStringLabelSize = [dateString sizeWithFont:dateStringLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        dateStringLabel.frame = CGRectMake(textLeftEdge, nextElementY, dateStringLabelSize.width, dateStringLabelSize.height);
        nextElementY = dateStringLabel.frame.origin.y + dateStringLabel.frame.size.height + VERTICAL_GAP;
    }
    
    // other custom components?
    
    // set the frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (nextElementY - VERTICAL_GAP) + EDGE_MARGIN*2);
}


- (void)dealloc
{
    self.iconFileName = nil;
    self.icon = nil;

    self.smallIconFileName = nil;
    self.smallIcon = nil;
    
    self.smallIconDescription = nil;
    self.smallIconDescriptionLabel = nil;

    self.title = nil;
    self.titleLabel = nil;
    
    self.boldText1 = nil;
    self.boldText1Label = nil;
    
    self.boldText2 = nil;
    self.boldText2Label = nil;
    
    self.comments = nil;
    self.commentsLabel = nil;
    
    self.dateString = nil;
    self.dateStringLabel = nil;
    
    [super dealloc];
}

@end
