//
//  NSString+stripHTML.m
//  eCollege
//
//  Created by Tony Hillerson on 4/7/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "NSString+stripHTML.h"


@implementation NSString (stripHTMLAdditions)

- (NSString *) stripHTML {
	NSString *tagHolder = nil;
	NSString *flattenedString = self;
	
	NSScanner *scanner = [NSScanner scannerWithString:flattenedString];
	
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<" intoString:NULL]; 
        [scanner scanUpToString:@">" intoString:&tagHolder];
		
        flattenedString = [flattenedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", tagHolder]
																	 withString:@" "];
    }
	
	flattenedString = [flattenedString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	flattenedString = [flattenedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return flattenedString;
}

@end
