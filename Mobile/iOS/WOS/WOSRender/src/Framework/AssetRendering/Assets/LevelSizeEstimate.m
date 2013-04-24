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

#import "LevelSizeEstimate.h"
#import "WSAssetContext.h"
#import "MediaViewController.h"
#import "UIDevice+Resolutions.h"

@implementation LevelSizeEstimate

@synthesize pictScale = pictScale_;
@synthesize pictReScale = pictReScale_;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.pictReScale = 1;
        self.pictScale = 1;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *) [[event touchesForView:self] anyObject];

    if (originTouch_.x == 0) {
        originTouch_ = [touch locationInView:self];
    } else if (destTouch_.x == 0) {
        destTouch_ = [touch locationInView:self];
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // required to force a refresh so that the distance displays in the response text field.
    [self drawRect:CGRectMake(0, 0, 360, 480)];
}

- (void)clearSegment {
    originTouch_.x = 0;
    originTouch_.y = 0;
    destTouch_.x = 0;
    destTouch_.y = 0;

    MediaViewController *controller = [WSAssetContext sharedAssetContext].mediaView;

    [controller respTextField].text = @"";

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, 360, 480));

    if (originTouch_.x != 0) {
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextSetLineWidth(context, 6.0);
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextAddEllipseInRect(context, CGRectMake((originTouch_.x - 3), (originTouch_.y - 3), 6, 6));
        CGContextStrokePath(context);
    }

    if (destTouch_.x != 0) {
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextSetLineWidth(context, 6.0);
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextAddEllipseInRect(context, CGRectMake((destTouch_.x - 3), (destTouch_.y - 3), 6, 6));
        CGContextStrokePath(context);
    }

    if ((originTouch_.x != 0) && (destTouch_.x != 0)) {
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextSetLineWidth(context, 4.0);

        CGContextMoveToPoint(context, originTouch_.x, originTouch_.y);
        CGContextAddLineToPoint(context, destTouch_.x, destTouch_.y);
        CGContextStrokePath(context);

        MediaViewController *controller = [WSAssetContext sharedAssetContext].mediaView;

        double distance = sqrt(pow((originTouch_.x - destTouch_.x), 2.0) + pow((originTouch_.y - destTouch_.y), 2.0));

        //CGFloat distance = distanceBetweenPoints(originTouch_, destTouch_);

        CGFloat phoneScale = 0.0;

        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                ([UIScreen mainScreen].scale == 2.0)) {
            phoneScale = 2.0;
        } else {
            phoneScale = 1.0;
        }
		
		int    valueDevice = [[UIDevice currentDevice] resolution];
		double distanceMM = 0;
		
		// iPhone 4   = .0779 mm per pixel  (311)
		// < iPhone 4 = 0.1558282 mm per pixel
		// size of reference object is 24.26 mm
		
		if (valueDevice == UIDeviceResolution_iPhoneStandard) {            // iPhone 1,3,3GS Standard Display  (320x480px)
			distanceMM = (distance * (.1558282 / phoneScale)) * (pictScale_ / pictReScale_);
		} else if (valueDevice == UIDeviceResolution_iPhoneRetina4) {      // iPhone 4,4S Retina Display 3.5"  (640x960px)
			distanceMM = (distance * (.3116564 / phoneScale)) * (pictScale_ / pictReScale_);
		} else if (valueDevice == UIDeviceResolution_iPhoneRetina5) {      // iPhone 5 Retina Display 4"       (640x1136px)
			distanceMM = (distance * (.3116564 / phoneScale)) * (pictScale_ / pictReScale_);
		}

        [controller respTextField].text = [[NSString alloc] initWithFormat:@"%f   MM", distanceMM];
    }
}

@end
