//
//  ActivityTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityStreamItem.h"

@interface ActivityTableCell : UITableViewCell {
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel* friendlyDate;
    IBOutlet UILabel* title;
    IBOutlet UILabel* courseName;
    IBOutlet UILabel* description;
}

-(void)setData:(ActivityStreamItem*)item;

@end
