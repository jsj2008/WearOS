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

#import "Study.h"
#import "StringUtils.h"
#import "SiteDAO.h"
#import "ResdbResult.h"

@implementation Study

@synthesize organizationID;
@synthesize studyID;
@synthesize calibrated;
@synthesize investigator;
@synthesize referredBy;
@synthesize studyType;
@synthesize lamportDayClock;
@synthesize lamportHourClock;
@synthesize lamportWeekClock;
@synthesize msStartDate;
@synthesize useLogicalClock;
@synthesize appVersion;
@synthesize clinicalPathwayAuthor;
@synthesize clinicalPathwayVersion;
@synthesize startDate;
@synthesize studyDuration;
@synthesize studyEmailFrom;
@synthesize studyEmailLogin;
@synthesize studyEmailPass;
@synthesize studyEmailPort;
@synthesize studyEmailSMTP;
@synthesize studyEmailSubject;
@synthesize studyEmailTo;
@synthesize studyName;
@synthesize studyPrimaryResearcher;
@synthesize studySecondaryResearcher;
@synthesize studyPrimaryLanguage;
@synthesize studyWorldModel;
@synthesize studySite;
@synthesize studyWeek;
@synthesize studyDay;
@synthesize var1;
@synthesize var2;
@synthesize var3;

- (Study*) init {
	self = [super init];
	
	if (self) {
		lamportDayClock     = 1;
		lamportHourClock    = 0;
		lamportWeekClock   = 1;
		msStartDate             = 0;
		useLogicalClock       = 0;
	}
	
	return self;
}	

- (id)mutableCopyWithZone:(NSZone *)zone {
	
	Study* study = [[Study allocWithZone:zone] init];

	study.organizationID = self.organizationID;
	study.studyID = self.studyID;
	study.calibrated = self.calibrated;
	study.investigator = self.investigator;
	study.referredBy = self.referredBy;
	study.studyType = self.studyType;
	study.lamportDayClock = self.lamportDayClock;
	study.lamportHourClock = self.lamportHourClock;
	study.lamportWeekClock = self.lamportWeekClock;
	study.msStartDate = self.msStartDate;
	study.useLogicalClock = self.useLogicalClock;
	study.appVersion = self.appVersion;
	study.clinicalPathwayAuthor = self.clinicalPathwayAuthor;
	study.clinicalPathwayVersion = self.clinicalPathwayVersion;
	study.startDate = self.startDate;
	study.studyDuration = self.studyDuration;
	study.studyEmailFrom = self.studyEmailFrom;
	study.studyEmailLogin = self.studyEmailLogin;
	study.studyEmailPass = self.studyEmailPass;
	study.studyEmailPort = self.studyEmailPort;
	study.studyEmailSMTP = self.studyEmailSMTP;
	study.studyEmailSubject = self.studyEmailSubject;
	study.studyEmailTo = self.studyEmailTo;
	study.studyName = self.studyName;
	study.studyPrimaryResearcher = self.studyPrimaryResearcher;
	study.studySecondaryResearcher = self.studySecondaryResearcher;
	study.studyPrimaryLanguage = self.studyPrimaryLanguage;
    study.studySite = self.studySite;
	study.var1 = self.var1;
	study.var2 = self.var2;
	study.var3 = self.var3;
	study.studyWorldModel = self.studyWorldModel;	
	study.studyWeek = self.studyWeek;
	study.studyDay = self.studyDay;

	return study;
}

- (NSString*)studySiteName {
	if ([StringUtils  isNotEmpty:studySite]) {
		SiteDAO*      dao = [SiteDAO new];
		ResdbResult*  result;
		
		result = [dao retrieve:studySite];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			return ((Site*)result.resdbObject).name;
		}
	} 
		
	return @"";
}

- (void) incrLamportHourClock {
	if (lamportHourClock == 24) {
		lamportHourClock = 0;
	} else {
		lamportHourClock++;
	}
}  

- (void) incrLamportDayClock {
	if (lamportDayClock == 7) {
		lamportDayClock = 1;
	} else {
		lamportDayClock++;
	}
}

- (void) incrLamportWeekClock {
	lamportWeekClock++;
}

@end
