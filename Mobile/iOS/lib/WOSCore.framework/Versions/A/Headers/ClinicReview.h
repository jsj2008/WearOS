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

#import "OpenPATHCore.h"

#define  VISIT_ONE						@"Visit1"
#define  VISIT_TWO						@"Visit2"
#define  VISIT_THREE					@"Visit3"
#define  VISIT_FOUR						@"Visit4"
#define  VISIT_FIVE						@"Visit5"
#define	VISIT_FINALREVIEW				@"FinalReview"

// Well-known active visit identifiers
#define  VISIT_ACTIVE_UNKNOWN		0
#define  VISIT_ACTIVE_ONE		    1
#define  VISIT_ACTIVE_TWO		    2
#define  VISIT_ACTIVE_THREE			3
#define  VISIT_ACTIVE_FOUR			4
#define  VISIT_ACTIVE_FIVE			5
#define	VISIT_ACTIVE_FINALREVIEW	6

// Well-known visit status values
#define	VISIT_STATUS_FINALREVIEW	3
#define	VISIT_STATUS_COMPLETE		2
#define	VISIT_STATUS_INPROGRESS	    1
#define	VISIT_STATUS_NOTACTIVE		0


@interface ClinicReview : ResdbObject {
	NSString*		lastName;
	NSString*		firstName;
	NSString*		patientNum;
	NSString*		gender;
	NSString*       dateOfBirth;
	NSString*       weight;
	NSString*		height;
	NSString*		deviceToken;
	NSString*		primaryClinic;
	NSString*		primaryClinicCode;
	NSString*		sample;
	NSString*       visit1;
	NSURL*			lastVisit1Interaction;
	NSString*       visit2;
	NSURL*			lastVisit2Interaction;
	NSString*       visit3;
	NSURL*			lastVisit3Interaction;
	NSString*       visit4;
	NSURL*			lastVisit4Interaction;
	NSString*       visit5;
	NSURL*			lastVisit5Interaction;
	NSString*		finalReview;
	NSURL*			lastFinalReviewInteraction;
	id              engine;
	int				activeVisit;
	int				visit1Status;
	int				visit2Status;
	int				visit3Status;
	int				visit4Status;
	int				visit5Status;	
}

@property (nonatomic, copy) NSString*	lastName;
@property (nonatomic, copy) NSString*	firstName;
@property (nonatomic, copy) NSString*	patientNum;
@property (nonatomic, copy) NSString*	gender;
@property (nonatomic, copy) NSString*	dateOfBirth;
@property (nonatomic, copy) NSString* weight;
@property (nonatomic, copy) NSString*	height;
@property (nonatomic, copy) NSString*	deviceToken;
@property (nonatomic, copy) NSString* primaryClinic;
@property (nonatomic, copy) NSString* primaryClinicCode;
@property (nonatomic, copy) NSString* sample;
@property (nonatomic, copy) NSString* visit1;
@property (nonatomic, copy) NSString* visit2;
@property (nonatomic, copy) NSString* visit3;
@property (nonatomic, copy) NSString* visit4;
@property (nonatomic, copy) NSString* visit5;
@property (nonatomic, retain) id engine;
@property (nonatomic) int activeVisit;
@property (nonatomic, copy) NSURL* lastVisit1Interaction;
@property (nonatomic, copy) NSURL* lastVisit2Interaction;
@property (nonatomic, copy) NSURL* lastVisit3Interaction;
@property (nonatomic, copy) NSURL* lastVisit4Interaction;
@property (nonatomic, copy) NSURL* lastVisit5Interaction;
@property (nonatomic) int visit1Status;
@property (nonatomic) int visit2Status;
@property (nonatomic) int visit3Status;
@property (nonatomic) int visit4Status;
@property (nonatomic) int visit5Status;

@property (nonatomic, copy) NSString* finalReview;
@property (nonatomic, copy) NSURL* lastFinalReviewInteraction;

- (void)saveLastInteraction:(NSURL*)systemID;
- (NSString*)visitDateFromVisitNumber:(int)visit;

@end
