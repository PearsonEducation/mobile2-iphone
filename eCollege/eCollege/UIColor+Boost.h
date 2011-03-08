//
//  UIColor+Boost.h
//  Common
//
//  Created by Sean Christmann on 3/17/10.
//  Copyright 2010 EffectiveUI. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEBCOLOR(web) [UIColor colorWithHexString:(web)]
#define HEXCOLOR(hex) [UIColor colorWithHex:(hex)]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


@interface UIColor (Boost)

/*usage
 RGBA style hex value
 UIColor *solidColor = [UIColor colorWithHexA:0xFF0000FF];
 UIColor *alphaColor = [UIColor colorWithHexA:0xFF000099];
 */
+ (UIColor *) colorWithHexA:(uint) hex;

/*usage
 ARGB style hex value
 UIColor *alphaColor = [UIColor colorWithAHex:0x99FF0000];
 */
+ (UIColor *) colorWithAHex:(uint) hex;

/*usage
 RGB style hex value, alpha set to full
 UIColor *solidColor = [UIColor colorWithHex:0xFF0000];
 */
+ (UIColor *) colorWithHex:(uint) hex;

/*usage 
 UIColor *solidColor = [UIColor colorWithWeb:@"#FF0000"];
 safe to omit # sign as well
 UIColor *solidColor = [UIColor colorWithWeb:@"FF0000"];
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

- (NSString *) hexString;

- (UIColor*) colorBrighterByPercent:(float) percent;
- (UIColor*) colorDarkerByPercent:(float) percent;

@property (nonatomic, readonly) CGFloat r;
@property (nonatomic, readonly) CGFloat g;
@property (nonatomic, readonly) CGFloat b;
@property (nonatomic, readonly) CGFloat a;

@end
