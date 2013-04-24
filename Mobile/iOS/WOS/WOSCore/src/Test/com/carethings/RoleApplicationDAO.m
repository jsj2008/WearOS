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

#import "RoleApplicationDAO.h"
#import "RoleApplication.h"
#import "ApplicationDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "MedStudyDebug.h"
#import "ResourceIdentityGenerator.h"
#import "RoleDAO.h"
#import "Role.h"

static sqlite3_stmt* retrieveAllStatement                              = nil;
static sqlite3_stmt* retrieveAllApplicationsOfRoleStatement            = nil;
static sqlite3_stmt* retrieveAllApplicationIDsOfRoleStatement          = nil;
static sqlite3_stmt* retrieveAllApplicationsOfRoleArrayStatement       = nil;
static sqlite3_stmt* deleteAllApplicationsOfRoleStatement              = nil;
static sqlite3_stmt* retrieveCountApplicationsOfRoleStatement          = nil;
static sqlite3_stmt* insertStatement                                   = nil;
static sqlite3_stmt* deleteStatement                                   = nil;
static sqlite3_stmt* deleteByApplicationIDStatement                    = nil;
static sqlite3_stmt* retrieveAllApplicationIDsOfRoleHierarchyStatement = nil;
static sqlite3_stmt* retrieveAllApplicationIDsOfRoleListStatement      = nil;


@implementation RoleApplicationDAO

- (void)transferRoleApplicationData:(RoleApplication*)roleApplication roleApplicationRow:(sqlite3_stmt*)roleApplicationRow {
    char*  textPtr = nil;

    if ((roleApplication == nil) || (roleApplicationRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,0)))
        roleApplication.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,1)))
        roleApplication.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,2)))
        roleApplication.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,3)))
        roleApplication.roleID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,4)))
        roleApplication.applicationID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(roleApplicationRow,5)))
        roleApplication.roleHierarchy = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,roleID,applicationID,roleHierarchy from RoleApplication";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        RoleApplication* roleApplication = [RoleApplication new];

        [self transferRoleApplicationData: roleApplication roleApplicationRow: retrieveAllStatement];

        [applications addObject: roleApplication];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplications {
    ResdbResult*     result       = nil;
    NSMutableArray*  applications = [NSMutableArray new];

    result = [self retrieveAll];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        ApplicationDAO*   dao       = [ApplicationDAO new];
        ResdbResult*      appResult = nil;

        for (RoleApplication* roleApplication in result.resdbCollection) {
            appResult = [dao retrieve: roleApplication.applicationID];

            if (appResult.resdbCode == RESDB_SQL_ROWS)
                [applications addObject: appResult.resdbObject];
        }
    }

    ResdbResult*  finalResult = [ResdbResult new];

    if ([applications count] > 0) {
        finalResult.sqliteCode      = SQLITE_ROW;
        finalResult.resdbCode       = RESDB_SQL_ROWS;
        finalResult.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        finalResult.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return finalResult;
}

- (ResdbResult*)retrieveAllApplicationsIDs {
    ResdbResult*     result       = nil;
    NSMutableArray*  applications = [NSMutableArray new];

    result = [self retrieveAll];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        for (RoleApplication* roleApplication in result.resdbCollection)
            [applications addObject: roleApplication.applicationID];
    }

    ResdbResult*  finalResult = [ResdbResult new];

    if ([applications count] > 0) {
        finalResult.sqliteCode      = SQLITE_ROW;
        finalResult.resdbCode       = RESDB_SQL_ROWS;
        finalResult.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        finalResult.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return finalResult;
}

