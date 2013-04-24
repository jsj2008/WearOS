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
#import "NextLevelViewController.h"

@class Goal; 
@class ServerBrowser;
@class WSStyle;

#define kGoalNameRowIndex           		0
#define kGoalShortDescriptionRowIndex		1
#define kGoalInstructionsRowIndex       	2
           //#define kGoalActivationRowIndex            3
#define kGoalPersonalValueRowIndex       	3
           //#define kGoalExpectationOfSuccessRowIndex  5
           //#define kGoalRewardRowIndex                6
#define kGoalActionPlanRowIndex  			4

static const int kGoalPatientFullNameRowIndex    = 100;
static const int kLabelTag                       = 4096;
static const int kCategoryLabelTag               = 4097;
static const int kTextFieldTag                   = 4098;
static const int kSwitchFieldTag                 = 4099;

@interface GoalDetailViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
	IBOutlet UITableView*	table_;
	IBOutlet UIImageView*	backgroundImageView_;
	IBOutlet UILabel*		header_;
    Goal*				    goal;
	Goal*                   tempGoal;
    NSMutableArray*			fieldLabels;
    UITextField*			textFieldBeingEdited;   
	UISwitch*               switchFieldBeingEdited;
	
	UIView*                 footerView;
	
	CGFloat                 animatedDistance;
	CGSize                  keyboardSize;
	
	WSStyle*				style_;
	
	ServerBrowser*          serverBrowser;
}

@property (nonatomic, retain) Goal* goal;
@property (nonatomic, retain) NSMutableArray* fieldLabels;
@property (nonatomic, retain) UITextField* textFieldBeingEdited;
@property (nonatomic, retain) UISwitch* switchFieldBeingEdited;
@property (nonatomic, retain) ServerBrowser* serverBrowser;
@property (nonatomic) CGFloat animatedDistance;
@property (nonatomic) CGSize keyboardSize;

- (IBAction)cancel:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@end
