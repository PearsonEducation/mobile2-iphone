//
//  ResponseTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseTableCell.h"
#import "NSDateUtilities.h"

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
    self.userDiscussionResponse = responseValue;

    // set the date
    dateLabel.text = [responseValue.response.postedDate friendlyString];
    
    
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
        activityImage.image = [UIImage imageNamed:@"icon_discussions_hot_topic.png"];                
    } else if (totalResponses > 0) {
        activityImage.image = [UIImage imageNamed:@"icon_discussions_responses.png"];                
    } else {
        activityImage.image = [UIImage imageNamed:@"icon_discussions_no_responses.png"];
    }
    
    // set the tiny little icon
    smallResponsesIcon.image = [UIImage imageNamed:@"response_icon_small.png"];
    
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
    UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    NSString* unreadText = [NSString stringWithFormat:@"%d",unreadResponses];
    CGSize maximumSize = CGSizeMake(1000, 20);
    CGSize labelSize = [unreadText sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeTailTruncation];
    labelSize.width += 10;
    
    // minimum width of the size of the graphic, 58
    if (labelSize.width < 29) {
        labelSize.width = 29;
    }
    
    // put the right edge of the label at x=294 inside the cell, 10px padding on each side of the label
    CGRect labelFrame = CGRectMake(294-labelSize.width, 26, labelSize.width, 20);        
    numberOfUnreadResponsesLabel.frame = labelFrame;
    numberOfUnreadResponsesLabel.textAlignment = UITextAlignmentCenter;
    numberOfUnreadResponsesLabel.text = unreadText;
    numberOfUnreadResponsesLabel.textColor = [UIColor whiteColor];
    
    // put the count bubble image behind the number
    // NOTE: tried to do this in code, but when you set a background color on a label, when the table cell
    // is selected, that color goes away. This code was:
    //      unreadResponsesLabel.layer.cornerRadius = 10.0;
    //      unreadResponsesLabel.backgroundColor = HEXCOLOR(0x1D2372);
    countBubbleImage.frame = labelFrame;
    countBubbleImage.image = [[UIImage imageNamed:@"count_bubble.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:10];
}

- (void)awakeFromNib {
    // set the disclosure arrow
    disclosureArrowImage.image = [UIImage imageNamed:@"list_arrow_icon.png"];
    smallPosterIcon.image = [UIImage imageNamed:@"person_small_icon.png"];
    smallResponsesIcon.image = [UIImage imageNamed:@"response_icon_small.png"];
    
}


#pragma mark - View lifecycle


@end
