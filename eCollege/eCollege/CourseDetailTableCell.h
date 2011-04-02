//
//  CourseDetailTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/2/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseDetailTableCell : UITableViewCell {
    UIImageView *arrowImageView;
    UILabel *unreadCountLabel;
    UIImageView *countBubbleImageView;
}

@property (nonatomic, retain) UIImageView* arrowImageView;
@property (nonatomic, retain) UILabel* unreadCountLabel;
@property (nonatomic, retain) UIImageView* countBubbleImageView;

@end
