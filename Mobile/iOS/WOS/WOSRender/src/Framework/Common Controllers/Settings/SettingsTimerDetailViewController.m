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

#import "SettingsTimerDetailViewController.h"
#import "SettingsTimerSoundsViewController.h"
#import "SettingsTimerRepeatViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "TextFieldCustomCell.h"
#import "LabelCustomCell.h"
#import "SwitchFieldCustomCell.h"
#import "SettingsTimerStartTimeViewController.h"
#import "SettingsTimerMessageViewController.h"
#import "DeleteCustomCell.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@implementation SettingsTimerDetailViewController

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

@synthesize timer;
@synthesize fieldLabels;
@synthesize textFieldBeingEdited;

-(IBAction)cancel:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}

- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger		section = [indexPath section];
	NSUInteger      row = [indexPath row];
	
	if ((section == 0) && (row == kTimerSoundRowIndex)) {
		SettingsTimerSoundsViewController*  rvController = [[SettingsTimerSoundsViewController alloc] initWithStyle:UITableViewStylePlain];
		
		rvController.navController      = [self navigationController];
		rvController.currentLevel      += 1;
		rvController.timer              = tempTimer;
		
		[rvController setTitle: NSLocalizedString(@"Ringtones",nil)];
		
		[[self navigationController] pushViewController:rvController animated:YES];
		
	} else if ((section == 0) && (row == kTimerRepeatRowIndex)) {
		
		SettingsTimerRepeatViewController*  rvController = [[SettingsTimerRepeatViewController alloc] initWithStyle:UITableViewStylePlain];
		
		rvController.navController      = [self navigationController];
		rvController.currentLevel      += 1;
		rvController.timer              = tempTimer;
		
		[rvController setTitle: NSLocalizedString(@"Repeat",nil)];
		
		[[self navigationController] pushViewController:rvController animated:YES];
	} else if ((section == 0) && (row == kTimerStartTimeRowIndex)) {
		
		SettingsTimerStartTimeViewController*  rvController = [[SettingsTimerStartTimeViewController alloc] init];
		
		rvController.timer = tempTimer;
		
		
		if (tempTimer.startTime == nil)
			tempTimer.startTime = timer.startTime;
		
		[rvController setTitle: NSLocalizedString(@"Start Time",nil)];
		
		[[self navigationController] pushViewController:rvController animated:YES];
	} else if ((section == 0) && (row == kTimerMessageRowIndex)) {
		
		SettingsTimerMessageViewController*  rvController = [[SettingsTimerMessageViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
		rvController.navController      = [self navigationController];
		rvController.currentLevel      += 1;
		rvController.timer              = tempTimer;
		
		[rvController setTitle: NSLocalizedString(@"Message",nil)];
		
		[[self navigationController] pushViewController:rvController animated:YES];
	} else if (section == 1) 
		[self deleteAction:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	switch (textField.tag) {
		case kTimerNameRowIndex:
			tempTimer.name = textField.text;
			break;
		default:
			break;
	}
	
   	self.textFieldBeingEdited = nil;
}

- (void)scheduleNotification {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
	
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	NSDateFormatter *usDateFormatter = [NSDateFormatter new];
	
	[usDateFormatter setDateFormat:@"HH:mm"];
		
    NSDate *alarmDate = [usDateFormatter dateFromString:timer.startTime];
	
    notification.fireDate = alarmDate;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.repeatInterval = NSDayCalendarUnit;
	
    notification.alertBody = timer.message;
	
    notification.soundName = ([StringUtils isNotEmpty:timer.sound]) ? timer.sound : UILocalNotificationDefaultSoundName;
	
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void) saveAction:(id)sender {
    if (textFieldBeingEdited != nil) {
        tempTimer.name = textFieldBeingEdited.text;
    }
	
	if ([StringUtils isNotEmpty:tempTimer.name])
		timer.name = tempTimer.name;
	if ([StringUtils isNotEmpty:tempTimer.sound])
		timer.sound = tempTimer.sound;
	if ([StringUtils isNotEmpty:tempTimer.repeat])
		timer.repeat = tempTimer.repeat;
	if (tempTimer.active >= 0)
		timer.active = tempTimer.active;
	if ([StringUtils isNotEmpty:tempTimer.category])
		timer.category = tempTimer.category;
	if ([StringUtils isNotEmpty:tempTimer.startTime])
		timer.startTime = tempTimer.startTime;
	if ([StringUtils isNotEmpty:tempTimer.startTimeTerse])
		timer.startTimeTerse = tempTimer.startTimeTerse;
	if ([StringUtils isNotEmpty:tempTimer.message])
		timer.message = tempTimer.message;
	
	TimerDAO*     dao = [TimerDAO new];
	ResdbResult*  result = nil;
	
	if (timer.objectID == nil) {
		//  This is a new object.
		[timer allocateObjectId];
		result = [dao insert:timer];
	} else {
		result = [dao update:timer];
	}
	
	if (timer.active) {
		[self scheduleNotification];
	}
		
    [[self navigationController] popViewControllerAnimated:YES];	
}

- (void)deleteAction:(id)sender {
	if (timer.objectID != nil) {
		
		TimerDAO*     dao = [TimerDAO new];
		
		[dao delete:[timer objectID]];
	}
	
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self deleteAction:nil];
	} else if (buttonIndex == 1) {
		[self saveAction:nil];
	} 
}

