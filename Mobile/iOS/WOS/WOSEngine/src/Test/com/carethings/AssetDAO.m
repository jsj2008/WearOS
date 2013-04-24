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

#import "AssetDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt *retrieveStatement = nil;
static sqlite3_stmt *retrieveDataByIdStatement = nil;
static sqlite3_stmt *retrieveCountStatement = nil;
static sqlite3_stmt *insertStatement = nil;
static sqlite3_stmt *retrieveAllStatement = nil;
static sqlite3_stmt *deleteAllStatement = nil;
static sqlite3_stmt *deleteByRelatedIdStatement = nil;
static sqlite3_stmt *updateStatement = nil;
static sqlite3_stmt *deleteStatement = nil;
static sqlite3_stmt *retrieveByRelatedIdStatement = nil;
static sqlite3_stmt *retrieveByPatientIdStatement = nil;
static sqlite3_stmt *retrieveByUnArchivedStatement = nil;
static sqlite3_stmt *retrieveByUnAssetArchivedStatement = nil;
static sqlite3_stmt *updateAllArchivedStatement = nil;
static sqlite3_stmt *updateAllUnArchiveStatement = nil;
static sqlite3_stmt *updateNullPatientIDStatement = nil;


@implementation AssetDAO

- (void)transferAssetData:(Asset *)asset:(sqlite3_stmt *)assetRow {
    char *textPtr = nil;

    if ((asset == nil) || (assetRow == nil))
        return;

    int i = 0;

    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.worldModel = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.assetID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.fileUrl = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.timeLength = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.fileSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.relatedID = [NSString stringWithUTF8String:textPtr];
    //if (sqlite3_column_bytes(assetRow, i) > 0)
    //    asset.data = [NSMutableData dataWithBytes:sqlite3_column_blob(assetRow, i) length:sqlite3_column_bytes(assetRow, i)];
    //i++;
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.originator = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.location = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.locationCode = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
        asset.patientID = [NSString stringWithUTF8String:textPtr];
    asset.assetType = sqlite3_column_int(assetRow, i++);
    asset.archived  = (bool) sqlite3_column_int(assetRow, i++);
    asset.assetArchived = (bool) sqlite3_column_int(assetRow, i++);
    if ((textPtr = (char *) sqlite3_column_text(assetRow, i++)))
            asset.container = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult *)retrieveDataById:(NSString *)objectID {
    Asset*       asset  = [Asset new];
    ResdbResult* result = [ResdbResult new];
	
    if (retrieveDataByIdStatement == nil) {
        const char *sql = "select data from Asset where objectID=?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveDataByIdStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveDataByIdStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveDataByIdStatement) == SQLITE_ROW) {
		asset.data = [NSMutableData dataWithBytes:sqlite3_column_blob(retrieveDataByIdStatement, 0) length:(NSUInteger) sqlite3_column_bytes(retrieveDataByIdStatement, 0)];

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = asset;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveDataByIdStatement);
	
    return result;
}

- (ResdbResult *)retrieve:(NSString *)objectID {
    Asset *asset = [Asset new];
    ResdbResult *result = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char *sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferAssetData:asset :retrieveStatement];
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbObject = asset;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveCount {
	ResdbResult*  result   = [ResdbResult new];
	
	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Asset";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {
		NSInteger actCount = sqlite3_column_int(retrieveCountStatement,0);
		
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [[NSString alloc] initWithFormat: @"%d",actCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveCountStatement);
	sqlite3_clear_bindings(retrieveCountStatement);
	
	return result;
}

