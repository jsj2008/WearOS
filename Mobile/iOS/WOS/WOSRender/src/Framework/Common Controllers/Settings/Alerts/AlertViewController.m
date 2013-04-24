/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *			When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author	Larry Suarez
 *  @package com.carethings.domain
 *
 *  Copyright (c) 2011, CareThings, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation
 *         and/or other materials provided with the distribution.
 *	3. Neither the name of CareThings nor the names of its contributors may be used to endorse or promote products derived from this software without specific
 *         prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AlertViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "AlertDetailViewController.h"
#import "SimpleCustomCell3.h"
#import "AlertUtilities.h"

@implementation AlertViewController

- (NSBundle *)frameworkBundle {
	static NSBundle* frameworkBundle = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
		NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"WOSRender.bundle"];
		frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
	});
	return frameworkBundle;
}

static const int kTableRowHeight = 55;

@synthesize alertData;

-(int)childrenCount:(int)row {	
	int           count = 0;
	ResdbResult*  result = nil;
	AlertDAO*     dao = [AlertDAO new];
	
	result = [dao retrieveCountByRelatedId:WS_ROOT_OBJECT_IDENTIFIER];
	
	if (result.resdbCode == RESDB_SQL_ROWS)
		count = [(NSString*)result.resdbObject integerValue];
	
	return count;	
}

- (void)callAlertDetail:(Alert*)alert {
	AlertDetailViewController* childController = [[AlertDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];

	childController.title = NSLocalizedString(@"Alert",nil);
	childController.alert = alert;
	
	[[self navController] pushViewController:childController animated:YES];	
}

- (IBAction)addAlert:(id)sender {
	[self callAlertDetail:nil];
}

- (void)reloadFromDB {
	AlertDAO*     dao = [AlertDAO new];
	ResdbResult*  result = nil;
	
	[self.alertData removeAllObjects];
	
	result = [dao retrieveByRelatedId:WS_ROOT_OBJECT_IDENTIFIER];
		
	if (result.resdbCode == RESDB_SQL_ROWS)
		[self.alertData addObjectsFromArray:result.resdbCollection];
}

-(void)viewWillAppear:(BOOL)animated {
	[self reloadFromDB];
	[self.tableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.alertData = [NSMutableArray new];
	
	[self reloadFromDB];
	
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/background.png"]];
	
	[[self navigationController] setNavigationBarHidden:NO animated:NO];
	
	self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/background.png"]];
	
	self.navigationItem.title = NSLocalizedString(@"Alerts",nil);

	self.navController = [self navigationController];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.alertData count];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	return kTableRowHeight;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
	
	SimpleCustomCell3*  cell = (SimpleCustomCell3*)[tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
	
    if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell3" owner:self options:nil];
		
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell3 class]])
                cell = (SimpleCustomCell3 *)oneObject;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    NSUInteger	row = [indexPath row];
    Alert*      alert = [alertData objectAtIndex:row];
	
	cell.nameLabel.text        = alert.message;
	cell.lowerRightLabel.text  = [DateFormatter localizedStringFromUSDateString:alert.creationTime];
	cell.lowerLeftLabel.text   = alert.priority;
	
	cell.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/CellBackground.png"]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self callAlertDetail:[alertData objectAtIndex:indexPath.row]];
}

@end
