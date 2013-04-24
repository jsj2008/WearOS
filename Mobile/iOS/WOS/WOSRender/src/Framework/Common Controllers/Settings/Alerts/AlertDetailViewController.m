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

#import "AlertDetailViewController.h"
#import "LabelCustomCell.h"

@implementation AlertDetailViewController

@synthesize alert;
@synthesize detailMessageView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (alert == nil)
		return;
	
	detailMessageView                  = [[UITextView alloc] initWithFrame: CGRectMake(1, 1, 280, 200)];
	detailMessageView.textColor        = [UIColor colorWithRed:0.0 green:0.0 blue:217.0 alpha:1.0];
	detailMessageView.font             = [UIFont systemFontOfSize:16];
	detailMessageView.backgroundColor  = [UIColor clearColor];
	detailMessageView.editable         = NO;

	
	//self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
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
	NSInteger			row = indexPath.row;
	static NSString*    MyIdentifier = @"GenericCell";
	
	LabelCustomCell* cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	if (cell == nil) {
		cell = [[LabelCustomCell alloc] initWithIdentifier:MyIdentifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType  = UITableViewCellAccessoryNone;
		
		if (row == kAlertDetailMessageRowIndex)
			[cell.contentView addSubview:detailMessageView];
	}
	
	switch (row) {
		case kAlertMessageRowIndex:
			cell.nameLabel.text = @"Message";
			cell.label.text = alert.message;
			break;
		case kAlertPriorityRowIndex:
			cell.nameLabel.text = @"Priority";
			cell.label.text = alert.priority;
			break;		
		case kAlertCreationDateRowIndex:
			cell.nameLabel.text = @"Date";
			cell.label.text = alert.creationTime;
			break;	
		case kAlertDetailMessageRowIndex:
			detailMessageView.text = alert.detailMessage;
			break;		
		default:
			break;
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == kAlertDetailMessageRowIndex) 
		return 210;
	else 
		return 45;
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

@end
