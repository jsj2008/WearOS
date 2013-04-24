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

#import "PatientGenderViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "SimpleCustomCell.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "ImageUtilities.h"


@implementation PatientGenderViewController

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

@synthesize genderData;
@synthesize patient;

- (void)reloadFromDB {
	self.genderData = [NSArray arrayWithObjects:GENDER_MALE, GENDER_FEMALE, nil];
}

-(void)backAction:(id)sender {
	
	[[self navigationController] popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self reloadFromDB];
	
	self.title = NSLocalizedString(@"Gender", @"Gender of the particpant");
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.tableView.backgroundView  = nil;
	self.tableView.tableFooterView = nil;
	self.tableView.tableHeaderView = nil;

	self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine; //UITableViewCellSeparatorStyleNone;
	self.tableView.separatorColor  = [UIColor lightGrayColor];
	
	UIImageView*  imageView = [[UIImageView alloc] initWithImage:[ImageUtilities resizedImage:[UIImage imageWithData:[Base64 decode:style_.background]] rectSize:CGRectMake(0, 0, 320, 480)]];
	
	self.tableView.backgroundView  = imageView;
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
	return 2; //[self.genderData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.patient.gender = [genderData objectAtIndex:indexPath.row];
	
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
    }
	
	if ([self.patient.gender isEqualToString:[genderData objectAtIndex:indexPath.row]])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;	
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
 	cell.nameLabel.text = NSLocalizedString([genderData objectAtIndex:[indexPath row]], nil);
	[cell.countLabel removeFromSuperview];
	[cell.countButton removeFromSuperview];
	
	cell.nameLabel.textColor = [style_ textColor];
	cell.nameLabel.font      = [style_ fontFromStyle];
	
	return cell;
}

-(void)viewWillAppear:(BOOL)animated {
}


@end
