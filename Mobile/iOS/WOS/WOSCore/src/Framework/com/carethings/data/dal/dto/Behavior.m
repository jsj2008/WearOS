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

#import "Behavior.h"


@implementation Behavior

@synthesize relatedID;
@synthesize behaviorType;
@synthesize decoratedName;
@synthesize behaviorState;
@synthesize concept;
@synthesize monitorWatcher;
@synthesize reactorActivation;
@synthesize monitorEnd;
@synthesize monitorEndCode;
@synthesize monitorEndLanguage;
@synthesize monitorEndCodeLen;
@synthesize monitorEndCodeValid;
@synthesize monitorException;
@synthesize monitorExceptionCode;
@synthesize monitorExceptionLanguage;
@synthesize monitorExceptionCodeLen;
@synthesize monitorExceptionCodeValid;
@synthesize startActions;
@synthesize startActionsCode;
@synthesize startActionsLanguage;
@synthesize startActionsCodeLen;
@synthesize startActionsCodeValid;
@synthesize stopActions;
@synthesize stopActionsCode;
@synthesize stopActionsLanguage;
@synthesize stopActionsCodeLen;
@synthesize stopActionsCodeValid;
@synthesize protocol;
@synthesize protocolCode;
@synthesize protocolLanguage;
@synthesize protocolCodeLen;
@synthesize protocolCodeValid;
@synthesize knowledge;

// Language type for a behavior various "code" attributes
int const BEHAVIOR_LANG_TYPE_UNKNOWN     = 0;
int const BEHAVIOR_LANG_TYPE_UCSF_XML    = 1;
int const BEHAVIOR_LANG_TYPE_REDCAP_XML  = 2;
int const BEHAVIOR_LANG_TYPE_JAVASCRIPT  = 3;
int const BEHAVIOR_LANG_TYPE_JAVA        = 4;

// Valid execution states of a behavior
int const BEHAVIOR_STATE_INACTIVE        = 0;
int const BEHAVIOR_STATE_DISABLED        = 1;
int const BEHAVIOR_STATE_ACTIVE          = 2;
int const BEHAVIOR_STATE_COMMIT          = 3;

// Valid types of behaviors.  "Surveys" are considered PROCEDUREs.
int const BEHAVIOR_TYPE_UNKNOWN          = 0;
int const BEHAVIOR_TYPE_REACTIVE         = 1;
int const BEHAVIOR_TYPE_PROCEDURE        = 2;

@end