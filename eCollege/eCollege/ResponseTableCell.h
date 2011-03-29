//
//  ResponseTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDiscussionResponse.h"

@interface ResponseTableCell : UITableViewCell {
    IBOutlet UILabel* titleLabel;
    IBOutlet UIImageView* activityImage;
    IBOutlet UIImageView* smallPosterIcon;
    IBOutlet UIImageView* smallResponsesIcon;
    IBOutlet UILabel* posterNameLabel;
    IBOutlet UILabel* numberOfResponsesLabel;
    IBOutlet UILabel* numberOfUnreadResponsesLabel;
    IBOutlet UIImageView* countBubbleImage;
    IBOutlet UIImageView* disclosureArrowImage;
    IBOutlet UIWebView* responseContentWebView;
    IBOutlet UILabel* dateLabel;
    IBOutlet UILabel* contentLabel;
    UserDiscussionResponse* userDiscussionResponse;
}

- (void)setData:(UserDiscussionResponse*)response;

@end
