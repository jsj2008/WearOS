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

#import "RoleDAO.h"
#import "WSResourceManager.h"
#import "Role.h"
#import "StringUtils.h"


@implementation RoleDAO

- (id)allocateDaoObject {
    return [Role new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Role* role = (Role*)daoObject;

    if ((role == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        role.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        role.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        role.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        role.name = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,4) > 0)
        role.image = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,4) length: sqlite3_column_bytes(sqlRow,4)];
}

- (NSString*)getRoleName:(NSString*)objectID {
    NSString *      sql    = @"select name from Role where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,image,hierarchy from Role where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByName:(NSString*)roleName {
     NSString *      sql    = @"select objectID,creationTime,description,name,image,hierarchy from Role where name=?";
   NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:roleName] ? [NSNull null] : roleName), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
     NSString *      sql    = @"select objectID,creationTime,description,name,image,hierarchy from Role";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
     NSString *      sql    = @"select count(*) from Role";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Role*)role {
    NSString *      sql    = @"INSERT into Role (objectID,description,name,image,hierarchy) values (?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:role.objectID] ? [NSNull null] : role.objectID),
                                                              ([StringUtils isEmpty:role.description] ? [NSNull null] : role.description),
                                                              ([StringUtils isEmpty:role.name] ? [NSNull null] : role.name),
                                                              ((role.image == nil) ? [NSNull null] : role.image),
                                                              ([StringUtils isEmpty:role.hierarchy] ? [NSNull null] : role.hierarchy), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Role*)role {
    NSString *      sql    = @"UPDATE Role SET objectID = ?, description = ?, name = ?, image = ? , hierarchy = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:role.objectID] ? [NSNull null] : role.objectID),
                                                              ([StringUtils isEmpty:role.description] ? [NSNull null] : role.description),
                                                              ([StringUtils isEmpty:role.name] ? [NSNull null] : role.name),
                                                              ((role.image == nil) ? [NSNull null] : role.image),
                                                              ([StringUtils isEmpty:role.hierarchy] ? [NSNull null] : role.hierarchy),
                                                              ([StringUtils isEmpty:role.objectID] ? [NSNull null] : role.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Role";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByName:(NSString*)name {
    NSString *      sql    = @"delete from Role where name = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Role where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
