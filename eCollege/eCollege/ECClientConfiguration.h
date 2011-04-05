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
- (NSUInteger)primaryColor;
- (NSUInteger)secondaryColor;
- (NSUInteger)tertiaryColor;
- (NSString*)schoolName;

@end
