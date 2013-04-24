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

#import "SessionPatientDAO.h"
#import "SessionPatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"

static sqlite3_stmt* retrieveAllPatientsOfSessionStatement   = nil;
static sqlite3_stmt* retrieveAllPatientIDsOfSessionStatement = nil;
static sqlite3_stmt* deleteAllPatientsOfSessionStatement     = nil;
static sqlite3_stmt* retrieveCountPatientsOfSessionStatement = nil;
static sqlite3_stmt* insertStatement                         = nil;
static sqlite3_stmt* deleteStatement                         = nil;
static sqlite3_stmt* deleteByPatientIDStatement              = nil;


@implementation SessionPatientDAO

- (void)transferSessionPatientData:(SessionPatient*)sessionPatient sessionPatientRow:(sqlite3_stmt*)sessionPatientRow {
    char*  textPtr = nil;

    if ((sessionPatient == nil) || (sessionPatientRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sessionPatientRow,0)))
        sessionPatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionPatientRow,1)))
        sessionPatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionPatientRow,2)))
        sessionPatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionPatientRow,3)))
        sessionPatient.sessionID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionPatientRow,4)))
        sessionPatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfSession:(NSString*)sessionObjectID {

    NSMutableArray*  patients = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllPatientsOfSessionStatement == nil) {
        const char* sql = "select objectID,creationTime,description,sessionID,patientID from SessionPatient where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientsOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllPatientsOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllPatientsOfSessionStatement) == SQLITE_ROW) {
        SessionPatient* sessionPatient = [SessionPatient new];

        [self transferSessionPatientData: sessionPatient sessionPatientRow: retrieveAllPatientsOfSessionStatement];

        [patients addObject: sessionPatient];
    }

    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllPatientsOfSessionStatement);

    return result;
}

- (ResdbResult*)retrieveAllPatientIDsOfSession:(NSString*)sessionObjectID {
    NSMutableArray*  patientIDs = [NSMutableArray new];
    
    ResdbResult*     result     = [ResdbResult new];

    if (retrieveAllPatientIDsOfSessionStatement == nil) {
        const char* sql = "select patientID from SessionPatient where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientIDsOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllPatientIDsOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllPatientIDsOfSessionStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllPatientIDsOfSessionStatement,0)))
            [patientIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([patientIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patientIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllPatientIDsOfSessionStatement);

    return result;
}

- (ResdbResult*)retrieveCountPatientsOfSession:(NSString*)sessionObjectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountPatientsOfSessionStatement == nil) {
        const char* sql = "SELECT count(*) from SessionPatient where sessionID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountPatientsOfSessionStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountPatientsOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountPatientsOfSessionStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountPatientsOfSessionStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountPatientsOfSessionStatement);

    return result;
}


- (ResdbResult*)deleteAllPatientsOfSession:(NSString*)sessionObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllPatientsOfSessionStatement == nil) {
        const char* sql = "delete from SessionPatient where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllPatientsOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteAllPatientsOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteAllPatientsOfSessionStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllPatientsOfSessionStatement);

    return result;
}

- (ResdbResult*)insert:(NSString*)sessionObjectID patient:(NSString*)patientObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into SessionPatient (objectID,description,sessionID,patientID) values (?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"SessionPatient"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [sessionObjectID UTF8String],              -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [patientObjectID UTF8String],              -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs session:(NSString*)sessionObjectID {
    for (NSString* patientID in patientIDs) {
        [self insert: sessionObjectID patient: patientID];
    }

    return nil;
}

- (ResdbResult*)delete:(NSString*)sessionObjectID patient:(NSString*)patientObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from SessionPatient where sessionID = ? and patientID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteStatement, 2, [patientObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByPatientIDStatement == nil) {
        const char* sql = "delete from SessionPatient where patientID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByPatientIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByPatientIDStatement, 1, [patientObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByPatientIDStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByPatientIDStatement);

    return result;
}

@end
