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


#import "WOSCore/OpenPATHCore.h"
#import "AudioTalkToUsViewController.h"
#import "AlertUtilities.h"

@implementation AudioTalkToUsViewController

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

@synthesize asset;
@synthesize btn_record;
@synthesize btn_play;
@synthesize btn_save;
@synthesize btn_delete;
@synthesize recording;
@synthesize playing;
@synthesize recordingExists;
@synthesize audioPlayer;
@synthesize autoMemoPlayer;
@synthesize audioRecorder;
@synthesize soundFileURL;
@synthesize soundFileString;
@synthesize speakerOn;
@synthesize timerMinutesLabel;
@synthesize timerSecondsLabel;
@synthesize timer;
@synthesize recTimerMinutes;
@synthesize recTimerSeconds;
@synthesize playTimerMinutes;
@synthesize playTimerSeconds;
@synthesize autoMemo;
@synthesize albumName;
@synthesize patientNum;

- (id)init {
    self = [super initWithNibName:@"AudioTalkToUsViewController" bundle:[self frameworkBundle]];
	
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

- (void)releaseTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateRecTimerLabel:(id)sender {
    if (recTimerSeconds == 159) {
        recTimerMinutes += 1;
        recTimerSeconds = 100;
    } else {
        recTimerSeconds += 1;
    }

    timerMinutesLabel.text = [[NSString stringWithFormat:@"%2d", recTimerMinutes] substringFromIndex:1];
    timerSecondsLabel.text = [[NSString stringWithFormat:@"%2d", recTimerSeconds] substringFromIndex:1];

    if (autoMemo) {
        if (recTimerSeconds > 110) {
            [self record:nil];
            [self save:nil];
        }
    }
}

- (void)updatePlayTimerLabel:(id)sender {
    if (playTimerSeconds == 159) {
        playTimerMinutes += 1;
        playTimerSeconds = 100;
    } else {
        playTimerSeconds += 1;
    }

    timerMinutesLabel.text = [[NSString stringWithFormat:@"%2d", playTimerMinutes] substringFromIndex:1];
    timerSecondsLabel.text = [[NSString stringWithFormat:@"%2d", playTimerSeconds] substringFromIndex:1];
}

- (IBAction)delete:(id)sender {
    if (asset.objectID != nil) {
        AssetDAO *dao = [AssetDAO new];

        [dao delete:[asset objectID]];
    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)resetMemoView {
    asset = [Asset new];

    btn_play.enabled = NO;
    btn_record.enabled = YES;
    btn_save.enabled = NO;
    btn_delete.enabled = NO;

    recordingExists = false;

    //memo.fileUrl = [[[IdentityGenerator generate] substringToIndex:8] stringByAppendingString:@".caf"];
    asset.fileUrl = [[NSString alloc] initWithString:@"TemporaryMemoFile.caf"];

    NSString *tempDir = NSTemporaryDirectory();
    NSString *soundFilePath = [tempDir stringByAppendingString:asset.fileUrl];
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    self.soundFileURL = newURL;
    self.soundFileString = soundFilePath;

    timerMinutesLabel.text = @"00";
    timerSecondsLabel.text = @"00";

    recTimerMinutes = 100;
    recTimerSeconds = 100;
}

- (IBAction)save:(id)sender {
    if (!recordingExists) {
        [AlertUtilities showOkAlert:NSLocalizedString(@"You must record a message before saving the memo", nil)];
        return;
    }

    AssetDAO *dao = [AssetDAO new];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent:(NSString *) asset.fileUrl];
    NSDictionary *fileAttrs = [fileManager attributesOfItemAtPath:recordFile error:nil];
    Study *study = [OpenPATHContext sharedOpenPATHContext].activeStudy;

    recTimerMinutes = recTimerMinutes - 100;
    recTimerSeconds = recTimerSeconds - 100;

    asset.fileSize = [[NSNumber numberWithInt:[fileAttrs fileSize]] stringValue];
    asset.timeLength = [[NSString alloc] initWithFormat:@"%i:%i", recTimerMinutes, recTimerSeconds];

    if (asset.objectID == nil) {
        //  This is a new object.
        [asset allocateObjectId];
        asset.assetID = NSLocalizedString(@"Audio Memo", nil);
        asset.relatedID = albumName;
        asset.originator = study.studyPrimaryResearcher;
        asset.location = study.organizationID;
        asset.assetType = AssetTypeAudio;

        if ([StringUtils isNotEmpty:patientNum]) {
            asset.patientID = patientNum;
        }

        [dao insert:asset];
    } else {
        [dao update:asset];
    }

    //  We create a corresponding diary event so the physician knows there's an available audio memo when viewing the events.
    ActivityDAO *activityDao = [ActivityDAO new];
    Activity *event = [Activity new];

    event.objectID = asset.objectID;
    event.code = @"AudioMemo";
    event.reason = @"Patient Event";
    event.relatedID = albumName;
    event.value = asset.timeLength;

    [activityDao insert:event];

    if (autoMemo)
        [[self navigationController] popViewControllerAnimated:YES];
    else
        [self resetMemoView];


    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)playRecordRequest {
    NSError *err;
    NSString *memoRecordPath = [[self frameworkBundle] pathForResource:@"RecordYourMemo" ofType:@"m4a"];
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath:memoRecordPath];

    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:&err];

    self.autoMemoPlayer = newPlayer;

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);

    self.autoMemoPlayer.numberOfLoops = 0;
    self.autoMemoPlayer.delegate = self;
    [self.autoMemoPlayer setVolume:1.0];
    [self.autoMemoPlayer prepareToPlay];
    [self.autoMemoPlayer play];
}


