//
//  DataEntryTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DataEntryTableCell.h"
#import "GradientCellBackground.h"
#import "ECClientConfiguration.h"

@implementation DataEntryTableCell

@synthesize titleTextField;
@synthesize titleBackground;
@synthesize contentTextView;
@synthesize contentBackground;
@synthesize contentPromptLabel;

- (void)dealloc
{
    self.titleTextField = nil;
    self.titleBackground = nil;
    self.contentTextView = nil;
    self.contentBackground = nil;
    self.contentPromptLabel = nil;
    [super dealloc];
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellEditingStyleNone;
    
    ECClientConfiguration* config = [ECClientConfiguration currentConfiguration];
    
    UIView* bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    bv.autoresizesSubviews = YES;
    bv.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    GradientCellBackground* gcb = [[GradientCellBackground alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    gcb.lightColor = [[ECClientConfiguration currentConfiguration] tertiaryColor];
    gcb.darkColor = [[ECClientConfiguration currentConfiguration] lightGrayColor];
    gcb.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    UIView* texturedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    texturedView.backgroundColor = [config texturedBackgroundColor];
    texturedView.opaque = NO;
    texturedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    [bv addSubview:gcb];
    [bv addSubview:texturedView];
    self.backgroundView = bv;
    
    [bv release];
    [gcb release];
    [texturedView release];
    


    
    
//    self.backgroundView = [[[GradientCellBackground alloc] init] autorelease];
//    ((GradientCellBackground *)self.backgroundView).lightColor = [[ECClientConfiguration currentConfiguration] tertiaryColor];
//    ((GradientCellBackground *)self.backgroundView).darkColor = [[ECClientConfiguration currentConfiguration] lightGrayColor];
    
    self.titleBackground.image = [UIImage imageNamed:@"text_input_background.png"];
    self.contentBackground.image = [[UIImage imageNamed:@"text_input_background.png"] stretchableImageWithLeftCapWidth:147.0 topCapHeight:15.0];
    self.clipsToBounds = YES;
    
    titleTextField.placeholder = NSLocalizedString(@"Enter a response",nil);
    contentPromptLabel.text = NSLocalizedString(@"Enter a response: body", nil);
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
