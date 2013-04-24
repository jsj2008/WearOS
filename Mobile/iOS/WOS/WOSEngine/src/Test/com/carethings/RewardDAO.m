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
 * This code  is the  sole  property of CareThings, Inc. and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade secret, not to be disclosed 
 * without written authorization from CareThings.  Any  use, duplication, or  disclosure of this program  
 * by other than CareThings and its assigned licensees is strictly forbidden by law.
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

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement      = nil;
static sqlite3_stmt* retrieveCountStatement            = nil;


@implementation RewardDAO

- (void)transferRewardData:(Reward*)reward:(sqlite3_stmt*)rewardRow {
	char*  textPtr = nil;

	if ((reward == nil) || (rewardRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
		reward.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
		reward.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
		reward.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
   		reward.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
   		reward.shortDescription = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
        reward.activation = [[NSMutableArray alloc] initWithArray:[[NSString stringWithUTF8String:textPtr] componentsSeparatedByString:@","]];
    reward.completionCount  = sqlite3_column_int(rewardRow,i++);
    reward.repeat = sqlite3_column_int(rewardRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
		reward.instructions = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
   		reward.lastCompletionTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(rewardRow,i++)))
   		reward.actionPlan = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Reward*           reward         = [Reward new];
	ResdbResult*    result       = [ResdbResult new];


	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferRewardData: reward: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = reward;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)actionPlan {
	NSMutableArray*  rewards   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward where actionPlan=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [actionPlan UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
		Reward* reward = [Reward new];

		[self transferRewardData: reward: retrieveByRelatedIdStatement];

		[rewards addObject: reward];
	}

	if ([rewards count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = rewards;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  rewards   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];


	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan from Reward";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Reward* reward = [Reward new];

		[self transferRewardData: reward: retrieveAllStatement];

		[rewards addObject: reward];
	}

	if ([rewards count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = rewards;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)retrieveCount {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Reward";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

		NSInteger rewardCount = sqlite3_column_int(retrieveCountStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",rewardCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountStatement);

	return result;
}

- (ResdbResult*)insert:(Reward*)reward {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Reward (objectID,description,name,shortDescription,activation,completionCount,repeat,instructions,lastCompletionTime,actionPlan) values (?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(insertStatement, 1, [reward.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 2, [reward.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [reward.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [reward.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [[reward.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement,  6, reward.completionCount);
    sqlite3_bind_int(insertStatement,  7, reward.repeat);
	sqlite3_bind_text(insertStatement, 8, [reward.instructions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 9, [reward.lastCompletionTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 10, [[reward.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Reward*)reward {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Reward SET objectID = ?, description = ?, name = ?, shortDescription = ?, activation = ?,completionCount = ?,repeat = ?,instructions = ?,lastCompletionTime = ?,actionPlan = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with expectationOfSuccess '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(updateStatement, 1, [reward.objectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 2, [reward.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [reward.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [reward.shortDescription UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [[reward.activation componentsJoinedByString:@","] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement,  6, reward.completionCount);
    sqlite3_bind_int(updateStatement,  7, reward.repeat);
	sqlite3_bind_text(updateStatement, 8, [reward.instructions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 9, [reward.lastCompletionTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [[reward.actionPlan absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 11, [reward.objectID UTF8String], -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from Reward";

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
		const char* sql = "delete from Reward where objectID = ?";

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