-(void)options:(id)sender {
	UIActionSheet*  popupOptions;
	
	popupOptions = [[UIActionSheet alloc]
					initWithTitle:nil
					delegate:self
					cancelButtonTitle:@"Cancel"
					destructiveButtonTitle:nil
					otherButtonTitles:@"Delete Timer",@"Save Timer",nil];
	
	popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
	[popupOptions showInView:self.view];
}

-(void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Timer";
	
	if (timer == nil)
		timer = [Timer new];
	
	tempTimer = [Timer new];
	tempTimer.active = -1;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									  initWithTitle:NSLocalizedString(@"Cancel",nil)
									  style:UIBarButtonItemStylePlain
									  target:self
									  action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;	
		
	if (timer.objectID == nil) {
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemSave
										target:self
										action:@selector(saveAction:)];
		
		self.navigationItem.rightBarButtonItem = saveButton;	
	} else {
		UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
										  target:self
										  action:@selector(options:)];
		
		self.navigationItem.rightBarButtonItem = actionButton;
	}	
			
	UIView*   backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[Base64 decode:style_.background]]];

	self.tableView.backgroundView  = backgroundView;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	
	fieldLabels = [NSMutableArray new];
	
    NSArray*      mainArray      = [[NSArray alloc] initWithObjects:@"Name", @"Sound", @"Repeat", @"Active", @"Start Time", @"Message", nil];
    NSDictionary* mainLabelsDict = [NSDictionary dictionaryWithObject:mainArray forKey:@"Labels"];
	
    [self.fieldLabels addObject:mainLabelsDict];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(IBAction)textFieldDone:(id)textField {
	[textField resignFirstResponder];
}

