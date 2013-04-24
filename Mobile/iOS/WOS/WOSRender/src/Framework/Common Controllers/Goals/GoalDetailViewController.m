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

#import "GoalDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "AlertUtilities.h"
#import "TextFieldCustomCell.h"
#import "LabelCustomCell.h"
#import "SwitchFieldCustomCell.h"
#import "LabelWithCountCustomCell.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "LabelTextViewCustomCell.h"

@implementation GoalDetailViewController

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

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;

@synthesize goal;
@synthesize fieldLabels;
@synthesize textFieldBeingEdited;
@synthesize switchFieldBeingEdited;
@synthesize animatedDistance;
@synthesize keyboardSize;
@synthesize serverBrowser;


- (id)init {
    self = [super initWithNibName:@"GoalDetailViewController" bundle:[self frameworkBundle]];
	
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

- (void)deleteAction:(id)sender {
	
	if (goal.objectID != nil) {
		GoalDAO*     dao = [GoalDAO new];
		
		[dao delete:[goal objectID]];
	}
	
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)cancel:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {		
	if (tempGoal.name != nil)
		goal.name = tempGoal.name;
	if (tempGoal.shortDescription != nil)
		goal.shortDescription = tempGoal.shortDescription;
	if (tempGoal.instructions != nil)
		goal.instructions = tempGoal.instructions;
	if (tempGoal.activation != nil)
		goal.activation = tempGoal.activation;
	if (tempGoal.personalValue != nil)
		goal.personalValue = tempGoal.personalValue;
	if (tempGoal.expectationOfSuccess != nil)
		goal.expectationOfSuccess = tempGoal.expectationOfSuccess;
	if (tempGoal.reward != nil)
		goal.reward = tempGoal.reward;
	if (tempGoal.actionPlan != nil)
		goal.actionPlan = tempGoal.actionPlan;
	
	GoalDAO*     dao = [GoalDAO new];
	ResdbResult*  result = nil;
	
	if (goal.objectID == nil) {
		//  This is a new object.
		[goal allocateObjectId];
		result = [dao insert:goal];
	} else {
		result = [dao update:goal];
	}
	
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (goal.objectID != nil) {
		if (buttonIndex == 0) {
			[self deleteAction:nil];
		} else if (buttonIndex == 1) {
			[self saveAction:nil];
		} 
	} else {
		if (buttonIndex == 0) {
			[self saveAction:nil];
		} 	
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switchFieldBeingEdited = nil;
}

-(void)options:(id)sender {
	
	UIActionSheet*  popupOptions;
	
	if (goal.objectID != nil) {
		popupOptions = [[UIActionSheet alloc]
						initWithTitle:nil
						delegate:self
						cancelButtonTitle:@"Cancel"
						destructiveButtonTitle:nil
						otherButtonTitles:@"Delete Goal",@"Save Goal",nil];
	} else {
		popupOptions = [[UIActionSheet alloc]
						 initWithTitle:nil
						 delegate:self
						 cancelButtonTitle:@"Cancel"
						 destructiveButtonTitle:nil
						 otherButtonTitles:@"Save Goal",nil];
	}
	
	popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
	[popupOptions showInView:self.tabBarController.view];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	fieldLabels = [NSMutableArray new];
	
	goal = [OpenPATHContext sharedOpenPATHContext].activeGoal;
	
	if (goal == nil) {
		goal = [Goal new];
	}
	
	style_  = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
    self.view.backgroundColor = [UIColor whiteColor]; // LLS [Theme backgroundColor];
	
    [table_ setBackgroundView:nil];
    table_.backgroundColor = [UIColor clearColor]; // LLS [Theme backgroundColor];
	
    table_.separatorColor = [UIColor clearColor]; // LLS [UIColor whiteColor];
	
	header_.textColor = [style_ textColor];
	
	if ([StringUtils isNotEmpty:style_.background]) {
		UIImage *backgroundImage = [UIImage imageWithData:[Base64 decode:style_.background]];
		backgroundImageView_.image = backgroundImage;
	}
	
	// Object which holds updated values without corrupting the goal object sent into this function.
	tempGoal = [Goal new];
	
    NSArray*      mainArray      = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Name",nil), NSLocalizedString(@"Description",nil), NSLocalizedString(@"Instructions",nil), NSLocalizedString(@"Motivation",nil), NSLocalizedString(@"Action Plan",nil), nil];
    NSDictionary* mainLabelsDict = [NSDictionary dictionaryWithObject:mainArray forKey:@"Labels"];
	
	NSArray*      dataArray         = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Data Values",nil), nil];
	NSDictionary* dataLabelsDict    = [NSDictionary dictionaryWithObject:dataArray forKey:@"Labels"];
	
    [self.fieldLabels addObject:mainLabelsDict];
	[self.fieldLabels addObject:dataLabelsDict];
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		
	[super viewDidLoad];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary* dictionary = [fieldLabels objectAtIndex:section];
	NSArray* array = [dictionary objectForKey:@"Labels"];
    return [array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    CGFloat height = 50;
	
    if (height != 0) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 290, height)];
        NSString *textStr = @"Goal";
		
        textView.textColor = style_.headerTextColor;
		
        textView.font = [style_ headerFontFromStyle];
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
		
        textView.text = textStr;
		
        [headerView addSubview:textView];
    }
	
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString*		   GoalTextCellIdentifier = @"GoalTextCellIdentifier";
	static NSString*		   GoalSwitchCellIdentifier = @"GoalSwitchCellIdentifier";
	static NSString*		   GoalLabelCellIdentifier = @"GoalLabelCellIdentifier";
	static NSString*           GoalLabelCountCellIdentifier = @"GoalLabelCountCellIdentifier";
	static NSString*           GoalLabelTextViewCellIdentifier = @"GoalLabelTextViewCellIdentifier";
    TextFieldCustomCell*       textCell;
	SwitchFieldCustomCell*     switchCell;
	LabelCustomCell*           labelCell;
	LabelWithCountCustomCell*  labelCountCell;
	LabelTextViewCustomCell*   labelTextViewCell;
	
	
	NSUInteger		row = [indexPath row];
	NSUInteger		section = [indexPath section];
	NSDictionary*	dictionary = [fieldLabels objectAtIndex:section];
	NSArray*		array = [dictionary objectForKey:@"Labels"];
	NSString*		cellTitle = [array objectAtIndex:row];
	
	if (section == 0) {
		// Allocate the correct cell type
		labelCell = [tableView dequeueReusableCellWithIdentifier:GoalLabelCellIdentifier];
		
		if (labelCell == nil) {
			labelCell = [[LabelCustomCell alloc] initWithIdentifier:GoalLabelCellIdentifier];
			
			labelCell.nameLabel.font            = [style_ fontFromStyle];
	    	labelCell.nameLabel.textColor       = [style_ textColor];
			labelCell.backgroundColor           = [UIColor clearColor];
			labelCell.nameLabel.backgroundColor	= [UIColor clearColor];
			labelCell.label.backgroundColor     = [UIColor clearColor];
			
			NSString* backgroundImagePath = [[self frameworkBundle] pathForResource:@"WOSRender.bundle/paintCellBackground" ofType:@"png"];
			UIImage*  backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
			UIView*   backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];

			labelCell.backgroundView = backgroundView;
		}
		
		labelTextViewCell = [tableView dequeueReusableCellWithIdentifier:GoalLabelTextViewCellIdentifier];
		
		if (labelTextViewCell == nil) {
			labelTextViewCell = [[LabelTextViewCustomCell alloc] initWithIdentifier:GoalLabelTextViewCellIdentifier];
			
			labelTextViewCell.nameLabel.font            = [style_ fontFromStyle];
	    	labelTextViewCell.nameLabel.textColor       = [style_ textColor];
			labelTextViewCell.backgroundColor           = [UIColor clearColor];
			labelTextViewCell.nameLabel.backgroundColor	= [UIColor clearColor];
			labelTextViewCell.textView.backgroundColor  = [UIColor clearColor];
			labelTextViewCell.textView.editable         = false;
			
			NSString* backgroundImagePath = [[self frameworkBundle] pathForResource:@"WOSRender.bundle/paintCellBackground" ofType:@"png"];
			UIImage*  backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
			UIView*   backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
			
			labelTextViewCell.backgroundView = backgroundView;
		}
		
		//labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		switch (row) {
			case kGoalNameRowIndex:
				labelTextViewCell.nameLabel.text = cellTitle;
				labelTextViewCell.textView.text = (tempGoal.name) ? tempGoal.name : goal.name;
				
				return labelTextViewCell;	
				break;				
			case kGoalShortDescriptionRowIndex:
				labelTextViewCell.nameLabel.text = cellTitle;
				labelTextViewCell.textView.text = (tempGoal.shortDescription != nil) ? tempGoal.shortDescription : goal.shortDescription;
				
				return labelTextViewCell;
				break;
			case kGoalInstructionsRowIndex:
				labelTextViewCell.nameLabel.text = cellTitle;
				labelTextViewCell.textView.text = (tempGoal.instructions != nil) ? tempGoal.instructions : goal.instructions;
				
				return labelTextViewCell;	
				break;
				
			case kGoalPersonalValueRowIndex:
				labelTextViewCell.nameLabel.text = cellTitle;
				labelTextViewCell.textView.text = (tempGoal.personalValue != nil) ? tempGoal.personalValue : goal.personalValue;
				
				return labelTextViewCell;
				break;
				
		    /*
			case kGoalActivationRowIndex:
				labelCell.nameLabel.text = cellTitle;
				labelCell.label.text = (tempGoal.activation != nil) ? tempGoal.activation : goal.activation;
				
				return labelCell;	
				break;		
			case kGoalExpectationOfSuccessRowIndex:
				labelCell.nameLabel.text = cellTitle;
				labelCell.label.text = (tempGoal.expectationOfSuccess != nil) ? tempGoal.expectationOfSuccess : goal.expectationOfSuccess;
				
				return labelCell;	
				break;		
			case kGoalRewardRowIndex:
				labelCell.nameLabel.text = cellTitle;
				labelCell.label.text = (tempGoal.reward != nil) ? tempGoal.reward : goal.reward;
				
				return labelCell;	
				break;	
	        */
				
			case kGoalActionPlanRowIndex:
				labelTextViewCell.nameLabel.text = cellTitle;
				//labelTextViewCell.textView.text = (tempGoal.actionPlan != nil) ? tempGoal.actionPlan : goal.actionPlan;
				
				return labelTextViewCell;
				break;
			default:
				break;
		}
	}  else
		return nil;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger		section = [indexPath section];
	NSUInteger      row = [indexPath row];
	
	if ((section == 0) && (row == kGoalNameRowIndex)) {
	}
}

#pragma mark Text Field Delegate Methods

- (void)keyboardWillShow:(NSNotification *)aNotification {	
	NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	
    keyboardSize = [aValue CGRectValue].size;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	CGRect   textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
	CGFloat  keyboardDistance = keyboardSize.height + 12;
	
	// Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
	if (textFieldRect.origin.y > keyboardDistance) {
		CGRect viewFrame = self.view.frame;
		
		animatedDistance = textFieldRect.origin.y - keyboardDistance;
		viewFrame.origin.y -= animatedDistance;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		
		[self.view setFrame:viewFrame];
		
		[UIView commitAnimations];
	} else {
		animatedDistance = 0;
	}
	
	self.textFieldBeingEdited = textField;
}

- (void)textFieldDone:(id)textField {
	[textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	//[self setGoalPropertyFromTextField:textField];
	
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
	[self.view setFrame:viewFrame];
	
	self.textFieldBeingEdited = nil;
    
	[UIView commitAnimations];		
}

-(void)viewWillAppear:(BOOL)animated {
	[table_ reloadData];
}

- (void) displayChatMessage:(NSString*)message fromUser:(NSString*)userName {
}

- (void) roomTerminated:(id)room reason:(NSString*)string {
}

@end