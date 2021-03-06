//
//  TopicTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/21/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "TopicTableCell.h"
#import <QuartzCore/CoreAnimation.h>
#import "UIColor+Boost.h"
#import "ECClientConfiguration.h"
#import "UIImageUtilities.h"

@implementation TopicTableCell

@synthesize topic;

-(void)setData:(UserDiscussionTopic*)topicValue {
    // get the config
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    self.topic = topicValue;
    if (titleLabel) {
        
        // grab the counts
        int totalResponses = 0;
        int myResponses = 0;
        int unreadResponses = 0;
        int last24HourResponseCount = 0;
        
        if (topic.childResponseCounts) {
            totalResponses = topic.childResponseCounts.totalResponseCount;
            myResponses = topic.childResponseCounts.personalResponseCount;
            unreadResponses = topic.childResponseCounts.unreadResponseCount;
            last24HourResponseCount = topic.childResponseCounts.last24HourResponseCount;
        }
        
        // set the title
        titleLabel.text = topic.topic.title;
        
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
        
        // set the number of responses by you
        if (myResponses == 1) {
            pluralizedResponses = NSLocalizedString(@"response by you", @"response by you, singular");
        } else {
            pluralizedResponses = NSLocalizedString(@"responses by you", @"responses by you, plural");
        }
        responsesByYouLabel.text = [NSString stringWithFormat:@"%d %@", myResponses, pluralizedResponses];
        
        // set the unread responses label (and give it a dark blue background with rounded corners, and a white text color)
        unreadResponsesLabel.hidden = (unreadResponses == 0);
        countBubbleImage.hidden = (unreadResponses == 0);
        NSString* unreadText = [NSString stringWithFormat:@"%d",unreadResponses];
        CGSize maximumSize = CGSizeMake(1000, 20);
        CGSize labelSize = [unreadText sizeWithFont:unreadResponsesLabel.font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
        labelSize.width += 10;
        
        // minimum width of the size of the graphic, 58
        if (labelSize.width < 29) {
            labelSize.width = 29;
        }
                
        // put the right edge of the label at x=294 inside the cell, 10px padding on each side of the label
        CGRect labelFrame = CGRectMake(294-labelSize.width, 26, labelSize.width, 20);        
        unreadResponsesLabel.frame = labelFrame;
        unreadResponsesLabel.text = unreadText;
        
        // put the count bubble image behind the number
        // NOTE: tried to do this in code, but when you set a background color on a label, when the table cell
        // is selected, that color goes away. This code was:
        //      unreadResponsesLabel.layer.cornerRadius = 10.0;
        //      unreadResponsesLabel.backgroundColor = HEXCOLOR(0x1D2372);
        countBubbleImage.frame = labelFrame;
    }    
}

- (void)awakeFromNib {    
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];

    disclosureArrowImage.image = [[UIImage imageNamed:[config listArrowFileName]] imageWithOverlayColor:[config secondaryColor]];

    titleLabel.font = [config cellHeaderFont];
    titleLabel.textColor = [config secondaryColor];

    smallResponsesImage.image = [UIImage imageNamed:[config smallResponsesIconFileName]];
    
    totalResponsesLabel.font = [config cellSmallBoldFont];
    totalResponsesLabel.textColor = [config blackColor];

    responsesByYouLabel.font = [config cellItalicsFont];
    responsesByYouLabel.textColor = [config blackColor];
    
    unreadResponsesLabel.font = [config mediumBoldFont];
    unreadResponsesLabel.textColor = [config whiteColor];
    unreadResponsesLabel.textAlignment = UITextAlignmentCenter;
    
    countBubbleImage.image = [[UIImage imageNamed:[config countBubbleImageFileName]] stretchableImageWithLeftCapWidth:14.0 topCapHeight:10];
}

- (void)dealloc
{
    if (unreadResponsesLabel) {
        [unreadResponsesLabel release];
        unreadResponsesLabel = nil;
    }
    self.topic = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
