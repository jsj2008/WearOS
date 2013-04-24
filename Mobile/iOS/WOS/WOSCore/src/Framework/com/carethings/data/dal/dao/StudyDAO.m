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

#import "StudyDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation StudyDAO

- (id)allocateDaoObject {
    return [Study new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Study* study = (Study*)daoObject;

    if ((study == nil) || (sqlRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.organizationID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyID = [[NSURL alloc] initWithString:[NSString stringWithUTF8String: textPtr]];
	study.calibrated = sqlite3_column_int(sqlRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.investigator = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.referredBy = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyType = [NSString stringWithUTF8String: textPtr];
	study.lamportDayClock = sqlite3_column_int(sqlRow,i++);
	study.lamportHourClock = sqlite3_column_int(sqlRow,i++);
	study.lamportWeekClock = sqlite3_column_int(sqlRow,i++);
	study.msStartDate = sqlite3_column_double(sqlRow,i++);
	study.useLogicalClock = sqlite3_column_int(sqlRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.appVersion = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.clinicalPathwayAuthor = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.clinicalPathwayVersion = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.startDate = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyDuration = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailFrom = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailLogin = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailPass = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailPort = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailSMTP = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailSubject = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyEmailTo = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studyPrimaryResearcher = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.studySecondaryResearcher = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.var1 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.var2 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		study.var3 = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        study.studySite = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        study.studyPrimaryLanguage = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3,studySite,studyPrimaryLanguage from Study where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByStudyId:(NSString*)studyID {
	NSString *      sql    = @"select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3,studySite,studyPrimaryLanguage from Study where studyID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:studyID] ? [NSNull null] : studyID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3,studySite,studyPrimaryLanguage from Study";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from Study";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Study*)study {
	NSString *      sql    = @"INSERT into Study (objectID,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3,studySite,studyPrimaryLanguage) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:study.objectID] ? [NSNull null] : study.objectID),
                                                              ([StringUtils isEmpty:study.description] ? [NSNull null] : study.description),
                                                              ([StringUtils isEmpty:study.organizationID] ? [NSNull null] : study.organizationID),
                                                              ((study.studyID == nil) ? [NSNull null] : [study.studyID absoluteString]),
                                                              [[NSNumber alloc] initWithInt:study.calibrated],
                                                              ([StringUtils isEmpty:study.investigator] ? [NSNull null] : study.investigator),
                                                              ([StringUtils isEmpty:study.referredBy] ? [NSNull null] : study.referredBy),
                                                              ([StringUtils isEmpty:study.studyType] ? [NSNull null] : study.studyType),
                                                              [[NSNumber alloc] initWithInt:study.lamportDayClock],
                                                              [[NSNumber alloc] initWithInt:study.lamportHourClock],
                                                              [[NSNumber alloc] initWithInt:study.lamportWeekClock],
                                                              [[NSNumber alloc] initWithDouble:study.msStartDate],
                                                              [[NSNumber alloc] initWithInt:study.useLogicalClock],
                                                              ([StringUtils isEmpty:study.appVersion] ? [NSNull null] : study.appVersion),
                                                              ([StringUtils isEmpty:study.clinicalPathwayAuthor] ? [NSNull null] : study.clinicalPathwayAuthor),
                                                              ([StringUtils isEmpty:study.clinicalPathwayVersion] ? [NSNull null] : study.clinicalPathwayVersion),
                                                              ([StringUtils isEmpty:study.startDate] ? [NSNull null] : study.startDate),
                                                              ([StringUtils isEmpty:study.studyDuration] ? [NSNull null] : study.studyDuration),
                                                              ([StringUtils isEmpty:study.studyEmailFrom] ? [NSNull null] : study.studyEmailFrom),
                                                              ([StringUtils isEmpty:study.studyEmailLogin] ? [NSNull null] : study.studyEmailLogin),
                                                              ([StringUtils isEmpty:study.studyEmailPass] ? [NSNull null] : study.studyEmailPass),
                                                              ([StringUtils isEmpty:study.studyEmailPort] ? [NSNull null] : study.studyEmailPort),
                                                              ([StringUtils isEmpty:study.studyEmailSMTP] ? [NSNull null] : study.studyEmailSMTP),
                                                              ([StringUtils isEmpty:study.studyEmailSubject] ? [NSNull null] : study.studyEmailSubject),
                                                              ([StringUtils isEmpty:study.studyEmailTo] ? [NSNull null] : study.studyEmailTo),
                                                              ([StringUtils isEmpty:study.studyName] ? [NSNull null] : study.studyName),
                                                              ([StringUtils isEmpty:study.studyPrimaryResearcher] ? [NSNull null] : study.studyPrimaryResearcher),
                                                              ([StringUtils isEmpty:study.studySecondaryResearcher] ? [NSNull null] : study.studySecondaryResearcher),
                                                              ([StringUtils isEmpty:study.var1] ? [NSNull null] : study.var1),
                                                              ([StringUtils isEmpty:study.var2] ? [NSNull null] : study.var2),
                                                              ([StringUtils isEmpty:study.var3] ? [NSNull null] : study.var3),
                                                              ([StringUtils isEmpty:study.studySite] ? [NSNull null] : study.studySite),
                                                              ([StringUtils isEmpty:study.studyPrimaryLanguage] ? [NSNull null] : study.studyPrimaryLanguage), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Study*)study {
	NSString *      sql    = @"UPDATE Study SET objectID = ?,description = ?,organizationID = ?,studyID = ?,calibrated = ?,investigator = ?,referredBy = ?,studyType = ?,lamportDayClock = ?,lamportHourClock = ?,lamportWeekClock = ?,msStartDate = ?,useLogicalClock = ?,appVersion = ?,clinicalPathwayAuthor = ?,clinicalPathwayVersion = ?,startDate = ?,studyDuration = ?,studyEmailFrom = ?,studyEmailLogin = ?,studyEmailPass = ?,studyEmailPort = ?,studyEmailSMTP = ?,studyEmailSubject = ?,studyEmailTo = ?,studyName = ?,studyPrimaryResearcher = ?,studySecondaryResearcher = ?,var1 = ?,var2 = ?,var3 = ?,studySite = ?,studyPrimaryLanguage = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:study.objectID] ? [NSNull null] : study.objectID),
                                                              ([StringUtils isEmpty:study.description] ? [NSNull null] : study.description),
                                                              ([StringUtils isEmpty:study.organizationID] ? [NSNull null] : study.organizationID),
                                                              ((study.studyID == nil) ? [NSNull null] : [study.studyID absoluteString]),
                                                              [[NSNumber alloc] initWithInt:study.calibrated],
                                                              ([StringUtils isEmpty:study.investigator] ? [NSNull null] : study.investigator),
                                                              ([StringUtils isEmpty:study.referredBy] ? [NSNull null] : study.referredBy),
                                                              ([StringUtils isEmpty:study.studyType] ? [NSNull null] : study.studyType),
                                                              [[NSNumber alloc] initWithInt:study.lamportDayClock],
                                                              [[NSNumber alloc] initWithInt:study.lamportHourClock],
                                                              [[NSNumber alloc] initWithInt:study.lamportWeekClock],
                                                              [[NSNumber alloc] initWithDouble:study.msStartDate],
                                                              [[NSNumber alloc] initWithInt:study.useLogicalClock],
                                                              ([StringUtils isEmpty:study.appVersion] ? [NSNull null] : study.appVersion),
                                                              ([StringUtils isEmpty:study.clinicalPathwayAuthor] ? [NSNull null] : study.clinicalPathwayAuthor),
                                                              ([StringUtils isEmpty:study.clinicalPathwayVersion] ? [NSNull null] : study.clinicalPathwayVersion),
                                                              ([StringUtils isEmpty:study.startDate] ? [NSNull null] : study.startDate),
                                                              ([StringUtils isEmpty:study.studyDuration] ? [NSNull null] : study.studyDuration),
                                                              ([StringUtils isEmpty:study.studyEmailFrom] ? [NSNull null] : study.studyEmailFrom),
                                                              ([StringUtils isEmpty:study.studyEmailLogin] ? [NSNull null] : study.studyEmailLogin),
                                                              ([StringUtils isEmpty:study.studyEmailPass] ? [NSNull null] : study.studyEmailPass),
                                                              ([StringUtils isEmpty:study.studyEmailPort] ? [NSNull null] : study.studyEmailPort),
                                                              ([StringUtils isEmpty:study.studyEmailSMTP] ? [NSNull null] : study.studyEmailSMTP),
                                                              ([StringUtils isEmpty:study.studyEmailSubject] ? [NSNull null] : study.studyEmailSubject),
                                                              ([StringUtils isEmpty:study.studyEmailTo] ? [NSNull null] : study.studyEmailTo),
                                                              ([StringUtils isEmpty:study.studyName] ? [NSNull null] : study.studyName),
                                                              ([StringUtils isEmpty:study.studyPrimaryResearcher] ? [NSNull null] : study.studyPrimaryResearcher),
                                                              ([StringUtils isEmpty:study.studySecondaryResearcher] ? [NSNull null] : study.studySecondaryResearcher),
                                                              ([StringUtils isEmpty:study.var1] ? [NSNull null] : study.var1),
                                                              ([StringUtils isEmpty:study.var2] ? [NSNull null] : study.var2),
                                                              ([StringUtils isEmpty:study.var3] ? [NSNull null] : study.var3),
                                                              ([StringUtils isEmpty:study.studySite] ? [NSNull null] : study.studySite),
                                                              ([StringUtils isEmpty:study.studyPrimaryLanguage] ? [NSNull null] : study.studyPrimaryLanguage),
                                                              ([StringUtils isEmpty:study.objectID] ? [NSNull null] : study.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Study";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Study where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByStudyId:(NSString*)studyID {
	NSString *      sql    = @"delete from Study where studyID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:studyID] ? [NSNull null] : studyID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
