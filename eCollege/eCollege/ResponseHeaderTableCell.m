//
//  ResponseHeaderTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/21/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseHeaderTableCell.h"
#import <QuartzCore/CoreAnimation.h>
#import "UIColor+Boost.h"
#import "NSDateUtilities.h"
#import "ECClientConfiguration.h"

@implementation ResponseHeaderTableCell

@synthesize response;

-(void)setData:(UserDiscussionResponse*)responseValue {
    self.response = responseValue;
    
    // grab the counts
    int totalResponses = 0;
    int unreadResponses = 0;
    int last24HourResponseCount = 0;
    
    if (response.childResponseCounts) {
        totalResponses = response.childResponseCounts.totalResponseCount;
        unreadResponses = response.childResponseCounts.unreadResponseCount;
        last24HourResponseCount = response.childResponseCounts.last24HourResponseCount;
    }
    
    // get the configuration
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    // set the title
    titleLabel.text = response.response.title;
    
    // set the name
    nameLabel.text = [self.response.response.author fullName];
    
    // set the date
    dateLabel.text = [self.response.response.postedDate friendlyString];
    
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
    totalResponsesLabel.text = [NSString stringWithFormat:@"%d %@", totalResponses, pluralizedResponses];
    
    // set the unread responses label (and give it a dark blue background with rounded corners, and a white text color)
    unreadResponsesLabel.hidden = (unreadResponses == 0);
    countBubbleImage.hidden = (unreadResponses == 0);

    NSString* unreadText = [NSString stringWithFormat:@"%d",unreadResponses];
    CGSize maximumSize = CGSizeMake(1000, 20);
    CGSize labelSize = [unreadText sizeWithFont:unreadResponsesLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
    // 5px padding on each side
    labelSize.width += 10;
    
    // minimum width of the size of the graphic, 29
    if (labelSize.width < 29) {
        labelSize.width = 29;
    }
    
    // put the right edge of the label at x=310 inside the cell, 5px padding on each side of the label
    CGRect labelFrame = CGRectMake(310-labelSize.width, 26, labelSize.width, 20);        
    unreadResponsesLabel.frame = labelFrame;
    unreadResponsesLabel.text = unreadText;
    
    // put the count bubble image behind the number
    // NOTE: tried to do this in code, but when you set a background color on a label, when the table cell
    // is selected, that color goes away. This code was:
    //      unreadResponsesLabel.layer.cornerRadius = 10.0;
    //      unreadResponsesLabel.backgroundColor = HEXCOLOR(0x1D2372);
    countBubbleImage.frame = labelFrame;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellEditingStyleNone;
    
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];

    texturedImage.backgroundColor = [config texturedBackgroundColor];
    texturedImage.opaque = NO;

    self.contentView.backgroundColor = [config tertiaryColor];

    personIcon.image = [UIImage imageNamed:[config smallPersonIconFileName]];

    activityImage.contentMode = UIViewContentModeScaleAspectFit;
    CGRect f = activityImage.frame;
    f.size.width = 25;
    f.size.height = 25;
    activityImage.frame = f;
    
    titleLabel.font = [config cellHeaderFont];
    titleLabel.textColor = [config secondaryColor];
    
    nameLabel.font = [config cellSmallFont];
    nameLabel.textColor = [config blackColor];
    
    dateLabel.font = [config cellDateFont];
    dateLabel.textColor = [config greyColor];
    
    smallResponsesImage.image = [UIImage imageNamed:[config smallResponsesIconFileName]];
    
    totalResponsesLabel.font = [config cellSmallBoldFont];
    totalResponsesLabel.textColor = [config blackColor];
    
    unreadResponsesLabel.font = [config mediumBoldFont];
    unreadResponsesLabel.textColor = [config whiteColor];
    unreadResponsesLabel.textAlignment = UITextAlignmentCenter;
    
    countBubbleImage.image = [[UIImage imageNamed:[config countBubbleImageFileName]] stretchableImageWithLeftCapWidth:14.0 topCapHeight:10];
}

- (void)dealloc
{
    self.response = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