- (IBAction)play:(id)sender {
    if (audioPlayer && audioPlayer.playing) {
        [audioPlayer stop];
        self.audioPlayer = nil;

        btn_play.enabled = YES;
        btn_record.enabled = YES;

        if (recordingExists)
            btn_save.enabled = YES;
        else
            btn_save.enabled = NO;

        if (asset.objectID == nil)
            btn_delete.enabled = NO;
        else
            btn_delete.enabled = YES;

        [btn_play setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];

        [self releaseTimer];
    } else {
        NSError *err;

        //AVAudioPlayer* newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:&err];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:asset.data error:&err];

        self.audioPlayer = newPlayer;

        audioPlayer.numberOfLoops = 0;
        audioPlayer.delegate = self;
        [audioPlayer setVolume:1.0];
        [audioPlayer prepareToPlay];
        [audioPlayer play];

        [btn_play setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];

        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlayTimerLabel:) userInfo:nil repeats:YES];

        timerMinutesLabel.text = @"00";
        timerSecondsLabel.text = @"00";

        playTimerMinutes = 100;
        playTimerSeconds = 100;

        btn_play.enabled = YES;
        btn_record.enabled = NO;
        btn_save.enabled = NO;
        btn_delete.enabled = NO;

        playing = YES;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)completed {
    //  If doing an auto memo, we must first wait till the "record your memo" introduction recording is done.
    //  That is why we kick off the recording thread here.
    if (autoMemo && (player == self.autoMemoPlayer)) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecTimerLabel:) userInfo:nil repeats:YES];
        [NSThread detachNewThreadSelector:@selector(startRecordMemo:) toTarget:self withObject:nil];
        return;
    }

    if (completed == YES) {
        [audioPlayer stop];
        self.audioPlayer = nil;

        [btn_play setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];

        btn_play.enabled = YES;
        btn_record.enabled = YES;

        if (recordingExists)
            btn_save.enabled = YES;
        else
            btn_save.enabled = NO;

        if (asset.objectID == nil)
            btn_delete.enabled = NO;
        else
            btn_delete.enabled = YES;

        [self releaseTimer];
    }
}

