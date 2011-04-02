//
//  HighlightedAnnouncementTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/1/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Announcement.h"

@interface HighlightedAnnouncementTableCell : UITableViewCell {
    UILabel* titleLabel;
    UILabel* textLabel;
    Announcement *announcement;
}

@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* textLabel;
@property (nonatomic, retain) Announcement* announcement;

@end
