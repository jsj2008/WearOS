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

#import "SessionDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "SessionPatientDAO.h"
#import "SessionStudyDAO.h"
#import "PatientDAO.h"
#import "StudyDAO.h"
#import "SessionPatient.h"
#import "SessionStudy.h"
#import "StringUtils.h"

@implementation SessionDAO

- (id)allocateDaoObject {
    return [Session new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    Session* session = (Session*)daoObject;

    if ((session == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.organizationID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.sessionID = [NSString stringWithUTF8String: textPtr];
    session.active =     sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        session.investigator = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        session.referredBy = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        session.startTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        session.endTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.sessionType = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.category = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        session.duration = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveBySessionId:(NSString*)sessionID {
    NSString *      sql    = @"select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where sessionID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionID] ? [NSNull null] : sessionID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveActiveSession {
    NSString *      sql    = @"select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where active=1";

    return [self findMultiRow:sql withParams:nil];
}


- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCompleteSessions {
    NSString *      sql    = @"select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where startTime is not null and endTime is not null";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from Session";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)retrieveCountCompleteSessions {
    NSString *      sql    = @"SELECT count(*) from Session where startTime is not null and endTime is not null";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Session*)session {
    NSString *      sql    = @"INSERT into Session (objectID,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration) values (?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:session.objectID] ? [NSNull null] : session.objectID),
                                                              ([StringUtils isEmpty:session.description] ? [NSNull null] : session.description),
                                                              ([StringUtils isEmpty:session.organizationID] ? [NSNull null] : session.organizationID),
                                                              ([StringUtils isEmpty:session.sessionID] ? [NSNull null] : session.sessionID),
                                                              [[NSNumber alloc] initWithInt:session.active],
                                                              ([StringUtils isEmpty:session.investigator] ? [NSNull null] : session.investigator),
                                                              ([StringUtils isEmpty:session.referredBy] ? [NSNull null] : session.referredBy),
                                                              ([StringUtils isEmpty:session.startTime] ? [NSNull null] : session.startTime),
                                                              ([StringUtils isEmpty:session.endTime] ? [NSNull null] : session.endTime),
                                                              ([StringUtils isEmpty:session.sessionType] ? [NSNull null] : session.sessionType),
                                                              ([StringUtils isEmpty:session.category] ? [NSNull null] : session.category),
                                                              ([StringUtils isEmpty:session.duration] ? [NSNull null] : session.duration), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Session*)session {
    NSString *      sql    = @"UPDATE Session SET objectID = ?,description = ?,organizationID = ?,sessionID = ?,active = ?,investigator = ?,referredBy = ?,startTime = ?,endTime = ?,sessionType = ?,category = ?,duration = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:session.objectID] ? [NSNull null] : session.objectID),
                                                              ([StringUtils isEmpty:session.description] ? [NSNull null] : session.description),
                                                              ([StringUtils isEmpty:session.organizationID] ? [NSNull null] : session.organizationID),
                                                              ([StringUtils isEmpty:session.sessionID] ? [NSNull null] : session.sessionID),
                                                              [[NSNumber alloc] initWithInt:session.active],
                                                              ([StringUtils isEmpty:session.investigator] ? [NSNull null] : session.investigator),
                                                              ([StringUtils isEmpty:session.referredBy] ? [NSNull null] : session.referredBy),
                                                              ([StringUtils isEmpty:session.startTime] ? [NSNull null] : session.startTime),
                                                              ([StringUtils isEmpty:session.endTime] ? [NSNull null] : session.endTime),
                                                              ([StringUtils isEmpty:session.sessionType] ? [NSNull null] : session.sessionType),
                                                              ([StringUtils isEmpty:session.category] ? [NSNull null] : session.category),
                                                              ([StringUtils isEmpty:session.duration] ? [NSNull null] : session.duration),
                                                              ([StringUtils isEmpty:session.objectID] ? [NSNull null] : session.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)updateAllNotActive {
    NSString *      sql    = @"UPDATE Session SET active = 0";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Session";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
     NSString *      sql    = @"delete from Session where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteBySessionId:(NSString*)sessionID {
    NSString *      sql    = @"delete from Session where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionID] ? [NSNull null] : sessionID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)retrievePatients:(NSString*)sessionObjectID {

    SessionPatientDAO*  dao      = [SessionPatientDAO new];
    NSMutableArray*     patients = [NSMutableArray new];
    ResdbResult*        result   = nil;

    result = [dao retrieveAllPatientsOfSession: sessionObjectID];

    if (result.resdbCode == RESDB_SQL_ROWS) {

        for (SessionPatient* sessionPatient in result.resdbCollection) {
            PatientDAO*  patientDAO    = [PatientDAO new];
            ResdbResult* patientResult = nil;

            patientResult = [patientDAO retrieve:[sessionPatient patientID]];

            if (patientResult.resdbCode == RESDB_SQL_ROWS)
                [patients addObject:[patientResult resdbObject]];
        }
    }

    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)retrievePatient:(NSString*)sessionObjectID {

    SessionDAO*                     dao = [SessionDAO new];
    ResdbResult*            tempResult  = nil;
    ResdbResult*        result          = [ResdbResult new];

    tempResult = [dao retrievePatients: sessionObjectID];

    if (tempResult.resdbCode == RESDB_SQL_ROWS) {
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)retrieveStudies:(NSString*)sessionObjectID {
    SessionStudyDAO*    dao     = [SessionStudyDAO new];
    NSMutableArray*     studies = [NSMutableArray new];
    ResdbResult*        result  = nil;

    result = [dao retrieveAllStudiesOfSession: sessionObjectID];

    if (result.resdbCode == RESDB_SQL_ROWS) {

        for (SessionStudy* sessionStudy in result.resdbCollection) {
            StudyDAO*    studyDAO    = [StudyDAO new];
            ResdbResult* studyResult = nil;

            studyResult = [studyDAO retrieve:[sessionStudy studyID]];

            if (studyResult.resdbCode == RESDB_SQL_ROWS)
                [studies addObject:[studyResult resdbObject]];
        }
    }

    if ([studies count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: studies];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)addPatient:(NSString*)patientObjectID session:(NSString*)sessionObjectID {

    SessionPatientDAO*    dao = [SessionPatientDAO new];

    return [dao insert: sessionObjectID patient: patientObjectID];
}

- (ResdbResult*)addStudy:(NSString*)studyObjectID session:(NSString*)sessionObjectID {
    SessionStudyDAO*    dao = [SessionStudyDAO new];

    return [dao insert: sessionObjectID study: studyObjectID];
}

- (ResdbResult*)removePatient:(NSString*)patientObjectID session:(NSString*)sessionObjectID {
    SessionPatientDAO*    dao = [SessionPatientDAO new];

    return [dao delete: sessionObjectID patient: patientObjectID];
}

- (ResdbResult*)removeStudy:(NSString*)studyObjectID session:(NSString*)sessionObjectID {
    SessionStudyDAO*    dao = [SessionStudyDAO new];

    return [dao delete: sessionObjectID study: studyObjectID];
}

- (ResdbResult*)removeAllPatients:(NSString*)sessionObjectID {
    SessionPatientDAO*    dao = [SessionPatientDAO new];

    return [dao deleteAllPatientsOfSession: sessionObjectID];
}

- (ResdbResult*)removeAllStudies:(NSString*)sessionObjectID {
    SessionStudyDAO*    dao = [SessionStudyDAO new];

    return [dao deleteAllStudiesOfSession: sessionObjectID];
}

@end
