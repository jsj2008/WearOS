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

#import "AlertDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation AlertDAO

- (id)allocateDaoObject {
    return [Alert new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Alert* alert = (Alert*)daoObject;

	if ((alert == nil) || (sqlRow == nil))
		return;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
		alert.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
		alert.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
		alert.description = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
		alert.priority = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
		alert.message = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
		alert.detailMessage = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
		alert.relatedID = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,priority,message,detailMessage,relatedID from Alert where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,priority,message,detailMessage,relatedID from Alert where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,priority,message,detailMessage,relatedID from Alert";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"SELECT count(*) from Alert where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(Alert*)alert {
    NSString *      sql    = @"INSERT into Alert (objectID,description,priority,message,detailMessage,relatedID) values (?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:alert.objectID] ? [NSNull null] : alert.objectID),
                                                              ([StringUtils isEmpty:alert.description] ? [NSNull null] : alert.description),
                                                              ([StringUtils isEmpty:alert.priority] ? [NSNull null] : alert.priority),
                                                              ([StringUtils isEmpty:alert.message] ? [NSNull null] : alert.message),
                                                              ([StringUtils isEmpty:alert.detailMessage] ? [NSNull null] : alert.detailMessage),
                                                              ([StringUtils isEmpty:alert.relatedID] ? [NSNull null] : alert.relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Alert*)alert {
    NSString *      sql    = @"UPDATE Alert SET objectID = ?, description = ?, priority = ?, message = ?, detailMessage = ?, relatedID = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:alert.objectID] ? [NSNull null] : alert.objectID),
                                                              ([StringUtils isEmpty:alert.description] ? [NSNull null] : alert.description),
                                                              ([StringUtils isEmpty:alert.priority] ? [NSNull null] : alert.priority),
                                                              ([StringUtils isEmpty:alert.message] ? [NSNull null] : alert.message),
                                                              ([StringUtils isEmpty:alert.detailMessage] ? [NSNull null] : alert.detailMessage),
                                                              ([StringUtils isEmpty:alert.relatedID] ? [NSNull null] : alert.relatedID),
                                                              ([StringUtils isEmpty:alert.objectID] ? [NSNull null] : alert.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Alert";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from Alert where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Alert where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
