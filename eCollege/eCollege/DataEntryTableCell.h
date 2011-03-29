//
//  DataEntryTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataEntryTableCell : UITableViewCell {
    IBOutlet UITextField* titleTextField;
    IBOutlet UIImageView* titleBackground;
    IBOutlet UITextView* contentTextView;
    IBOutlet UIImageView* contentBackground;
}

@property (nonatomic, retain) UITextField* titleTextField;
@property (nonatomic, retain) UIImageView* titleBackground;
@property (nonatomic, retain) UITextView* contentTextView;
@property (nonatomic, retain) UIImageView* contentBackground;

@end
