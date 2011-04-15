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
- (UIColor*)lightGrayColor;
- (UIColor*)whiteColor;
- (UIColor*)blackColor;
- (UIColor*)texturedBackgroundColor;

// STRINGS
- (NSString*)schoolName;

// FONTS
- (UIFont*)headerFont;
- (UIFont*)mediumBoldFont;
- (UIFont*)mediumFont;
- (UIFont*)secondaryButtonFont;
- (UIFont*)cellHeaderFont;
- (UIFont*)cellFont;
- (UIFont*)cellFontBold;
- (UIFont*)cellItalicsFont;
- (UIFont*)cellDateFont;
- (UIFont*)cellSmallFont;
- (UIFont*)cellSmallBoldFont;
- (UIFont*)smallFont;
- (UIFont*)smallBoldFont;
- (UIFont*)detailBoxHeaderFont;
- (UIFont*)detailBoxStandardFont;
- (UIFont*)detailBoxBoldFont;
- (UIFont*)detailBoxItalicsFont;
- (UIFont*)detailHeaderCourseNameFont;
- (UIFont*)detailHeaderItemTypeFont;

// FILE NAMES
- (NSString*)splashFileName;
- (NSString*)listArrowFileName;
- (NSString*)dropboxIconFileName;
- (NSString*)examIconFileName;
- (NSString*)gradeIconFileName;
- (NSString*)topicIconFileName;
- (NSString*)responseIconFileName;
- (NSString*)responseWithResponsesIconFileName;
- (NSString*)onFireIconFileName;
- (NSString*)smallResponsesIconFileName;
- (NSString*)smallPersonIconFileName;
- (NSString*)countBubbleImageFileName;
- (NSString*)announcementIconFileName;


// View helpers
- (UINavigationController *) primaryNavigationControllerWithRootViewController:(UIViewController *)viewController;



@end
