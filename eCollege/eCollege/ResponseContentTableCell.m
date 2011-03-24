//
//  ResponseContentTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/24/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseContentTableCell.h"


@implementation ResponseContentTableCell

@synthesize button;
@synthesize webView;

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];    
}

- (void)loadHtmlString:(NSString*)htmlString {
    [webView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
