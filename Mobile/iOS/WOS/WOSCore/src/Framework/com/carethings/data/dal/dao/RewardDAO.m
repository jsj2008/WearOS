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

#import "RewardDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation RewardDAO

- (id)allocateDaoObject {
    return [Reward new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Reward* reward = (Reward*)daoObject;

    if ((reward == nil) || (sqlRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		reward.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		reward.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		reward.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        reward.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		reward.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		reward.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        reward.activation = [[NSMutableArray alloc] initWithArray:[[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","]];
    reward.completionCount  = sqlite3_column_int(sqlRow,i++);
    reward.repeat = sqlite3_column_int(sqlRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		reward.instructions = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		reward.lastCompletionTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		reward.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward where actionPlan=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:actionPlan] ? [NSNull null] : actionPlan), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByOntology:(NSString*)ontology {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward where ontology=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from Reward";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Reward*)reward {
	NSString *      sql    = @"INSERT into Reward (objectID,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan) values (?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reward.objectID] ? [NSNull null] : reward.objectID),
                                                              ([StringUtils isEmpty:reward.description] ? [NSNull null] : reward.description),
                                                              ([StringUtils isEmpty:reward.ontology] ? [NSNull null] : reward.ontology),
                                                              ([StringUtils isEmpty:reward.name] ? [NSNull null] : reward.name),
                                                              ([StringUtils isEmpty:reward.shortDescription] ? [NSNull null] : reward.shortDescription),
                                                              ([StringUtils isEmpty:[reward.activation componentsJoinedByString:@","]] ? [NSNull null] : reward.activation),
                                                              [[NSNumber alloc] initWithInt:reward.completionCount],
                                                              [[NSNumber alloc] initWithInt:reward.repeat],
                                                              ([StringUtils isEmpty:reward.instructions] ? [NSNull null] : reward.instructions),
                                                              ([StringUtils isEmpty:reward.lastCompletionTime] ? [NSNull null] : reward.lastCompletionTime),
                                                              ((reward.actionPlan == nil) ? [NSNull null] : [reward.actionPlan absoluteString]), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Reward*)reward {
	NSString *      sql    = @"UPDATE Reward SET objectID = ?, description = ?, name = ?, shortDescription = ?, activation = ?,completionCount = ?,repeat = ?,instructions = ?,lastCompletionTime = ?,actionPlan = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:reward.objectID] ? [NSNull null] : reward.objectID),
                                                              ([StringUtils isEmpty:reward.description] ? [NSNull null] : reward.description),
                                                              ([StringUtils isEmpty:reward.ontology] ? [NSNull null] : reward.ontology),
                                                              ([StringUtils isEmpty:reward.name] ? [NSNull null] : reward.name),
                                                              ([StringUtils isEmpty:reward.shortDescription] ? [NSNull null] : reward.shortDescription),
                                                              ([StringUtils isEmpty:[reward.activation componentsJoinedByString:@","]] ? [NSNull null] : reward.activation),
                                                              [[NSNumber alloc] initWithInt:reward.completionCount],
                                                              [[NSNumber alloc] initWithInt:reward.repeat],
                                                              ([StringUtils isEmpty:reward.instructions] ? [NSNull null] : reward.instructions),
                                                              ([StringUtils isEmpty:reward.lastCompletionTime] ? [NSNull null] : reward.lastCompletionTime),
                                                              ((reward.actionPlan == nil) ? [NSNull null] : [reward.actionPlan absoluteString]),
                                                              ([StringUtils isEmpty:reward.objectID] ? [NSNull null] : reward.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Reward";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Reward where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end