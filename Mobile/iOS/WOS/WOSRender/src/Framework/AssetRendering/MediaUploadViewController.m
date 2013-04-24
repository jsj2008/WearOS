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

#import "MediaUploadViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLHeading.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "AlertUtilities.h"
#import "MediaSendDataManager.h"
#import <QuartzCore/QuartzCore.h>


@implementation MediaUploadViewController

@synthesize submitBtn;
@synthesize statusView;
@synthesize dataManager;

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
    self = [super initWithNibName:@"MediaUploadViewController" bundle:[self frameworkBundle]];
	
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

- (void)notificationHandler:(NSNotification *)notification {
	NSString* message = (NSString*)notification.object;
	
	if ([message isEqualToString:@"START UPLOAD"]) {
		[statusMessages setString:@""];
		dispatch_async(dispatch_get_main_queue(), ^{ self.statusView.text = @""; });		
	} else {
		[statusMessages appendString:(NSString*)notification.object];
		dispatch_async(dispatch_get_main_queue(), ^{ self.statusView.text = statusMessages; });
		dispatch_async(dispatch_get_main_queue(), ^{ [self.statusView scrollRangeToVisible:NSMakeRange([self.statusView.text length], 0)]; });
	}
}

- (IBAction)submitAction:(id)sender {
	[NSThread detachNewThreadSelector:@selector(sendData:) toTarget:dataManager withObject:nil];
}

- (IBAction)submitCSVAction:(id)sender {
	[NSThread detachNewThreadSelector:@selector(sendCSVData:) toTarget:dataManager withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"carePATHUploadStatus" object:nil];	
	
	statusMessages = [[NSMutableString alloc] initWithCapacity:100];
	
	[[statusView layer] setBorderColor:[[UIColor blueColor] CGColor]];
	[[statusView layer] setBorderWidth:1.0];
	[[statusView layer] setCornerRadius:15];
	[statusView setClipsToBounds: YES];
	
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
