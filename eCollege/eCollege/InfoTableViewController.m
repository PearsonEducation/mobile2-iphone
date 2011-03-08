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

@implementation InfoTableViewController

@synthesize cancelDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.cancelDelegate = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)cancelButtonClicked:(id)sender {
    [cancelDelegate cancelButtonClicked:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // add the "Cancel" button to the navigation bar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Settings", @"Name of the 'Settings' screen");
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"My Profile", @"Name of the 'My Profile' screen");
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"About", @"Name of the 'About' screen");
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Feedback", @"Name of the 'Feedback' screen");
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Help", @"Name of the 'Help' screen");
            break;            
        default:
            break;
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* newView;
    switch (indexPath.row) {
        case 0:
            newView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            break;
        case 1:
            newView = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            break;
        case 2:
            newView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            break;
        case 3:
            newView = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
            break;
        case 4:
            newView = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
            break;            
        default:
            break;
    }
    
    [self.navigationController pushViewController:newView animated:YES];
    [newView release];

}


@end