- (ResdbResult*)retrieveAllRoleApplicationsOfRole:(NSString*)roleObjectID {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];

    if (retrieveAllApplicationsOfRoleStatement == nil) {
        const char* sql = "select objectID,creationTime,description,roleID,applicationID,roleHierarchy from RoleApplication where roleID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationsOfRoleStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllApplicationsOfRoleStatement, 1, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllApplicationsOfRoleStatement) == SQLITE_ROW) {
        RoleApplication* roleApplication = [RoleApplication new];

        [self transferRoleApplicationData: roleApplication roleApplicationRow: retrieveAllApplicationsOfRoleStatement];

        [applications addObject: roleApplication];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationsOfRoleStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationsOfRole:(NSString*)roleObjectID {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = nil;

    result = [self retrieveAllRoleApplicationsOfRole: roleObjectID];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        ApplicationDAO*   dao       = [ApplicationDAO new];
        ResdbResult*      appResult = nil;

        for (RoleApplication* roleApplication in result.resdbCollection) {
            appResult = [dao retrieve: roleApplication.applicationID];

            if (appResult.resdbCode == RESDB_SQL_ROWS)
                [applications addObject: appResult.resdbObject];
        }
    }

    ResdbResult*  finalResult = [ResdbResult new];

    if ([applications count] > 0) {
        finalResult.sqliteCode      = SQLITE_ROW;
        finalResult.resdbCode       = RESDB_SQL_ROWS;
        finalResult.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        finalResult.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return finalResult;
}

- (ResdbResult*)retrieveAllRoleApplicationsOfRoleList:(NSArray*)roleObjectIDList {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];

    if ((roleObjectIDList == nil) || [roleObjectIDList count] == 0) {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
        return result;
    }

    NSMutableString* sqlInStmt = [NSMutableString new];

    [sqlInStmt appendString: @"select objectID,creationTime,description,roleID,applicationID,roleHierarchy from RoleApplication where roleID in ("];

    for (NSString* roleID in roleObjectIDList) {
        [sqlInStmt appendFormat: @"'%@',", roleID];
    }

    [sqlInStmt replaceCharactersInRange: NSMakeRange(([sqlInStmt length] - 1), 1) withString: @")"];

    if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], [sqlInStmt UTF8String], -1, &retrieveAllApplicationsOfRoleArrayStatement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
        result.resdbCode = RESDB_SQL_ERROR;

        return result;
    }

    while (sqlite3_step(retrieveAllApplicationsOfRoleArrayStatement) == SQLITE_ROW) {
        RoleApplication* roleApplication = [RoleApplication new];

        [self transferRoleApplicationData: roleApplication roleApplicationRow: retrieveAllApplicationsOfRoleArrayStatement];

        [applications addObject: roleApplication];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationsOfRoleArrayStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationsOfRoleList:(NSArray*)roleObjectIDList {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = nil;

    result = [self retrieveAllRoleApplicationsOfRoleList: roleObjectIDList];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        ApplicationDAO*   dao       = [ApplicationDAO new];
        ResdbResult*      appResult = nil;

        for (RoleApplication* roleApplication in result.resdbCollection) {
            appResult = [dao retrieve: roleApplication.applicationID];

            if (appResult.resdbCode == RESDB_SQL_ROWS)
                [applications addObject: appResult.resdbObject];
        }
    }

    ResdbResult*  finalResult = [ResdbResult new];

    if ([applications count] > 0) {
        finalResult.sqliteCode      = SQLITE_ROW;
        finalResult.resdbCode       = RESDB_SQL_ROWS;
        finalResult.resdbCollection = [[NSArray alloc] initWithArray: applications];
    } else {
        finalResult.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    return finalResult;
}

- (ResdbResult*)retrieveAllApplicationIDsOfRole:(NSString*)roleObjectID {
    NSMutableArray*  applicationIDs = [NSMutableArray new];
    ResdbResult*     result         = [ResdbResult new];

    if (retrieveAllApplicationIDsOfRoleStatement == nil) {
        const char* sql = "select applicationID from RoleApplication where roleID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationIDsOfRoleStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllApplicationIDsOfRoleStatement, 1, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllApplicationIDsOfRoleStatement) == SQLITE_ROW) {

        if ((textPtr = (char*)sqlite3_column_text(retrieveAllApplicationIDsOfRoleStatement,0)))
            [applicationIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([applicationIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applicationIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationIDsOfRoleStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationIDsOfRoleList:(NSArray*)roleObjectIDList {
    NSMutableArray*  applicationIDs = [NSMutableArray new];
    ResdbResult*     result         = [ResdbResult new];

    if ((roleObjectIDList == nil) || [roleObjectIDList count] == 0) {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
        return result;
    }

    NSMutableString* sqlInStmt = [NSMutableString new];

    [sqlInStmt appendString: @"select applicationID from RoleApplication where roleID in ("];

    for (NSString* roleID in roleObjectIDList) {
        [sqlInStmt appendFormat: @"'%@',", roleID];
    }

    [sqlInStmt replaceCharactersInRange: NSMakeRange(([sqlInStmt length] - 1), 1) withString: @")"];

    if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], [sqlInStmt UTF8String], -1, &retrieveAllApplicationIDsOfRoleListStatement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
        result.resdbCode = RESDB_SQL_ERROR;

        return result;
    }

    char*  textPtr = nil;

    while (sqlite3_step(retrieveAllApplicationIDsOfRoleListStatement) == SQLITE_ROW) {
        if ((textPtr = (char*)sqlite3_column_text(retrieveAllApplicationIDsOfRoleListStatement,0)))
            [applicationIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([applicationIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applicationIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationIDsOfRoleListStatement);

    return result;
}

- (ResdbResult*)retrieveCountApplicationsOfRole:(NSString*)roleObjectID {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountApplicationsOfRoleStatement == nil) {
        const char* sql = "SELECT count(*) from RoleApplication where roleID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountApplicationsOfRoleStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountApplicationsOfRoleStatement, 1, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountApplicationsOfRoleStatement) == SQLITE_ROW) {

        NSInteger ruleCount = sqlite3_column_int(retrieveCountApplicationsOfRoleStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [ResdbObject new];
		result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountApplicationsOfRoleStatement);

    return result;
}

- (ResdbResult*)retrieveAllApplicationIDsOfRoleHierarchy:(NSString*)hierarchy {
    NSMutableArray*    applicationIDs = [NSMutableArray new];
    ResdbResult*       result         = [ResdbResult new];
    NSMutableString*   srchString     = [NSMutableString new];
    char*              textPtr        = nil;

    [srchString setString: @"%"];
    [srchString appendString: hierarchy];
    [srchString appendString: @"%"];

    if (retrieveAllApplicationIDsOfRoleHierarchyStatement == nil) {
        const char* sql = "select applicationID from RoleApplication where roleHierarchy like ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllApplicationIDsOfRoleHierarchyStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllApplicationIDsOfRoleHierarchyStatement, 1, [srchString UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllApplicationIDsOfRoleHierarchyStatement) == SQLITE_ROW) {
        if ((textPtr = (char*)sqlite3_column_text(retrieveAllApplicationIDsOfRoleHierarchyStatement,0)))
            [applicationIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }

    if ([applicationIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: applicationIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllApplicationIDsOfRoleHierarchyStatement);

    return result;
}

- (ResdbResult*)deleteAllApplicationsOfRole:(NSString*)roleObjectID {

    ResdbResult*     result   = [ResdbResult new];

    if (deleteAllApplicationsOfRoleStatement == nil) {
        const char* sql = "delete from RoleApplication where roleID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllApplicationsOfRoleStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteAllApplicationsOfRoleStatement, 1, [roleObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteAllApplicationsOfRoleStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteAllApplicationsOfRoleStatement);

    return result;
}

- (ResdbResult*)insert:(RoleApplication*)roleApplication {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into RoleApplication (objectID,description,roleID,applicationID,roleHierarchy) values (?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"RoleApplication"] fragment] UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [roleApplication.description UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [roleApplication.roleID UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [roleApplication.applicationID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [roleApplication.roleHierarchy UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)insertApplicationIDs:(NSArray*)applicationIDs role:(NSString*)roleObjectID {

    ResdbResult* result = nil;
    RoleDAO*     dao    = [RoleDAO new];
    Role*        role   = nil;

    result = [dao retrieve: roleObjectID];
    role   = (Role*)result.resdbObject;

    for (NSString* applicationID in applicationIDs) {
        RoleApplication* roleApplication = [RoleApplication new];

        roleApplication.roleID        = roleObjectID;
        roleApplication.applicationID = applicationID;
        roleApplication.roleHierarchy = role.hierarchy;

        [self insert:roleApplication];
    }

    return nil;
}

- (ResdbResult*)delete:(NSString*)roleObjectID application:(NSString*)applicationObjectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from RoleApplication where roleID = ? and applicationID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteStatement, 1, [roleObjectID UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteStatement, 2, [applicationObjectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteStatement);

    return result;
}

- (ResdbResult*)deleteByApplicationID:(NSString*)applicationObjectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByApplicationIDStatement == nil) {
        const char* sql = "delete from RoleApplication where applicationID = ?";

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
