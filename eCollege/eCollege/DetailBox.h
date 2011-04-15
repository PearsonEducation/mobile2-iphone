//
//  DetailBox.h
//  eCollege
//
//  Created by Brad Umbaugh on 4/14/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailBox : UIView {
    NSString* iconFileName;
    UIImageView* icon;
    
    NSString* title;
    UILabel* titleLabel;
    
    NSString* smallIconFileName;
    UIImageView* smallIcon;
    
    NSString* smallIconDescription;
    UILabel* smallIconDescriptionLabel;
    
    NSString* boldText1;
    UILabel* boldText1Label;
    
    NSString* boldText2;
    UILabel* boldText2Label;
    
    NSString* comments;
    UILabel* commentsLabel;
    
    NSString* dateString;
    UILabel* dateStringLabel;
    
    NSInteger nextElementY;
}

@property (nonatomic, retain) NSString* iconFileName;
@property (nonatomic, retain) NSString* smallIconDescription;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* smallIconFileName;
@property (nonatomic, retain) NSString* boldText1;
@property (nonatomic, retain) NSString* boldText2;
@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) NSString* dateString;

@end
