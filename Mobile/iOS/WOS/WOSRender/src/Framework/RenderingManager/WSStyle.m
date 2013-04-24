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

#import "WSStyle.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSStyle

@synthesize type = type_;
@synthesize textColor = textColor_;
@synthesize labelTextColor = labelTextColor_;
@synthesize headerTextColor = headerTextColor_;
@synthesize fontSize = fontSize_;
@synthesize headerFontSize = headerFontSize_;
@synthesize fontFamily = fontFamily_;
@synthesize headerFontFamily = headerFontFamily_;
@synthesize background = background_;
@synthesize subTextColor = subTextColor_;
@synthesize subFontSize = subFontSize_;
@synthesize subFontFamily = subFontFamily_;
@synthesize tableCellBackgroundImage = tableCellBackgroundImage_;
@synthesize tableCellBackgroundSelectedImage = tableCellBackgroundSelectedImage_;
@synthesize tableCellBackgroundColor = tableCellBackgroundColor_;
@synthesize tableSeparatorColor = tableSeparatorColor_;
@synthesize buttonBackgroundSelectedImage = buttonBackgroundSelectedImage_;


- (UIFont*)fontFromStyle {
    return [UIFont fontWithName:fontFamily_ size:fontSize_];
}

- (UIFont*)headerFontFromStyle {
    return [UIFont fontWithName:headerFontFamily_ size:headerFontSize_];
}

- (UIFont*)subFontFromStyle {
    return [UIFont fontWithName:subFontFamily_ size:subFontSize_];
}

- (void)addResource:(NSString*)resource forKey:(NSURL*)key {
    if ([StringUtils isEmpty:resource] || (key == nil)) {
        return;
    }

    if (resources_ == nil) {
        resources_ = [[NSMutableDictionary alloc] initWithCapacity:20];
    }

    [resources_ setObject:resource forKey:key];
}

- (NSString*)resourceForKey:(NSURL*)key {
    if (resources_ == nil)
        return nil;

    return [resources_ objectForKey:key];
}

@end
