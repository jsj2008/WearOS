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

#import "SessionDataTypeDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement                  = nil;
static sqlite3_stmt* insertStatement                    = nil;
static sqlite3_stmt* retrieveAllStatement               = nil;
static sqlite3_stmt* deleteAllStatement                 = nil;
static sqlite3_stmt* updateStatement                    = nil;
static sqlite3_stmt* renameCategoryStatement            = nil;
static sqlite3_stmt* deleteStatement                    = nil;
static sqlite3_stmt* retrieveBySessionDataTypeStatement = nil;
static sqlite3_stmt* retrieveByCategoryStatement        = nil;
static sqlite3_stmt* deleteByCategoryStatement          = nil;
static sqlite3_stmt* retrieveCountByCategoryStatement   = nil;


@implementation SessionDataTypeDAO

- (void)transferSessionDataTypeData:(SessionDataType*)sessionDataType:(sqlite3_stmt*)sessionDataTypeRow {
	char*  textPtr = nil;
	
    if ((sessionDataType == nil) || (sessionDataTypeRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.lookup = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.title = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sessionDataTypeRow,i++)))
        sessionDataType.category = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    SessionDataType*             sessionDataType = [SessionDataType new];
    
    ResdbResult*     result                      = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lookup,title,category from SessionDataType where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferSessionDataTypeData: sessionDataType: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = sessionDataType;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSMutableArray*  sessionDataTypes = [NSMutableArray new];
    
    ResdbResult*     result           = [ResdbResult new];

    if (retrieveByCategoryStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lookup,title,category from SessionDataType where category=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByCategoryStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByCategoryStatement) == SQLITE_ROW) {
        SessionDataType* sessionDataType = [SessionDataType new];

        [self transferSessionDataTypeData: sessionDataType: retrieveByCategoryStatement];

        [sessionDataTypes addObject: sessionDataType];
    }

    if ([sessionDataTypes count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = sessionDataTypes;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByCategoryStatement);

    return result;
}

- (ResdbResult*)retrieveBySessionDataType:(NSString*)sessionDataType {
    NSMutableArray*  sessionDataTypes = [NSMutableArray new];
    
    ResdbResult*     result           = [ResdbResult new];


    if (retrieveBySessionDataTypeStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lookup,title,category from SessionDataType where lookup=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveBySessionDataTypeStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveBySessionDataTypeStatement, 1, [sessionDataType UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveBySessionDataTypeStatement) == SQLITE_ROW) {
        SessionDataType* sessionDataType = [SessionDataType new];

        [self transferSessionDataTypeData: sessionDataType: retrieveBySessionDataTypeStatement];

        [sessionDataTypes addObject: sessionDataType];
    }

    if ([sessionDataTypes count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = sessionDataTypes;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveBySessionDataTypeStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  sessionDataTypes = [NSMutableArray new];
    
    ResdbResult*     result           = [ResdbResult new];


    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lookup,title,category from SessionDataType";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        SessionDataType* sessionDataType = [SessionDataType new];

        [self transferSessionDataTypeData: sessionDataType: retrieveAllStatement];

        [sessionDataTypes addObject: sessionDataType];
    }

    if ([sessionDataTypes count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = sessionDataTypes;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountByCategoryStatement == nil) {
        const char* sql = "SELECT count(*) from SessionDataType where category = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByCategoryStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountByCategoryStatement) == SQLITE_ROW) {

        NSInteger sessionDataTypeCount = sqlite3_column_int(retrieveCountByCategoryStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",sessionDataTypeCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountByCategoryStatement);

    return result;
}

- (ResdbResult*)insert:(SessionDataType*)sessionDataType {
    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into SessionDataType (objectID,description,lookup,title,category) values (?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [sessionDataType.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [sessionDataType.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [sessionDataType.lookup UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [sessionDataType.title UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [sessionDataType.category UTF8String],    -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(SessionDataType*)sessionDataType {
    
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE SessionDataType SET objectID = ?, description = ?, lookup = ?, title = ?, category = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [sessionDataType.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [sessionDataType.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [sessionDataType.lookup UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [sessionDataType.title UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [sessionDataType.category UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [sessionDataType.objectID UTF8String],    -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);

    return result;
}

- (ResdbResult*)renameCategory:(NSString*)oldCategoryName newName:(NSString*)newCategoryName {
    
    ResdbResult*     result   = [ResdbResult new];

    if (renameCategoryStatement == nil) {
        const char* sql = "UPDATE SessionDataType SET category = ? WHERE category = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &renameCategoryStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(renameCategoryStatement, 1, [newCategoryName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(renameCategoryStatement, 2, [oldCategoryName UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(renameCategoryStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(renameCategoryStatement);

    return result;
}

- (ResdbResult*)deleteAll {
    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllStatement == nil) {
        const char* sql = "delete from SessionDataType";

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
        const char* sql = "delete from SessionDataType where objectID = ?";

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

- (ResdbResult*)deleteByCategory:(NSString*)category {
    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByCategoryStatement == nil) {
        const char* sql = "delete from SessionDataType where category = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByCategoryStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByCategoryStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByCategoryStatement);

    return result;
}

@end