-(void)onSwitchChanged:(UISwitch*)activeSwitch {
	if (activeSwitch.tag == kTimerActiveRowIndex) {
		tempTimer.active = [activeSwitch isOn] ? 1 : 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString*		TimerTextCellIdentifier = @"TimerTextCellIdentifier";
	static NSString*		TimerLabelCellIdentifier = @"TimerLabelCellIdentifier";
	static NSString*		TimerSwitchCellIdentifier = @"TimerSwitchCellIdentifier";
	static NSString*        TimerDeleteCellIdentifier = @"TimerDeleteCellIdentifier";
    TextFieldCustomCell*    textCell;
	LabelCustomCell*        labelCell;
	SwitchFieldCustomCell*  switchCell;
	DeleteCustomCell*       deleteCell;
	RingtoneDAO*            ringtoneDao = [RingtoneDAO new];
	TimerRepeatDAO*         timerRepeatDao = [TimerRepeatDAO new];

	NSUInteger		row = [indexPath row];
	NSUInteger		section = [indexPath section];
	
	if (section == 0) {
		switch (row) {
			case kTimerNameRowIndex:
				textCell = [tableView dequeueReusableCellWithIdentifier:TimerTextCellIdentifier];
			
				if (textCell == nil) 
					textCell = [[TextFieldCustomCell alloc] initWithIdentifier:TimerTextCellIdentifier delegate:self];
				
				textCell.nameLabel.font = [style_ fontFromStyle];
				textCell.textField.font = [style_ fontFromStyle];
				textCell.contentView.backgroundColor = [UIColor clearColor];
				textCell.textField.backgroundColor = [UIColor whiteColor];
				textCell.backgroundColor = [UIColor whiteColor];
				break;
			case kTimerSoundRowIndex:
			case kTimerRepeatRowIndex:
			case kTimerStartTimeRowIndex:
			case kTimerMessageRowIndex:
				labelCell = [tableView dequeueReusableCellWithIdentifier:TimerLabelCellIdentifier];
			
				if (labelCell == nil)
					labelCell = [[LabelCustomCell alloc] initWithIdentifier:TimerLabelCellIdentifier];
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
				labelCell.nameLabel.font = [style_ fontFromStyle];
				labelCell.label.font     = [style_ fontFromStyle];
				labelCell.contentView.backgroundColor = [UIColor whiteColor];
				break;
			case kTimerActiveRowIndex:
				switchCell = [tableView dequeueReusableCellWithIdentifier:TimerSwitchCellIdentifier];
			
				if (switchCell == nil) 
					switchCell = [[SwitchFieldCustomCell alloc] initWithIdentifier:TimerSwitchCellIdentifier delegate:self];
				
				switchCell.nameLabel.font = [style_ fontFromStyle];
				switchCell.contentView.backgroundColor = [UIColor whiteColor];
				break;
			default:
				break;
		}
		
		switch (row) {
			case kTimerNameRowIndex:
				textCell.nameLabel.text = @"Name";
				textCell.textField.tag = row;
				textCell.textField.text = (tempTimer.name != nil) ? tempTimer.name : timer.name;
				textCell.selectionStyle = UITableViewCellSelectionStyleNone;
				return textCell;
				break;
			case kTimerSoundRowIndex:
				labelCell.nameLabel.text = @"Sound";
				labelCell.tag = row;
				labelCell.label.text = (tempTimer.sound != nil) ? [ringtoneDao retrieveName:[tempTimer sound]] : [ringtoneDao retrieveName:[timer sound]];
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return labelCell;
				break;
			case kTimerRepeatRowIndex:
				labelCell.nameLabel.text = @"Repeat";
				labelCell.tag = row;
				labelCell.label.text = (tempTimer.repeat != nil) ? [timerRepeatDao retrieveRepeatName:[tempTimer repeat]] : [timerRepeatDao retrieveRepeatName:[timer repeat]];
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return labelCell;
				break;
			case kTimerActiveRowIndex:
				switchCell.nameLabel.text = @"Active";
			
				if (tempTimer.active >= 0)
					[switchCell.switchField setOn:tempTimer.active];
				else
					[switchCell.switchField setOn:timer.active];
			
				switchCell.switchField.tag = row;
				return switchCell;
				break;
			case kTimerStartTimeRowIndex:
				labelCell.nameLabel.text = @"Start Time";
				labelCell.tag = row;
				labelCell.label.text = (tempTimer.startTimeTerse != nil) ? tempTimer.startTimeTerse : timer.startTimeTerse;
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return labelCell;
				break;
			case kTimerMessageRowIndex:
				labelCell.nameLabel.text = @"Message";
				labelCell.tag = row;
				labelCell.label.text = (tempTimer.message != nil) ? tempTimer.message : timer.message;
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return labelCell;
				break;
			default:
				break;
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 6;
	else if ((section == 1) && (timer.objectID != nil))
		return 1;
    else
		return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
