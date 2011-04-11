//
//  ResponseContentTableCell.h
//  eCollege
//
//  Created by Brad Umbaugh on 3/24/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResponseContentTableCell : UITableViewCell {
    IBOutlet UIWebView* webView;
    IBOutlet UIButton* button;
    UIView* texturedBackground;
    float degrees;
}

@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) UIButton* button;

- (void)loadHtmlString:(NSString*)htmlString;
- (void)rotateButton;

@end
