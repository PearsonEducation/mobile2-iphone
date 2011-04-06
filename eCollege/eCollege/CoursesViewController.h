//
//  CoursesViewController.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/3/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPrimaryViewController.h"

@interface CoursesViewController : ECPrimaryViewController <UITableViewDelegate, UITableViewDelegate> {
    IBOutlet UITableView* table;
}

@end
