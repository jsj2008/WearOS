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

#import "SettingsPasscodeViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>

@implementation SettingsPasscodeViewController


@synthesize animationView;
@synthesize titleLabel;
@synthesize instructionLabel;
@synthesize bulletField0;
@synthesize bulletField1;
@synthesize bulletField2;
@synthesize bulletField3;

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
    self = [super initWithNibName:@"SettingsPasscodeViewController" bundle:[self frameworkBundle]];
	
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

- (void)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)saveAction:(id)sender {
	[OpenPATHContext sharedOpenPATHContext].activeSecurity.password = passcode_;
	
	SecurityDAO* dao = [SecurityDAO new];
	
	[dao update:[OpenPATHContext sharedOpenPATHContext].activeSecurity];
	
	if ([StringUtils isEmpty:passcode_]) {
		[OpenPATHContext sharedOpenPATHContext].activeFeatures.hasAuthentication = false;
	} else {
		[OpenPATHContext sharedOpenPATHContext].activeFeatures.hasAuthentication = true;
	}
	
	[[OpenPATHContext sharedOpenPATHContext] saveActiveFeatures];
	
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
			
	if ([StringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeSecurity.password]) {
		passcodeTextField_.text = [OpenPATHContext sharedOpenPATHContext].activeSecurity.password;
	}
	
	passOne_ = false;
	
	[self navigationController].navigationBar.hidden = YES;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	passcodeLabel_.font           = [style_ headerFontFromStyle];
	passcodeLabel_.textColor      = [style_ headerTextColor];
	backgroundImageView_.image    = [UIImage imageWithData:[Base64 decode:style_.background]];
		
	//[passcodeTextField_ becomeFirstResponder];
	
	instructionLabel.text = @"Setting a passcode will enable authentication. To turn off authentication, press the SAVE button now.";
	
	fakeField = [[UITextField alloc] initWithFrame:CGRectZero];
    fakeField.delegate = self;
    fakeField.keyboardType = UIKeyboardTypeNumberPad;
    fakeField.secureTextEntry = YES;
    fakeField.text = @"";
    [fakeField becomeFirstResponder];
    [self.view addSubview:fakeField];
	
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    fakeField = nil;
	
    self.animationView = nil;
	
    self.titleLabel = nil;
    self.instructionLabel = nil;
	
    self.bulletField0 = nil;
    self.bulletField1 = nil;
    self.bulletField2 = nil;
    self.bulletField3 = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)internalResetWithAnimation:(NSNumber *)animationStyleNumber {
    KVPasscodeAnimationStyle animationStyle = [animationStyleNumber intValue];
	
    switch (animationStyle) {
        case KVPasscodeAnimationStyleInvalid:
        {
            // Vibrate to indicate error
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
			
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
            [animation setDuration:0.025];
            [animation setRepeatCount:8];
            [animation setAutoreverses:YES];
            [animation setFromValue:[NSValue valueWithCGPoint:
									 CGPointMake([animationView center].x - 14.0f, [animationView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
								   CGPointMake([animationView center].x + 14.0f, [animationView center].y)]];
            [[animationView layer] addAnimation:animation forKey:@"position"];
        }
            break;
        case KVPasscodeAnimationStyleConfirm:
        {
            // This will cause the 'new' fields to appear without bullets already in them
            self.bulletField0.text = nil;
            self.bulletField1.text = nil;
            self.bulletField2.text = nil;
            self.bulletField3.text = nil;
			
            CATransition *transition = [CATransition animation];
            [transition setDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
            [transition setType:kCATransitionPush];
            [transition setSubtype:kCATransitionFromRight];
            [transition setDuration:0.5f];
            [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            [[animationView layer] addAnimation:transition forKey:@"swipe"];
        }
            break;
        case KVPasscodeAnimationStyleNone:
        default:
            self.bulletField0.text = nil;
            self.bulletField1.text = nil;
            self.bulletField2.text = nil;
            self.bulletField3.text = nil;
			
            fakeField.text = @"";
            break;
    }
}

- (void)resetWithAnimation:(KVPasscodeAnimationStyle)animationStyle {
    // Do the animation a little later (for better animation) as it's likely this method is called in our delegate method
    [self performSelector:@selector(internalResetWithAnimation:) withObject:[NSNumber numberWithInt:animationStyle] afterDelay:0];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.bulletField0.text = nil;
    self.bulletField1.text = nil;
    self.bulletField2.text = nil;
    self.bulletField3.text = nil;
	
    fakeField.text = @"";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *passcode = [textField text];
    passcode = [passcode stringByReplacingCharactersInRange:range withString:string];
	
    switch ([passcode length]) {
        case 0:
            self.bulletField0.text = nil;
            self.bulletField1.text = nil;
            self.bulletField2.text = nil;
            self.bulletField3.text = nil;
			
            break;
        case 1:
            self.bulletField0.text = @"*";
            self.bulletField1.text = nil;
            self.bulletField2.text = nil;
            self.bulletField3.text = nil;
			
			instructionLabel.text = @"";
			
            break;
        case 2:
            self.bulletField0.text = @"*";
            self.bulletField1.text = @"*";
            self.bulletField2.text = nil;
            self.bulletField3.text = nil;
            break;
        case 3:
            self.bulletField0.text = @"*";
            self.bulletField1.text = @"*";
            self.bulletField2.text = @"*";
            self.bulletField3.text = nil;
            break;
        case 4:
            self.bulletField0.text = @"*";
            self.bulletField1.text = @"*";
            self.bulletField2.text = @"*";
            self.bulletField3.text = @"*";
			
			if (passOne_) {
			    if ([passcode_ isEqualToString:passcode]) {
					[self saveAction:nil];
				} else {
					instructionLabel.text = @"Passcodes did not match.  Please try again.";
					passcode_             = @"";
					passOne_              = false;
					
					[self performSelector:@selector(internalResetWithAnimation:) withObject:[NSNumber numberWithInt:KVPasscodeAnimationStyleInvalid] afterDelay:0];
				}
			} else {
		 		passcode_      = passcode;
				passOne_       = true;
				fakeField.text = @"";
				
				instructionLabel.text = @"Please enter passcode again.";
				
				self.bulletField0.text = nil;
				self.bulletField1.text = nil;
				self.bulletField2.text = nil;
				self.bulletField3.text = nil;
			}
			
            return NO;
			
            break;
        default:
            break;
    }
	
    return YES;
}

@end
