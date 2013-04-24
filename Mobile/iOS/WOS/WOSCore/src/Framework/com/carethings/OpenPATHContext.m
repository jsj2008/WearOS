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

#import "OpenPATHContext.h"

@implementation OpenPATHContext;

static OpenPATHContext* sharedOpenPATHContext_ = nil;

@synthesize pathwayFileName = pathwayFileName_;
@synthesize engine = engine_;
@synthesize parent = parent_;
@synthesize stopWatch = stopWatch_;
@synthesize activeStudy = activeStudy_;
@synthesize patient = patient_;
@synthesize studyStoreId = studyStoreId_;
@synthesize factBase = factBase_;
@synthesize studyList = studyList_;
@synthesize tmpInt = tmpInt_;
@synthesize tmpStr = tmpStr_;
@synthesize tmpDouble = tmpDouble_;
@synthesize activePatient = activePatient_;
@synthesize activeGoal = activeGoal_;
@synthesize activeTask = activeTask_;
@synthesize activeReward = activeReward_;
@synthesize authenticated = authenticated_;
@synthesize activeSecurity = activeSecurity_;
@synthesize activeTimer = activeTimer_;
@synthesize lastLogin = lastLogin_;
@synthesize gameEngine = gameEngine_;
@synthesize activeFeatures = activeFeatures_;
@synthesize dataDistributionManager = dataDistributionManager_;
@synthesize persistenceManager = persistenceManager_;
@synthesize registerAccum001 = registerAccum001_;
@synthesize registerAccum002 = registerAccum002_;
@synthesize registerAccum003 = registerAccum003_;


