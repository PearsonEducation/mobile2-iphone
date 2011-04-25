//
//  UpcomingEventItemTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpcomingEventItem.h"

@interface UpcomingEventItemTableCell : UITableViewCell {
    IBOutlet UIImageView* arrowView;
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel* friendlyDate;
    IBOutlet UILabel* title;
    IBOutlet UILabel* courseName;
}

-(void)setData:(UpcomingEventItem*)item;

@end
