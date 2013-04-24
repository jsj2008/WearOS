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

#import "UserRoleDAO.h"
#import "UserRole.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "StringUtils.h"


@implementation UserRoleDAO

- (id)allocateDaoObject {
    return [UserRole new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    UserRole* userRole = (UserRole*)daoObject;

    if ((userRole == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        userRole.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        userRole.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        userRole.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        userRole.userID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        userRole.roleID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllRolesOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,userID,roleID from UserRole where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];
    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllRoleIDsOfUser:(NSString*)userID {
    NSString *      sql    = @"select roleID from UserRole where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userID] ? [NSNull null] : userID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountRolesOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"SELECT count(*) from UserRole where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)deleteAllRolesOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"delete from UserRole where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)userObjectID role:(NSString*)roleObjectID {
    NSString *      sql    = @"INSERT into UserRole (objectID,description,userID,roleID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID),
                                                              ([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertRoleIDs:(NSArray*)roleIDs user:(NSString*)userObjectID {
    ResdbResult* result = nil;

    for (NSString* roleID in roleIDs) {
        result = [self insert: userObjectID role: roleID];
    }

    return result;
}

- (ResdbResult*)delete:(NSString*)userObjectID role:(NSString*)roleObjectID {
    NSString *      sql    = @"delete from UserRole where userID = ? and roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID),
                                                              ([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByRoleID:(NSString*)roleObjectID {
    NSString *      sql    = @"delete from UserRole where roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
