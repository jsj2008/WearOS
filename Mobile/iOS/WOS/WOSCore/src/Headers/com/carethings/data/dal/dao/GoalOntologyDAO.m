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

#import "GoalOntologyDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation GoalOntologyDAO

- (id)allocateDaoObject {
    return [GoalOntology new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;
	
    GoalOntology* goalOntology = (GoalOntology*)daoObject;
	
    if ((goalOntology == nil) || (sqlRow == nil))
		return;
	
    int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goalOntology.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goalOntology.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		goalOntology.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        goalOntology.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
   		goalOntology.name = [NSString stringWithUTF8String:textPtr];
    goalOntology.active = sqlite3_column_int(sqlRow,i++);

}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,ontology,name,active from GoalOntology where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];
	
    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,active from GoalOntology";
	
    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByActive {
	NSString *      sql    = @"SELECT count(*) from GoalOntology where active = 1";
	
    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from GoalOntology";
	
    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(GoalOntology*)goalOntology {
    NSString *      sql = @"INSERT into GoalOntology (objectID,description,ontology,name,active) values (?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goalOntology.objectID] ? [NSNull null] : goalOntology.objectID),
							  ([StringUtils isEmpty:goalOntology.description] ? [NSNull null] : goalOntology.description),
							  ([StringUtils isEmpty:goalOntology.ontology] ? [NSNull null] : goalOntology.ontology),
							  ([StringUtils isEmpty:goalOntology.name] ? [NSNull null] : goalOntology.name),
							  [[NSNumber alloc] initWithInt:goalOntology.active], nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(GoalOntology*)goalOntology {
	NSString *      sql    = @"UPDATE GoalOntology SET objectID = ?, description = ?, ontology = ?, name = ?, active = ? WHERE objectID = ?";
	NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:goalOntology.objectID] ? [NSNull null] : goalOntology.objectID),
							  ([StringUtils isEmpty:goalOntology.description] ? [NSNull null] : goalOntology.description),
							  ([StringUtils isEmpty:goalOntology.ontology] ? [NSNull null] : goalOntology.ontology),
							  ([StringUtils isEmpty:goalOntology.name] ? [NSNull null] : goalOntology.name),
							  [[NSNumber alloc] initWithInt:goalOntology.active],
							  ([StringUtils isEmpty:goalOntology.objectID] ? [NSNull null] : goalOntology.objectID), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from GoalOntology";
	
    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from GoalOntology where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end