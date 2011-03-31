//
//  DataEntryTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DataEntryTableCell.h"

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
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];    
    self.selectionStyle = UITableViewCellEditingStyleNone;
    
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
