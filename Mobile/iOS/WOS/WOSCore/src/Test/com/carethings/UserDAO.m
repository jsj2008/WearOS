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

#import "UserDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "UserRole.h"
#import "UserRoleDAO.h"
#import "RoleApplicationDAO.h"
#import "RoleDAO.h"

static sqlite3_stmt* retrieveStatement       = nil;
static sqlite3_stmt* insertStatement         = nil;
static sqlite3_stmt* retrieveAllStatement    = nil;
static sqlite3_stmt* deleteAllStatement      = nil;
static sqlite3_stmt* updateStatement         = nil;
static sqlite3_stmt* deleteStatement         = nil;
static sqlite3_stmt* retrieveCountStatement  = nil;


@implementation UserDAO

- (void)transferUserData:(User*)user:(sqlite3_stmt*)userRow {
    char*  textPtr = nil;

    if ((user == nil) || (userRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(userRow,0)))
        user.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,1)))
        user.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,2)))
        user.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,3)))
        user.lastName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,4)))
        user.firstName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,5)))
        user.userNum = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,6)))
        user.gender = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,7)))
        user.weight = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,8)))
        user.height = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userRow,9)))
        user.deviceToken = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    User*            user     = [User new];
    
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken from User where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferUserData: user: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = user;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  studies  = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken from User";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        User* user = [User new];

        [self transferUserData: user: retrieveAllStatement];

        [studies addObject: user];
    }

    if ([studies count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: studies];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplications:(NSString*)userObjectID {
    UserRoleDAO*        dao          = [UserRoleDAO new];
    NSMutableArray*     applications = [NSMutableArray new];
    ResdbResult*        result       = nil;

    result = [dao retrieveAllRoleIDsOfUser: userObjectID];

    if (result.resdbCode == RESDB_SQL_ROWS) {

        for (NSString* roleID in result.resdbCollection) {
            RoleApplicationDAO*  roleAppDAO = [RoleApplicationDAO new];
            ResdbResult*         roleResult = nil;

            roleResult = [roleAppDAO retrieveAllRoleApplicationsOfRole: roleID];

            if (roleResult.resdbCode == RESDB_SQL_ROWS)
                [applications addObjectsFromArray:[roleResult resdbCollection]];
        }
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)retrieveCount {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStatement == nil) {
        const char* sql = "SELECT count(*) from User";

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

- (ResdbResult*)insert:(User*)user {
    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into User (objectID,description,lastName,firstName,userNum,gender,weight,height,deviceToken) values (?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [user.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [user.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [user.lastName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [user.firstName UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [user.userNum UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [user.gender UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 7, [user.weight UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 8, [user.height UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 9, [user.deviceToken UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(User*)user {
    
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE User SET objectID = ?,description = ?,lastName = ?,firstName = ?,userNum = ?,gender = ?,weight = ?,height = ?,deviceToken = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement,  1, [user.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  2, [user.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  3, [user.lastName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  4, [user.firstName UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  5, [user.userNum UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  6, [user.gender UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  7, [user.weight UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  8, [user.height UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  9, [user.deviceToken UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [user.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from User";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));

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
        const char* sql = "delete from User where objectID = ?";

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

- (ResdbResult*)retrieveRoles:(NSString*)userObjectID {

    UserRoleDAO*        dao    = [UserRoleDAO new];
    NSMutableArray*     roles  = [NSMutableArray new];
    ResdbResult*        result = nil;

    result = [dao retrieveAllRolesOfUser: userObjectID];

    if (result.resdbCode == RESDB_SQL_ROWS) {

        for (UserRole*   userRole in result.resdbCollection) {
            RoleDAO*     roleDAO    = [RoleDAO new];
            ResdbResult* roleResult = nil;

            roleResult = [roleDAO retrieve:[userRole roleID]];

            if (roleResult.resdbCode == RESDB_SQL_ROWS)
                [roles addObject:[roleResult resdbObject]];
        }
    }

    if ([roles count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: roles];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)retrieveRole:(NSString*)userObjectID {

    UserDAO*                        dao = [UserDAO new];
    ResdbResult*            tempResult  = nil;
    ResdbResult*        result          = [ResdbResult new];

    tempResult = [dao retrieveRoles: userObjectID];

    if (tempResult.resdbCode == RESDB_SQL_ROWS) {
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return result;
}

- (ResdbResult*)addRole:(NSString*)roleObjectID session:(NSString*)userObjectID {

    UserRoleDAO*    dao = [UserRoleDAO new];

    return [dao insert: userObjectID role: roleObjectID];
}

- (ResdbResult*)delete:(NSString*)objectID role:(NSString*)roleID {
	return nil;
}

- (ResdbResult*)removeRole:(NSString*)roleObjectID user:(NSString*)userObjectID {

    UserRoleDAO*    dao = [UserRoleDAO new];

    return [dao delete: userObjectID role: roleObjectID];
}

- (ResdbResult*)removeAllRoles:(NSString*)userObjectID {

    UserRoleDAO*    dao = [UserRoleDAO new];

    return [dao deleteAllRolesOfUser: userObjectID];
}

@end
