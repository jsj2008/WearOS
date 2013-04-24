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

#import "TextMsgViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WOSCore/OpenPATHCore.h"
#import "WOSEngine/OpenPATHEngine.h"
#import "WSRenderingEngine.h"
#import "WSStyle.h"

@implementation TextMsgViewController

@synthesize dataDistributionManager = dataDistributionManager_;
@synthesize groupName = groupName_;
@synthesize groupDescription = groupDescription_;

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
    self = [super initWithNibName:@"TextMsgViewController" bundle:[self frameworkBundle]];
	
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

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	sendProgressView_.hidden = YES;
	[progressTimer_ invalidate];
	progressTimer_ = nil;
	textMessageView_.text = @"";
}

- (void)notificationHandler:(NSNotification *)notification {
	[self cancelAction:nil];
}

- (void)onTimer {
	if ([sendProgressView_ progress] == 0.8) {
		return;
	}
	
	[sendProgressView_ setProgress:([sendProgressView_ progress] + .2)];
}


-(IBAction)cancelAction:(id)sender {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self.navigationController popViewControllerAnimated:true];	
}

- (void) sendChatterData:(NSString*)phoneData {
	NSError* error;
	NSData*  returnData = [dataDistributionManager_ sendText:phoneData toGroup:groupName_ WithOptions:WSChannelOptionNone  didFailWithError:&error];
		
	if (returnData != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"optionsSendChatterStatus" object:@"SEND OK"];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"optionsSendChatterStatus" object:@"SEND ERROR"];
	}
}

-(IBAction)sendAction:(id)sender {
	if ([StringUtils isEmpty:textMessageView_.text]) {
		[self cancelAction:nil];
		return;
	}
		
	NSMutableString*  message = [[NSMutableString alloc] initWithString:@"{ \"body\" : { \"messageSegments\" : [ { \"type\" : \"Text\", \"text\" : \""];
	
	[message appendFormat:@"From: %@: ", [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum];
	[message appendString:[textMessageView_.text stringByEncodingJSON]];
	[message appendFormat:@"\" } ] }}"];
		
	//progressTimer_ = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
	
	//[textMessageView_ resignFirstResponder];

	//[sendProgressView_ setProgress:0.0];
	//sendProgressView_.hidden = NO;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self sendChatterData:message];
	});
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[[textMessageView_ layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
	[[textMessageView_ layer] setBorderWidth:1.0];
	[[textMessageView_ layer] setCornerRadius:15];
	[textMessageView_ setClipsToBounds: YES];
	
	[textMessageView_ becomeFirstResponder];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
		
	backgroundView_.image   = [UIImage imageWithData:[Base64 decode:style_.background]];
	messageTitleLabel_.font = [style_ headerFontFromStyle];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"optionsSendChatterStatus" object:nil];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
