//
//  NoResponsesTableCell.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/24/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "NoResponsesTableCell.h"


@implementation NoResponsesTableCell

- (void)awakeFromNib {
    noResponsesMessage.text = NSLocalizedString(@"No responses yet.",nil);
    noResponsesIcon.image = [UIImage imageNamed:@"no_responses_icon.png"];
    self.selectionStyle = UITableViewCellEditingStyleNone;
}

- (void)dealloc
{
    [super dealloc];
}

@end
