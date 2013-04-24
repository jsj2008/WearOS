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

#import "LevelQuarterView.h"
#import "UIDevice+Resolutions.h"

@implementation LevelQuarterView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
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

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 3.0);

	int valueDevice = [[UIDevice currentDevice] resolution];
	
	if (valueDevice == UIDeviceResolution_iPhoneStandard) {            // iPhone 1,3,3GS Standard Display  (320x480px)
		CGContextClearRect(context, CGRectMake(0, 0, 320, 480));
		CGContextAddEllipseInRect(context, CGRectMake(82, 118, 155, 155));
	} else if (valueDevice == UIDeviceResolution_iPhoneRetina4) {      // iPhone 4,4S Retina Display 3.5"  (640x960px)
		CGContextClearRect(context, CGRectMake(0, 0, 640, 960));
		CGContextAddEllipseInRect(context, CGRectMake(82, 118, 155, 155));
	} else if (valueDevice == UIDeviceResolution_iPhoneRetina5) {      // iPhone 5 Retina Display 4"       (640x1136px)
		CGContextClearRect(context, CGRectMake(0, 0, 640, 1136));
		CGContextAddEllipseInRect(context, CGRectMake(82, 162, 155, 155));
	}

    // iPhone 4   = .0779 mm per pixel  (311)
    // < iPhone 4 = 0.1558282 mm per pixel
    // size of reference object is 24.26 mm

    CGContextStrokePath(context);
}

@end
