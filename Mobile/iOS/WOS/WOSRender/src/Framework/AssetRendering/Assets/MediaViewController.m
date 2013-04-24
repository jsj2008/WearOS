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

#import "MediaViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "LevelQuarterView.h"
#import "LevelSizeEstimate.h"
#import "LevelBall.h"
#import "LevelView.h"
#import "WSAssetContext.h"

double angleBetweenPoints(CGPoint p1, CGPoint p2){
    return atan2(p2.y-p1.y,p2.x-p1.x);
}


double distanceBetweenPoints(CGPoint p1, CGPoint p2){
    return sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y));
}


@implementation MediaViewController

// Transform values for full screen support:
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.12412	//use this is for iOS 3.x
//#define CAMERA_TRANSFORM_Y 1.24299 // use this is for iOS 4.x

@synthesize doneBtn = doneBtn_;
@synthesize measureBtn = measureBtn_;
@synthesize imageView = imageView_;
@synthesize image;
@synthesize respTextField = respTextField_;
@synthesize patientNum = patientNum_;

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
    self = [super initWithNibName:@"MediaViewController" bundle:[self frameworkBundle]];
	
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)) {
	//	orientationOffset_ = 625;
	//} else {
	//	orientationOffset_ = 900;
	//}

	// Return YES for supported orientations
	return YES;
	//return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft); //UIInterfaceOrientationPortrait);
}

- (IBAction) clearSegment:(id)sender {
	if (levelSizeEstimate_ != nil)
		[levelSizeEstimate_ clearSegment];
}

