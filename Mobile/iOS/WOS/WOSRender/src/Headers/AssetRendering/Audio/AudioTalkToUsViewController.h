/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *              When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author     Larry Suarez
 *  @package    com.carethings.domain
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
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@class Asset;

@interface AudioTalkToUsViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {

    //IBOutlet SpeakHereController* controller;
    Asset *asset;
    IBOutlet UIButton *btn_record;
    IBOutlet UIButton *btn_play;
    IBOutlet UIBarButtonItem *btn_save;
    IBOutlet UIBarButtonItem *btn_delete;
    BOOL recording;
    BOOL playing;
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *autoMemoPlayer;
    AVAudioRecorder *audioRecorder;
    BOOL recordingExists;
    NSURL *soundFileURL;
    NSString *soundFileString;
    BOOL speakerOn;
    NSTimer *timer;
    NSInteger recTimerMinutes;
    NSInteger recTimerSeconds;
    NSInteger playTimerMinutes;
    NSInteger playTimerSeconds;
    IBOutlet UILabel *timerMinutesLabel;
    IBOutlet UILabel *timerSecondsLabel;
    BOOL autoMemo;
    NSString *albumName;
    NSString *patientNum;
}

@property(retain, nonatomic) Asset *asset;
@property(nonatomic, retain) UIButton *btn_record;
@property(nonatomic, retain) UIButton *btn_play;
@property(nonatomic, retain) UIBarButtonItem *btn_save;
@property(nonatomic, retain) UIBarButtonItem *btn_delete;
@property(nonatomic, retain) AVAudioPlayer *audioPlayer;
@property(nonatomic, retain) AVAudioPlayer *autoMemoPlayer;
@property(nonatomic, retain) AVAudioRecorder *audioRecorder;
@property(nonatomic) BOOL recordingExists;
@property(nonatomic) BOOL recording;
@property(nonatomic) BOOL playing;
@property(nonatomic) BOOL speakerOn;
@property(nonatomic) BOOL autoMemo;
@property(nonatomic, retain) NSURL *soundFileURL;
@property(nonatomic, copy) NSString *soundFileString;
@property(retain, nonatomic) NSTimer *timer;
@property(nonatomic) NSInteger recTimerMinutes;
@property(nonatomic) NSInteger recTimerSeconds;
@property(nonatomic) NSInteger playTimerMinutes;
@property(nonatomic) NSInteger playTimerSeconds;
@property(retain, nonatomic) IBOutlet UILabel *timerMinutesLabel;
@property(retain, nonatomic) IBOutlet UILabel *timerSecondsLabel;
@property(nonatomic, copy) NSString *albumName;
@property(nonatomic, copy) NSString *patientNum;

- (IBAction)record:(id)sender;

- (IBAction)play:(id)sender;

- (IBAction)delete:(id)sender;

- (IBAction)save:(id)sender;

@end