- (IBAction)record:(id)sender {
    if (audioRecorder && audioRecorder.recording) {
        [audioRecorder stop];
        self.audioRecorder = nil;

        btn_play.enabled = YES;
        btn_record.enabled = YES;
        btn_save.enabled = YES;

        if (asset.objectID == nil)
            btn_delete.enabled = NO;
        else
            btn_delete.enabled = YES;

        [btn_record setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];

        asset.data = [NSData dataWithContentsOfURL:self.soundFileURL];

        [self releaseTimer];
    } else {
        NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey, nil];

        NSError *err;

        AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:&err];

        self.audioRecorder = newRecorder;

        audioRecorder.delegate = self;
        [audioRecorder prepareToRecord];
        [audioRecorder record];

        [btn_record setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];

        btn_play.enabled = NO;

        if (autoMemo)
            btn_record.enabled = NO;
        else
            btn_record.enabled = YES;

        btn_save.enabled = NO;
        btn_delete.enabled = NO;

        recordingExists = YES;

        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecTimerLabel:) userInfo:nil repeats:YES];

        timerMinutesLabel.text = @"00";
        timerSecondsLabel.text = @"00";

        recTimerMinutes = 100;
        recTimerSeconds = 100;
    }
}

- (void)setSpeaker:(id)sender {
    if (speakerOn) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        speakerOn = false;
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    } else {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        speakerOn = true;
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Audio Note";

    // Close any existing session
    [[AVAudioSession sharedInstance] setActive:NO error:nil];

    // Reset the speaker
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    speakerOn = false;
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;

    [btn_record setBackgroundImage:[UIImage imageNamed:@"WOSRender.bundle/StopStudy.png"] forState:UIControlStateDisabled];
    [btn_play setBackgroundImage:[UIImage imageNamed:@"WOSRender.bundle/StartStudy.png"] forState:UIControlStateDisabled];

    [btn_record setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];
    [btn_play setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];

    if (asset != nil) {
        btn_play.enabled = YES;
        btn_record.enabled = YES;
        btn_save.enabled = NO;
        btn_delete.enabled = YES;

        recordingExists = true;

        // Set the timer to the correct values
        NSArray *timerComponents = [asset.timeLength componentsSeparatedByString:@":"];
        NSInteger timerMinutes = [[timerComponents objectAtIndex:0] intValue] + 100;
        NSInteger timerSeconds = [[timerComponents objectAtIndex:1] intValue] + 100;

        timerMinutesLabel.text = [[NSString stringWithFormat:@"%2d", timerMinutes] substringFromIndex:1];
        timerSecondsLabel.text = [[NSString stringWithFormat:@"%2d", timerSeconds] substringFromIndex:1];

        recTimerMinutes = timerMinutes;
        recTimerSeconds = timerSeconds;

        NSString *tempDir = NSTemporaryDirectory();
        NSString *soundFilePath = [tempDir stringByAppendingString:asset.fileUrl];
        NSURL *newURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];

        self.soundFileURL = newURL;
        self.soundFileString = soundFilePath;
    } else {
        [self resetMemoView];
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    audioSession.delegate = self;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

    recording = NO;
    playing = NO;
    speakerOn = NO;

    UIBarButtonItem *speakerButton = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Speaker", nil) style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(setSpeaker:)];

    self.navigationItem.rightBarButtonItem = speakerButton;
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicAudioBackgroundView.png"]];

    // Auto memos start recording immediately.
    /*
      if (autoMemo) {
          btn_play.enabled     = NO;
          btn_record.enabled   = NO;
          btn_save.enabled     = NO;
          btn_delete.enabled   = NO;

          [NSThread detachNewThreadSelector:@selector(startAutoMemo:) toTarget:self withObject:nil];
      }

      if (![[SessionManager sharedSessionManager] isActiveSession]) {
          btn_play.enabled     = NO;
          btn_record.enabled   = NO;
          btn_save.enabled     = NO;
          btn_delete.enabled   = NO;
      }
       */
}

//
//  First part of the auto memo.  We need to play the introductory "please record your memo".  Then the next task is once that
//  recording is complete, to start the recording.  That task is handled by the "playing finished" routine.
//
- (void)startAutoMemo:(id)sender {
    [self playRecordRequest];
}

//
//  This is the routine that is run in a detached thread to do the actual recording of an auto memo.
//
- (void)startRecordMemo:(id)sender {
    [self record:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// Return YES for supported orientations
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
