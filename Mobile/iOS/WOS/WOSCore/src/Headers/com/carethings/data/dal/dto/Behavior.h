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

// Language type for a behavior various "code" attributes
extern int const BEHAVIOR_LANG_TYPE_UNKNOWN;
extern int const BEHAVIOR_LANG_TYPE_UCSF_XML;
extern int const BEHAVIOR_LANG_TYPE_REDCAP_XML;
extern int const BEHAVIOR_LANG_TYPE_JAVASCRIPT;
extern int const BEHAVIOR_LANG_TYPE_JAVA;

// Valid execution states of a behavior
extern int const BEHAVIOR_STATE_INACTIVE;
extern int const BEHAVIOR_STATE_DISABLED;
extern int const BEHAVIOR_STATE_ACTIVE;
extern int const BEHAVIOR_STATE_COMMIT;

// Valid types of behaviors.  "Surveys" are considered PROCEDUREs.
extern int const BEHAVIOR_TYPE_UNKNOWN;
extern int const BEHAVIOR_TYPE_WORLD_MODEL;
extern int const BEHAVIOR_TYPE_REACTIVE;
extern int const BEHAVIOR_TYPE_PROCEDURE;


@interface Behavior : ResdbObject {
    NSString*			relatedID;
    int                 behaviorType;
    NSString*           decoratedName;
    int                 behaviorState;
    NSString*           concept;
    float               monitorWatcher;
    NSString*           reactorActivation;
    NSString*           monitorEnd;
    NSMutableData*      monitorEndCode;
    int                 monitorEndLanguage;
    int                 monitorEndCodeLen;
    bool                monitorEndCodeValid;
    NSString*           monitorException;
    NSMutableData*      monitorExceptionCode;
    int                 monitorExceptionLanguage;
    int                 monitorExceptionCodeLen;
    bool                monitorExceptionCodeValid;
    NSString*           startActions;
    NSMutableData*      startActionsCode;
    int                 startActionsLanguage;
    int                 startActionsCodeLen;
    bool                startActionsCodeValid;
    NSString*           stopActions;
    NSMutableData*      stopActionsCode;
    int                 stopActionsLanguage;
    int                 stopActionsCodeLen;
    bool                stopActionsCodeValid;
    NSMutableData*      protocol;
    NSMutableData*      protocolCode;
    int                 protocolLanguage;
    int                 protocolCodeLen;
    bool                protocolCodeValid;
    NSURL*              knowledge;
}

@property(nonatomic, copy) NSString* relatedID;
@property(nonatomic) int behaviorType;
@property(nonatomic, copy) NSString *decoratedName;
@property(nonatomic) int behaviorState;
@property(nonatomic, copy) NSString *concept;
@property(nonatomic) float monitorWatcher;
@property(nonatomic, copy) NSString *reactorActivation;
@property(nonatomic, copy) NSString *monitorEnd;
@property(nonatomic) NSMutableData *monitorEndCode;
@property(nonatomic) int monitorEndLanguage;
@property(nonatomic) int monitorEndCodeLen;
@property(nonatomic) bool monitorEndCodeValid;
@property(nonatomic, copy) NSString *monitorException;
@property(nonatomic) NSMutableData *monitorExceptionCode;
@property(nonatomic) int monitorExceptionLanguage;
@property(nonatomic) int monitorExceptionCodeLen;
@property(nonatomic) bool monitorExceptionCodeValid;
@property(nonatomic, copy) NSString *startActions;
@property(nonatomic) NSMutableData *startActionsCode;
@property(nonatomic) int startActionsLanguage;
@property(nonatomic) int startActionsCodeLen;
@property(nonatomic) bool startActionsCodeValid;
@property(nonatomic, copy) NSString *stopActions;
@property(nonatomic) NSMutableData *stopActionsCode;
@property(nonatomic) int stopActionsLanguage;
@property(nonatomic) int stopActionsCodeLen;
@property(nonatomic) bool stopActionsCodeValid;
@property(nonatomic) NSMutableData *protocol;
@property(nonatomic) NSMutableData *protocolCode;
@property(nonatomic) int protocolLanguage;
@property(nonatomic) int protocolCodeLen;
@property(nonatomic) bool protocolCodeValid;
@property(nonatomic) NSURL *knowledge;

@end