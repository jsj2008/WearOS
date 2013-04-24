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

#import <UIKit/UIKit.h>


@class Study;
@class WSStyle;

// The following values represent keys in the tempValues dictionary.  The values are essentially
// the section number and row number of the field in the table view.  The section number is a mulitple of 100 added
// to the row of the field in that section.  Hence, 101 represents a field in section 1 at row 1.

// Patient Section
#define kSettingsPhaseRowIndex                0
#define kSettingsAlarmTimeRowIndex            1
#define kSettingsPasscodeRowIndex             2
#define kSettingsParticipantIDRowIndex        3
#define kSettingsUserNameRowIndex             4
#define kSettingResearcherRowIndex            5
#define kSettingSiteRowIndex                  6
#define kSettingVirtualCoachRowIndex          7
#define kSettingLanguageRowIndex              8
#define kSettingDesktopPhotoRowIndex          9
#define kSettingGeozoneRowIndex               10
#define kSettingResearcherLanguageRowIndex    11


@interface SettingsViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
	IBOutlet UITableView*      tableView_;
	IBOutlet UIButton*         backButton_;
	IBOutlet UIButton*         saveButton_;
	IBOutlet UIImageView*      backgroundView_;
	
	Study*                     study;
    Study*                     tempStudy;
    NSMutableArray*            fieldLabels;
    UITextField*               textFieldBeingEdited;
    UISwitch*                  switchFieldBeingEdited;
	UIImagePickerController*   imagePickerController;
	
    UIView*                    footerView;
	
    CGFloat                    animatedDistance;
    CGSize                     keyboardSize;
	
	BOOL                       enableControls;
	BOOL                       noParent;
	WSStyle*                   style_;
	NSMutableArray*            features_;
	NSString*                  siteName_;
	NSString*                  researcherName_;
	
	IBOutlet UIImageView*      topBanner_;
}

- (void)setNoParent:(BOOL)value;
- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
