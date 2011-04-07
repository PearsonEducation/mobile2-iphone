//
//  ResponseContentTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/24/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "ResponseContentTableCell.h"
#import "ECClientConfiguration.h"
#import "Math.h"

@interface ResponseContentTableCell ()

@property (nonatomic, retain) UIView* texturedBackgroundView;

@end

@implementation ResponseContentTableCell

@synthesize button;
@synthesize webView;
@synthesize texturedBackgroundView;

- (void)dealloc
{
    self.button = nil;
    self.webView = nil;
    self.texturedBackgroundView = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)rotateButton {

    degrees = (degrees == 0) ? 180 : 0;
    
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeRotation((degrees/180.0)*M_PI);
    button.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

- (void)awakeFromNib {
    
    degrees = 0.0;
    
    self.clipsToBounds = YES;
    
    [button setBackgroundImage:[UIImage imageNamed:@"expand_text_icon.png"] forState:UIControlStateNormal];
    CGRect f = button.frame;
    f.size = CGSizeMake(16, 17);
    f.origin = CGPointMake(288, 10);
    button.frame = f;
        
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];

    self.texturedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    self.texturedBackgroundView.backgroundColor = [config texturedBackgroundColor];
    self.texturedBackgroundView.opaque = NO;
    self.contentView.backgroundColor = [config tertiaryColor];
    [self.contentView addSubview:self.texturedBackgroundView];
    [self.contentView sendSubviewToBack:self.texturedBackgroundView];
    
    self.selectionStyle = UITableViewCellEditingStyleNone;
    [self.webView setUserInteractionEnabled:NO];
}

- (void)setHeight:(float)value {
    CGRect f = self.contentView.frame;
    f.size.height = value;
    self.contentView.frame = f;
}

- (void)layoutSubviews {
    // resize the textured background view so that the texture covers the entire cell
    CGRect f = self.texturedBackgroundView.frame;
    f.size.height = self.contentView.frame.size.height;
    f.size.width = self.contentView.frame.size.width;
    self.texturedBackgroundView.frame = f;
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
