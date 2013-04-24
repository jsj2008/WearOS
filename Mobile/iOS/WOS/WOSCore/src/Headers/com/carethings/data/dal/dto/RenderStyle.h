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

#import "ResdbObject.h"

@interface RenderStyle : ResdbObject {
    NSString*   textColor;
    NSString*   textFontSize;
    NSString*   textFontFamily;
    NSString*   questionColor;
    NSString*   questionFontSize;
    NSString*   questionFontFamily;
    NSString*   headerColor;
    NSString*   headerFontSize;
    NSString*   headerFontFamily;
    NSString*   choiceTextColor;
    NSString*   choiceFontSize;
    NSString*   choiceFontFamily;
    NSString*   responseBorderColor;
    NSString*   backgroundColor;
    NSString*   separatorColor;
    NSString*   nextButtonText;
    NSString*   previousButtonText;
    NSString*   homeButtonText;
    NSString*   theme;
    NSString*   version;
}

@property (nonatomic, copy)  NSString* textColor;
@property (nonatomic, copy)  NSString* textFontSize;
@property (nonatomic, copy)  NSString* textFontFamily;
@property (nonatomic, copy)  NSString* questionColor;
@property (nonatomic, copy)  NSString* questionFontSize;
@property (nonatomic, copy)  NSString* questionFontFamily;
@property (nonatomic, copy)  NSString* headerColor;
@property (nonatomic, copy)  NSString* headerFontSize;
@property (nonatomic, copy)  NSString* headerFontFamily;
@property (nonatomic, copy)  NSString* choiceTextColor;
@property (nonatomic, copy)  NSString* choiceFontSize;
@property (nonatomic, copy)  NSString* choiceFontFamily;
@property (nonatomic, copy)  NSString* responseBorderColor;
@property (nonatomic, copy)  NSString* backgroundColor;
@property (nonatomic, copy)  NSString* separatorColor;
@property (nonatomic, copy)  NSString* nextButtonText;
@property (nonatomic, copy)  NSString* previousButtonText;
@property (nonatomic, copy)  NSString* homeButtonText;
@property (nonatomic, copy)  NSString* theme;
@property (nonatomic, copy)  NSString* version;

@end