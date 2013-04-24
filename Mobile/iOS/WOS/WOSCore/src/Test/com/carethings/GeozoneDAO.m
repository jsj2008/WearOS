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

#import "GeozoneDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "Geozone.h"
#import "GeoPointDAO.h"

static sqlite3_stmt* retrieveStatement                  = nil;
static sqlite3_stmt* insertStatement                    = nil;
static sqlite3_stmt* retrieveAllStatement               = nil;
static sqlite3_stmt* deleteAllStatement                 = nil;
static sqlite3_stmt* deleteByRelatedIdStatement         = nil;
static sqlite3_stmt* updateStatement                    = nil;
static sqlite3_stmt* deleteStatement                    = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement       = nil;
static sqlite3_stmt* retrieveCountByRelatedIdStatement  = nil;


@implementation GeozoneDAO

- (void)transferGeozoneData:(Geozone*)geozone:(sqlite3_stmt*)geozoneRow {
    char*  textPtr = nil;

    if ((geozone == nil) || (geozoneRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.name = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.relatedID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geozoneRow,i++)))
        geozone.alertDistance = [NSString stringWithUTF8String: textPtr];
    geozone.active =     sqlite3_column_int(geozoneRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Geozone*        geozone   = [Geozone new];
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferGeozoneData: geozone: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = geozone;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);
    sqlite3_clear_bindings(retrieveStatement);

    return result;
}

- (ResdbResult*)retrievePoints:(NSString*)objectID {
    GeoPointDAO* dao = [GeoPointDAO new];

    return [dao retrieveByRelatedId: objectID];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSMutableArray*  geozones = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveByRelatedIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where relatedID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        Geozone* geozone = [Geozone new];

        [self transferGeozoneData: geozone: retrieveByRelatedIdStatement];

        [geozones addObject: geozone];
    }

    if ([geozones count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = geozones;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);
    sqlite3_clear_bindings(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveActiveByRelatedId:(NSString*)relatedID {
    NSMutableArray*  geozones = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveByRelatedIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where relatedID=? and active=1";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        Geozone* geozone = [Geozone new];

        [self transferGeozoneData: geozone: retrieveByRelatedIdStatement];

        [geozones addObject: geozone];
    }

    if ([geozones count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = geozones;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);
    sqlite3_clear_bindings(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  activities = [NSMutableArray new];
    ResdbResult*     result     = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Geozone* geozone = [Geozone new];

        [self transferGeozoneData: geozone: retrieveAllStatement];

        [activities addObject: geozone];
    }

    if ([activities count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = activities;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);
    sqlite3_clear_bindings(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountByRelatedIdStatement == nil) {
        const char* sql = "SELECT count(*) from Geozone where relatedID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountByRelatedIdStatement) == SQLITE_ROW) {

        NSInteger alertCount = sqlite3_column_int(retrieveCountByRelatedIdStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",alertCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountByRelatedIdStatement);

    return result;
}

- (ResdbResult*)insert:(Geozone*)geozone {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Geozone (objectID,description,name,relatedID,alertDistance,active) values (?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [geozone.objectID UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [geozone.description UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [geozone.name UTF8String],          -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [geozone.relatedID UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [geozone.alertDistance UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, 6, geozone.active);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Geozone*)geozone {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Geozone SET objectID = ?,description = ?,name = ?,relatedID = ?,alertDistance = ?,active = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [geozone.objectID UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [geozone.description UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [geozone.name UTF8String],          -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [geozone.relatedID UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [geozone.alertDistance UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, 6, geozone.active);
    sqlite3_bind_text(updateStatement, 7, [geozone.objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);
    sqlite3_clear_bindings(updateStatement);

    return result;
}


- (ResdbResult*)deleteAll {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllStatement == nil) {
        const char* sql = "delete from Geozone";

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
    sqlite3_clear_bindings(deleteAllStatement);

    return result;
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByRelatedIdStatement == nil) {
        const char* sql = "delete from Geozone where relatedID = ?";

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
    sqlite3_clear_bindings(deleteByRelatedIdStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from Geozone where objectID = ?";

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
    sqlite3_clear_bindings(deleteStatement);

    return result;
}


@end
