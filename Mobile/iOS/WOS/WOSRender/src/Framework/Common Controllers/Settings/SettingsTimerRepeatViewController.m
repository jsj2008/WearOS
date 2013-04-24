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

#import "SettingsTimerRepeatViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "SimpleCustomCell.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@implementation SettingsTimerRepeatViewController

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

@synthesize repeatData;
@synthesize timer;

- (id)init {
    self = [super initWithNibName:@"SettingsTimerRepeatViewController" bundle:[self frameworkBundle]];
	
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

- (void)reloadFromDB {
	
	TimerRepeatDAO*    dao = [TimerRepeatDAO new];
	ResdbResult*    result = nil;
	
	result = [dao retrieveAll];
	
	if (result.resdbCode == RESDB_SQL_ROWS) {
		self.repeatData = [[NSArray alloc] initWithArray:result.resdbCollection];
	} else {
		TimerRepeatDAO* repeatDao = [TimerRepeatDAO new];
		TimerRepeat*    repeat    = [TimerRepeat new];
		
		repeat.name = @"Every Day";
		[repeat allocateObjectId];
		
		[repeatDao insert:repeat];
		
		repeat.name = @"Once a Week";
		[repeat allocateObjectId];
		
		[repeatDao insert:repeat];
		
		repeat.name = @"Three Times a Day";
		[repeat allocateObjectId];
		
		[repeatDao insert:repeat];

		
		repeat.name = @"Every Other Day";
		[repeat allocateObjectId];
		
		[repeatDao insert:repeat];
		
		result = [dao retrieveAll];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			self.repeatData = [[NSArray alloc] initWithArray:result.resdbCollection];
		}
	}
}

-(void)backAction:(id)sender {
	
	[[self navigationController] popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self reloadFromDB];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
		
	self.tableView.backgroundView  = nil;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageWithData:[Base64 decode:style_.background]]];
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
	return [self.repeatData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.timer.repeat = [[repeatData objectAtIndex:indexPath.row] objectID];
	
	[self.tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
	
	SimpleCustomCell* cell = (SimpleCustomCell*)[tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	
    if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell class]])
                cell = (SimpleCustomCell *)oneObject;
		
		cell.nameLabel.font = [style_ fontFromStyle];
    }
	
	if ([self.timer.repeat isEqual:[[repeatData objectAtIndex:indexPath.row] objectID]])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;	
	
 	cell.nameLabel.text = [[repeatData objectAtIndex:[indexPath row]] name];
	[cell.countLabel removeFromSuperview];
	[cell.countButton removeFromSuperview];
	
	return cell;
}
	
-(void)viewWillAppear:(BOOL)animated {
	
	[self reloadFromDB];
	[self.tableView reloadData];
}

@end
