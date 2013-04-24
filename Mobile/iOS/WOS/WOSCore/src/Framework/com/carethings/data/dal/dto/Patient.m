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

#import "Patient.h"
#import "PatientDAO.h"

@implementation Patient

@synthesize	lastName;
@synthesize	firstName;
@synthesize	patientNum;
@synthesize	gender;
@synthesize weight;
@synthesize	height;
@synthesize	deviceToken;
@synthesize primaryClinic;
@synthesize primaryClinicCode;
@synthesize dateOfBirth;
@synthesize sample;
@synthesize visit1;
@synthesize visit2;
@synthesize visit3;
@synthesize visit4;
@synthesize visit5;
@synthesize engine;
@synthesize activeVisit;
@synthesize lastVisit1Interaction;
@synthesize lastVisit2Interaction;
@synthesize lastVisit3Interaction;
@synthesize lastVisit4Interaction;
@synthesize lastVisit5Interaction;
@synthesize visit1Status;
@synthesize visit2Status;
@synthesize visit3Status;
@synthesize visit4Status;
@synthesize visit5Status;
@synthesize finalReview;
@synthesize lastFinalReviewInteraction;
@synthesize rewardPoints;
@synthesize points;
@synthesize photo;
@synthesize photo2;
@synthesize photo3;
@synthesize coachFilePath;
@synthesize coachPhoto1;
@synthesize coachPhoto2;
@synthesize welcomeCoach;


- (id)init {
	if (self = [super init]) {
		visit1Status	= VISIT_STATUS_NOTACTIVE;
		visit2Status	= VISIT_STATUS_NOTACTIVE;
		visit3Status	= VISIT_STATUS_NOTACTIVE;
		visit4Status	= VISIT_STATUS_NOTACTIVE;
		visit5Status	= VISIT_STATUS_NOTACTIVE;
		activeVisit	    = VISIT_ACTIVE_UNKNOWN;
	}
	
	return self;
}

- (void)saveLastInteraction:(NSURL*)systemID {
	if (self.activeVisit == VISIT_ACTIVE_UNKNOWN)
		return;
	
	if (self.activeVisit == VISIT_ACTIVE_ONE) {
		self.lastVisit1Interaction = systemID;
	} else if (self.activeVisit == VISIT_ACTIVE_TWO) {
		self.lastVisit2Interaction = systemID;
	} else if (self.activeVisit == VISIT_ACTIVE_THREE) {
		self.lastVisit3Interaction = systemID;	
	} else if (self.activeVisit == VISIT_ACTIVE_FOUR) {
		self.lastVisit4Interaction = systemID;	
	} else if (self.activeVisit == VISIT_ACTIVE_FIVE) {
		self.lastVisit5Interaction = systemID;	
	} else if (self.activeVisit == VISIT_ACTIVE_FINALREVIEW) {
		self.lastFinalReviewInteraction = systemID;	
	}
	
	PatientDAO*   dao = [PatientDAO new];
	[dao update:self];
}

- (NSString*)visitDateFromVisitNumber:(int)visit {
	switch (visit) {
		case 1:
			return visit1;
			break;
		case 2:
			return visit2;
			break;
		case 3:
			return visit3;
			break;
		case 4:
			return visit4;
			break;
		case 5:
			return visit5;
			break;
		default:
			return visit1;
			break;
	}
}

@end
