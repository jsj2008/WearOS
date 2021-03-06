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


#import <sqlite3.h>
#import "Activity.h"
#import "ObjectDAO.h"

@class ResdbResult;


@interface ActivityDAO : ObjectDAO {

}

- (ResdbResult*)retrieve:(NSString*)objectID;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID;
- (ResdbResult*)retrieveAll;
- (ResdbResult*)retrieveByUserId:(NSString*)userID andRelatedId:(NSString*)relatedId;
- (ResdbResult*)mostRecentActivityByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code;
- (ResdbResult*)mostRecentActivityWithReason:(NSString*)reason;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andCode:(NSString*)code;
- (ResdbResult*)retrieveByGoalId:(NSString*)goalId andCode:(NSString*)code;
- (ResdbResult*)retrieveByTaskId:(NSString*)taskId andCode:(NSString*)code;
- (ResdbResult*)retrieveByRewardId:(NSString*)rewardId andCode:(NSString*)code;
- (ResdbResult*)retrieveByInstanceId:(__unused NSString*)instanceID andType:(__unused NSString *)type;
- (ResdbResult*)retrieveByReason:(NSString*)reason;
- (ResdbResult*)retrieveCountByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code;
- (ResdbResult*)retrieveCount;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andReason:(NSString*)reason;
- (ResdbResult*)retrieveCountByRelatedIdAndReason:(NSString*)relatedID:(NSString*)reason;
- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason;
- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andCode:(NSString*)code andReason:(NSString*)reason;
- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId;
- (ResdbResult*)retrieveOrderByRelatedIdReasonForLocationCode:(NSString*)locationCode;
- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId andLocationCode:(NSString*)locationCode;
- (ResdbResult*)retrieveUnArchived;
- (ResdbResult*)retrieveUnArchivedByRelatedId:(NSString*)relatedID;
- (ResdbResult*)insert:(Activity*)activity;
- (ResdbResult*)update:(Activity*)activity;
- (ResdbResult*)updateAllArchived;
- (ResdbResult*)updateAllUnArchive;
- (ResdbResult*)updateList:(NSArray*)activitiesToSend;
- (ResdbResult*)delete:(NSString*)objectID;
- (ResdbResult*)deleteAll;
- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID;
- (ResdbResult*)deleteByLocationCode:(NSString*)locationCode;
- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code;
- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code andReason:(NSString*)reason;
- (ResdbResult*)deleteByGoalId:(NSString*)goalID andCode:(NSString*)code;
- (ResdbResult*)deleteByTaskId:(NSString*)taskID andCode:(NSString*)code;
- (ResdbResult*)deleteByRewardId:(NSString*)rewardID andCode:(NSString*)code;
- (ResdbResult*)deleteByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason;
- (ResdbResult*)retrieveByOriginator:(NSString*)originator andLocation:(NSString*)location andAbstractionDate:abDate;
- (ResdbResult*)retrieveOrderByDescCreationForReason:(NSString*)reason;
- (ResdbResult*)retrieveAllWithMonth:(NSString*)month;
- (ResdbResult*)retrieveWithType:(NSString*)type andStartTimeMonth:(NSString*)month;

@end
