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

#import "UserRoleDAO.h"
#import "UserRole.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"

static sqlite3_stmt* retrieveAllRolesOfUserStatement   = nil;
static sqlite3_stmt* retrieveAllRoleIDsOfUserStatement = nil;
static sqlite3_stmt* deleteAllRolesOfUserStatement     = nil;
static sqlite3_stmt* retrieveCountRolesOfUserStatement = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* deleteByRoleIDStatement           = nil;


@implementation UserRoleDAO

- (void)transferUserRoleData:(UserRole*)userRole userRoleRow:(sqlite3_stmt*)userRoleRow {
    char*  textPtr = nil;

    if ((userRole == nil) || (userRoleRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(userRoleRow,0)))
        userRole.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRoleRow,1)))
        userRole.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRoleRow,2)))
        userRole.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRoleRow,3)))
        userRole.userID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRoleRow,4)))
        userRole.roleID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllRolesOfUser:(NSString*)userObjectID {

    NSMutableArray*  roles    = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllRolesOfUserStatement == nil) {
        const char* sql = "select objectID,creationTime,description,userID,roleID from UserRole where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllRolesOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllRolesOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllRolesOfUserStatement) == SQLITE_ROW) {
        UserRole* userRole = [UserRole new];

        [self transferUserRoleData: userRole userRoleRow: retrieveAllRolesOfUserStatement];

        [roles addObject: userRole];
    }

    if ([roles count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: roles];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllRolesOfUserStatement);

    return result;
}

- (ResdbResult*)retrieveAllRoleIDsOfUser:(NSString*)userObjectID {
    NSMutableArray*  roleIDs  = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllRoleIDsOfUserStatement == nil) {
        const char* sql = "select roleID from UserRole where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllRoleIDsOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllRoleIDsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllRoleIDsOfUserStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllRoleIDsOfUserStatement,0)))
            [roleIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([roleIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: roleIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllRoleIDsOfUserStatement);

    return result;
}

- (ResdbResult*)retrieveCountRolesOfUser:(NSString*)userObjectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountRolesOfUserStatement == nil) {
        const char* sql = "SELECT count(*) from UserRole where userID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountRolesOfUserStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountRolesOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountRolesOfUserStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountRolesOfUserStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
		
        result.resdbObject             = [ResdbObject new];
		result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountRolesOfUserStatement);

    return result;
}


- (ResdbResult*)deleteAllRolesOfUser:(NSString*)userObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllRolesOfUserStatement == nil) {
        const char* sql = "delete from UserRole where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllRolesOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteAllRolesOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteAllRolesOfUserStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllRolesOfUserStatement);

    return result;
}

- (ResdbResult*)insert:(NSString*)userObjectID role:(NSString*)roleObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into UserRole (objectID,description,userID,roleID) values (?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"UserRole"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [userObjectID UTF8String],                 -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [roleObjectID UTF8String],                 -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertRoleIDs:(NSArray*)roleIDs user:(NSString*)userObjectID {

    ResdbResult* result = nil;

    for (NSString* roleID in roleIDs) {
        result = [self insert: userObjectID role: roleID];
    }

    return result;
}

- (ResdbResult*)delete:(NSString*)userObjectID role:(NSString*)roleObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from UserRole where userID = ? and roleID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

                        sqlite3_bind_text(deleteStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_text(deleteStatement, 2, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)deleteByRoleID:(NSString*)roleObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByRoleIDStatement == nil) {
        const char* sql = "delete from UserRole where roleID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRoleIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByRoleIDStatement, 1, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByRoleIDStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByRoleIDStatement);

    return result;
}

@end
