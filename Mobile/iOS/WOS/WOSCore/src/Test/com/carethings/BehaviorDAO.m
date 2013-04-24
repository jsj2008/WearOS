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

static sqlite3_stmt* retrieveStatement = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement = nil;
static sqlite3_stmt* insertStatement = nil;
static sqlite3_stmt* retrieveAllStatement = nil;
static sqlite3_stmt* deleteAllStatement = nil;
static sqlite3_stmt* updateStatement = nil;
static sqlite3_stmt* deleteStatement = nil;

@implementation BehaviorDAO

- (void)transferBehaviorData:(Behavior*)behavior:(sqlite3_stmt*)behaviorRow {
	char*  textPtr = nil;

	if ((behavior == nil) || (behaviorRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
		behavior.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
		behavior.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
		behavior.description = [NSString stringWithUTF8String:textPtr];
    behavior.behaviorType = sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.decoratedName = [NSString stringWithUTF8String:textPtr];
    behavior.behaviorState = sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.concept = [NSString stringWithUTF8String:textPtr];
    behavior.monitorWatcher = (float) sqlite3_column_double(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.reactorActivation = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.monitorEnd = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.monitorEndCode = [NSMutableData dataWithBytes:sqlite3_column_blob(behaviorRow, i) length:(NSUInteger) sqlite3_column_bytes(behaviorRow, i)];
   	i++;
    behavior.monitorEndLanguage = sqlite3_column_int(behaviorRow,i++);
    behavior.monitorEndCodeLen = sqlite3_column_int(behaviorRow,i++);
    behavior.monitorEndCodeValid = (bool) sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
		behavior.monitorException = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.monitorExceptionCode = [NSMutableData dataWithBytes:sqlite3_column_blob(behaviorRow, i) length:(NSUInteger) sqlite3_column_bytes(behaviorRow, i)];
   	i++;
    behavior.monitorExceptionLanguage = sqlite3_column_int(behaviorRow,i++);
    behavior.monitorExceptionCodeLen = sqlite3_column_int(behaviorRow,i++);
    behavior.monitorExceptionCodeValid = (bool) sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.startActions = [[NSString alloc] initWithUTF8String: textPtr];
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.startActionsCode = [NSMutableData dataWithBytes:sqlite3_column_blob(behaviorRow, i) length:(NSUInteger) sqlite3_column_bytes(behaviorRow, i)];
   	i++;
    behavior.startActionsLanguage = sqlite3_column_int(behaviorRow,i++);
    behavior.startActionsCodeLen = sqlite3_column_int(behaviorRow,i++);
    behavior.startActionsCodeValid = (bool) sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
   		behavior.stopActions = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.stopActionsCode = [NSMutableData dataWithBytes:sqlite3_column_blob(behaviorRow, i) length:(NSUInteger) sqlite3_column_bytes(behaviorRow, i)];
   	i++;
    behavior.stopActionsLanguage = sqlite3_column_int(behaviorRow,i++);
    behavior.stopActionsCodeLen = sqlite3_column_int(behaviorRow,i++);
    behavior.stopActionsCodeValid = (bool) sqlite3_column_int(behaviorRow,i++);
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.protocol = [NSMutableData dataWithBytes:sqlite3_column_blob(behaviorRow, i) length:(NSUInteger) sqlite3_column_bytes(behaviorRow, i)];
    i++;
    if (sqlite3_column_bytes(behaviorRow,i) > 0)
   		behavior.protocolCode = [NSMutableData dataWithBytes: sqlite3_column_blob(behaviorRow,i) length:(NSUInteger)  sqlite3_column_bytes(behaviorRow,i)];
   	i++;
    behavior.protocolLanguage = sqlite3_column_int(behaviorRow,i++);
    behavior.protocolCodeLen = sqlite3_column_int(behaviorRow,i++);
    behavior.protocolCodeValid = (bool) sqlite3_column_int(behaviorRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i++)))
        behavior.knowledge = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:textPtr]];
    if ((textPtr = (char*)sqlite3_column_text(behaviorRow, i)))
        behavior.relatedID = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Behavior*        behavior = [Behavior new];
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferBehaviorData: behavior: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = behavior;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);
	sqlite3_clear_bindings(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
	NSMutableArray*  behaviors  = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];

	if (retrieveByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior where relatedID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
		Behavior* behavior = [Behavior new];

		[self transferBehaviorData: behavior: retrieveByRelatedIdStatement];

		[behaviors addObject: behavior];
	}

	if ([behaviors count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = behaviors;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdStatement);
	sqlite3_clear_bindings(retrieveByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  activities = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];

	if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID from Behavior";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Behavior* behavior = [Behavior new];

		[self transferBehaviorData: behavior: retrieveAllStatement];

		[activities addObject: behavior];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);
	sqlite3_clear_bindings(retrieveAllStatement);

	return result;
}

