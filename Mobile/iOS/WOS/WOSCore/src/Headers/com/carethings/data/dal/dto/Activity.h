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


@interface Activity : ResdbObject {
	NSString*			reason;
	NSString*			type;
	NSString*			code;
	NSString*			userCode;
	NSString*			vendorType;
	NSString*			value;
	NSString*			startTime;
	NSString*			endTime;
	NSString*			relatedID;
    NSString*           goalID;
    NSString*           taskID;
    NSString*           rewardID;
	bool				archived;
	NSString*			sysID;
	NSString*			userID;
    NSString*           instanceID;
	NSMutableData*  	data;
	NSString*			originator;
	NSString*			location;
	NSString*			locationCode;
	int					dayOfWeekOfStudy;
	int					hourOfDayOfStudy;
	int					numberOfSteps;
	int					weekOfStudy;
	int					weeklyGoal;
}

@property (nonatomic, copy) NSString* reason;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSString* userCode;
@property (nonatomic, copy) NSString* vendorType;
@property (nonatomic, copy) NSString* value;
@property (nonatomic, copy) NSString* startTime;
@property (nonatomic, copy) NSString* endTime;
@property (nonatomic, copy) NSString* relatedID;
@property (nonatomic, copy) NSString* goalID;
@property (nonatomic, copy) NSString* taskID;
@property (nonatomic, copy) NSString* rewardID;
@property (nonatomic) bool archived;
@property (nonatomic, copy) NSString* sysID;
@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* instanceID;
@property (nonatomic) NSMutableData* data;
@property (nonatomic, copy) NSString* originator;
@property (nonatomic, copy) NSString* location;
@property (nonatomic, copy) NSString* locationCode;
@property (nonatomic) int dayOfWeekOfStudy;
@property (nonatomic) int hourOfDayOfStudy;
@property (nonatomic) int numberOfSteps;
@property (nonatomic) int weekOfStudy;
@property (nonatomic) int weeklyGoal;

@end
