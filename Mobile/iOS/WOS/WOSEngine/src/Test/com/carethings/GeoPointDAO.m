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

#import "GeoPointDAO.h"
#import "WSResourceManager.h"
#import "GeoPoint.h"

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* deleteByRelatedIdStatement        = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement      = nil;
static sqlite3_stmt* retrieveCountByRelatedIdStatement = nil;


@implementation GeoPointDAO

- (void)transferGeoPointData:(GeoPoint*)geoPoint:(sqlite3_stmt*)geoPointRow {
    char*  textPtr = nil;

    if ((geoPoint == nil) || (geoPointRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(geoPointRow,i++)))
		geoPoint.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geoPointRow,i++)))
        geoPoint.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(geoPointRow,i++)))
        geoPoint.description = [NSString stringWithUTF8String: textPtr];
    geoPoint.latitude  = sqlite3_column_double(geoPointRow,i++);
    geoPoint.longitude = sqlite3_column_double(geoPointRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(geoPointRow,i++)))
        geoPoint.relatedID = [NSString stringWithUTF8String: textPtr];
    geoPoint.accuracy = sqlite3_column_double(geoPointRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    GeoPoint*        geoPoint = [GeoPoint new];
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferGeoPointData: geoPoint: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = geoPoint;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);
    sqlite3_clear_bindings(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSMutableArray*  geoPoints = [NSMutableArray new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveByRelatedIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint where relatedID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        GeoPoint* geoPoint = [GeoPoint new];

        [self transferGeoPointData: geoPoint: retrieveByRelatedIdStatement];

        [geoPoints addObject: geoPoint];
    }

    if ([geoPoints count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = geoPoints;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);
    sqlite3_clear_bindings(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  geoPoints = [NSMutableArray new];
    ResdbResult*     result    = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        GeoPoint* geoPoint = [GeoPoint new];

        [self transferGeoPointData: geoPoint: retrieveAllStatement];

        [geoPoints addObject: geoPoint];
    }

    if ([geoPoints count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = geoPoints;
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
        const char* sql = "SELECT count(*) from GeoPoint where relatedID = ?";

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

- (ResdbResult*)insert:(GeoPoint*)geoPoint {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into GeoPoint (objectID,description,latitude,longitude,relatedID,accuracy) values (?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [geoPoint.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [geoPoint.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(insertStatement, 3, geoPoint.latitude);
    sqlite3_bind_double(insertStatement, 4, geoPoint.longitude);
    sqlite3_bind_text(insertStatement, 5, [geoPoint.relatedID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(insertStatement, 6, geoPoint.accuracy);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertByArray:(NSArray*)points {
    for (GeoPoint* point in points) {
        [self insert: point];
    }

    return nil;
}

- (ResdbResult*)update:(GeoPoint*)geoPoint {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE GeoPoint SET objectID = ?,description = ?,latitude = ?,longitude = ?,relatedID = ?,accuracy = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [geoPoint.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [geoPoint.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(updateStatement, 3, geoPoint.latitude);
    sqlite3_bind_double(updateStatement, 4, geoPoint.longitude);
    sqlite3_bind_text(updateStatement, 5, [geoPoint.relatedID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(updateStatement, 6, geoPoint.accuracy);
    sqlite3_bind_text(updateStatement, 7, [geoPoint.objectID UTF8String], -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from GeoPoint";

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
        const char* sql = "delete from GeoPoint where relatedID = ?";

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
        const char* sql = "delete from GeoPoint where objectID = ?";

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
