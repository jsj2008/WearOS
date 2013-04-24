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

#import "GeozoneViewController.h"
#import "GeozoneDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "SimpleCustomCell.h"
#import "AlertUtilities.h"


@implementation GeozoneViewController

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

static const int kLabelTag  = 4096;

@synthesize geozoneData;

-(int)childrenCount:(int)row {
	int           count = 0;
	ResdbResult*  result = nil;
	GeozoneDAO*   dao = [GeozoneDAO new];
	
	result = [dao retrieveCountByRelatedId:WS_ROOT_OBJECT_IDENTIFIER];
	
	if (result.resdbCode == RESDB_SQL_ROWS)
		count = [(NSString*)result.resdbObject integerValue];
	
	return count;
}

- (id)init {
    self = [super initWithNibName:@"GeozoneViewController" bundle:[self frameworkBundle]];
	
    return self;
}

- (id)initWithNibName:(NSString *)n bundle:(NSBundle *)b {
    return [self init];
}

- (id)initWithCoder:(NSCoder *)inCoder {
	if (self = [super initWithCoder:inCoder]) {
		self = [self init];
	}
	
	return self;
}

- (void)callGeozoneDetail:(Geozone*)geozone {
	
	GeozoneDetailViewController* childController = [[GeozoneDetailViewController alloc] init];
	
	childController.title = NSLocalizedString(@"Geozone",nil);
	childController.geozone = geozone;
	childController.hidesBottomBarWhenPushed = YES;
	
	[[self navController] pushViewController:childController animated:YES];	
}

- (IBAction)addGeozone:(id)sender {	
	[self callGeozoneDetail:nil];
}

- (void)reloadFromDB {
	
	GeozoneDAO*     dao = [GeozoneDAO new];
	ResdbResult*    result = nil;
	
	[self.geozoneData removeAllObjects];
	
	result = [dao retrieveByRelatedId:WS_ROOT_OBJECT_IDENTIFIER];
	
	if (result.resdbCode == RESDB_SQL_ROWS)
		[self.geozoneData addObjectsFromArray:result.resdbCollection];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.geozoneData = [NSMutableArray new];
	
	[super viewDidLoad];
	[self reloadFromDB];
	
	self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addGeozone:)];	
	
    self.navigationItem.rightBarButtonItem = addButton;
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

/*
 - (void)viewDidUnload {
 // Release any retained subviews of the main view.
 // e.g. self.myOutlet = nil;
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.geozoneData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self callGeozoneDetail:[geozoneData objectAtIndex:indexPath.row]];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString*   SimpleTableIdentifier = @"SimpleTableIdentifier";
	SimpleCustomCell*  cell = (SimpleCustomCell*)[tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
	
    if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell" owner:self options:nil];
		
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell class]])
                cell = (SimpleCustomCell *)oneObject;
		
		UILabel* activeLabel = [[UILabel alloc] initWithFrame: CGRectMake(110, 10, 150, 25)];
        activeLabel.textAlignment = UITextAlignmentRight;
		activeLabel.tag = kLabelTag;
		activeLabel.backgroundColor = [UIColor clearColor];
		activeLabel.font = [UIFont systemFontOfSize:14];
		activeLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        [cell.contentView addSubview:activeLabel];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    NSUInteger	row = [indexPath row];
    Geozone*    geozone = [geozoneData objectAtIndex:row];
	UILabel*    label = (UILabel *)[cell viewWithTag:kLabelTag];
			
	cell.nameLabel.text = [geozone name];
	
	if (geozone.active == 0)
		label.text = @"InActive";
	else 
		label.text = @"Active";
	
	[cell.countLabel removeFromSuperview];
	[cell.countButton removeFromSuperview];
	
	return cell;
}

-(void)viewWillAppear:(BOOL)animated {
	[self reloadFromDB];
	[self.tableView reloadData];
}


@end
