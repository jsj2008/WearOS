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

@interface OpenPATHContext : NSObject {
@private
    id	                engine_;
    NSObject*			parent_;
    NSString*			pathwayFileName_;
    NSMutableArray*		studyList_;
    Study*				activeStudy_;
    Patient*			activePatient_;
    Goal*               activeGoal_;
    Task*               activeTask_;
    Reward*             activeReward_;
    Security*			activeSecurity_;
    Timer*              activeTimer_;
    Features*           activeFeatures_;
    Patient *			patient_;
    int					studyStoreId_;
    id					stopWatch_;
    NSMutableArray*		factBase_;
    int					tmpInt_;
    NSString*			tmpStr_;
    double				tmpDouble_;
    BOOL				authenticated_;
    NSDate*				lastLogin_;
    id                  gameEngine_;
    RenderStyle*        renderStyle_;
    Features*           features_;
    id                  dataDistributionManager_;
	id                  persistenceManager_;
	double              registerAccum001_;
	double              registerAccum002_;
	double              registerAccum003_;
}

@property (nonatomic, copy) NSString* pathwayFileName;
@property (nonatomic) id engine;
@property (nonatomic) NSObject* parent;
@property (nonatomic) id stopWatch;
@property (nonatomic) Study* activeStudy;
@property (nonatomic) Patient* activePatient;
@property (nonatomic) Goal* activeGoal;
@property (nonatomic) Task* activeTask;
@property (nonatomic) Reward* activeReward;
@property (nonatomic) Security* activeSecurity;
@property (nonatomic) Patient * patient;
@property (nonatomic) Features* activeFeatures;
@property (nonatomic) NSMutableArray* factBase;
@property (nonatomic) NSMutableArray* studyList;
@property (nonatomic) Timer* activeTimer;
@property int studyStoreId;
@property BOOL authenticated;
@property int tmpInt;
@property (nonatomic, copy) NSString* tmpStr;
@property double tmpDouble;
@property (nonatomic) NSDate* lastLogin;
@property (nonatomic) id gameEngine;
@property (nonatomic) RenderStyle* renderStyle;
@property (nonatomic) Features* features;
@property (nonatomic) id dataDistributionManager;
@property (nonatomic) id persistenceManager;
@property (nonatomic) double registerAccum001;
@property (nonatomic) double registerAccum002;
@property (nonatomic) double registerAccum003;


+(void)initWithParent : (NSObject*)parent andPathway : (NSString*)pathway;
+(OpenPATHContext*)sharedOpenPATHContext;
-(int)getLamportWeekClock;
-(void)incrLamportWeekClock;
-(int)getLamportDayClock;
-(void)incrLamportDayClock;
-(int)getLamportHourClock;
-(void)incrLamportHourClock;
-(NSURL*)getStudyID;
-(int)useLogicalClock;
-(void)enableLogicalClock;
-(void)disableLogicalClock;
-(void)setStudyID : (NSURL*)ident;
-(void)setStudyStartDate;
-(void) setStudyStartDateWithWeek:(int)week andDay:(int)day;
-(void)addFact : (NSString*)fact;
-(void)clearFactBase;
-(NSArray*)retrieveFactBase;
-(void)addStudy : (Study*)study;
-(void)clearStudyList;
-(NSArray*)retrieveStudyList;
-(ResdbResult*)saveActiveStudy;
-(ResdbResult*)saveActivePatient;
-(ResdbResult*)saveActiveGoal;
-(ResdbResult*)saveActiveTask;
-(ResdbResult*)saveActiveReward;
-(ResdbResult*)saveActiveSecurity;
-(ResdbResult*)saveActiveTimer;
-(ResdbResult*)saveActiveFeatures;

@end