- (IBAction)doneAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)saveMeasurement {
	ActivityDAO*		dao = [ActivityDAO new];
	
	Activity* activity = [Activity new];
		
	[activity allocateObjectId];
		
	activity.relatedID			= patientNum_;
	activity.type				= @"Clinical Eye Measurement";
	activity.code				= @"measurement";
	activity.reason				= @"exam";
	activity.archived			= false;	
	activity.originator			= [OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher;
	activity.location			= [OpenPATHContext sharedOpenPATHContext].activeStudy.organizationID;
		
	activity.value 				= respTextField_.text;
		
	[dao insert:activity];
}

- (IBAction)scaleAction:(id)sender {
	if (scaleMode_) {
		scaleMode_ = NO;
		
		double newViewWidth = imageView_.frame.size.width;
		
		levelSizeEstimate_.pictReScale = (newViewWidth / 320);		

		[self.view addSubview:levelSizeEstimate_];
		
		scaleButton_.title = @"Scale On";
		
		NSMutableArray *items = [navBar_.items mutableCopy];
		[items removeObject:spacerItemClear_];
		[items insertObject:clearButton_ atIndex:0];
		
		navBar_.items = items;
		
		[self.view bringSubviewToFront:toolbarView_];
		[self.view bringSubviewToFront:mainNavBar_];
	} else {
		scaleMode_ = YES;
		
		[self clearSegment:nil];
		
		scaleButton_.title = @"Scale Off";
		
		[levelSizeEstimate_ removeFromSuperview];
		
		imageView_.multipleTouchEnabled = TRUE;
		self.view.multipleTouchEnabled = YES;
		
		[self.view bringSubviewToFront:imageView_];
		
		NSMutableArray *items = [navBar_.items mutableCopy];
		[items removeObject:clearButton_];
		[items insertObject:spacerItemClear_ atIndex:0];
		
		navBar_.items = items;
		
		[self.view bringSubviewToFront:toolbarView_];
		[self.view bringSubviewToFront:mainNavBar_];
	}
}

- (IBAction)modeAction:(id)sender {
	if ([[modeButton_ title] caseInsensitiveCompare:@"MEASURE"] == 0) {
		levelQuarterView_	= [[LevelQuarterView alloc] initWithFrame: CGRectMake(0, 44, 320,480)];
		
		levelQuarterView_.multipleTouchEnabled = true;
		[levelQuarterView_ setNeedsDisplay];
		
		[self.view addSubview:levelQuarterView_];
				
		modeButton_.title = @"Calibrate";
	} else if ([[modeButton_ title] caseInsensitiveCompare:@"CALIBRATE"] == 0) {
		levelQuarterView_.hidden				= YES;
		levelQuarterView_.multipleTouchEnabled	= FALSE;
		modeButton_.title						= @"Save";
		
		// determine the scale
		double newViewWidth = imageView_.frame.size.width;
		
		toolbarView_.hidden = NO;
		
		levelSizeEstimate_ = [[LevelSizeEstimate alloc] initWithFrame:CGRectMake(0, 88, 320,416)];
		
		levelSizeEstimate_.pictScale = (newViewWidth / 320);		
		
		imageView_.image					= lastImage_;
		imageView_.multipleTouchEnabled		= TRUE;
		
		[self.view addSubview:levelSizeEstimate_];
	} else if ([[modeButton_ title] caseInsensitiveCompare:@"SAVE"] == 0) {
		[self saveMeasurement];
		
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	toolbarView_.hidden = YES;
	
	scaleMode_ = NO;
		
	[WSAssetContext sharedAssetContext].mediaView = self;
	
    // Do any additional setup after loading the view from its nib.
	
	imageView_.hidden					= NO;
	imageView_.multipleTouchEnabled		= true;
	imageView_.image					= image;
	
	switch (image.imageOrientation) {
		case UIImageOrientationRight:
			imageView_.image = image;
			break;
			
		case UIImageOrientationDown:
			imageView_.image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
			break;
			
		case UIImageOrientationUp:
			imageView_.image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
			break;
			
		case UIImageOrientationLeft:
			imageView_.image = image;
			break;
	}

	lastImage_ = imageView_.image; //image;
		
	spacerItemClear_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spacerItemClear_.width = 50;
	
	spacerItemScale_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spacerItemScale_.width = 50;
}

- (void) viewDidAppear:(BOOL)animated {
	[self.view bringSubviewToFront:toolbarView_];
	[self.view bringSubviewToFront:mainNavBar_];
	
	[super viewDidAppear:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	previousDistance_ = 0;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	if (([[modeButton_ title] caseInsensitiveCompare:@"CALIBRATE"] == 0) || (scaleMode_)) {
		if ([touches count] == 2) {
			NSArray*					firstTwoTouches	= [[event allTouches] allObjects];
			UITouch*					firstTouch			= [firstTwoTouches objectAtIndex:0];
			UITouch*					secondTouch		= [firstTwoTouches objectAtIndex:1];
			CGAffineTransform		transform1			= [self scaleFromTouch:firstTouch secondTouch:secondTouch];
			CGAffineTransform		transform2			= [self rotationFromTouch:firstTouch secondTouch:secondTouch];
			
			imageView_.transform            = CGAffineTransformConcat(imageView_.transform,transform1);
			imageView_.transform            = CGAffineTransformConcat(imageView_.transform,transform2);
			timeSinceLastDoubleTouch_     = 0;
			
			[self.view bringSubviewToFront:toolbarView_];
			[self.view bringSubviewToFront:mainNavBar_];
		} else {
			if (timeSinceLastDoubleTouch_ < 10) {
				// often times at the end of a rotate/scale gesture
				// one finger will lift before the other so ignore
				// that effect by waiting
				timeSinceLastDoubleTouch_++;
				return;
			}
			
			NSArray*				touches		= [[event allTouches] allObjects];
			UITouch*				firstTouch	= [touches objectAtIndex:0];
			CGPoint 					pt      		= [firstTouch locationInView:self.view];
			CGPoint 					pt2     		= [firstTouch previousLocationInView:self.view];
			double 					dx      		= pt.x - pt2.x;
			double 					dy      		= pt.y - pt2.y;
			CGAffineTransform 	transform	= CGAffineTransformMakeTranslation(dx, dy);
			
			imageView_.transform = CGAffineTransformConcat(imageView_.transform, transform);
			
			[self.view bringSubviewToFront:toolbarView_];
			[self.view bringSubviewToFront:mainNavBar_];
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	timeSinceLastDoubleTouch_ = 999;
}

- (CGAffineTransform) scaleFromTouch:(UITouch *)firstTouch secondTouch:(UITouch *) secondTouch {
	CGFloat currentDistance = distanceBetweenPoints([firstTouch locationInView:self.view], [secondTouch locationInView:self.view]);
	
	if (previousDistance_ == 0) {
		previousDistance_ = currentDistance;
	} 
	
	CGFloat				ratio		= (currentDistance-previousDistance_)/previousDistance_ +1.0;
	CGAffineTransform	transform	= CGAffineTransformMakeScale(ratio,ratio);
	
	//respTextField_.text = [[NSString alloc] initWithFormat:@"%f", ratio];
	
	previousDistance_ = currentDistance;
	
	[self.view bringSubviewToFront:toolbarView_];
	[self.view bringSubviewToFront:mainNavBar_];
	
	return transform;
}

-(CGAffineTransform) rotationFromTouch:(UITouch *)firstTouch secondTouch:(UITouch *)secondTouch {
	//	CGFloat		currentAngle		= angleBetweenPoints([firstTouch locationInView:self.view], [secondTouch locationInView:self.view]);
	//	CGFloat		lastAngle		= angleBetweenPoints([firstTouch previousLocationInView:self.view], [secondTouch previousLocationInView:self.view]);
	//	double		total				= (currentAngle-lastAngle);
	
	return CGAffineTransformMakeRotation(0.0);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return false;
}

- (void)dealloc {
}

@end
