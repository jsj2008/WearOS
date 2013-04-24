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
#import "MediaSendDataManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class Asset;
@class WSStyle;

// The following values represent keys in the tempValues dictionary.  The values are essentially
// the section number and row number of the field in the table view.  The section number is a mulitple of 100 added
// to the row of the field in that section.  Hence, 101 represents a field in section 1 at row 1.

// Asset Section
#define kAssetFileViewIndex          0
#define kAssetFileUrlIndex           1
#define kAssetTimeLengthIndex        2
#define kAssetFileSizeIndex          3
#define kAssetRelatedIDIndex         4
#define kAssetOriginatorIndex        5
#define kAssetLocationIndex          6
#define kAssetLocationCodeIndex      7
#define kAssetPatientIDIndex         8
#define kAssetAssetTypeIndex         9
#define kAssetArchivedIndex          10
#define kAssetAssetArchivedIndex     11
#define kAssetContainerIndex         12

// NSConditionLock values
enum {
    WDASSETURL_PENDINGREADS = 1,
    WDASSETURL_ALLFINISHED  = 0
};


@interface MediaAssetsDetailViewController : NextLevelViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    Asset*						asset;
    Asset*						tempAsset;
    NSMutableArray*				fieldLabels;
    UITextField*				textFieldBeingEdited;
    UISwitch*					switchFieldBeingEdited;
	
    UIView*						footerView;
	
    CGFloat 					animatedDistance;
    CGSize 						keyboardSize;
	NSMutableArray*				optionActions;
	UIActivityIndicatorView*	loadingIndicator;
	id<MediaSendDataManager> 	dataManager;
	WSStyle*					style_;
	ALAssetsLibrary*			library_;
}

@property(nonatomic, retain) Asset *asset;
@property(nonatomic, retain) Asset *tempAsset;
@property(nonatomic, retain) NSMutableArray *fieldLabels;
@property(nonatomic, retain) UITextField *textFieldBeingEdited;
@property(nonatomic, retain) UISwitch *switchFieldBeingEdited;
@property(nonatomic) CGFloat animatedDistance;
@property(nonatomic) CGSize keyboardSize;
@property(nonatomic, retain) id<MediaSendDataManager> dataManager;

- (IBAction)cancel:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)setAssetPropertyFromTextField:(UITextField *)textField;


@end
