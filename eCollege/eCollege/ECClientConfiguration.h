//
//  ECClientConfiguration.h
//  eCollege
//
//  Created by Tony Hillerson on 2/25/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ECClientConfiguration : NSObject {
    
}

+ (ECClientConfiguration *) currentConfiguration;

- (NSString*)clientId;
- (NSString*)clientString;

// ------------------------------------- STYLES

// COLORS
- (UIColor*)primaryColor;
- (UIColor*)secondaryColor;
- (UIColor*)tertiaryColor;
- (UIColor*)greyColor;
- (UIColor*)whiteColor;
- (UIColor*)blackColor;
- (UIColor *) texturedBackgroundColor;

// STRINGS
- (NSString*)schoolName;

// FONTS
- (UIFont*)mediumBoldFont;
- (UIFont*)mediumFont;
- (UIFont*)cellHeaderFont;
- (UIFont*)cellFont;
- (UIFont*)cellItalicsFont;
- (UIFont*)cellDateFont;

// FILE NAMES
- (NSString*)splashFileName;

// View helpers
- (UINavigationController *) newPrimaryNavigationControllerWithRootViewController:(UIViewController *)viewController;



@end
