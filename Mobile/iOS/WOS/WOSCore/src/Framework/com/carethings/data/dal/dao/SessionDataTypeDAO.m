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

#import "SessionDataTypeDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation SessionDataTypeDAO

- (id)allocateDaoObject {
    return [SessionDataType new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    SessionDataType* sessionDataType = (SessionDataType*)daoObject;

    if ((sessionDataType == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.lookup = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.title = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        sessionDataType.category = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from SessionDataType where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from SessionDataType where category=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveBySessionDataType:(NSString*)sessionDataType {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from SessionDataType where lookup=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionDataType] ? [NSNull null] : sessionDataType), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from SessionDataType";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
    NSString *      sql    = @"SELECT count(*) from SessionDataType where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(SessionDataType*)sessionDataType {
    NSString *      sql    = @"INSERT into SessionDataType (objectID,description,lookup,title,category) values (?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionDataType.objectID] ? [NSNull null] : sessionDataType.objectID),
                                                              ([StringUtils isEmpty:sessionDataType.description] ? [NSNull null] : sessionDataType.description),
                                                              ([StringUtils isEmpty:sessionDataType.lookup] ? [NSNull null] : sessionDataType.lookup),
                                                              ([StringUtils isEmpty:sessionDataType.title] ? [NSNull null] : sessionDataType.title),
                                                              ([StringUtils isEmpty:sessionDataType.category] ? [NSNull null] : sessionDataType.category), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(SessionDataType*)sessionDataType {
    NSString *      sql    = @"UPDATE SessionDataType SET objectID = ?, description = ?, lookup = ?, title = ?, category = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionDataType.objectID] ? [NSNull null] : sessionDataType.objectID),
                                                              ([StringUtils isEmpty:sessionDataType.description] ? [NSNull null] : sessionDataType.description),
                                                              ([StringUtils isEmpty:sessionDataType.lookup] ? [NSNull null] : sessionDataType.lookup),
                                                              ([StringUtils isEmpty:sessionDataType.title] ? [NSNull null] : sessionDataType.title),
                                                              ([StringUtils isEmpty:sessionDataType.category] ? [NSNull null] : sessionDataType.category),
                                                              ([StringUtils isEmpty:sessionDataType.objectID] ? [NSNull null] : sessionDataType.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)renameCategory:(NSString*)oldCategoryName newName:(NSString*)newCategoryName {
    NSString *      sql    = @"UPDATE SessionDataType SET category = ? WHERE category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:oldCategoryName] ? [NSNull null] : oldCategoryName),
                                                              ([StringUtils isEmpty:newCategoryName] ? [NSNull null] : newCategoryName), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from SessionDataType";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from SessionDataType where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByCategory:(NSString*)category {
    NSString *      sql    = @"delete from SessionDataType where category = ?";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

@end
