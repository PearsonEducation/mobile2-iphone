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
}

@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) UIButton* button;

- (void)loadHtmlString:(NSString*)htmlString;

@end