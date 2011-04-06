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
	//return @"sandbox";
    return @"ctstate";
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark - Styles

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

- (NSString*)schoolName {
    return SCHOOL_NAME;
}

- (UIColor*)greyColor {
    return [UIColor darkGrayColor];
}

- (UIColor*)blackColor {
    return [UIColor blackColor];
}

- (UIColor*)whiteColor {
    return [UIColor whiteColor];
}

- (NSString*)splashFileName {
    return @"splash.png";
}

- (NSString*)listArrowFileName {
    return @"list_arrow_icon_white.png";
}

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

- (UIFont*)cellItalicsFont {
    return [UIFont fontWithName:@"Helvetica-Oblique" size:13.0];
}

- (UIFont*)cellDateFont {
    return [UIFont fontWithName:@"Helvetica" size:13.0];
}


#pragma mark - View Helpers and useful factory methods

- (UINavigationController *) primaryNavigationControllerWithRootViewController:(UIViewController *)viewController {
	UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	nc.navigationBar.tintColor = [self primaryColor];
	return nc;
}

@end
