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

#import "RingtoneDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement             = nil;
static sqlite3_stmt* retrieveRingtoneNameStatement = nil;
static sqlite3_stmt* insertStatement               = nil;
static sqlite3_stmt* retrieveAllStatement          = nil;
static sqlite3_stmt* deleteAllStatement            = nil;
static sqlite3_stmt* deleteByRelatedIdStatement    = nil;
static sqlite3_stmt* updateStatement               = nil;
static sqlite3_stmt* deleteStatement               = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement  = nil;


@implementation RingtoneDAO

- (void)transferRingtoneData:(Ringtone*)ringtone:(sqlite3_stmt*)ringtoneRow {
	char*  textPtr = nil;
	
    if ((ringtone == nil) || (ringtoneRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,0)))
        ringtone.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,1)))
        ringtone.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,2)))
        ringtone.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,3)))
        ringtone.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,4)))
        ringtone.fileUrl = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,5)))
        ringtone.timeLength = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(ringtoneRow,6)))
        ringtone.fileSize = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(ringtoneRow,7) > 0)
        ringtone.soundData = [NSMutableData dataWithBytes: sqlite3_column_blob(ringtoneRow,8) length: sqlite3_column_bytes(ringtoneRow,7)];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Ringtone*                        ringtone = [Ringtone new];
    ResdbResult*     result                   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferRingtoneData: ringtone: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = ringtone;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

+ (NSString*)getRingtoneName:(NSString*)objectID {
    NSString*            ringtoneName = nil;
    ResdbResult*     result           = [ResdbResult new];


    if (retrieveRingtoneNameStatement == nil) {
        const char* sql = "select name from Ringtone where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveRingtoneNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return nil;
        }
    }

    sqlite3_bind_text(retrieveRingtoneNameStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveRingtoneNameStatement) == SQLITE_ROW) {
        if ((char*)                                               sqlite3_column_text(retrieveRingtoneNameStatement,0))
            ringtoneName = [NSString stringWithUTF8String: (char*)sqlite3_column_text(retrieveRingtoneNameStatement,0)];
    } else {
        ringtoneName = nil;
    }

    sqlite3_reset(retrieveRingtoneNameStatement);

    return ringtoneName;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSMutableArray*  ringtones = [NSMutableArray new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveByRelatedIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone where relatedID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        Ringtone* ringtone = [Ringtone new];

        [self transferRingtoneData: ringtone: retrieveByRelatedIdStatement];

        [ringtones addObject: ringtone];
    }

    if ([ringtones count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = ringtones;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  ringtones = [NSMutableArray new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Ringtone* ringtone = [Ringtone new];

        [self transferRingtoneData: ringtone: retrieveAllStatement];

        [ringtones addObject: ringtone];
    }

    if ([ringtones count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = ringtones;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)insert:(Ringtone*)ringtone {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Ringtone (objectID,description,name,fileUrl,timeLength,fileSize,soundData) values (?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [ringtone.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [ringtone.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [ringtone.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [ringtone.fileUrl UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [ringtone.timeLength UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [ringtone.fileSize UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, 7, [ringtone.soundData bytes], [ringtone.soundData length], SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Ringtone*)ringtone {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Ringtone SET objectID = ?, description = ?, name = ?, fileUrl = ?, timeLength = ?, fileSize = ?, soundData = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [ringtone.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [ringtone.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [ringtone.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [ringtone.fileUrl UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [ringtone.timeLength UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [ringtone.fileSize UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, 7, [ringtone.soundData bytes], [ringtone.soundData length], SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 8, [ringtone.objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);

    return result;
}


- (ResdbResult*)deleteAll {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllStatement == nil) {
        const char* sql = "delete from Ringtone";

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

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByRelatedIdStatement == nil) {
        const char* sql = "delete from Ringtone where relatedID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByRelatedIdStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByRelatedIdStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from Ringtone where objectID = ?";

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


@end
