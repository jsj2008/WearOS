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

#import "UserApplicationDAO.h"
#import "UserApplication.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "StringUtils.h"

@implementation UserApplicationDAO

- (id)allocateDaoObject {
    return [UserApplication new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    UserApplication* userApplication = (UserApplication*)daoObject;

    if ((userApplication == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        userApplication.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        userApplication.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        userApplication.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        userApplication.userID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        userApplication.applicationID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllApplicationsIDs {
    NSString *      sql    = @"select applicationID from UserApplication";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveAllUserApplicationsOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,userID,applicationID from UserApplication where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllApplicationsOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,userID,applicationID from UserApplication where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllApplicationIDsOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"select applicationID from UserApplication where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountApplicationsOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"SELECT count(*) from UserApplication where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self findCount:sql withParams:params];
}


- (ResdbResult*)deleteAllApplicationsOfUser:(NSString*)userObjectID {
    NSString *      sql    = @"delete from UserApplication where userID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)userObjectID application:(NSString*)applicationObjectID {
    NSString *      sql    = @"INSERT into UserApplication (objectID,description,userID,applicationID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:[[ResourceIdentityGenerator generateWithPath:@"UserApplication"] fragment],
                                                              @"iRPM Generated Row",
                                                              ([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID),
                                                              ([StringUtils isEmpty:applicationObjectID] ? [NSNull null] : applicationObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertApplicationIDs:(NSArray*)applicationIDs user:(NSString*)userObjectID {
    for (NSString* applicationID in applicationIDs) {
        [self insert: userObjectID application: applicationID];
    }

    return nil;
}

- (ResdbResult*)delete:(NSString*)userObjectID study:(NSString*)applicationObjectID {
    NSString *      sql    = @"delete from UserApplication where userID = ? and applicationID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:userObjectID] ? [NSNull null] : userObjectID),
                                                              ([StringUtils isEmpty:applicationObjectID] ? [NSNull null] : applicationObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from UserApplication where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByApplicationID:(NSString*)applicationObjectID {
    NSString *      sql    = @"delete from UserApplication where applicationID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:applicationObjectID] ? [NSNull null] : applicationObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
