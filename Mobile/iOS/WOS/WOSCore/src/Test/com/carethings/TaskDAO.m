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

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement      = nil;
static sqlite3_stmt* retrieveCountStatement            = nil;


@implementation TaskDAO

- (void)transferTaskData:(Task*)task:(sqlite3_stmt*)taskRow {
	char*  textPtr = nil;

	if ((task == nil) || (taskRow == nil))
		return;

	if ((textPtr = (char*)sqlite3_column_text(taskRow,0)))
		task.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(taskRow,1)))
		task.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(taskRow,2)))
		task.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(taskRow,3)))
   		task.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(taskRow,4)))
   		task.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(taskRow,5))) {
		NSArray* components = [[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","];
        task.activation = [[NSMutableArray alloc] initWithArray:components];
    }
	task.completionCount  = sqlite3_column_int(taskRow,6);
    task.repeat = sqlite3_column_int(taskRow,7);
	if ((textPtr = (char*)sqlite3_column_text(taskRow,8)))
		task.instructions = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(taskRow,9)))
		task.priority = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(taskRow,10)))
		task.status = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(taskRow,11)))
   		task.lastCompletionTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(taskRow,12)))
   		task.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Task*           task         = [Task new];
	ResdbResult*    result       = [ResdbResult new];


	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferTaskData: task: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = task;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSMutableArray*  tasks   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task where actionPlan=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [actionPlan UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
		Task* task = [Task new];

		[self transferTaskData: task: retrieveByRelatedIdStatement];

		[tasks addObject: task];
	}

	if ([tasks count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = tasks;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  tasks   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];


	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan from Task";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Task* task = [Task new];

		[self transferTaskData: task: retrieveAllStatement];

		[tasks addObject: task];
	}

	if ([tasks count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = tasks;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)retrieveCount {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Task";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

		NSInteger taskCount = sqlite3_column_int(retrieveCountStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",taskCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountStatement);

	return result;
}

- (ResdbResult*)insert:(Task*)task {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Task (objectID,description,name,shortDescription,activation,completionCount,repeat,instructions,priority,status,lastCompletionTime,actionPlan) values (?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(insertStatement, 1, [task.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 2, [task.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [task.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [task.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [[task.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement,  6, task.completionCount);
    sqlite3_bind_int(insertStatement,  7, task.repeat);
	sqlite3_bind_text(insertStatement, 8, [task.instructions UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 9, [task.priority UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 10, [task.status UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 11, [task.lastCompletionTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 12, [[task.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Task*)task {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Task SET objectID = ?, description = ?, name = ?, shortDescription = ?, activation = ?,completionCount = ?,repeat = ?,instructions = ?,priority = ?,status = ?,lastCompletionTime = ?,actionPlan = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(updateStatement, 1, [task.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 2, [task.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [task.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [task.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [[task.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement,  6, task.completionCount);
    sqlite3_bind_int(updateStatement,  7, task.repeat);
	sqlite3_bind_text(updateStatement, 8, [task.instructions UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 9, [task.priority UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [task.status UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 11, [task.lastCompletionTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 12, [[task.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 13, [task.objectID UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(updateStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateStatement);

	return result;
}


- (ResdbResult*)deleteAll {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteAllStatement == nil) {
		const char* sql = "delete from Task";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	result.sqliteCode = sqlite3_step(deleteAllStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteAllStatement);

	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteStatement == nil) {
		const char* sql = "delete from Task where objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteStatement);

	return result;
}


@end