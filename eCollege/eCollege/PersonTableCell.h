//
//  PersonTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/31/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterUser.h"

@interface PersonTableCell : UITableViewCell {
    UILabel* nameLabel;
    UILabel* roleLabel;
    RosterUser* person;
    UIImageView* icon;
    UIImageView* arrowImageView;
}

- (void)setData:(RosterUser*)person;

@end
