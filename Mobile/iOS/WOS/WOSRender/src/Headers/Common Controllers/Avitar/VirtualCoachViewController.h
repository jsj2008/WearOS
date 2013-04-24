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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@class Patient;
@class WSUCSFCarePlanModel;
@class AvatarPersistanceModel;
@class WSClinicalEngine;
@class VSSpeechSynthesizer;
@class WSClinicalEngine;
@class WSIntervention;
@class WSInteraction;
@class WSResponse;
@class WSGeneralProtocolHistoryManager;
@class WSStyle;

#define TAG_TEXT_VIEW			200
#define	TAG_TEXT_FIELD			300
#define	TAG_BUTTON_VIEW			400
#define	TAG_SLIDER_VIEW			500
#define TAG_TEXT_QUESTION_VIEW  600
#define TAG_TEXT_RESPONSE_VIEW  700

#define COACH_NO_COACH			0
#define COACH_FEMALE_A			100
#define COACH_FEMALE_B			200
#define COACH_MALE_A			300
#define COACH_MALE_B			400


@interface VirtualCoachViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
	IBOutlet UITableView*			questionTableView_;
	IBOutlet UIImageView*			kioskBanner_;
	IBOutlet UIImageView*			sideBanner_;
	IBOutlet UIImageView*           backgroundImageView_;
	IBOutlet UISlider*				progressSlider_;
	IBOutlet UIButton*				clearBtn_;
	IBOutlet UIButton*				sendBtn_;
	IBOutlet UIButton*				previousBtn_;
	IBOutlet UIButton*				audioBtn_;
	IBOutlet UIButton*				homeBtn_;
	IBOutlet UIButton*				nextBtn_;
	IBOutlet UIButton*				coachBtn_;
	IBOutlet UIWebView*				webView_;
	IBOutlet UIView*				touchView_;
	IBOutlet UIScrollView*          scrollView_;
	IBOutlet UIButton*				talkToUsBtn_;
	int								activeCoach_;
	VSSpeechSynthesizer*			speech_;
	BOOL 							audioFeature_;
	IBOutlet UILabel*				slideNum_;
	AVAudioPlayer*              	audioPlayer_;
	UITextView*						responseTextView_;
	UITextField*					responseTextField_;
	UIPickerView*					pickerView_;
	UIDatePicker*					datePickerView_;
	WSClinicalEngine*				engine_;
	MPMoviePlayerController*		videoPlayer_;
	NSURL*							videoURL_;
	UITextField*					textFieldBeingEdited_;
	UITextView*						textViewBeingEdited_;
	int								orientationOffset_;
	UIImageView*					coachingView_;
	
	WSGeneralProtocolHistoryManager* 	histManager_;
	AvatarPersistanceModel*				persistModel_;
	
	NSString*                       protocol_;
	
	IBOutlet UIImageView*       	topBanner_;
	WSStyle*                        style_;
}

@property (nonatomic, retain) UISegmentedControl* surveyNavTabs;
@property (nonatomic, retain) UITableView* questionTableView;
@property (nonatomic, retain) UIImageView* kioskBanner;
@property (nonatomic, retain) UIImageView* sideBanner;
@property (nonatomic, retain) UISlider* progressSlider;
@property (nonatomic, retain) MPMoviePlayerController* videoPlayer;
@property (nonatomic, retain) WSClinicalEngine* engine;
@property (nonatomic, retain) UIDatePicker* datePickerView;
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, copy ) NSString* protocol;

- (IBAction)navigateSurvey:(id)sender;
- (IBAction)sendXML;
- (IBAction)clearSurvey;
- (IBAction)previousAction:(id)sender;
- (IBAction)audioAction:(id)sender;
- (IBAction)homeAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)coachHelpAction:(id)sender;

- (void)setupSurvey;
- (void)coachAction:(int)coach;

@end