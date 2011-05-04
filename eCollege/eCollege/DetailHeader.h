//
//  DetailHeader.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailHeader : UIView {
    UILabel* courseNameLabel;
    UILabel* itemTypeLabel;
	UILabel* thirdHeaderLabel;
}

@property (nonatomic, retain) NSString* courseName;
@property (nonatomic, retain) NSString* itemType;
@property (nonatomic, retain) NSString* thirdHeaderText;

@end
