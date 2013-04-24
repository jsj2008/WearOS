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

#import "TaskDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation TaskDAO

- (id)allocateDaoObject {
    return [Task new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Task* task = (Task*)daoObject;

    if ((task == nil) || (sqlRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        task.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		task.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		task.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++))) {
		NSArray* components = [[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","];
        task.activation = [[NSMutableArray alloc] initWithArray:components];
    }
	task.completionCount  = sqlite3_column_int(sqlRow,i++);
    task.repeat = sqlite3_column_int(sqlRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.instructions = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.priority = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		task.status = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		task.lastCompletionTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		task.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task where actionPlan=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:actionPlan] ? [NSNull null] : actionPlan), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByOntology:(NSString*)ontology {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task where ontology=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from Task";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Task*)task {
	NSString *      sql    = @"INSERT into Task (objectID,description,ontology,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:task.objectID] ? [NSNull null] : task.objectID),
                                                              ([StringUtils isEmpty:task.description] ? [NSNull null] : task.description),
                                                              ([StringUtils isEmpty:task.ontology] ? [NSNull null] : task.ontology),
                                                              ([StringUtils isEmpty:task.name] ? [NSNull null] : task.name),
                                                              ([StringUtils isEmpty:task.shortDescription] ? [NSNull null] : task.shortDescription),
                                                              ((task.activation == nil) ? [NSNull null] : [task.activation componentsJoinedByString:@","]),
                                                              [[NSNumber alloc] initWithInt:task.completionCount],
                                                              [[NSNumber alloc] initWithInt:task.repeat],
                                                              ([StringUtils isEmpty:task.instructions] ? [NSNull null] : task.instructions),
                                                              ([StringUtils isEmpty:task.priority] ? [NSNull null] : task.priority),
                                                              ([StringUtils isEmpty:task.status] ? [NSNull null] : task.status),
                                                              ([StringUtils isEmpty:task.lastCompletionTime] ? [NSNull null] : task.lastCompletionTime),
                                                              ((task.actionPlan == nil) ? [NSNull null] : [task.actionPlan absoluteString]), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Task*)task {
	NSString *      sql    = @"UPDATE Task SET objectID = ?, description = ?, ontology = ?, name = ?, shortDescription = ?, activation = ?,completionCount = ?,repeat = ?,instructions = ?,priority = ?,status = ?,lastCompletionTime = ?,actionPlan = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:task.objectID] ? [NSNull null] : task.objectID),
                                                              ([StringUtils isEmpty:task.description] ? [NSNull null] : task.description),
                                                              ([StringUtils isEmpty:task.ontology] ? [NSNull null] : task.ontology),
                                                              ([StringUtils isEmpty:task.name] ? [NSNull null] : task.name),
                                                              ([StringUtils isEmpty:task.shortDescription] ? [NSNull null] : task.shortDescription),
                                                              ((task.activation == nil) ? [NSNull null] : [task.activation componentsJoinedByString:@","]),
                                                              [[NSNumber alloc] initWithInt:task.completionCount],
                                                              [[NSNumber alloc] initWithInt:task.repeat],
                                                              ([StringUtils isEmpty:task.instructions] ? [NSNull null] : task.instructions),
                                                              ([StringUtils isEmpty:task.priority] ? [NSNull null] : task.priority),
                                                              ([StringUtils isEmpty:task.status] ? [NSNull null] : task.status),
                                                              ([StringUtils isEmpty:task.lastCompletionTime] ? [NSNull null] : task.lastCompletionTime),
                                                              ((task.actionPlan == nil) ? [NSNull null] : [task.actionPlan absoluteString]),
                                                              ([StringUtils isEmpty:task.objectID] ? [NSNull null] : task.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Task";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Task where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end