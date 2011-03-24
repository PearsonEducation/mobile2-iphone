//
//  DataEntryTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/23/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "DataEntryTableCell.h"

@implementation DataEntryTableCell

@synthesize textField;

- (void)dealloc
{
    self.textField = nil;
    [super dealloc];
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
