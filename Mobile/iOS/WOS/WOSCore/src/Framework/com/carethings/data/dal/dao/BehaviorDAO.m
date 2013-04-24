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

#import "BehaviorDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation BehaviorDAO

- (id)allocateDaoObject {
    return [Behavior new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Behavior* behavior = (Behavior*)daoObject;

    if ((behavior == nil) || (sqlRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		behavior.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		behavior.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		behavior.description = [NSString stringWithUTF8String:textPtr];
    behavior.behaviorType = sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.decoratedName = [NSString stringWithUTF8String:textPtr];
    behavior.behaviorState = sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.concept = [NSString stringWithUTF8String:textPtr];
    behavior.monitorWatcher = (float) sqlite3_column_double(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.reactorActivation = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.monitorEnd = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.monitorEndCode = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
   	i++;
    behavior.monitorEndLanguage = sqlite3_column_int(sqlRow,i++);
    behavior.monitorEndCodeLen = sqlite3_column_int(sqlRow,i++);
    behavior.monitorEndCodeValid = (bool) sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
		behavior.monitorException = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.monitorExceptionCode = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
   	i++;
    behavior.monitorExceptionLanguage = sqlite3_column_int(sqlRow,i++);
    behavior.monitorExceptionCodeLen = sqlite3_column_int(sqlRow,i++);
    behavior.monitorExceptionCodeValid = (bool) sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.startActions = [[NSString alloc] initWithUTF8String: textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.startActionsCode = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
   	i++;
    behavior.startActionsLanguage = sqlite3_column_int(sqlRow,i++);
    behavior.startActionsCodeLen = sqlite3_column_int(sqlRow,i++);
    behavior.startActionsCodeValid = (bool) sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
   		behavior.stopActions = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.stopActionsCode = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
   	i++;
    behavior.stopActionsLanguage = sqlite3_column_int(sqlRow,i++);
    behavior.stopActionsCodeLen = sqlite3_column_int(sqlRow,i++);
    behavior.stopActionsCodeValid = (bool) sqlite3_column_int(sqlRow,i++);
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.protocol = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
    i++;
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		behavior.protocolCode = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,i) length:(NSUInteger)  sqlite3_column_bytes(sqlRow,i)];
   	i++;
    behavior.protocolLanguage = sqlite3_column_int(sqlRow,i++);
    behavior.protocolCodeLen = sqlite3_column_int(sqlRow,i++);
    behavior.protocolCodeValid = (bool) sqlite3_column_int(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        behavior.knowledge = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i)))
        behavior.relatedID = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
	NSString *      sql    = @"select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(Behavior*)behavior {
    NSString *      sql    = @"INSERT into Behavior (objectID,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:behavior.objectID] ? [NSNull null] : behavior.objectID),
                                                              ([StringUtils isEmpty:behavior.description] ? [NSNull null] : behavior.description),
                                                              [[NSNumber alloc] initWithInt:behavior.behaviorType],
                                                              ([StringUtils isEmpty:behavior.decoratedName] ? [NSNull null] : behavior.decoratedName),
                                                              [[NSNumber alloc] initWithInt:behavior.behaviorState],
                                                              ([StringUtils isEmpty:behavior.concept] ? [NSNull null] : behavior.concept),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorWatcher],
                                                              ([StringUtils isEmpty:behavior.reactorActivation] ? [NSNull null] : behavior.reactorActivation),
                                                              ([StringUtils isEmpty:behavior.monitorEnd] ? [NSNull null] : behavior.monitorEnd),
                                                              ([StringUtils isEmpty:behavior.monitorEndCode] ? [NSNull null] : behavior.monitorEndCode),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndCodeValid],
                                                              ([StringUtils isEmpty:behavior.monitorException] ? [NSNull null] : behavior.monitorException),
                                                              ([StringUtils isEmpty:behavior.monitorExceptionCode] ? [NSNull null] : behavior.monitorExceptionCode),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionCodeValid],
                                                              ([StringUtils isEmpty:behavior.startActions] ? [NSNull null] : behavior.startActions),
                                                              ([StringUtils isEmpty:behavior.startActionsCode] ? [NSNull null] : behavior.startActionsCode),
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsCodeValid],
                                                              ([StringUtils isEmpty:behavior.stopActions] ? [NSNull null] : behavior.stopActions),
                                                              ([StringUtils isEmpty:behavior.stopActionsCode] ? [NSNull null] : behavior.stopActionsCode),
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsCodeValid],
                                                              ([StringUtils isEmpty:behavior.protocol] ? [NSNull null] : behavior.protocol),
                                                              ([StringUtils isEmpty:behavior.protocolCode] ? [NSNull null] : behavior.protocolCode),
                                                              [[NSNumber alloc] initWithInt:behavior.protocolLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.protocolCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.protocolCodeValid],
                                                              ([StringUtils isEmpty:[behavior.knowledge absoluteString]] ? [NSNull null] : behavior.knowledge),
                                                              ([StringUtils isEmpty:behavior.relatedID] ? [NSNull null] : behavior.relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Behavior*)behavior {
    NSString *      sql    = @"UPDATE Behavior SET objectID = ?, description = ?, behaviorType = ?, decoratedName = ?, behaviorState = ?, concept = ?, monitorWatcher = ?, reactorActivation = ?, monitorEnd = ?, monitorEndCode = ?, monitorEndLanguage = ?, monitorEndCodeLen = ?, monitorEndCodeValid = ?, monitorException = ?, monitorExceptionCode = ?, monitorExceptionLanguage = ?, monitorExceptionCodeLen = ?, monitorExceptionCodeValid = ?, startActions = ?, startActionsCode = ?, startActionsLanguage = ?, startActionsCodeLen = ?, startActionsCodeValid = ?, stopActions = ?, stopActionsCode = ?, stopActionsLanguage = ?, stopActionsCodeLen = ?, stopActionsCodeValid = ?, protocol = ?, protocolCode = ?, protocolLanguage = ?, protocolCodeLen = ?, protocolCodeValid = ?, knowledge = ?, relatedID = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:behavior.objectID] ? [NSNull null] : behavior.objectID),
                                                              ([StringUtils isEmpty:behavior.description] ? [NSNull null] : behavior.description),
                                                              [[NSNumber alloc] initWithInt:behavior.behaviorType],
                                                              ([StringUtils isEmpty:behavior.decoratedName] ? [NSNull null] : behavior.decoratedName),
                                                              [[NSNumber alloc] initWithInt:behavior.behaviorState],
                                                              ([StringUtils isEmpty:behavior.concept] ? [NSNull null] : behavior.concept),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorWatcher],
                                                              ([StringUtils isEmpty:behavior.reactorActivation] ? [NSNull null] : behavior.reactorActivation),
                                                              ([StringUtils isEmpty:behavior.monitorEnd] ? [NSNull null] : behavior.monitorEnd),
                                                              ([StringUtils isEmpty:behavior.monitorEndCode] ? [NSNull null] : behavior.monitorEndCode),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorEndCodeValid],
                                                              ([StringUtils isEmpty:behavior.monitorException] ? [NSNull null] : behavior.monitorException),
                                                              ([StringUtils isEmpty:behavior.monitorExceptionCode] ? [NSNull null] : behavior.monitorExceptionCode),
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.monitorExceptionCodeValid],
                                                              ([StringUtils isEmpty:behavior.startActions] ? [NSNull null] : behavior.startActions),
                                                              ([StringUtils isEmpty:behavior.startActionsCode] ? [NSNull null] : behavior.startActionsCode),
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.startActionsCodeValid],
                                                              ([StringUtils isEmpty:behavior.stopActions] ? [NSNull null] : behavior.stopActions),
                                                              ([StringUtils isEmpty:behavior.stopActionsCode] ? [NSNull null] : behavior.stopActionsCode),
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.stopActionsCodeValid],
                                                              ([StringUtils isEmpty:behavior.protocol] ? [NSNull null] : behavior.protocol),
                                                              ([StringUtils isEmpty:behavior.protocolCode] ? [NSNull null] : behavior.protocolCode),
                                                              [[NSNumber alloc] initWithInt:behavior.protocolLanguage],
                                                              [[NSNumber alloc] initWithInt:behavior.protocolCodeLen],
                                                              [[NSNumber alloc] initWithInt:behavior.protocolCodeValid],
                                                              ([StringUtils isEmpty:[behavior.knowledge absoluteString]] ? [NSNull null] : behavior.knowledge),
                                                              ([StringUtils isEmpty:behavior.relatedID] ? [NSNull null] : behavior.relatedID),
                                                              ([StringUtils isEmpty:behavior.objectID] ? [NSNull null] : behavior.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Behavior";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Behavior where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
