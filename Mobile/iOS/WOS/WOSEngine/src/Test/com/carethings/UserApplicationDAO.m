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

#import "UserApplicationDAO.h"
#import "UserApplication.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"

@implementation UserApplicationDAO

static sqlite3_stmt* retrieveAllApplicationsOfUserStatement     = nil;
static sqlite3_stmt* retrieveAllApplicationIDsOfUserStatement   = nil;
static sqlite3_stmt* deleteAllApplicationsOfUserStatement       = nil;
static sqlite3_stmt* retrieveCountApplicationsOfUserStatement   = nil;
static sqlite3_stmt* insertStatement                            = nil;
static sqlite3_stmt* deleteStatement                            = nil;
static sqlite3_stmt* deleteByApplicationIDStatement             = nil;
static sqlite3_stmt* retrieveAllApplicationIDsStatement         = nil;
static sqlite3_stmt* retrieveAllUserApplicationsOfUserStatement = nil;
static sqlite3_stmt* deleteByIDStatement                        = nil;


- (void)transferUserApplicationData:(UserApplication*)userApplication userApplicationRow:(sqlite3_stmt*)userApplicationRow {
    char*  textPtr = nil;

    if ((userApplication == nil) || (userApplicationRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(userApplicationRow,0)))
        userApplication.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userApplicationRow,1)))
        userApplication.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userApplicationRow,2)))
        userApplication.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userApplicationRow,3)))
        userApplication.userID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(userApplicationRow,4)))
        userApplication.applicationID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllApplicationsIDs {
    NSMutableArray*  applicationIDs = [NSMutableArray new];
    
    ResdbResult*     result         = [ResdbResult new];

    if (retrieveAllApplicationIDsStatement == nil) {
        const char* sql = "select applicationID from UserApplication";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationIDsStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllApplicationIDsStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllApplicationIDsStatement,0)))
            [applicationIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([applicationIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applicationIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationIDsStatement);

    return result;
}

- (ResdbResult*)retrieveAllUserApplicationsOfUser:(NSString*)userObjectID {
    NSMutableArray*  userApplications = [NSMutableArray new];
    
    ResdbResult*     result           = [ResdbResult new];

    if (retrieveAllUserApplicationsOfUserStatement == nil) {
        const char* sql = "select objectID,creationTime,description,userID,applicationID from UserApplication where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllUserApplicationsOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllUserApplicationsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllUserApplicationsOfUserStatement) == SQLITE_ROW) {
        UserApplication* userApplication = [UserApplication new];

        [self transferUserApplicationData: userApplication userApplicationRow: retrieveAllUserApplicationsOfUserStatement];

        [userApplications addObject: userApplication];
    }

    if ([userApplications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: userApplications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllUserApplicationsOfUserStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationsOfUser:(NSString*)userObjectID {

    NSMutableArray*  applications = [NSMutableArray new];
    
    ResdbResult*     result       = [ResdbResult new];

    if (retrieveAllApplicationsOfUserStatement == nil) {
        const char* sql = "select objectID,creationTime,description,userID,applicationID from UserApplication where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationsOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllApplicationsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllApplicationsOfUserStatement) == SQLITE_ROW) {
        UserApplication* userApplication = [UserApplication new];

        [self transferUserApplicationData: userApplication userApplicationRow: retrieveAllApplicationsOfUserStatement];

        [applications addObject: userApplication];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationsOfUserStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationIDsOfUser:(NSString*)userObjectID {
    NSMutableArray*  applicationIDs = [NSMutableArray new];
    
    ResdbResult*     result         = [ResdbResult new];

    if (retrieveAllApplicationIDsOfUserStatement == nil) {
        const char* sql = "select applicationID from UserApplication where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationIDsOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllApplicationIDsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllApplicationIDsOfUserStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllApplicationIDsOfUserStatement,0)))
            [applicationIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([applicationIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applicationIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationIDsOfUserStatement);

    return result;
}

- (ResdbResult*)retrieveCountApplicationsOfUser:(NSString*)userObjectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountApplicationsOfUserStatement == nil) {
        const char* sql = "SELECT count(*) from UserApplication where userID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountApplicationsOfUserStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountApplicationsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountApplicationsOfUserStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountApplicationsOfUserStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountApplicationsOfUserStatement);

    return result;
}


- (ResdbResult*)deleteAllApplicationsOfUser:(NSString*)userObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllApplicationsOfUserStatement == nil) {
        const char* sql = "delete from UserApplication where userID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllApplicationsOfUserStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteAllApplicationsOfUserStatement, 1, [userObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteAllApplicationsOfUserStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllApplicationsOfUserStatement);

    return result;
}

- (ResdbResult*)insert:(NSString*)userObjectID application:(NSString*)applicationObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into UserApplication (objectID,description,userID,applicationID) values (?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"UserApplication"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [userObjectID UTF8String],                 -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [applicationObjectID UTF8String],          -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertApplicationIDs:(NSArray*)applicationIDs user:(NSString*)userObjectID {
    for (NSString* applicationID in applicationIDs) {
        [self insert: userObjectID application: applicationID];
    }

    return nil;
}

- (ResdbResult*)delete:(NSString*)userObjectID study:(NSString*)applicationObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from UserApplication where userID = ? and applicationID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteStatement, 1, [userObjectID UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteStatement, 2, [applicationObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByIDStatement == nil) {
        const char* sql = "delete from UserApplication where objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByIDStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByIDStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByIDStatement);

    return result;
}

- (ResdbResult*)deleteByApplicationID:(NSString*)applicationObjectID {

    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByApplicationIDStatement == nil) {
        const char* sql = "delete from UserApplication where applicationID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByApplicationIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByApplicationIDStatement, 1, [applicationObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByApplicationIDStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByApplicationIDStatement);

    return result;
}

@end
