//
//  ProfileViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPrimaryViewController.h"

@interface ProfileViewController : ECPrimaryViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel *studentNameLabel;
	IBOutlet UILabel *tableTitleLable;
	IBOutlet UITableView *tableView;
	IBOutlet UIImageView *textureImageView;
}

- (IBAction) signOutPressed:(id)sender;

@end
