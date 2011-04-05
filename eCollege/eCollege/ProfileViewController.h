//
//  ProfileViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel *studentNameLabel;
	IBOutlet UIButton *signOutButton;
	IBOutlet UILabel *tableTitleLable;
	IBOutlet UITableView *tableView;
}

- (IBAction) signOutPressed:(id)sender;

@end
