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

#import "RuleDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation RuleDAO

- (id)allocateDaoObject {
    return [Rule new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Rule* rule = (Rule*)daoObject;

    if ((rule == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        rule.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        rule.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        rule.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        rule.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        rule.type = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        rule.ruleText = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        rule.category = [NSString stringWithUTF8String:textPtr];
    rule.active = sqlite3_column_int(sqlRow,7);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,type,ruleText,category,active from Rule where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,name,type,ruleText,category,active from Rule where category=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveActiveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,name,type,ruleText,category,active from Rule where category=? and active=1";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,name,type,ruleText,category,active from Rule";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
    NSString *      sql    = @"SELECT count(*) from Rule where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)retrieveByName:(NSString*)name {
    NSString *      sql    = @"select objectID,creationTime,description,name,type,ruleText,category,active from Rule where name=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)insert:(Rule*)rule {
    NSString *      sql    = @"INSERT into Rule (objectID,description,name,type,ruleText,category,active) values (?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:rule.objectID] ? [NSNull null] : rule.objectID),
                                                              ([StringUtils isEmpty:rule.description] ? [NSNull null] : rule.description),
                                                              ([StringUtils isEmpty:rule.name] ? [NSNull null] : rule.name),
                                                              ([StringUtils isEmpty:rule.type] ? [NSNull null] : rule.type),
                                                              ([StringUtils isEmpty:rule.ruleText] ? [NSNull null] : rule.ruleText),
                                                              ([StringUtils isEmpty:rule.category] ? [NSNull null] : rule.category),
                                                              [[NSNumber alloc] initWithInt:rule.active], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Rule*)rule {
    NSString *      sql    = @"UPDATE Rule SET objectID = ?, description = ?, name = ?, type = ?, ruleText = ?, category = ? , active = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:rule.objectID] ? [NSNull null] : rule.objectID),
                                                              ([StringUtils isEmpty:rule.description] ? [NSNull null] : rule.description),
                                                              ([StringUtils isEmpty:rule.name] ? [NSNull null] : rule.name),
                                                              ([StringUtils isEmpty:rule.type] ? [NSNull null] : rule.type),
                                                              ([StringUtils isEmpty:rule.ruleText] ? [NSNull null] : rule.ruleText),
                                                              ([StringUtils isEmpty:rule.category] ? [NSNull null] : rule.category),
                                                              [[NSNumber alloc] initWithInt:rule.active],
                                                              ([StringUtils isEmpty:rule.objectID] ? [NSNull null] : rule.objectID),nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Rule";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByCategory:(NSString*)category {
    NSString *      sql    = @"delete from Rule where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Rule where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
