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

// a little help on the animation from: http://iphonedevelopertips.com/user-interface/rotate-an-image-with-animation.html

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
	self.texturedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.backgroundColor = [config tertiaryColor];
    [self.contentView addSubview:self.texturedBackgroundView];
    [self.contentView sendSubviewToBack:self.texturedBackgroundView];
    
    self.selectionStyle = UITableViewCellEditingStyleNone;
    [self.webView setUserInteractionEnabled:NO];
	self.webView.backgroundColor = [UIColor clearColor];
	self.webView.opaque = NO;
	self.clipsToBounds = YES;

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
