//
//  TopicHeaderTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/21/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDiscussionTopic.h"

@interface TopicHeaderTableCell : UITableViewCell {
    UserDiscussionTopic* topic;
    IBOutlet UILabel* titleLabel;
    IBOutlet UIImageView* activityImage;
    IBOutlet UIImageView* smallResponsesImage;
    IBOutlet UILabel* totalResponsesLabel;
    IBOutlet UILabel* unreadResponsesLabel;
    IBOutlet UIImageView* disclosureArrowImage;
    IBOutlet UIImageView* countBubbleImage;
    IBOutlet UIView* texturedImage;
}

@property (nonatomic, retain) UserDiscussionTopic* topic;

-(void)setData:(UserDiscussionTopic*)topic;

@end
