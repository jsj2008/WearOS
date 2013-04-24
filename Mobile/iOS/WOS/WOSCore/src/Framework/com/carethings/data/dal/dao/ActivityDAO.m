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

#import "ActivityDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation ActivityDAO

- (id)allocateDaoObject {
    return [Activity new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Activity* activity = (Activity*)daoObject;

	if ((activity == nil) || (sqlRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.objectID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.creationTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.reason = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.description = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.type = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.code = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.vendorType = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.value = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.startTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.endTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.relatedID = [[NSString alloc] initWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        activity.goalID = [[NSString alloc] initWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        activity.taskID = [[NSString alloc] initWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        activity.rewardID = [[NSString alloc] initWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.sysID = [[NSString alloc] initWithUTF8String: textPtr];
	activity.archived = (bool) sqlite3_column_int(sqlRow,i++);
	if (sqlite3_column_bytes(sqlRow, i) > 0)
		activity.data = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow, i) length: sqlite3_column_bytes(sqlRow, i)];
    i++;
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.originator = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.location = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.userCode = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.userID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.locationCode = [[NSString alloc] initWithUTF8String: textPtr];
	activity.dayOfWeekOfStudy = sqlite3_column_int(sqlRow, i++);
	activity.hourOfDayOfStudy = sqlite3_column_int(sqlRow, i++);
	activity.numberOfSteps = sqlite3_column_int(sqlRow, i++);
	activity.weekOfStudy = sqlite3_column_int(sqlRow, i++);
	activity.weeklyGoal = sqlite3_column_int(sqlRow, i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		activity.instanceID = [[NSString alloc] initWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklygoal,instanceID from Activity where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklygoal,instanceID from Activity where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:relatedID, nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByUserId:(NSString*)userID andRelatedId:(NSString*)relatedId {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklygoal,instanceID from Activity where userID=? and relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userID] ? [NSNull null] : userID),
                                                              ([StringUtils isEmpty:relatedId] ? [NSNull null] : relatedId), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByReason:(NSString*)reason {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklygoal,instanceID from Activity where reason=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveUnArchived {
    NSString * sql = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where archived=0";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveOrderByRelatedIdReasonForLocationCode:(NSString*)locationCode {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where locationCode=? order by relatedID, reason";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:locationCode] ? [NSNull null] : locationCode), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId andLocationCode:(NSString*)locationCode {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and locationCode=? order by reason";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedId] ? [NSNull null] : relatedId),
                                                              ([StringUtils isEmpty:locationCode] ? [NSNull null] : locationCode), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? order by reason";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)mostRecentActivityByRelatedIdAndCode:(NSString*)relatedId:(NSString*)code {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID = ? and code = ? and creationTime = (select max(creationTime) from Activity)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedId] ? [NSNull null] : relatedId),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)leastRecentActivityWithReason:(NSString*)reason {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where creationTime = (select min(creationTime) from Activity where reason = ?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)mostRecentActivityWithReason:(NSString*)reason {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where creationTime = (select max(creationTime) from Activity where reason = ?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveOrderByDescCreationForReason:(NSString*)reason {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where reason = ? order by creationTime desc";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedId andCode:(NSString*)code {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedId] ? [NSNull null] : relatedId),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByGoalId:(NSString*)goalID andCode:(NSString*)code {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goalID] ? [NSNull null] : goalID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByTaskId:(NSString*)taskID andCode:(NSString*)code {
    NSString *      sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where taskID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:taskID] ? [NSNull null] : taskID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRewardId:(NSString*)rewardID andCode:(NSString*)code {
    NSString*       sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where code = ? and rewardID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:rewardID] ? [NSNull null] : rewardID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult *)retrieveByInstanceId:(__unused NSString *)instanceID andType:(__unused NSString *)type {
    return nil;
}


- (ResdbResult*)retrieveWithType:(NSString*)type andStartTimeMonth:(NSString*)month {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where type = ? and strftime('%m', startTime) = ? order by startTime";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:type] ? [NSNull null] : type),
                                                              ([StringUtils isEmpty:month] ? [NSNull null] : month), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllWithMonth:(NSString*)month {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where strftime('%m', creationTime) = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:month] ? [NSNull null] : month), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByOriginator:(NSString*)originator andLocation:(NSString*)location andAbstractionDate:(NSString*)abDate {
    NSString*       sql    = @"SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where originator = ? and location = ? and startTime = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:originator] ? [NSNull null] : originator),
                                                              ([StringUtils isEmpty:location] ? [NSNull null] : location),
                                                              ([StringUtils isEmpty:abDate] ? [NSNull null] : abDate), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code {
    NSString*       sql    = @"SELECT count(*) from Activity where relatedID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andReason:(NSString*)reason {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID = ? and reason = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveUnArchivedByRelatedId:(NSString*)relatedID {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and archived=0";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and sysID=? and reason=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:sysID] ? [NSNull null] : sysID),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andCode:(NSString*)code andReason:(NSString*)reason {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and code=? and reason=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountByRelatedIdAndReason:(NSString*)relatedID:(NSString*)reason {
    NSString*       sql    = @"SELECT count(*) from Activity where relatedID = ? and reason = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)retrieveCount {
    NSString*       sql    = @"SELECT count(*) from Activity";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)retrieveAll {
    NSString*       sql    = @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(Activity*)activity {
    NSString*       sql    = @"INSERT into Activity (objectID,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,goalID,taskID,rewardID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:activity.objectID] ? [NSNull null] : activity.objectID),
                                                              ([StringUtils isEmpty:activity.reason] ? [NSNull null] : activity.reason),
                                                              ([StringUtils isEmpty:activity.description] ? [NSNull null] : activity.description),
                                                              ([StringUtils isEmpty:activity.type] ? [NSNull null] : activity.type),
                                                              ([StringUtils isEmpty:activity.code] ? [NSNull null] : activity.code),
                                                              ([StringUtils isEmpty:activity.vendorType] ? [NSNull null] : activity.vendorType),
                                                              ([StringUtils isEmpty:activity.value] ? [NSNull null] : activity.value),
                                                              ([StringUtils isEmpty:activity.startTime] ? [NSNull null] : activity.startTime),
                                                              ([StringUtils isEmpty:activity.endTime] ? [NSNull null] : activity.endTime),
                                                              ([StringUtils isEmpty:activity.relatedID] ? [NSNull null] : activity.relatedID),
                                                              ([StringUtils isEmpty:activity.goalID] ? [NSNull null] : activity.goalID),
                                                              ([StringUtils isEmpty:activity.taskID] ? [NSNull null] : activity.taskID),
                                                              ([StringUtils isEmpty:activity.rewardID] ? [NSNull null] : activity.rewardID),
                                                              ([StringUtils isEmpty:activity.sysID] ? [NSNull null] : activity.sysID),
                                                              [[NSNumber alloc] initWithInt:activity.archived],
                                                              ((activity.data == nil) ? [NSNull null] : activity.data),
                                                              ([StringUtils isEmpty:activity.originator] ? [NSNull null] : activity.originator),
                                                              ([StringUtils isEmpty:activity.location] ? [NSNull null] : activity.location),
                                                              ([StringUtils isEmpty:activity.userCode] ? [NSNull null] : activity.userCode),
                                                              ([StringUtils isEmpty:activity.userID] ? [NSNull null] : activity.userID),
                                                              ([StringUtils isEmpty:activity.locationCode] ? [NSNull null] : activity.locationCode),
                                                              [[NSNumber alloc] initWithInt:activity.dayOfWeekOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.hourOfDayOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.numberOfSteps],
                                                              [[NSNumber alloc] initWithInt:activity.weekOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.weeklyGoal],
                                                              ([StringUtils isEmpty:activity.instanceID] ? [NSNull null] : activity.instanceID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Activity*)activity {
    NSString* sql = @"UPDATE Activity SET objectID = ?, reason = ?, description = ?, type = ?, code = ?, vendorType = ?, value = ?, startTime = ?, endTime = ?, relatedID = ?, goalID = ?, taskID = ?, rewardID = ?, sysID=?, archived=?, data = ?, originator = ?, location = ?, userCode=?,userID=?, locationCode=?, dayOfWeekOfStudy=?, hourOfDayOfStudy=?, numberOfSteps=?, weekOfStudy=?, weeklyGoal=?, instanceID=? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:activity.objectID] ? [NSNull null] : activity.objectID),
                                                              ([StringUtils isEmpty:activity.reason] ? [NSNull null] : activity.reason),
                                                              ([StringUtils isEmpty:activity.description] ? [NSNull null] : activity.description),
                                                              ([StringUtils isEmpty:activity.type] ? [NSNull null] : activity.type),
                                                              ([StringUtils isEmpty:activity.code] ? [NSNull null] : activity.code),
                                                              ([StringUtils isEmpty:activity.vendorType] ? [NSNull null] : activity.vendorType),
                                                              ([StringUtils isEmpty:activity.value] ? [NSNull null] : activity.value),
                                                              ([StringUtils isEmpty:activity.startTime] ? [NSNull null] : activity.startTime),
                                                              ([StringUtils isEmpty:activity.endTime] ? [NSNull null] : activity.endTime),
                                                              ([StringUtils isEmpty:activity.relatedID] ? [NSNull null] : activity.relatedID),
                                                              ([StringUtils isEmpty:activity.goalID] ? [NSNull null] : activity.goalID),
                                                              ([StringUtils isEmpty:activity.taskID] ? [NSNull null] : activity.taskID),
                                                              ([StringUtils isEmpty:activity.rewardID] ? [NSNull null] : activity.rewardID),
                                                              ([StringUtils isEmpty:activity.sysID] ? [NSNull null] : activity.sysID),
                                                              [[NSNumber alloc] initWithInt:activity.archived],
                                                              ((activity.data == nil) ? [NSNull null] : activity.data),
                                                              ([StringUtils isEmpty:activity.originator] ? [NSNull null] : activity.originator),
                                                              ([StringUtils isEmpty:activity.location] ? [NSNull null] : activity.location),
                                                              ([StringUtils isEmpty:activity.userCode] ? [NSNull null] : activity.userCode),
                                                              ([StringUtils isEmpty:activity.userID] ? [NSNull null] : activity.userID),
                                                              ([StringUtils isEmpty:activity.locationCode] ? [NSNull null] : activity.locationCode),
                                                              [[NSNumber alloc] initWithInt:activity.dayOfWeekOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.hourOfDayOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.numberOfSteps],
                                                              [[NSNumber alloc] initWithInt:activity.weekOfStudy],
                                                              [[NSNumber alloc] initWithInt:activity.weeklyGoal],
                                                              ([StringUtils isEmpty:activity.instanceID] ? [NSNull null] : activity.instanceID),
                                                              ([StringUtils isEmpty:activity.objectID] ? [NSNull null] : activity.objectID),nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)updateAllArchived {
    NSString* sql = @"UPDATE Activity SET archived=1";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)updateAllUnArchive {
    NSString* sql = @"UPDATE Activity SET archived=0";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)updateList:(NSArray*)activitiesToSend {
	for (Activity* activity in activitiesToSend) {
		[self update:activity];
	}

	ResdbResult* result = [ResdbResult new];

	result.resdbCode = RESDB_SQL_OK;

	return result;
}

- (ResdbResult*)deleteAll {
    NSString*       sql    = @"delete from Activity";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString*       sql    = @"delete from Activity where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByLocationCode:(NSString*)locationCode {
    NSString*       sql    = @"delete from Activity where locationCode = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:locationCode] ? [NSNull null] : locationCode), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code {
    NSString*       sql    = @"delete from Activity where relatedID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code andReason:(NSString*)reason {
    NSString*       sql    = @"delete from Activity where relatedID = ? and code = ? and reason = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByGoalId:(NSString*)goalID andCode:(NSString*)code {
    NSString*       sql    = @"delete from Activity where goalID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goalID] ? [NSNull null] : goalID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}
- (ResdbResult*)deleteByTaskId:(NSString*)taskID andCode:(NSString*)code {
    NSString*       sql    = @"delete from Activity where taskID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:taskID] ? [NSNull null] : taskID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByRewardId:(NSString*)rewardID andCode:(NSString*)code {
    NSString*       sql    = @"delete from Activity where rewardID = ? and code = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:rewardID] ? [NSNull null] : rewardID),
                                                              ([StringUtils isEmpty:code] ? [NSNull null] : code), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason {
    NSString*       sql    = @"delete from Activity where relatedID = ? and sysID = ? and reason = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID),
                                                              ([StringUtils isEmpty:sysID] ? [NSNull null] : sysID),
                                                              ([StringUtils isEmpty:reason] ? [NSNull null] : reason), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString*       sql    = @"delete from Activity where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
