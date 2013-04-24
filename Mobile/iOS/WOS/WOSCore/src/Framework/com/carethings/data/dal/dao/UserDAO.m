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
#import "StringUtils.h"

@implementation UserDAO

- (id)allocateDaoObject {
    return [User new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    User* user = (User*)daoObject;

    if ((user == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.lastName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.firstName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.userNum = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.gender = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.weight = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.height = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.deviceToken = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        user.role = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken,role from User where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByLastName:(NSString*)lastName {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken,role from User where lastName=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:lastName] ? [NSNull null] : lastName), nil];
	
    return [self findSingleRow:sql withParams:params];	
}

- (ResdbResult*)retrieveByRole:(NSString*)role {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken,role from User where role=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:role] ? [NSNull null] : role), nil];
	
    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,userNum,gender,weight,height,deviceToken,role from User";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from User";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(User*)user {
    NSString *      sql    = @"INSERT into User (objectID,description,lastName,firstName,userNum,gender,weight,height,deviceToken,role) values (?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:user.objectID] ? [NSNull null] : user.objectID),
                                                              ([StringUtils isEmpty:user.description] ? [NSNull null] : user.description),
                                                              ([StringUtils isEmpty:user.lastName] ? [NSNull null] : user.lastName),
                                                              ([StringUtils isEmpty:user.firstName] ? [NSNull null] : user.firstName),
                                                              ([StringUtils isEmpty:user.userNum] ? [NSNull null] : user.userNum),
                                                              ([StringUtils isEmpty:user.gender] ? [NSNull null] : user.gender),
                                                              ([StringUtils isEmpty:user.weight] ? [NSNull null] : user.weight),
                                                              ([StringUtils isEmpty:user.height] ? [NSNull null] : user.height),
                                                              ([StringUtils isEmpty:user.deviceToken] ? [NSNull null] : user.deviceToken),
							                                  ([StringUtils isEmpty:user.role] ? [NSNull null] : user.role), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(User*)user {
    NSString *      sql    = @"UPDATE User SET objectID = ?,description = ?,lastName = ?,firstName = ?,userNum = ?,gender = ?,weight = ?,height = ?,deviceToken = ?,role = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:user.objectID] ? [NSNull null] : user.objectID),
                                                              ([StringUtils isEmpty:user.description] ? [NSNull null] : user.description),
                                                              ([StringUtils isEmpty:user.lastName] ? [NSNull null] : user.lastName),
                                                              ([StringUtils isEmpty:user.firstName] ? [NSNull null] : user.firstName),
                                                              ([StringUtils isEmpty:user.userNum] ? [NSNull null] : user.userNum),
                                                              ([StringUtils isEmpty:user.gender] ? [NSNull null] : user.gender),
                                                              ([StringUtils isEmpty:user.weight] ? [NSNull null] : user.weight),
                                                              ([StringUtils isEmpty:user.height] ? [NSNull null] : user.height),
                                                              ([StringUtils isEmpty:user.deviceToken] ? [NSNull null] : user.deviceToken),
							                                  ([StringUtils isEmpty:user.role] ? [NSNull null] : user.role),
                                                              ([StringUtils isEmpty:user.objectID] ? [NSNull null] : user.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from User";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from User where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByLastName:(NSString*)lastName {
    NSString *      sql    = @"delete from User where lastName = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:lastName] ? [NSNull null] : lastName), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
