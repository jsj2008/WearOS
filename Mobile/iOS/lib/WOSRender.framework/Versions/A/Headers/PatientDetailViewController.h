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

@class Patient;
@class WSStyle;

// The following values represent keys in the tempValues dictionary.  The values are essentially
// the section number and row number of the field in the table view.  The section number is a mulitple of 100 added
// to the row of the field in that section.  Hence, 101 represents a field in section 1 at row 1.

// Patient Section
#define kPatientLastNameRowIndex     0
#define kPatientFirstNameRowIndex    1
#define kPatientNumRowIndex          2
#define kPatientGenderRowIndex       3
#define kPatientWeightRowIndex       4
#define kPatientHeightRowIndex       5
#define kPatientDateOfBirthRowIndex  6


@interface PatientDetailViewController : NextLevelViewController <UITextFieldDelegate> {
    Patient*         patient;
    Patient*         tempPatient;
    NSMutableArray*  fieldLabels;
    UITextField*     textFieldBeingEdited;
    UISwitch*        switchFieldBeingEdited;
 
    UIView*          footerView;

    CGFloat          animatedDistance;
    CGSize           keyboardSize;
	
	WSStyle*         style_;
}

@property(nonatomic, retain) Patient *patient;
@property(nonatomic, retain) Patient *tempPatient;
@property(nonatomic, retain) NSMutableArray *fieldLabels;
@property(nonatomic, retain) UITextField *textFieldBeingEdited;
@property(nonatomic, retain) UISwitch *switchFieldBeingEdited;
@property(nonatomic) CGFloat animatedDistance;
@property(nonatomic) CGSize keyboardSize;

- (IBAction)cancel:(id)sender;

- (IBAction)saveAction:(id)sender;

- (IBAction)textFieldDone:(id)sender;

@end
