//
//  GradebookItemCell.h
//  eCollege
//
//  Created by Tony Hillerson on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GradebookItemCell : UITableViewCell {
    UILabel *gradeLabel;
}

@property(nonatomic,retain) UILabel *gradeLabel;

@end
