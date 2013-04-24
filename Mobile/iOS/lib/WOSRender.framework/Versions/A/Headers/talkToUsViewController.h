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
#import <MediaPlayer/MediaPlayer.h>

@class WSClinicalEngine;
@class WSIntervention;
@class WSInteraction;
@class WSResponse;
@class WSStyle;
@class WSDataDistributionManager;

#define    TAG_TEXT_VIEW			200
#define    TAG_TEXT_FIELD			300
#define    TAG_BUTTON_VIEW			400
#define    TAG_SLIDER_VIEW			500
#define  TAG_DIRECTIVE_VIEW			600


@interface TalkToUsViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UITableView *			questionTableView_;
	IBOutlet UIImageView *   		backgroundView_;
    UIPickerView *					pickerView_;
    UIDatePicker *					datePickerView_;
    UIView *						userView_;
    IBOutlet UIImageView *			desktopLogoRunin_;
    WSClinicalEngine *				engine_;
    IBOutlet UIButton *				clearBtn_;
    IBOutlet UIButton *				sendBtn_;
    IBOutlet UIButton *				previousBtn_;
	IBOutlet UIButton *             backBtn_;
    UIImagePickerController *		imagePicker_;
    WSInteraction *					imagePickerInteraction_;
    WSResponse *					imagePickerResponse_;
    IBOutlet UIButton *				homeBtn_;
    IBOutlet UIButton *				nextBtn_;
    MPMoviePlayerController *		videoPlayer_;                // For questions requiring a video player.
    UITextField *					textFieldBeingEdited_;
    UITextView *					textViewBeingEdited_;
    CGFloat 						animatedDistance_;
    CGSize 							keyboardSize_;
    NSMutableArray *				partnerData_;
    UIDeviceOrientation 			screenOrientation_;
	IBOutlet UIImageView*           topBanner_;
	
	WSDataDistributionManager*      dataDistributionManager_;

    NSString *						albumName_;
    NSString *						patientNum_;
	
	WSStyle*						style_;
	
	BOOL                            noParent_;
}

@property(nonatomic, retain) IBOutlet UITableView *questionTableView;
@property(nonatomic, retain) UIPickerView *pickerView;
@property(nonatomic, retain) UIDatePicker *datePickerView;
@property(nonatomic, retain) UIView *userView;
@property(nonatomic, retain) WSClinicalEngine *engine;
@property(nonatomic, retain) IBOutlet UIButton *clearBtn;
@property(nonatomic, retain) IBOutlet UIButton *sendBtn;
@property(nonatomic, retain) IBOutlet UIButton *previousBtn;
@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *nextBtn;
@property(nonatomic, copy) NSString *albumName;
@property(nonatomic, copy) NSString *patientNum;
@property(nonatomic, retain) WSDataDistributionManager* dataDistributionManager;

- (IBAction)previousAction:(id)sender;
- (IBAction)homeAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)backAction:(id)sender;

- (void)setNoParent:(BOOL)value;
- (void)showInbox:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response;
- (void)showAudio:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response;
- (void)saveText:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response;
- (void)takePictureWithIntervention:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response;
- (void)takeVideoWithIntervention:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response;

@end
