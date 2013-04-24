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

#import "SettingsCoachViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@interface SettingsCoachViewController ()

@end

@implementation SettingsCoachViewController

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
    self = [super initWithNibName:@"SettingsCoachViewController" bundle:[self frameworkBundle]];
	
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

- (IBAction)welcomeCoachAction:(id)sender {
	welcomeCoach_.selected = !welcomeCoach_.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	if ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1 != nil) {
		[buttonCoachPhoto01_ setBackgroundImage:[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1] forState:UIControlStateNormal];
	}
	
	if ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2 != nil) {
		[buttonCoachPhoto02_ setBackgroundImage:[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2] forState:UIControlStateNormal];
	}
	
	if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachPhoto1"]) {
		buttonCoachPhoto01_.selected           = true;
		buttonCoachPhoto01Background_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachPhoto2"]) {
		buttonCoachPhoto02_.selected           = true;
		buttonCoachPhoto02Background_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachFemale01.jpg"]) {
		 buttonCoachFemale01_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachFemale02.jpg"]) {
		buttonCoachFemale02_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachFemale03.jpg"]) {
		buttonCoachFemale03_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachFemale04.jpg"]) {
		buttonCoachFemale04_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachFemale05.jpg"]) {
		buttonCoachFemale05_.selected = true;
	} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachMale01.jpg"]) {
		buttonCoachMale01_.selected = true;
	} else {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale01.jpg";
	}
	
	imagePickerController_                    = [[UIImagePickerController alloc] init];
	imagePickerController_.allowsImageEditing = YES;
	imagePickerController_.delegate           = self;
	imagePickerController_.sourceType         = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[scrollView_ addSubview:contentView_];
    scrollView_.contentSize = contentView_.bounds.size;
	
	welcomeCoach_.selected = [OpenPATHContext sharedOpenPATHContext].activePatient.welcomeCoach;

	[self navigationController].navigationBar.hidden = YES;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
}

- (IBAction)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
	if (buttonCoachPhoto01_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachPhoto1";
	} else if (buttonCoachPhoto02_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachPhoto2";
	} else if (buttonCoachFemale01_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale01.jpg";
	} else if (buttonCoachFemale02_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale02.jpg";
	} else if (buttonCoachFemale03_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale03.jpg";
	} else if (buttonCoachFemale04_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale04.jpg";
	} else if (buttonCoachFemale05_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale05.jpg";
	} else if (buttonCoachMale01_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachMale01.jpg";
	} else {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath = @"CoachFemale01.jpg";
	}
	
	[OpenPATHContext sharedOpenPATHContext].activePatient.welcomeCoach = welcomeCoach_.selected;
	
	PatientDAO* dao = [PatientDAO new];
	
	[dao update:[OpenPATHContext sharedOpenPATHContext].activePatient];

	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	if (buttonCoachPhoto01_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1 = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
  	
		if ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1 != nil) {
			[buttonCoachPhoto01_ setBackgroundImage:[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1] forState:UIControlStateNormal];
		}
	}
	
	if (buttonCoachPhoto02_.selected) {
		[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2 = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
	
		if ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2 != nil) {
			[buttonCoachPhoto02_ setBackgroundImage:[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2] forState:UIControlStateNormal];
		}
	}
	
	PatientDAO* dao = [PatientDAO new];
	
	[dao update:[OpenPATHContext sharedOpenPATHContext].activePatient];
	
	[picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectedCoachAction:(id)sender {
	if (sender == buttonCoachPhoto01_) {
		buttonCoachPhoto01_.selected           = true;
		buttonCoachPhoto01Background_.selected = true;
		[self presentModalViewController:imagePickerController_ animated:YES];
	} else {
		buttonCoachPhoto01_.selected           = false;
		buttonCoachPhoto01Background_.selected = false;
	}
	
	if (sender == buttonCoachPhoto02_) {
		buttonCoachPhoto02_.selected           = true;
		buttonCoachPhoto02Background_.selected = true;
		[self presentModalViewController:imagePickerController_ animated:YES];
	} else {
		buttonCoachPhoto02_.selected           = false;
		buttonCoachPhoto02Background_.selected = false;
	}
	
	buttonCoachFemale01_.selected = (sender == buttonCoachFemale01_);
	buttonCoachFemale02_.selected = (sender == buttonCoachFemale02_);
	buttonCoachFemale03_.selected = (sender == buttonCoachFemale03_);
	buttonCoachFemale04_.selected = (sender == buttonCoachFemale04_);
	buttonCoachFemale05_.selected = (sender == buttonCoachFemale05_);
	buttonCoachMale01_.selected   = (sender == buttonCoachMale01_);
}

@end
