//
//  ECClientConfiguration.m
//  eCollege
//
//  Created by Tony Hillerson on 2/25/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ECClientConfiguration.h"
#import "ECStyles.h"
#import "UIColor+Boost.h"

@implementation ECClientConfiguration
static ECClientConfiguration *currentConfiguration = nil;

#pragma mark - Singleton Implementation

+ (ECClientConfiguration *) currentConfiguration {
	if (currentConfiguration == nil) {
		currentConfiguration = [[super allocWithZone:NULL] init];
	}
	return currentConfiguration;
}

+ (id) allocWithZone:(NSZone *)zone {
	return [[self currentConfiguration] retain];
}

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

- (id) retain {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void) release {
    //do nothing -> singleton
}

- (id) autorelease {
    return self;
}

#pragma mark - Shared Object Implementation

- (NSString *) clientId {
	//TODO: add real implementation here
	return @"30bb1d4f-2677-45d1-be13-339174404402";
}

- (NSString *) clientString {
	//TODO: add real implementation here
	return @"sandbox";
    //return @"ctstate";
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark - Styles

// ---------------------------------------------------------- STRINGS

- (NSString*)schoolName {
    return SCHOOL_NAME;
}

// ---------------------------------------------------------- COLORS

- (UIColor*)primaryColor {
    return HEXCOLOR(PRIMARY_COLOR);
}

- (UIColor*)secondaryColor {
    return HEXCOLOR(SECONDARY_COLOR);
}

- (UIColor*)tertiaryColor {
    return HEXCOLOR(TERTIARY_COLOR);
}

- (UIColor *) texturedBackgroundColor {
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise_bg.png"]];	
}

- (UIColor*)greyColor {
    return [UIColor darkGrayColor];
}

- (UIColor*)lightGrayColor {
    return HEXCOLOR(0x9A968D);
}

- (UIColor*)blackColor {
    return [UIColor blackColor];
}

- (UIColor*)whiteColor {
    return [UIColor whiteColor];
}

// ---------------------------------------------------------- FILE NAMES

- (NSString*)splashFileName {
    return @"splash.png";
}

- (NSString*)listArrowFileName {
    return @"list_arrow_icon_white.png";
}

- (NSString*)dropboxIconFileName {
    return @"dropbox_icon.png";
}

- (NSString*)examIconFileName {
    return @"exam_icon.png";
}

- (NSString*)gradeIconFileName {
    return @"grade.png";
}

- (NSString*)topicIconFileName {
    return @"discussions_with_responses_icon.png";
}

- (NSString*)responseIconFileName {
    return @"discussions_no_response_icon.png";
}

- (NSString*)responseWithResponsesIconFileName {
    return @"discussions_with_responses_icon.png";
}

- (NSString*)onFireIconFileName {
    return @"icon_discussions_hot_topic.png";
}

- (NSString*)smallResponsesIconFileName {
    return @"response_icon_small.png";
}

- (NSString*)smallPersonIconFileName {
    return @"person_small_icon.png";
}

- (NSString*)countBubbleImageFileName {
    return @"count_bubble.png";
}

// ---------------------------------------------------------- FONTS

- (UIFont*)headerFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
}

- (UIFont*)mediumBoldFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
}

- (UIFont*)mediumFont {
    return [UIFont fontWithName:@"Helvetica" size:17.0];    
}

- (UIFont *)secondaryButtonFont {
	return [UIFont fontWithName:@"Helvetica" size:13.0];
}

- (UIFont*)cellHeaderFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
}

- (UIFont*)cellFont {
    return [UIFont fontWithName:@"Helvetica" size:13.0];
}

- (UIFont*)cellFontBold {
    return [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
}

- (UIFont*)cellItalicsFont {
    return [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
}

- (UIFont*)cellDateFont {
    return [UIFont fontWithName:@"Helvetica" size:13.0];
}

- (UIFont*)cellSmallFont {
    return [UIFont fontWithName:@"Helvetica" size:12.0];
}

- (UIFont*)cellSmallBoldFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
}



#pragma mark - View Helpers and useful factory methods

- (UINavigationController *) primaryNavigationControllerWithRootViewController:(UIViewController *)viewController {
	UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	nc.navigationBar.tintColor = [self primaryColor];
	return nc;
}

@end
