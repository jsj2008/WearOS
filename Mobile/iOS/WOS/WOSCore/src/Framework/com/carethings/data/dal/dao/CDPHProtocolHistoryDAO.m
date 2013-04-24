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

#import "CDPHProtocolHistoryDAO.h"
#import "WSResourceManager.h"
#import "CDPHProtocolHistory.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation CDPHProtocolHistoryDAO

- (id)allocateDaoObject {
    return [CDPHProtocolHistory new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    CDPHProtocolHistory* protocolHistory = (CDPHProtocolHistory*)daoObject;

    if ((protocolHistory == nil) || (sqlRow == nil))
		return;
	
	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.objectID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.creationTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.description = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.visit = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.abstractionDate = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.clientID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.abstractorID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.siteID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.history = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		protocolHistory.interventionSysID = [[NSString alloc] initWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByAbstractionDate:(NSString*)abstractionDate andSiteID:(NSString*)siteID andClientID:(NSString*)clientID  andVisit:(NSString*)visit andIntervention:(NSString*)interventionID {
	NSString *      sql    = @"select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory where abstractionDate=? and siteID=? and clientID=? and visit=? and interventionSysID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:abstractionDate] ? [NSNull null] : abstractionDate),
                                                              ([StringUtils isEmpty:siteID] ? [NSNull null] : siteID),
                                                              ([StringUtils isEmpty:clientID] ? [NSNull null] : clientID),
                                                              ([StringUtils isEmpty:visit] ? [NSNull null] : visit),
                                                              ([StringUtils isEmpty:interventionID] ? [NSNull null] : interventionID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(CDPHProtocolHistory*)protocolHistory {
	NSString *      sql    = @"INSERT into CDPHProtocolHistory (objectID,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID) values (?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:protocolHistory.objectID] ? [NSNull null] : protocolHistory.objectID),
                                                              ([StringUtils isEmpty:protocolHistory.description] ? [NSNull null] : protocolHistory.description),
                                                              ([StringUtils isEmpty:protocolHistory.visit] ? [NSNull null] : protocolHistory.visit),
                                                              ([StringUtils isEmpty:protocolHistory.abstractionDate] ? [NSNull null] : protocolHistory.abstractionDate),
                                                              ([StringUtils isEmpty:protocolHistory.clientID] ? [NSNull null] : protocolHistory.clientID),
                                                              ([StringUtils isEmpty:protocolHistory.abstractorID] ? [NSNull null] : protocolHistory.abstractorID),
                                                              ([StringUtils isEmpty:protocolHistory.siteID] ? [NSNull null] : protocolHistory.siteID),
                                                              ([StringUtils isEmpty:protocolHistory.history] ? [NSNull null] : protocolHistory.history),
                                                              ([StringUtils isEmpty:protocolHistory.interventionSysID] ? [NSNull null] : protocolHistory.interventionSysID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(CDPHProtocolHistory*)protocolHistory {
	NSString *      sql    = @"UPDATE CDPHProtocolHistory SET objectID = ?, description = ?, visit = ?, abstractionDate = ?, clientID = ?, abstractorID = ?, siteID = ?, history = ?, interventionSysID = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:protocolHistory.objectID] ? [NSNull null] : protocolHistory.objectID),
                                                              ([StringUtils isEmpty:protocolHistory.description] ? [NSNull null] : protocolHistory.description),
                                                              ([StringUtils isEmpty:protocolHistory.visit] ? [NSNull null] : protocolHistory.visit),
                                                              ([StringUtils isEmpty:protocolHistory.abstractionDate] ? [NSNull null] : protocolHistory.abstractionDate),
                                                              ([StringUtils isEmpty:protocolHistory.clientID] ? [NSNull null] : protocolHistory.clientID),
                                                              ([StringUtils isEmpty:protocolHistory.abstractorID] ? [NSNull null] : protocolHistory.abstractorID),
                                                              ([StringUtils isEmpty:protocolHistory.siteID] ? [NSNull null] : protocolHistory.siteID),
                                                              ([StringUtils isEmpty:protocolHistory.history] ? [NSNull null] : protocolHistory.history),
                                                              ([StringUtils isEmpty:protocolHistory.interventionSysID] ? [NSNull null] : protocolHistory.interventionSysID),
                                                              ([StringUtils isEmpty:protocolHistory.objectID] ? [NSNull null] : protocolHistory.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from CDPHProtocolHistory";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByIntervention:(NSString*)interventionID {
	NSString *      sql    = @"delete from ProtocolHistory where interventionSysID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:interventionID] ? [NSNull null] : interventionID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from CDPHProtocolHistory where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