+ (OpenPATHContext*) sharedOpenPATHContext {
    @synchronized(self) {
        if (sharedOpenPATHContext_ == nil) {
            sharedOpenPATHContext_					= [self new];
            sharedOpenPATHContext_.engine			= nil;
            sharedOpenPATHContext_.studyStoreId		= -1;
            sharedOpenPATHContext_.stopWatch		= nil;
            sharedOpenPATHContext_.factBase			= [[NSMutableArray alloc] initWithCapacity: 5];
            sharedOpenPATHContext_.studyList		= [[NSMutableArray alloc] initWithCapacity: 5];

            ResdbResult*  result = nil;

			sharedOpenPATHContext_.activeStudy           = nil;
            sharedOpenPATHContext_.activePatient         = nil;
            sharedOpenPATHContext_.activeGoal            = nil;
            sharedOpenPATHContext_.activeTask            = nil;
            sharedOpenPATHContext_.activeReward          = nil;
            sharedOpenPATHContext_.activeSecurity        = nil;
            sharedOpenPATHContext_.activeTimer           = nil;
            sharedOpenPATHContext_.features              = nil;
            sharedOpenPATHContext_.renderStyle           = nil;
            sharedOpenPATHContext_.authenticated         = FALSE;
			
			StudyDAO*     dao = [StudyDAO new];
			
            result = [dao retrieve:WS_ROOT_OBJECT_IDENTIFIER];
			
			/*
			UserDAO* userDao = [UserDAO new];
			User*    user = [User new];
			
			user.role = @"RESEARCHER";
			[user allocateObjectId];
			user.lastName = @"Test Researchers";
			
			[userDao insert:user];
			 */
			
            if (result.resdbCode == RESDB_SQL_ROWS) {
                sharedOpenPATHContext_.activeStudy = (Study*)result.resdbObject;
            } else   {
                sharedOpenPATHContext_.activeStudy                         	= [Study new];
                sharedOpenPATHContext_.activeStudy.objectID                 = WS_ROOT_OBJECT_IDENTIFIER;
                sharedOpenPATHContext_.activeStudy.startDate               	= nil;
                sharedOpenPATHContext_.activeStudy.msStartDate     			= 0;
                sharedOpenPATHContext_.activeStudy.studyID         			= nil;
				//sharedOpenPATHContext_.activeStudy.studyPrimaryResearcher   = user.objectID;
				
                [dao insert: sharedOpenPATHContext_.activeStudy];
            }

            PatientDAO* patientDao = [PatientDAO new];

            result = [patientDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

            if (result.resdbCode == RESDB_SQL_ROWS) {
                sharedOpenPATHContext_.activePatient = (Patient*)result.resdbObject;
            } else   {
                sharedOpenPATHContext_.activePatient             = [Patient new];
                sharedOpenPATHContext_.activePatient.objectID    = WS_ROOT_OBJECT_IDENTIFIER;
                sharedOpenPATHContext_.activePatient.patientNum  = nil;

                [patientDao insert: sharedOpenPATHContext_.activePatient];
            }

            SecurityDAO* securityDao = [SecurityDAO new];

            result = [securityDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

            if (result.resdbCode == RESDB_SQL_ROWS) {
                sharedOpenPATHContext_.activeSecurity = (Security*)result.resdbObject;
            } else   {
                sharedOpenPATHContext_.activeSecurity            = [Security new];
                sharedOpenPATHContext_.activeSecurity.objectID   = WS_ROOT_OBJECT_IDENTIFIER;

                [securityDao insert: sharedOpenPATHContext_.activeSecurity];
            }

            TimerDAO* timerDao = [TimerDAO new];

            result = [timerDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

            /*
         	if (result.resdbCode == RESDB_SQL_ROWS) {
         		sharedOpenPATHContext_.activeTimer = (Timer*)result.resdbObject;
         	} else   {
         		sharedOpenPATHContext_.activeTimer            = [Timer new];
         		sharedOpenPATHContext_.activeTimer.objectID   = WS_ROOT_OBJECT_IDENTIFIER;
                sharedOpenPATHContext_.activeTimer.active     = false;

         		[timerDao insert: sharedOpenPATHContext_.activeTimer];
         	}
         	*/

            FeaturesDAO* featuresDao = [FeaturesDAO new];

            result = [featuresDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

            if (result.resdbCode == RESDB_SQL_ROWS) {
                sharedOpenPATHContext_.activeFeatures = (Features*)result.resdbObject;
            } else   {
                sharedOpenPATHContext_.activeFeatures            = [Features new];
                sharedOpenPATHContext_.activeFeatures.objectID   = WS_ROOT_OBJECT_IDENTIFIER;

                [featuresDao insert: sharedOpenPATHContext_.activeFeatures];
            }

            sharedOpenPATHContext_.gameEngine = nil;
        }
    }

    return sharedOpenPATHContext_;
}

+ (id) allocWithZone: (NSZone*) zone {
    @synchronized(self) {
        if (sharedOpenPATHContext_ == nil) {
            sharedOpenPATHContext_ = (OpenPATHContext *) [super allocWithZone: zone];
            return sharedOpenPATHContext_;
        }
    }

    return nil;
}

+ (void) initWithParent: (NSObject*) parent andPathway: (NSString*) pathway {
    [self sharedOpenPATHContext];

    sharedOpenPATHContext_.parent                              = parent;
    sharedOpenPATHContext_.pathwayFileName     = pathway;

    ResdbResult*  result;
    StudyDAO*     dao = [StudyDAO new];

    result = [dao retrieveAll];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        sharedOpenPATHContext_.activeStudy = (Study*)[result.resdbCollection objectAtIndex: 0];
    }
}

- (int) getLamportWeekClock {
    return activeStudy_.lamportWeekClock;
}

- (void) incrLamportWeekClock {
    activeStudy_.lamportWeekClock++;

    [activeStudy_ incrLamportWeekClock];

    StudyDAO* dao =  [StudyDAO new];

    [dao update: activeStudy_];
}

- (int) getLamportDayClock {
    return activeStudy_.lamportDayClock;
}

- (void) incrLamportDayClock {
    [activeStudy_ incrLamportDayClock];
}

- (int) getLamportHourClock {
    return activeStudy_.lamportHourClock;
}

- (void) incrLamportHourClock {
    [activeStudy_ incrLamportHourClock];
}

- (NSURL*) getStudyID {
    return activeStudy_.studyID;
}

- (int) useLogicalClock {
    return [activeStudy_ useLogicalClock];
}

- (void) enableLogicalClock {
    activeStudy_.useLogicalClock = 1;
}

- (void) disableLogicalClock {
    activeStudy_.useLogicalClock = 0;
}

- (void) setStudyID: (NSURL*) ident {
    activeStudy_.studyID = ident;
}

-(ResdbResult*)saveActiveStudy {
    StudyDAO*     dao = [StudyDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeStudy_]);
}

-(ResdbResult*)saveActivePatient {
    PatientDAO*     dao = [PatientDAO new];
    ResdbResult*    result;

    return (result = [dao update:activePatient_]);
}

-(ResdbResult*)saveActiveGoal {
    GoalDAO*      dao = [GoalDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeGoal_]);
}

-(ResdbResult*)saveActiveTask {
    TaskDAO*      dao = [TaskDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeTask_]);
}