- (ResdbResult *)retrieveByRelatedId:(NSString *)relatedID {
    NSMutableArray *memos = [NSMutableArray new];
    ResdbResult *result = [ResdbResult new];

    if (retrieveByRelatedIdStatement == nil) {
        const char *sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where relatedID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        Asset *asset = [Asset new];

        [self transferAssetData:asset :retrieveByRelatedIdStatement];

        [memos addObject:asset];
    }

    if ([memos count] > 0) {
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbCollection = memos;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveUnArchived {
	NSMutableArray*     assets          = [NSMutableArray new];
	ResdbResult*        result          = [ResdbResult new];

	if (retrieveByUnArchivedStatement == nil) {
		const char* sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where archived=0";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByUnArchivedStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveByUnArchivedStatement) == SQLITE_ROW) {
		Asset* asset = [Asset new];

		[self transferAssetData: asset: retrieveByUnArchivedStatement];

		[assets addObject: asset];
	}

	if ([assets count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = assets;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByUnArchivedStatement);
	sqlite3_clear_bindings(retrieveByUnArchivedStatement);

	return result;
}

- (ResdbResult*)retrieveUnAssetArchived {
	NSMutableArray*     assets          = [NSMutableArray new];
	ResdbResult*        result          = [ResdbResult new];

	if (retrieveByUnAssetArchivedStatement == nil) {
		const char* sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where assetArchived=0";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByUnAssetArchivedStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveByUnAssetArchivedStatement) == SQLITE_ROW) {
		Asset* asset = [Asset new];

		[self transferAssetData: asset: retrieveByUnAssetArchivedStatement];

		[assets addObject: asset];
	}

	if ([assets count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = assets;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByUnAssetArchivedStatement);
	sqlite3_clear_bindings(retrieveByUnAssetArchivedStatement);

	return result;
}

- (ResdbResult*)updateAllArchived {
	ResdbResult*     result   = [ResdbResult new];

	if (updateAllArchivedStatement == nil) {
		const char* sql = "UPDATE Asset SET archived=1,assetArchived=1";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateAllArchivedStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	result.sqliteCode = sqlite3_step(updateAllArchivedStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateAllArchivedStatement);
	sqlite3_clear_bindings(updateAllArchivedStatement);

	return result;
}

- (ResdbResult*)updateAllUnArchive {
	ResdbResult*     result = [ResdbResult new];

	if (updateAllUnArchiveStatement == nil) {
		const char* sql = "UPDATE Asset SET archived=0,assetArchived=0";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateAllUnArchiveStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	result.sqliteCode = sqlite3_step(updateAllUnArchiveStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateAllUnArchiveStatement);
	sqlite3_clear_bindings(updateAllUnArchiveStatement);

	return result;
}

- (ResdbResult *)retrieveByPatientId:(NSString *)patientID {
    NSMutableArray *memos = [NSMutableArray new];
    ResdbResult *result = [ResdbResult new];

    if (retrieveByPatientIdStatement == nil) {
        const char *sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where patientID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByPatientIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByPatientIdStatement, 1, [patientID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByPatientIdStatement) == SQLITE_ROW) {
        Asset *asset = [Asset new];

        [self transferAssetData:asset :retrieveByPatientIdStatement];

        [memos addObject:asset];
    }

    if ([memos count] > 0) {
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbCollection = memos;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByPatientIdStatement);

    return result;
}

- (ResdbResult *)retrieveAll {
    NSMutableArray *memos = [NSMutableArray new];
    ResdbResult *result = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char *sql = "select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,container from Asset";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Asset *asset = [Asset new];

        [self transferAssetData:asset :retrieveAllStatement];

        [memos addObject:asset];
    }

    if ([memos count] > 0) {
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbCollection = memos;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult *)insert:(Asset *)asset {
    ResdbResult *result = [ResdbResult new];

    if (insertStatement == nil) {
        const char *sql = "INSERT into Asset (objectID,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,data,originator,location,locationCode,patientID,assetType,archived,assetArchived,container) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1,  [asset.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2,  [asset.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3,  [asset.worldModel UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4,  [asset.assetID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5,  [asset.fileUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6,  [asset.timeLength UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 7,  [asset.fileSize UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 8,  [asset.relatedID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, 9,  [asset.data bytes], [asset.data length], SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 10, [asset.originator UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 11, [asset.location UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 12, [asset.locationCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 13, [asset.patientID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement,  14, asset.assetType);
    sqlite3_bind_int(insertStatement,  15, asset.archived);
    sqlite3_bind_int(insertStatement,  16, asset.assetArchived);
    sqlite3_bind_text(insertStatement, 17, [asset.container UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult *)updateNullPatientId {
    ResdbResult *result = [ResdbResult new];
	
    if (updateNullPatientIDStatement == nil) {
        const char *sql = "UPDATE Asset SET patientID = 'NONE' WHERE patientID isNull";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateNullPatientIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
		
    result.sqliteCode = sqlite3_step(updateNullPatientIDStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(updateNullPatientIDStatement);
	
    return result;
}

- (ResdbResult *)update:(Asset *)asset {
    ResdbResult *result = [ResdbResult new];

    if (updateStatement == nil) {
        const char *sql = "UPDATE Asset SET objectID = ?, description = ?, worldModel = ?, assetID = ?, fileUrl = ?, timeLength = ?, fileSize = ?, relatedID = ?, data = ?, originator = ?, location = ?, locationCode = ?, patientID = ?, assetType = ?, archived = ?, assetArchived = ?, container = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [asset.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [asset.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [asset.worldModel UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [asset.assetID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [asset.fileUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [asset.timeLength UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 7, [asset.fileSize UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 8, [asset.relatedID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, 9, [asset.data bytes], [asset.data length], SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [asset.originator UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 11, [asset.location UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 12, [asset.locationCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 13, [asset.patientID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement,  14, asset.assetType);
    sqlite3_bind_int(updateStatement,  15, asset.archived);
    sqlite3_bind_int(updateStatement,  16, asset.assetArchived);
    sqlite3_bind_text(updateStatement, 17, [asset.container UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 18, [asset.objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);

    return result;
}

- (ResdbResult *)deleteAll {
    ResdbResult *result = [ResdbResult new];

    if (deleteAllStatement == nil) {
        const char *sql = "delete from Asset";

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

- (ResdbResult *)deleteByRelatedId:(NSString *)relatedID {
    ResdbResult *result = [ResdbResult new];

    if (deleteByRelatedIdStatement == nil) {
        const char *sql = "delete from Asset where relatedID = ?";

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

- (ResdbResult *)delete:(NSString *)objectID {
    ResdbResult *result = [ResdbResult new];

    if (deleteStatement == nil) {
        const char *sql = "delete from Asset where objectID = ?";

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
