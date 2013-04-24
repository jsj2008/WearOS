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

#import "SettingsTimerStartTimeViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "LabelCustomCell.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@implementation SettingsTimerStartTimeViewController

static const int kLabelTag              = 4096;
static const int kTextFieldTag          = 4097;

@synthesize timer;
@synthesize timePicker;
@synthesize timeView;

-(void)viewWillAppear:(BOOL)animated {
}

-(void)cancel:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

-(void)save:(id)sender {
	timer.startTime      = [DateFormatter hourMinFromDateTime:[timePicker date]];
	timer.startTimeTerse = [DateFormatter hourMinFromDateTime:[timePicker date]];
	
	[[self navigationController] popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Start Time";
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.timeView.backgroundView  = nil;
	self.timeView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageWithData:[Base64 decode:style_.background]]];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
			
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									  initWithTitle:NSLocalizedString(@"Cancel",nil)
									  style:UIBarButtonItemStylePlain
									  target:self
									  action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;	
	
	self.navigationItem.rightBarButtonItem =
		[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save",nil)
										style:UIBarButtonItemStyleBordered
										target:self
										action:@selector(save:)];
	
	if (timer.startTime != nil) {
		NSDateFormatter *usDateFormatter = [NSDateFormatter new];
		
        [usDateFormatter setDateFormat:@"HH:mm"];
		
        NSDate* pickerDate = [usDateFormatter dateFromString:timer.startTime];
		
        [timePicker setDate:pickerDate];
	} else {
		[timePicker setDate:[NSDate date]];
	}
	
	[timePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger		       row = indexPath.row;
	static NSString*       TimerStartTimeTextCellIdentifier = @"GenericCell"; 
	LabelCustomCell*       cell = [tableView dequeueReusableCellWithIdentifier:TimerStartTimeTextCellIdentifier];
	
	if (cell == nil) {
		cell = [[LabelCustomCell alloc] initWithIdentifier:TimerStartTimeTextCellIdentifier];
	
		cell.accessoryType  = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.nameLabel.font = [style_ fontFromStyle];
	}
	
	cell.nameLabel.text = @"Start Time";
	cell.label.text = [DateFormatter hourMinFromDateTime:[timePicker date]];

    return cell;
}

- (void)changeDateInLabel:(id)sender {
	[self.timeView reloadData];
}

@end
