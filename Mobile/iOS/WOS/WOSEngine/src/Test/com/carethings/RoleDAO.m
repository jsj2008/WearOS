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

#import "RoleDAO.h"
#import "WSResourceManager.h"
#import "Role.h"

static sqlite3_stmt* retrieveStatement         = nil;
static sqlite3_stmt* retrieveRoleNameStatement = nil;
static sqlite3_stmt* insertStatement           = nil;
static sqlite3_stmt* retrieveAllStatement      = nil;
static sqlite3_stmt* deleteAllStatement        = nil;
static sqlite3_stmt* updateStatement           = nil;
static sqlite3_stmt* deleteStatement           = nil;
static sqlite3_stmt* deleteByNameStatement     = nil;
static sqlite3_stmt* retrieveByNameStatement   = nil;
static sqlite3_stmt* retrieveCountStatement    = nil;


@implementation RoleDAO

- (void)transferRoleData:(Role*)role:(sqlite3_stmt*)roleRow {
	char*  textPtr = nil;
	
    if ((role == nil) || (roleRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(roleRow,0)))
        role.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleRow,1)))
        role.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleRow,2)))
        role.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleRow,3)))
        role.name = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(roleRow,4) > 0)
        role.image = [NSMutableData dataWithBytes: sqlite3_column_blob(roleRow,4) length: sqlite3_column_bytes(roleRow,4)];
}

+ (NSString*)getRoleName:(NSString*)objectID {
    NSString*            roleName = nil;
    ResdbResult*     result       = [ResdbResult new];


    if (retrieveRoleNameStatement == nil) {
        const char* sql = "select name from Role where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveRoleNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return nil;
        }
    }

    sqlite3_bind_text(retrieveRoleNameStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveRoleNameStatement) == SQLITE_ROW) {
        if ((char*)                                           sqlite3_column_text(retrieveRoleNameStatement,0))
            roleName = [NSString stringWithUTF8String: (char*)sqlite3_column_text(retrieveRoleNameStatement,0)];
    } else {
        roleName = nil;
    }

    sqlite3_reset(retrieveRoleNameStatement);

    return roleName;
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Role*        role         = [Role new];
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,image,hierarchy from Role where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferRoleData: role: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = role;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByName:(NSString*)roleName {
    Role*        role         = [Role new];
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveByNameStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,image,hierarchy from Role where name=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByNameStatement, 1, [roleName UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveByNameStatement) == SQLITE_ROW) {
        [self transferRoleData: role: retrieveByNameStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = role;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByNameStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  categories = [NSMutableArray new];
    ResdbResult*     result     = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,image,hierarchy from Role";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Role* role = [Role new];

        [self transferRoleData: role: retrieveAllStatement];

        [categories addObject: role];
    }

    if ([categories count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = categories;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCount {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStatement == nil) {
        const char* sql = "select count(*) from Role";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

        NSInteger roleCount = sqlite3_column_int(retrieveCountStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",roleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountStatement);

    return result;
}

- (ResdbResult*)insert:(Role*)role {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Role (objectID,description,name,image,hierarchy) values (?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [role.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [role.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [role.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, 4, [role.image bytes], [role.image length], SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [role.hierarchy UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Role*)role {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Role SET objectID = ?, description = ?, name = ?, image = ? , hierarchy = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [role.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [role.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [role.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, 4, [role.image bytes], [role.image length], SQLITE_TRANSIENT);
                        sqlite3_bind_text(updateStatement, 5, [role.hierarchy UTF8String], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_text(updateStatement, 6, [role.objectID UTF8String],  -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from Role";

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

- (ResdbResult*)deleteByName:(NSString*)name {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByNameStatement == nil) {
        const char* sql = "delete from Role where name = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByNameStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByNameStatement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByNameStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByNameStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from Role where objectID = ?";

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
