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

#import "SettingsResearcherViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"


@implementation SettingsResearcherViewController

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

- (id)init {
    self = [super initWithNibName:@"SettingsResearcherViewController" bundle:[self frameworkBundle]];
	
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

- (void)loadPartnersFromDB {
	[researcherData_ removeAllObjects];
	
    UserDAO*     dao = [UserDAO new];
    ResdbResult* result = nil;
	
    result = [dao retrieveByRole:@"RESEARCHER"];
	
    if (result.resdbCode == RESDB_SQL_ROWS) {
		[researcherData_ addObjectsFromArray:result.resdbCollection];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)backAction:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {	
	if ([StringUtils isNotEmpty:researcherName_.text]) {
		UserDAO*      dao = [UserDAO new];
		ResdbResult*  result;
		
		result = [dao retrieveByLastName:researcherName_.text];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher = ((User*)result.resdbObject).objectID;
		} else {
			User* user = [User new];
			
			[user allocateObjectId];
			user.lastName = researcherName_.text;
			user.role = @"RESEARCHER";
			
			[dao insert:user];
			
			[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher = user.objectID;
		}
	}

	[[OpenPATHContext sharedOpenPATHContext] saveActiveStudy];
	
	[[self navigationController] popViewControllerAnimated:YES];
}

- (NSString*)locateResearcherName {
	if ([StringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher]) {
		UserDAO*      dao = [UserDAO new];
		ResdbResult*  result;
		
		result = [dao retrieve:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			return ((User*)result.resdbObject).lastName;
		}
	}
	
	return @"";
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    researcherData_ = [[NSMutableArray alloc] initWithCapacity:10];

    [self loadPartnersFromDB];
	
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/yellowBackground.png"]];	
	
	researcherName_.font = [UIFont fontWithName:@"Bryant-Bold" size:18.0];
    researcherName_.text = [self locateResearcherName];

    researcherPicker_.frame = CGRectMake(26, 186, 274, 100);
	
	[self navigationController].navigationBar.hidden = YES;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	researcherNameLabel_.font      = [style_ headerFontFromStyle];
	researcherNameLabel_.textColor = [style_ headerTextColor];
	backgroundImageView_.image     = [UIImage imageWithData:[Base64 decode:style_.background]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark Picker view delegate

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
	if ([researcherData_ count] > 0)
    	return [researcherData_ count];
	else
		return 1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView_ {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if ([researcherData_ count] > 0)
    	return ((User*)[researcherData_ objectAtIndex:row]).lastName;
	else
		return @"";
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if ([researcherData_ count] > 0)
    	researcherName_.text = ((User*)[researcherData_ objectAtIndex:row]).lastName;
}

@end
