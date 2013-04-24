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

#import "SettingsParticipantIDViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSRenderingEngine.h"
#import "WSStyle.h"


@interface SettingsParticipantIDViewController ()

@end

@implementation SettingsParticipantIDViewController

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

- (id)init {
    self = [super initWithNibName:@"SettingsParticipantIDViewController" bundle:[self frameworkBundle]];
	
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

- (IBAction)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
	[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum = participantIdTextField_.text;
	
	PatientDAO* dao = [PatientDAO new];
	
	[dao update:[OpenPATHContext sharedOpenPATHContext].activePatient];
	
	if ([[OpenPATHContext sharedOpenPATHContext].dataDistributionManager isLoggedIn]) {
		NSError*  error;
	
		NSString* participantId   = [[OpenPATHContext sharedOpenPATHContext].dataDistributionManager retrieveParticipantIdForParticipant:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum withOptions:WSChannelOptionNone didFailWithError:&error];
		NSString* participantName = [[OpenPATHContext sharedOpenPATHContext].dataDistributionManager retrieveParticipantNameForParticipant:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum withOptions:WSChannelOptionNone didFailWithError:&error];
		
		if ([StringUtils isNotEmpty:participantId]) {
			PatientDAO*  dao = [PatientDAO new];
			
			[OpenPATHContext sharedOpenPATHContext].activePatient.deviceToken = participantId;
			[OpenPATHContext sharedOpenPATHContext].activePatient.firstName   = participantName;
			
			// This tells us that the patient num has been changed.
			[OpenPATHContext sharedOpenPATHContext].activePatient.visit1 = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
			
			[dao update:[OpenPATHContext sharedOpenPATHContext].activePatient];
		}
	}
	
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	if ([StringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum]) {
		participantIdTextField_.text = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
	}
	
	[self navigationController].navigationBar.hidden = YES;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	participantIdLabel_.font      = [style_ headerFontFromStyle];
	participantIdLabel_.textColor = [style_ headerTextColor];
	backgroundImageView_.image    = [UIImage imageWithData:[Base64 decode:style_.background]];
	
	[participantIdTextField_ becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
