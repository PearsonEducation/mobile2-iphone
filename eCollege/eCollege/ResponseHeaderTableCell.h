//
//  ResponseHeaderTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/21/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDiscussionResponse.h"

@interface ResponseHeaderTableCell : UITableViewCell {
    UserDiscussionResponse* Response;
    IBOutlet UILabel* titleLabel;
    IBOutlet UIImageView* activityImage;
    IBOutlet UIImageView* smallResponsesImage;
    IBOutlet UILabel* totalResponsesLabel;
    IBOutlet UILabel* unreadResponsesLabel;
    IBOutlet UIImageView* disclosureArrowImage;
    IBOutlet UIImageView* countBubbleImage;
}

@property (nonatomic, retain) UserDiscussionResponse* response;

-(void)setData:(UserDiscussionResponse*)response;

@end
