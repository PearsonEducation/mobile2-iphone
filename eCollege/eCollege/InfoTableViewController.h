//
//  InfoTableViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    id cancelDelegate;
    IBOutlet UITableView *table;
	IBOutlet UIImageView *texturedBackground;
}

@property (nonatomic, retain) id cancelDelegate;

@end
