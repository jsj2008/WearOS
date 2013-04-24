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

#import "SessionStudyDAO.h"
#import "SessionStudy.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"

static sqlite3_stmt* retrieveAllStudiesOfSessionStatement   = nil;
static sqlite3_stmt* retrieveAllStudyIDsOfSessionStatement  = nil;
static sqlite3_stmt* deleteAllStudiesOfSessionStatement     = nil;
static sqlite3_stmt* retrieveCountStudiesOfSessionStatement = nil;
static sqlite3_stmt* insertStatement                        = nil;
static sqlite3_stmt* deleteStatement                        = nil;
static sqlite3_stmt* deleteByStudyIDStatement               = nil;


@implementation SessionStudyDAO

- (void)transferSessionStudyData:(SessionStudy*)sessionStudy sessionStudyRow:(sqlite3_stmt*)sessionStudyRow {
    char*  textPtr = nil;

    if ((sessionStudy == nil) || (sessionStudyRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sessionStudyRow,0)))
        sessionStudy.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionStudyRow,1)))
        sessionStudy.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionStudyRow,2)))
        sessionStudy.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionStudyRow,3)))
        sessionStudy.sessionID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionStudyRow,4)))
        sessionStudy.studyID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveCountStudiesOfSession:(NSString*)sessionObjectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStudiesOfSessionStatement == nil) {
        const char* sql = "SELECT count(*) from SessionStudy where sessionID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStudiesOfSessionStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountStudiesOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountStudiesOfSessionStatement) == SQLITE_ROW) {
        NSInteger ruleCount = sqlite3_column_int(retrieveCountStudiesOfSessionStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountStudiesOfSessionStatement);

    return result;
}

- (ResdbResult*)retrieveAllStudiesOfSession:(NSString*)sessionObjectID {

    NSMutableArray*  studies  = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllStudiesOfSessionStatement == nil) {
        const char* sql = "select objectID,creationTime,description,sessionID,studyID from SessionStudy where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStudiesOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllStudiesOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllStudiesOfSessionStatement) == SQLITE_ROW) {
        SessionStudy* sessionStudy = [SessionStudy new];

        [self transferSessionStudyData: sessionStudy sessionStudyRow:retrieveAllStudiesOfSessionStatement];

        [studies addObject: sessionStudy];
    }

    if ([studies count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: studies];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStudiesOfSessionStatement);

    return result;
}

- (ResdbResult*)retrieveAllStudyIDsOfSession:(NSString*)sessionObjectID {

    NSMutableArray*  studyIDs = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllStudyIDsOfSessionStatement == nil) {
        const char* sql = "select studyID from SessionStudy where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStudyIDsOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllStudyIDsOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllStudyIDsOfSessionStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllStudyIDsOfSessionStatement,0)))
            [studyIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([studyIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: studyIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStudyIDsOfSessionStatement);

    return result;
}

- (ResdbResult*)deleteAllStudiesOfSession:(NSString*)sessionObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllStudiesOfSessionStatement == nil) {
        const char* sql = "delete from SessionStudy where sessionID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStudiesOfSessionStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteAllStudiesOfSessionStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteAllStudiesOfSessionStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllStudiesOfSessionStatement);

    return result;
}

- (ResdbResult*)insert:(NSString*)sessionObjectID study:(NSString*)studyObjectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into SessionStudy (objectID,description,sessionID,studyID) values (?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"SessionStudy"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [sessionObjectID UTF8String],              -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [studyObjectID UTF8String],                -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertStudyIDs:(NSArray*)studyIDs session:(NSString*)sessionObjectID {

    ResdbResult* result = nil;

    for (NSString* studyID in studyIDs) {
        result = [self insert: sessionObjectID study: studyID];
    }

    return result;
}

- (ResdbResult*)delete:(NSString*)sessionObjectID study:(NSString*)studyObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from SessionStudy where sessionID = ? and studyID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

                        sqlite3_bind_text(deleteStatement, 1, [sessionObjectID UTF8String], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_text(deleteStatement, 2, [studyObjectID UTF8String],   -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)deleteByStudyID:(NSString*)studyObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByStudyIDStatement == nil) {
        const char* sql = "delete from SessionStudy where studyID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByStudyIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByStudyIDStatement, 1, [studyObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByStudyIDStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByStudyIDStatement);

    return result;
}

@end
