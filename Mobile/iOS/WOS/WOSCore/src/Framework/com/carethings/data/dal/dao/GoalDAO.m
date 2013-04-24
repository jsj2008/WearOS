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

#import "GoalDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation GoalDAO

- (id)allocateDaoObject {
    return [Goal new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Goal* goal = (Goal*)daoObject;

    if ((goal == nil) || (sqlRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        goal.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		goal.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		goal.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		goal.instructions = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		goal.activation = [[NSMutableArray alloc] initWithArray:[[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.personalValue = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.expectationOfSuccess = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.reward = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goal.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        goal.completionTime = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime from Goal where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime from Goal where actionPlan=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:actionPlan] ? [NSNull null] : actionPlan), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByName:(NSString*)name {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime from Goal where name=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByOntology:(NSString*)ontology {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime from Goal where ontology=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime from Goal";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)actionPlan {
	NSString *      sql    = @"SELECT count(*) from Goal where actionPlan = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:actionPlan] ? [NSNull null] : actionPlan), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(Goal*)goal {
    NSString *      sql = @"INSERT into Goal (objectID,description,ontology,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan,completionTime) values (?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goal.objectID] ? [NSNull null] : goal.objectID),
                                                              ([StringUtils isEmpty:goal.description] ? [NSNull null] : goal.description),
                                                              ([StringUtils isEmpty:goal.ontology] ? [NSNull null] : goal.ontology),
                                                              ([StringUtils isEmpty:goal.name] ? [NSNull null] : goal.name),
                                                              ([StringUtils isEmpty:goal.shortDescription] ? [NSNull null] : goal.shortDescription),
                                                              ([StringUtils isEmpty:goal.instructions] ? [NSNull null] : goal.instructions),
                                                              ([StringUtils isEmpty:goal.activation] ? [NSNull null] : [goal.activation componentsJoinedByString:@","]),
                                                              ([StringUtils isEmpty:goal.personalValue] ? [NSNull null] : goal.personalValue),
                                                              ([StringUtils isEmpty:goal.expectationOfSuccess] ? [NSNull null] : goal.expectationOfSuccess),
                                                              ([StringUtils isEmpty:goal.reward] ? [NSNull null] : goal.reward),
                                                              (goal.actionPlan == nil) ? [NSNull null] : [goal.actionPlan absoluteString],
                                                              ([StringUtils isEmpty:goal.completionTime] ? [NSNull null] : goal.completionTime), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Goal*)goal {
	NSString *      sql    = @"UPDATE Goal SET objectID = ?, description = ?, ontology = ?, name = ?, shortDescription = ?, instructions = ?, activation = ?, personalValue = ?, expectationOfSuccess = ?, reward = ?, actionPlan = ?, completionTime = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goal.objectID] ? [NSNull null] : goal.objectID),
                                                              ([StringUtils isEmpty:goal.description] ? [NSNull null] : goal.description),
                                                              ([StringUtils isEmpty:goal.ontology] ? [NSNull null] : goal.ontology),
                                                              ([StringUtils isEmpty:goal.name] ? [NSNull null] : goal.name),
                                                              ([StringUtils isEmpty:goal.shortDescription] ? [NSNull null] : goal.shortDescription),
                                                              ([StringUtils isEmpty:goal.instructions] ? [NSNull null] : goal.instructions),
                                                              ([StringUtils isEmpty:goal.activation] ? [NSNull null] : [goal.activation componentsJoinedByString:@","]),
                                                              ([StringUtils isEmpty:goal.personalValue] ? [NSNull null] : goal.personalValue),
                                                              ([StringUtils isEmpty:goal.expectationOfSuccess] ? [NSNull null] : goal.expectationOfSuccess),
                                                              ([StringUtils isEmpty:goal.reward] ? [NSNull null] : goal.reward),
                                                              (goal.actionPlan == nil) ? [NSNull null] : [goal.actionPlan absoluteString],
                                                              ([StringUtils isEmpty:goal.completionTime] ? [NSNull null] : goal.completionTime),
                                                              ([StringUtils isEmpty:goal.objectID] ? [NSNull null] : goal.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Goal";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)actionPlan {
	NSString *      sql    = @"delete from Goal where actionPlan = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:actionPlan] ? [NSNull null] : actionPlan), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Goal where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end