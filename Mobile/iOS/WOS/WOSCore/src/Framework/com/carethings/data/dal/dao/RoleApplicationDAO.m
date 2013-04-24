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
#import "StringUtils.h"

@implementation RoleApplicationDAO

- (id)allocateDaoObject {
    return [RoleApplication new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    RoleApplication* roleApplication = (RoleApplication*)daoObject;

    if ((roleApplication == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        roleApplication.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        roleApplication.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        roleApplication.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        roleApplication.roleID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        roleApplication.applicationID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        roleApplication.roleHierarchy = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,roleID,applicationID,roleHierarchy from RoleApplication";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveAllApplications {
    ResdbResult*     result       = nil;
    NSMutableArray*  applications = [NSMutableArray new];

    return [self retrieveAll];
}

- (ResdbResult*)retrieveAllApplicationsIDs {
    ResdbResult*     result       = nil;
    NSMutableArray*  applications = [NSMutableArray new];

    return [self retrieveAll];
}

- (ResdbResult*)retrieveAllRoleApplicationsOfRole:(NSString*)roleObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,roleID,applicationID,roleHierarchy from RoleApplication where roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllApplicationsOfRole:(NSString*)roleObjectID {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = nil;

    return [self retrieveAllRoleApplicationsOfRole: roleObjectID];
}

- (ResdbResult*)retrieveAllRoleApplicationsOfRoleList:(NSArray*)roleObjectIDList {
    return nil;
}

- (ResdbResult*)retrieveAllApplicationsOfRoleList:(NSArray*)roleObjectIDList {
    NSMutableArray*  applications = [NSMutableArray new];

    return [self retrieveAllRoleApplicationsOfRoleList: roleObjectIDList];
}

- (ResdbResult*)retrieveAllApplicationIDsOfRole:(NSString*)roleObjectID {
    NSString *      sql    = @"select applicationID from RoleApplication where roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllApplicationIDsOfRoleList:(NSArray*)roleObjectIDList {
    return nil;
}

- (ResdbResult*)retrieveCountApplicationsOfRole:(NSString*)roleObjectID {
     NSString *      sql    = @"SELECT count(*) from RoleApplication where roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)retrieveAllApplicationIDsOfRoleHierarchy:(NSString*)hierarchy {
    return nil;
}

- (ResdbResult*)deleteAllApplicationsOfRole:(NSString*)roleObjectID {
    NSString *      sql    = @"delete from RoleApplication where roleID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(RoleApplication*)roleApplication {
    NSString *      sql    = @"INSERT into RoleApplication (objectID,description,roleID,applicationID,roleHierarchy) values (?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([[ResourceIdentityGenerator generateWithPath:@"RoleApplication"] fragment]),
                                                              ([StringUtils isEmpty:roleApplication.description ] ? [NSNull null] : roleApplication.description ),
                                                              ([StringUtils isEmpty:roleApplication.roleID] ? [NSNull null] : roleApplication.roleID),
                                                              ([StringUtils isEmpty:roleApplication.applicationID] ? [NSNull null] : roleApplication.applicationID),
                                                              ([StringUtils isEmpty:roleApplication.roleHierarchy] ? [NSNull null] : roleApplication.roleHierarchy), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
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
    NSString *      sql    = @"delete from RoleApplication where roleID = ? and applicationID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleObjectID] ? [NSNull null] : roleObjectID),
                                                              ([StringUtils isEmpty:applicationObjectID] ? [NSNull null] : applicationObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByApplicationID:(NSString*)applicationObjectID {
    NSString *      sql    = @"delete from RoleApplication where applicationID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:applicationObjectID] ? [NSNull null] : applicationObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
