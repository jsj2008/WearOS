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

#import <Foundation/Foundation.h>

@interface WSStyle : NSObject {
@private
	NSString*	            type_;
	UIColor* 	            subTextColor_;
	float	                subFontSize_;
	NSString*	            subFontFamily_;
	UIColor* 	            textColor_;
	UIColor* 	            labelTextColor_;
	float	                fontSize_;
	NSString*	            fontFamily_;
	NSString*               background_;
	NSString*               tableCellBackgroundImage_;
	NSString*               tableCellBackgroundSelectedImage_;
	UIColor*                tableCellBackgroundColor_;
	UIColor*                tableSeparatorColor_;
	NSString*               buttonBackgroundSelectedImage_;
	UIColor*                headerTextColor_;
	float                   headerFontSize_;
	NSString*               headerFontFamily_;
    NSMutableDictionary*    resources_;
}

@property (nonatomic, copy) NSString* type;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIColor* labelTextColor;
@property (nonatomic, retain) UIColor* subTextColor;
@property (nonatomic, retain) UIColor* headerTextColor;
@property (nonatomic)float fontSize;
@property (nonatomic)float subFontSize;
@property (nonatomic)float headerFontSize;
@property (nonatomic, copy) NSString* fontFamily;
@property (nonatomic, copy) NSString* subFontFamily;
@property (nonatomic, copy) NSString* headerFontFamily;
@property (nonatomic, copy) NSString* background;
@property (nonatomic, copy) NSString* tableCellBackgroundImage;
@property (nonatomic, copy) NSString* tableCellBackgroundSelectedImage;
@property (nonatomic, retain) UIColor* tableCellBackgroundColor;
@property (nonatomic, retain) UIColor* tableSeparatorColor;
@property (nonatomic, retain) NSString* buttonBackgroundSelectedImage;

- (UIFont*)fontFromStyle;
- (UIFont*)headerFontFromStyle;
- (UIFont*)subFontFromStyle;
- (void)addResource:(NSString*)resource forKey:(NSURL*)key;
- (NSString*)resourceForKey:(NSURL*)key;

@end
