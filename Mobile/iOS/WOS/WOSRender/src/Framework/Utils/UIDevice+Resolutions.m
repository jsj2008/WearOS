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
#import "UIDevice+Resolutions.h"

@implementation UIDevice (Resolutions)

- (UIDeviceResolution)resolution {
    UIDeviceResolution   resolution  = UIDeviceResolution_Unknown;
    UIScreen*            mainScreen  = [UIScreen mainScreen];
    CGFloat              scale       = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat              pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (scale == 2.0f) {
            if (pixelHeight == 960.0f) {
                resolution = UIDeviceResolution_iPhoneRetina4;
            } else if (pixelHeight == 1136.0f) {
                resolution = UIDeviceResolution_iPhoneRetina5;
			}
        } else if (scale == 1.0f && pixelHeight == 480.0f) {
            resolution = UIDeviceResolution_iPhoneStandard;
		}
    } else {
        if (scale == 2.0f && pixelHeight == 2048.0f) {
            resolution = UIDeviceResolution_iPadRetina;
        } else if (scale == 1.0f && pixelHeight == 1024.0f) {
            resolution = UIDeviceResolution_iPadStandard;
        }
    }
	
    return resolution;
}

// iPhone 1,3,3GS Standard Display  (320 x 480px)
// iPhone 4,4S Retina Display 3.5"  (640 x 960px)
// iPhone 5 Retina Display 4"       (640 x 1136px)
// iPad standard                    (768 x 1024)
// iPadRetina                       (1536 x 2048)


- (CGFloat)screenOrientationWidth {
	UIInterfaceOrientation   orientation = [self orientation];
	UIScreen*                mainScreen  = [UIScreen mainScreen];
	CGFloat                  scale       = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
	CGFloat                  pixelWidth  = CGRectGetWidth(mainScreen.bounds);
	CGFloat                  pixelHeight = CGRectGetHeight(mainScreen.bounds);
	
	if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown)) {
		return pixelWidth;
	} else {
		return pixelHeight;
	}
}

- (CGFloat)screenOrientationHeight {
	UIInterfaceOrientation   orientation = [self orientation];
	UIScreen*                mainScreen  = [UIScreen mainScreen];
	CGFloat                  scale       = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
	CGFloat                  pixelWidth  = CGRectGetWidth(mainScreen.bounds);
	CGFloat                  pixelHeight = CGRectGetHeight(mainScreen.bounds);
	
	if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown)) {
		return pixelHeight;
	} else {
		return pixelWidth;
	}
}

@end