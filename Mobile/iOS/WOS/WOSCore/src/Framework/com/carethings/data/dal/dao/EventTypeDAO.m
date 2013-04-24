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

#import "EventTypeDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation EventTypeDAO

- (id)allocateDaoObject {
    return [EventType new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    EventType* eventType = (EventType*)daoObject;

    if ((eventType == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        eventType.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        eventType.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        eventType.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        eventType.lookup = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        eventType.title = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        eventType.category = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from EventType where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from EventType where category=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByEventType:(NSString*)eventType {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from EventType where lookup=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:eventType] ? [NSNull null] : eventType), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,lookup,title,category from EventType";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
     NSString *      sql    = @"SELECT count(*) from EventType where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(EventType*)eventType {
    NSString *      sql    = @"INSERT into EventType (objectID,description,lookup,title,category) values (?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:eventType.objectID] ? [NSNull null] : eventType.objectID),
                                                              ([StringUtils isEmpty:eventType.description] ? [NSNull null] : eventType.description),
                                                              ([StringUtils isEmpty:eventType.lookup] ? [NSNull null] : eventType.lookup),
                                                              ([StringUtils isEmpty:eventType.title] ? [NSNull null] : eventType.title),
                                                              ([StringUtils isEmpty:eventType.category] ? [NSNull null] : eventType.category), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(EventType*)eventType {
    NSString *      sql    = @"UPDATE EventType SET objectID = ?, description = ?, lookup = ?, title = ?, category = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:eventType.objectID] ? [NSNull null] : eventType.objectID),
                                                              ([StringUtils isEmpty:eventType.description] ? [NSNull null] : eventType.description),
                                                              ([StringUtils isEmpty:eventType.lookup] ? [NSNull null] : eventType.lookup),
                                                              ([StringUtils isEmpty:eventType.title] ? [NSNull null] : eventType.title),
                                                              ([StringUtils isEmpty:eventType.category] ? [NSNull null] : eventType.category),
                                                              ([StringUtils isEmpty:eventType.objectID] ? [NSNull null] : eventType.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from EventType";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from EventType where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByCategory:(NSString*)category {
    NSString *      sql    = @"delete from EventType where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
