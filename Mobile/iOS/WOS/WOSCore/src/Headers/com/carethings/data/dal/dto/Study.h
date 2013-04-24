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


@interface Study : ResdbObject {
	NSString*			organizationID;
	NSURL*				studyID;
	NSInteger			calibrated;
	NSString*			investigator;
	NSString*			referredBy;
	NSString*			studyType;
	int					lamportDayClock;
	int					lamportHourClock;
	int					lamportWeekClock;
	double				msStartDate;
	int					useLogicalClock;
	NSString*			appVersion;
	NSString*			clinicalPathwayAuthor;
	NSString*			clinicalPathwayVersion;
	NSString*			startDate;
	NSString*			studyDuration;
	NSString*			studyEmailFrom;
	NSString*			studyEmailLogin;
	NSString*			studyEmailPass;
	NSString*			studyEmailPort;
	NSString*			studyEmailSMTP;
	NSString*			studyEmailSubject;
	NSString*			studyEmailTo;
	NSString*			studyName;
	NSString*			studyPrimaryResearcher;
	NSString*			studySecondaryResearcher;
	NSString*			studyPrimaryLanguage;
    NSString*           studySite;
	NSString*   		studyWeek;
    NSString*   		studyDay;
	NSString*			var1;
	NSString*			var2;
	NSString*			var3;
	NSMutableArray*		studyWorldModel;
}

@property (nonatomic, copy) NSString* organizationID;
@property (nonatomic, copy) NSURL* studyID;
@property (nonatomic) NSInteger	calibrated;
@property (nonatomic, copy) NSString*	investigator;
@property (nonatomic, copy) NSString*	referredBy;
@property (nonatomic, copy) NSString*	studyType;
@property int lamportDayClock;
@property int lamportHourClock;
@property int lamportWeekClock;
@property double msStartDate;
@property int useLogicalClock;
@property (nonatomic, copy) NSString* appVersion;
@property (nonatomic, copy) NSString* clinicalPathwayAuthor;
@property (nonatomic, copy) NSString* clinicalPathwayVersion;
@property (nonatomic, copy) NSString* startDate;
@property (nonatomic, copy) NSString* studyDuration;
@property (nonatomic, copy) NSString* studyEmailFrom;
@property (nonatomic, copy) NSString* studyEmailLogin;
@property (nonatomic, copy) NSString* studyEmailPass;
@property (nonatomic, copy) NSString* studyEmailPort;
@property (nonatomic, copy) NSString* studyEmailSMTP;
@property (nonatomic, copy) NSString* studyEmailSubject;
@property (nonatomic, copy) NSString* studyEmailTo;
@property (nonatomic, copy) NSString* studyName;
@property (nonatomic, copy) NSString* studyPrimaryResearcher;
@property (nonatomic, copy) NSString* studySecondaryResearcher;
@property (nonatomic, copy) NSString* studyPrimaryLanguage;
@property (nonatomic, copy) NSString* studySite;
@property (nonatomic) NSMutableArray* studyWorldModel;
@property (nonatomic, copy) NSString* studyWeek;
@property (nonatomic, copy) NSString* studyDay;
@property (nonatomic, copy) NSString* var1;
@property (nonatomic, copy) NSString* var2;
@property (nonatomic, copy) NSString* var3;

- (void) incrLamportHourClock;
- (void) incrLamportWeekClock;
- (void) incrLamportDayClock;
- (NSString*)studySiteName;

@end