- (ResdbResult*)insert:(Behavior*)behavior {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
        const char* sql = "INSERT into Behavior (objectID,description,behaviorType,decoratedName,behaviorState,concept,monitorWatcher,reactorActivation,monitorEnd,monitorEndCode,monitorEndLanguage,monitorEndCodeLen,monitorEndCodeValid,monitorException,monitorExceptionCode,monitorExceptionLanguage,monitorExceptionCodeLen,monitorExceptionCodeValid,startActions,startActionsCode,startActionsLanguage,startActionsCodeLen,startActionsCodeValid,stopActions,stopActionsCode,stopActionsLanguage,stopActionsCodeLen,stopActionsCodeValid,protocol,protocolCode,protocolLanguage,protocolCodeLen,protocolCodeValid,knowledge,relatedID) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

    int i = 1;

    sqlite3_bind_text(insertStatement, i++, [behavior.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [behavior.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.behaviorType);
    sqlite3_bind_text(insertStatement, i++, [behavior.decoratedName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.behaviorState);
    sqlite3_bind_text(insertStatement, i++, [behavior.concept UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(insertStatement, i++, behavior.monitorWatcher);
    sqlite3_bind_text(insertStatement, i++, [behavior.reactorActivation UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [behavior.monitorEnd UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, i++, [behavior.monitorEndCode bytes], [behavior.monitorEndCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorEndLanguage);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorEndCodeLen);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorEndCodeValid);
    sqlite3_bind_text(insertStatement, i++, [behavior.monitorException UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, i++, [behavior.monitorExceptionCode bytes], [behavior.monitorExceptionCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorExceptionLanguage);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorExceptionCodeLen);
    sqlite3_bind_int(insertStatement, i++, behavior.monitorExceptionCodeValid);
    sqlite3_bind_text(insertStatement, i++, [behavior.startActions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, i++, [behavior.startActionsCode bytes], [behavior.startActionsCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.startActionsLanguage);
    sqlite3_bind_int(insertStatement, i++, behavior.startActionsCodeLen);
    sqlite3_bind_int(insertStatement, i++, behavior.startActionsCodeValid);
    sqlite3_bind_text(insertStatement, i++, [behavior.stopActions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, i++, [behavior.stopActionsCode bytes], [behavior.stopActionsCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.stopActionsLanguage);
    sqlite3_bind_int(insertStatement, i++, behavior.stopActionsCodeLen);
    sqlite3_bind_int(insertStatement, i++, behavior.stopActionsCodeValid);
    sqlite3_bind_blob(insertStatement, i++, [behavior.protocol bytes], [behavior.protocol length], SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, i++, [behavior.protocolCode bytes], [behavior.protocolCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, behavior.protocolLanguage);
    sqlite3_bind_int(insertStatement, i++, behavior.protocolCodeLen);
    sqlite3_bind_int(insertStatement, i++, behavior.protocolCodeValid);
    sqlite3_bind_text(insertStatement, i++, [[behavior.knowledge absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i, [behavior.relatedID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE) {
		result.resdbCode = RESDB_SQL_ERROR;
	} else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Behavior*)behavior {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
        const char* sql = "UPDATE Behavior SET objectID = ?, description = ?, behaviorType = ?, decoratedName = ?, behaviorState = ?, concept = ?, monitorWatcher = ?, reactorActivation = ?, monitorEnd = ?, monitorEndCode = ?, monitorEndLanguage = ?, monitorEndCodeLen = ?, monitorEndCodeValid = ?, monitorException = ?, monitorExceptionCode = ?, monitorExceptionLanguage = ?, monitorExceptionCodeLen = ?, monitorExceptionCodeValid = ?, startActions = ?, startActionsCode = ?, startActionsLanguage = ?, startActionsCodeLen = ?, startActionsCodeValid = ?, stopActions = ?, stopActionsCode = ?, stopActionsLanguage = ?, stopActionsCodeLen = ?, stopActionsCodeValid = ?, protocol = ?, protocolCode = ?, protocolLanguage = ?, protocolCodeLen = ?, protocolCodeValid = ?, knowledge = ?, relatedID = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

    int i = 1;

    sqlite3_bind_text(updateStatement, i++, [behavior.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [behavior.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.behaviorType);
    sqlite3_bind_text(updateStatement, i++, [behavior.decoratedName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.behaviorState);
    sqlite3_bind_text(updateStatement, i++, [behavior.concept UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(updateStatement, i++, behavior.monitorWatcher);
    sqlite3_bind_text(updateStatement, i++, [behavior.reactorActivation UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [behavior.monitorEnd UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, i++, [behavior.monitorEndCode bytes], [behavior.monitorEndCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorEndLanguage);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorEndCodeLen);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorEndCodeValid);
    sqlite3_bind_text(updateStatement, i++, [behavior.monitorException UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, i++, [behavior.monitorExceptionCode bytes], [behavior.monitorExceptionCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorExceptionLanguage);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorExceptionCodeLen);
    sqlite3_bind_int(updateStatement, i++, behavior.monitorExceptionCodeValid);
    sqlite3_bind_text(updateStatement, i++, [behavior.startActions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, i++, [behavior.startActionsCode bytes], [behavior.startActionsCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.startActionsLanguage);
    sqlite3_bind_int(updateStatement, i++, behavior.startActionsCodeLen);
    sqlite3_bind_int(updateStatement, i++, behavior.startActionsCodeValid);
    sqlite3_bind_text(updateStatement, i++, [behavior.stopActions UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, i++, [behavior.stopActionsCode bytes], [behavior.stopActionsCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.stopActionsLanguage);
    sqlite3_bind_int(updateStatement, i++, behavior.stopActionsCodeLen);
    sqlite3_bind_int(updateStatement, i++, behavior.stopActionsCodeValid);
    sqlite3_bind_blob(updateStatement, i++, [behavior.protocol bytes], [behavior.protocol length], SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, i++, [behavior.protocolCode bytes], [behavior.protocolCode length], SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, behavior.protocolLanguage);
    sqlite3_bind_int(updateStatement, i++, behavior.protocolCodeLen);
    sqlite3_bind_int(updateStatement, i++, behavior.protocolCodeValid);
    sqlite3_bind_text(updateStatement, i++, [[behavior.knowledge absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [behavior.relatedID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i, [behavior.objectID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateStatement);
	sqlite3_clear_bindings(updateStatement);

	return result;
}


- (ResdbResult*)deleteAll {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteAllStatement == nil) {
		const char* sql = "delete from Behavior";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
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
	sqlite3_clear_bindings(deleteAllStatement);

	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteStatement == nil) {
		const char* sql = "delete from Behavior where objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
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
	sqlite3_clear_bindings(deleteStatement);

	return result;
}

@end
