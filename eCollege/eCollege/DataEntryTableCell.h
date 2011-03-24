//
//  DataEntryTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataEntryTableCell : UITableViewCell {
    IBOutlet UITextField* textField;
}

@property (nonatomic, retain) UITextField* textField;

@end