-(ResdbResult*)saveActiveReward {
    RewardDAO*    dao = [RewardDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeReward_]);
}

-(ResdbResult*)saveActiveSecurity {
    SecurityDAO*  dao = [SecurityDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeSecurity_]);
}

-(ResdbResult*)saveActiveTimer {
    TimerDAO*     dao = [TimerDAO new];
    ResdbResult*  result;

    return (result = [dao update:activeTimer_]);
}

-(ResdbResult*)saveActiveFeatures {
    FeaturesDAO*   dao = [FeaturesDAO new];
    ResdbResult*   result;

    return (result = [dao update:activeFeatures_]);
}

- (void) setStudyStartDate {
    NSDate*		currentDate	= [NSDate date];
    NSCalendar*	calendar	= [NSCalendar currentCalendar];

    [calendar setTimeZone:[NSTimeZone localTimeZone]];

    unsigned			unitFlags 		= NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* 	components 	= [calendar components:unitFlags fromDate:currentDate];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    NSDate* studyDate = [calendar dateFromComponents:components];

    activeStudy_.startDate = [DateFormatter localizedStringFromUSDate: studyDate];

    activeStudy_.msStartDate = [studyDate timeIntervalSince1970];

    StudyDAO* dao = [StudyDAO new];

    [dao update: activeStudy_];
}

- (void) setStudyStartDateWithWeek:(int)week andDay:(int)day {
    NSDate* 		currentDate 	= [NSDate date];
    NSCalendar*	calendar 		= [NSCalendar currentCalendar];
    double 			sDay 			    = 86400;
    double			sNow				= [currentDate timeIntervalSince1970];
    unsigned			unitFlags 		= NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    double			sDelta 			= sDay * (((week - 1) * 7) + (day - 1));

    sNow -= sDelta;

    NSDate* studyDate = [NSDate dateWithTimeIntervalSince1970:sNow];

    NSDateComponents* 	components 	= [calendar components:unitFlags fromDate:studyDate];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    studyDate = [calendar dateFromComponents:components];

    activeStudy_.startDate = [DateFormatter localizedStringFromUSDate: studyDate];

    activeStudy_.msStartDate = [studyDate timeIntervalSince1970];

    StudyDAO* dao = [StudyDAO new];

    [dao update: activeStudy_];
}

- (void) addFact: (NSString*) fact {
    if (fact == nil)
        return;

    [factBase_ addObject: fact];
}

- (void) clearFactBase {
    [factBase_ removeAllObjects];
}

- (NSArray*) retrieveFactBase {
    return factBase_;
}

- (void) addStudy: (Study*) study {
    if (study == nil)
        return;

    [studyList_ addObject: study];
}

- (void) clearStudyList {
    [studyList_ removeAllObjects];
}

- (NSArray*) retrieveStudyList {
    return studyList_;
}

@end