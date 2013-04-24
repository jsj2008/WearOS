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
 * This code  is the  sole  property of CareThings, Inc. and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade secret, not to be disclosed 
 * without written authorization from CareThings.  Any  use, duplication, or  disclosure of this program  
 * by other than CareThings and its assigned licensees is strictly forbidden by law.
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

static sqlite3_stmt* retrieveStatement                      = nil;
static sqlite3_stmt* insertStatement                        = nil;
static sqlite3_stmt* retrieveAllStatement                   = nil;
static sqlite3_stmt* retrieveActiveSessionStatement         = nil;
static sqlite3_stmt* deleteAllStatement                     = nil;
static sqlite3_stmt* deleteBySessionIdStatement             = nil;
static sqlite3_stmt* updateStatement                        = nil;
static sqlite3_stmt* deleteStatement                        = nil;
static sqlite3_stmt* retrieveBySessionIdStatement           = nil;
static sqlite3_stmt* updateAllNotActiveStatement            = nil;
static sqlite3_stmt* retrieveCompleteSessionsStatement      = nil;
static sqlite3_stmt* retrieveCountStatement                 = nil;
static sqlite3_stmt* retrieveCountCompleteSessionsStatement = nil;

@implementation SessionDAO

- (void)transferSessionData:(Session*)session sessionRow:(sqlite3_stmt*)sessionRow {
    char*  textPtr = nil;

    if ((session == nil) || (sessionRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.organizationID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.sessionID = [NSString stringWithUTF8String: textPtr];
    session.active =     sqlite3_column_int(sessionRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sessionRow, i++)))
        session.investigator = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow, i++)))
        session.referredBy = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow, i++)))
        session.startTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow, i++)))
        session.endTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.sessionType = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.category = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionRow,i++)))
        session.duration = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Session*           session = [Session new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferSessionData: session sessionRow: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = session;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveBySessionId:(NSString*)sessionID {
    Session*           session = [Session new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveBySessionIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where sessionID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveBySessionIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveBySessionIdStatement, 1, [sessionID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveBySessionIdStatement) == SQLITE_ROW) {
        [self transferSessionData: session sessionRow: retrieveBySessionIdStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = session;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveBySessionIdStatement);

    return result;
}

- (ResdbResult*)retrieveActiveSession {
    Session*				session  = [Session new];
    ResdbResult*			result   = [ResdbResult new];


    if (retrieveActiveSessionStatement == nil) {
        const char* sql = "select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where active=1";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveActiveSessionStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveActiveSessionStatement) == SQLITE_ROW) {
        [self transferSessionData: session sessionRow: retrieveActiveSessionStatement];

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = session;                     // This will bump the retain count to keep the object alive

    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveActiveSessionStatement);

    return result;
}


- (ResdbResult*)retrieveAll {
    NSMutableArray*  sessions = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Session* session = [Session new];

        [self transferSessionData: session sessionRow: retrieveAllStatement];

        [sessions addObject: session];
    }

    if ([sessions count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: sessions];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCompleteSessions {
    NSMutableArray*  sessions = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCompleteSessionsStatement == nil) {
        const char* sql = "select objectID,creationTime,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration from Session where startTime is not null and endTime is not null";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCompleteSessionsStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveCompleteSessionsStatement) == SQLITE_ROW) {
        Session* session = [Session new];

        [self transferSessionData: session sessionRow: retrieveCompleteSessionsStatement];

        [sessions addObject: session];
    }

    if ([sessions count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: sessions];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCompleteSessionsStatement);

    return result;
}

- (ResdbResult*)retrieveCount {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStatement == nil) {
        const char* sql = "SELECT count(*) from Session";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountStatement);

    return result;
}

- (ResdbResult*)retrieveCountCompleteSessions {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountCompleteSessionsStatement == nil) {
        const char* sql = "SELECT count(*) from Session where startTime is not null and endTime is not null";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountCompleteSessionsStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveCountCompleteSessionsStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountCompleteSessionsStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountCompleteSessionsStatement);

    return result;
}

- (ResdbResult*)insert:(Session*)session {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Session (objectID,description,organizationID,sessionID,active,investigator,referredBy,startTime,endTime,sessionType,category,duration) values (?,?,?,?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [session.objectID UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [session.description UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [session.organizationID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [session.sessionID UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, 5, session.active);
    sqlite3_bind_text(insertStatement,  6, [session.investigator UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement,  7, [session.referredBy UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement,  8, [session.startTime UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement,  9, [session.endTime UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 10, [session.sessionType UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 11, [session.category UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 12, [session.duration UTF8String],     -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Session*)session {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Session SET objectID = ?,description = ?,organizationID = ?,sessionID = ?,active = ?,investigator = ?,referredBy = ?,startTime = ?,endTime = ?,sessionType = ?,category = ?,duration = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [session.objectID UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [session.description UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [session.organizationID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [session.sessionID UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, 5, session.active);
    sqlite3_bind_text(updateStatement,  6, [session.investigator UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  7, [session.referredBy UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  8, [session.startTime UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  9, [session.endTime UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [session.sessionType UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 11, [session.category UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 12, [session.duration UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 13, [session.objectID UTF8String],     -1, SQLITE_TRANSIENT);


    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);

    return result;
}

- (ResdbResult*)updateAllNotActive {
    ResdbResult*     result   = [ResdbResult new];

    if (updateAllNotActiveStatement == nil) {
        const char* sql = "UPDATE Session SET active = 0";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateAllNotActiveStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    result.sqliteCode = sqlite3_step(updateAllNotActiveStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateAllNotActiveStatement);

    return result;
}

- (ResdbResult*)deleteAll {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllStatement == nil) {
        const char* sql = "delete from Session";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    result.sqliteCode = sqlite3_step(deleteAllStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from Session where objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)deleteBySessionId:(NSString*)sessionID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteBySessionIdStatement == nil) {
        const char* sql = "delete from Session where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteBySessionIdStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteBySessionIdStatement, 1, [sessionID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteBySessionIdStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteBySessionIdStatement);

    return result;
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
