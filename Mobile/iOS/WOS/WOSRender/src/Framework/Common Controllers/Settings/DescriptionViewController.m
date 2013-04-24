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

#import "DescriptionViewController.h"
#import "WOSCore/OpenPATHCore.h"


@implementation DescriptionViewController

@synthesize descrTextView;
@synthesize dto;

static const CGFloat PD_KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat PD_TAB_BAR_HEIGHT = 49;


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)cancel:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

-(void)save:(id)sender {
	
	dto.description = descrTextView.text;
	
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
									  initWithTitle:NSLocalizedString(@"Cancel",nil)
									  style:UIBarButtonItemStylePlain
									  target:self
									  action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									target:self
									action:@selector(save:)];
	
    self.navigationItem.rightBarButtonItem = saveButton;
	
	descrTextView                  = [[UITextView alloc] initWithFrame: CGRectMake(5, 5, 280, 200)];
	descrTextView.textColor        = [UIColor blackColor];
	descrTextView.font             = [UIFont fontWithName:@"Verdana" size:14];
	descrTextView.backgroundColor  = [UIColor clearColor]; // Larry
	[descrTextView setDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [super viewDidLoad];	
}

- (void)keyboardWillShow:(NSNotification *)aNotification {	
	NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	
    keyboardSize = [aValue CGRectValue].size;
	
	if ([descrTextView isFirstResponder]) {
		UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAction:)];
		self.navigationItem.rightBarButtonItem = doneItem;
		
		[self textFieldViewBeginEditing];
	}
}

- (void)dismissAction:(id)sender {
	[self.descrTextView resignFirstResponder];
	
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
									initWithTitle:NSLocalizedString(@"Save",nil) 
									style:UIBarButtonItemStyleDone
									target:self
									action:@selector(save:)];
	
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)textFieldViewBeginEditing  {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;  //NSLocalizedString(@"Description",nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger			row = indexPath.row;
	UITableViewCell*	cell = nil;
	
	static NSString *MyIdentifier = @"GenericCell";
	
	cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell.contentView addSubview:descrTextView];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	descrTextView.text = dto.description;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 210;
}

@end
