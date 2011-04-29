//
//  PersonDetailViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/5/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterUser.h"

@interface PersonDetailViewController : UIViewController {
    IBOutlet UILabel* nameLabel;
    IBOutlet UILabel* roleLabel;
    IBOutlet UILabel* courseNameLabel;
    IBOutlet UIView* whiteBox;
    IBOutlet UIImageView* iconView;
    RosterUser* user;
	IBOutlet UIImageView *textureImageView;
}

@property (nonatomic, retain) NSNumber *courseId;
@property (nonatomic, retain) RosterUser* user;

@end
