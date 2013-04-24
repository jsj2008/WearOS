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

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* deleteByRelatedIdStatement        = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement      = nil;
static sqlite3_stmt* retrieveCountByRelatedIdStatement = nil;


@implementation GoalDAO

- (void)transferGoalData:(Goal*)goal:(sqlite3_stmt*)goalRow {
	char*  textPtr = nil;

	if ((goal == nil) || (goalRow == nil))
		return;

	if ((textPtr = (char*)sqlite3_column_text(goalRow,0)))
		goal.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,1)))
		goal.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,2)))
		goal.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(goalRow,3)))
   		goal.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(goalRow,4)))
   		goal.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(goalRow,5)))
   		goal.instructions = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(goalRow,6)))
   		goal.activation = [[NSMutableArray alloc] initWithArray:[[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","]];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,7)))
		goal.personalValue = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,8)))
		goal.expectationOfSuccess = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,9)))
		goal.reward = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(goalRow,10)))
		goal.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Goal*           goal         = [Goal new];
	ResdbResult*     result        = [ResdbResult new];

	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan from Goal where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferGoalData: goal: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = goal;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSMutableArray*  goals   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan from Goal where actionPlan=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [actionPlan UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
		Goal* goal = [Goal new];

		[self transferGoalData: goal: retrieveByRelatedIdStatement];

		[goals addObject: goal];
	}

	if ([goals count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = goals;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  goals   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];


	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan from Goal";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Goal* goal = [Goal new];

		[self transferGoalData: goal: retrieveAllStatement];

		[goals addObject: goal];
	}

	if ([goals count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = goals;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)actionPlan {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountByRelatedIdStatement == nil) {
		const char* sql = "SELECT count(*) from Goal where actionPlan = ?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveCountByRelatedIdStatement, 1, [actionPlan UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveCountByRelatedIdStatement) == SQLITE_ROW) {

		NSInteger goalCount = sqlite3_column_int(retrieveCountByRelatedIdStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",goalCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountByRelatedIdStatement);

	return result;
}

- (ResdbResult*)insert:(Goal*)goal {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Goal (objectID,description,name,shortDescription,instructions,activation,personalValue,expectationOfSuccess,reward,actionPlan) values (?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(insertStatement, 1, [goal.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 2, [goal.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [goal.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [goal.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [goal.instructions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [[goal.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 7, [goal.personalValue UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 8, [goal.expectationOfSuccess UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 9, [goal.reward UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 10, [[goal.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Goal*)goal {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Goal SET objectID = ?, description = ?, name = ?, shortDescription = ?, instructions = ?, activation = ?, personalValue = ?, expectationOfSuccess = ?, reward = ?, actionPlan = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(updateStatement, 1, [goal.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 2, [goal.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [goal.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [goal.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [goal.instructions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [[goal.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 7, [goal.personalValue UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 8, [goal.expectationOfSuccess UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 9, [goal.reward UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 10, [[goal.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 11, [goal.objectID UTF8String], -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from Goal";

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

- (ResdbResult*)deleteByRelatedId:(NSString*)actionPlan {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteByRelatedIdStatement == nil) {
		const char* sql = "delete from Goal where actionPlan = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByRelatedIdStatement, 1, [actionPlan UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByRelatedIdStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByRelatedIdStatement);

	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteStatement == nil) {
		const char* sql = "delete from Goal where objectID = ?";

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