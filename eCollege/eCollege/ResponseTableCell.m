//
//  ResponseTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseTableCell.h"
#import "NSDateUtilities.h"
#import "ECClientConfiguration.h"
#import "UIImageUtilities.h"
#import "UIColor+Boost.h"
#import "NSString+stripHTML.h"

@interface ResponseTableCell () 

@property (nonatomic, retain) UserDiscussionResponse* userDiscussionResponse;

@end

@implementation ResponseTableCell

@synthesize userDiscussionResponse;

- (void)dealloc
{
    self.userDiscussionResponse = nil;
    [super dealloc];
}

-(void)setData:(UserDiscussionResponse*)responseValue {
    
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    self.userDiscussionResponse = responseValue;
    
    if (responseValue.markedAsRead) {
        activityImage.alpha = 0.35;
        self.contentView.backgroundColor = [config whiteColor];
    } else {
        activityImage.alpha = 1.0;
        // TODO: shouldn't be setting the color by using an alpha, so we should get new values...
        self.contentView.backgroundColor = [[config secondaryColor] colorWithAlphaComponent:0.35];
    }

    // set the date
    dateLabel.text = [responseValue.response.postedDate friendlyString];
    
    // set the name
    if (self.userDiscussionResponse && self.userDiscussionResponse.response && self.userDiscussionResponse.response.author && ![[self.userDiscussionResponse.response.author fullName] isEqualToString:@""]) {
        posterNameLabel.text = [self.userDiscussionResponse.response.author fullName];        
    }
    
    // grab the counts
    int totalResponses = 0;
    int myResponses = 0;
    int unreadResponses = 0;
    int last24HourResponseCount = 0;
    if (self.userDiscussionResponse && self.userDiscussionResponse.childResponseCounts) {
        totalResponses = userDiscussionResponse.childResponseCounts.totalResponseCount;
        myResponses = userDiscussionResponse.childResponseCounts.personalResponseCount;
        unreadResponses = userDiscussionResponse.childResponseCounts.unreadResponseCount;
        last24HourResponseCount = userDiscussionResponse.childResponseCounts.last24HourResponseCount;
        
    }
    
    // set the title
    titleLabel.text = userDiscussionResponse.response.title;
    
    // set the big icon
    if (last24HourResponseCount >= 10) {
        activityImage.image = [UIImage imageNamed:[config onFireIconFileName]];                
    } else if (totalResponses > 0) {
        activityImage.image = [UIImage imageNamed:[config responseWithResponsesIconFileName]];                
    } else {
        activityImage.image = [UIImage imageNamed:[config responseIconFileName]];
    }

    // set the number of total responses
    NSString* pluralizedResponses;
    if (totalResponses == 1) {
        pluralizedResponses = NSLocalizedString(@"total response", @"total response, singular");
    } else {
        pluralizedResponses = NSLocalizedString(@"total responses", @"total responses, plural");
    }
    numberOfResponsesLabel.text = [NSString stringWithFormat:@"%d %@", totalResponses, pluralizedResponses];
    
    // set the unread responses label (and give it a dark blue background with rounded corners, and a white text color)
    numberOfUnreadResponsesLabel.hidden = (unreadResponses == 0);
    countBubbleImage.hidden = (unreadResponses == 0);
    NSString* unreadText = [NSString stringWithFormat:@"%d",unreadResponses];
    CGSize maximumSize = CGSizeMake(1000, 20);
    CGSize labelSize = [unreadText sizeWithFont:numberOfUnreadResponsesLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
    labelSize.width += 10;
    
    // minimum width of the size of the graphic, 58
    if (labelSize.width < 29) {
        labelSize.width = 29;
    }
    
    // put the right edge of the label at x=294 inside the cell, 10px padding on each side of the label
    CGRect labelFrame = CGRectMake(294-labelSize.width, 26, labelSize.width, 20);        
    numberOfUnreadResponsesLabel.frame = labelFrame;
    numberOfUnreadResponsesLabel.text = unreadText;
    
    // put the count bubble image behind the number
    // NOTE: tried to do this in code, but when you set a background color on a label, when the table cell
    // is selected, that color goes away. This code was:
    //      unreadResponsesLabel.layer.cornerRadius = 10.0;
    //      unreadResponsesLabel.backgroundColor = HEXCOLOR(0x1D2372);
    countBubbleImage.frame = labelFrame;

    // set the content text
    contentLabel.text = [userDiscussionResponse.response.description stripHTML];
    
}

- (void)awakeFromNib {
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    disclosureArrowImage.image = [[UIImage imageNamed:[config listArrowFileName]] imageWithOverlayColor:[config secondaryColor]];

    smallPosterIcon.image = [UIImage imageNamed:[config smallPersonIconFileName]];
    smallResponsesIcon.image = [UIImage imageNamed:[config smallResponsesIconFileName]];
    
    dateLabel.font = [config cellDateFont];
    dateLabel.textColor = [config greyColor];
    
    posterNameLabel.font = [config cellSmallFont];
    posterNameLabel.textColor = [config blackColor];
    
    titleLabel.font = [config cellHeaderFont];
    titleLabel.textColor = [config secondaryColor];
    
    smallResponsesIcon.image = [UIImage imageNamed:[config smallResponsesIconFileName]];

    numberOfResponsesLabel.font = [config cellSmallBoldFont];
    numberOfResponsesLabel.textColor = [config blackColor];
    
    numberOfUnreadResponsesLabel.font = [config mediumBoldFont];
    numberOfUnreadResponsesLabel.textColor = [config whiteColor];
    numberOfUnreadResponsesLabel.textAlignment = UITextAlignmentCenter;
    
    countBubbleImage.image = [[UIImage imageNamed:[config countBubbleImageFileName]] stretchableImageWithLeftCapWidth:14.0 topCapHeight:10];
}


#pragma mark - View lifecycle


@end
