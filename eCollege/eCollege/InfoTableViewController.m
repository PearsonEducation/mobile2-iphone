//
//  InfoTableViewController.m
//  eCollege
//
//  Created by Brad Umbaugh on 3/8/11.
//  Copyright 2011 EffectiveUI. All rights reserved.
//

#import "InfoTableViewController.h"
#import "HelpViewController.h"
#import "FeedbackViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "ECClientConfiguration.h"
#import "IBButton.h"
#import "eCollegeAppDelegate.h"

@implementation InfoTableViewController

@synthesize cancelDelegate;

- (void)dealloc {
    self.cancelDelegate = nil;
    [super dealloc];
}

- (void)cancelButtonClicked:(id)sender {
    [cancelDelegate cancelButtonClicked:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
	
	IBButton *signOutButton = [IBButton glossButtonWithTitle:NSLocalizedString(@"Sign Out", @"Sign Out") color:[config primaryColor]];
    signOutButton.frame = CGRectMake(9, 115, 302, 37);
    [signOutButton addTarget:self action:@selector(signOutTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:signOutButton];
	
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close")
																	 style:UIBarButtonSystemItemCancel
																	target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
	self.title = NSLocalizedString(@"Settings", @"Settings");

	table.backgroundView.backgroundColor = [UIColor clearColor];
	table.backgroundView.opaque = NO;
	table.backgroundColor = [UIColor clearColor];
	table.opaque = NO;
	texturedBackground.backgroundColor = [config texturedBackgroundColor];	
	texturedBackground.opaque = NO;
	self.view.backgroundColor = [config tertiaryColor];
}

- (void) signOutTapped:(id)sender {
	[[eCollegeAppDelegate delegate] signOut];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	ECClientConfiguration *config = [ECClientConfiguration currentConfiguration];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [config cellFontBold];
		cell.textLabel.textColor = [config secondaryColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Settings", @"Name of the 'Settings' screen");
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Help", @"Name of the 'Help' screen");
            break;            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[table deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController* newView = nil;
    switch (indexPath.row) {
        case 0:
            newView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            break;
        case 1:
            newView = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
            break;            
        default:
            break;
    }
    
    [self.navigationController pushViewController:newView animated:YES];
    [newView release];

}


@end
