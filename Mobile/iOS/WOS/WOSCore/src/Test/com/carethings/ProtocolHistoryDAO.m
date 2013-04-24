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

#import "ProtocolHistoryDAO.h"
#import "WSResourceManager.h"
#import "ProtocolHistory.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement = nil;
static sqlite3_stmt* retrieveAllStatement = nil;
static sqlite3_stmt* insertStatement = nil;
static sqlite3_stmt* updateStatement = nil;
static sqlite3_stmt* deleteStatement = nil;
static sqlite3_stmt* deleteAllStatement = nil;
static sqlite3_stmt* deleteByInterventionStatement = nil;
static sqlite3_stmt* retrieveByInterventionStatement = nil;
static sqlite3_stmt* retrieveByInterventionAndRelatedStatement = nil;


@implementation ProtocolHistoryDAO

- (void)transferProtocolHistoryData:(ProtocolHistory*)protocolHistory:(sqlite3_stmt*)protocolHistoryRow {
	char*  textPtr = nil;
	
	if ((protocolHistory == nil) || (protocolHistoryRow == nil))
		return;
	
	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.history = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.interventionSysID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
   		protocolHistory.relatedID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	ProtocolHistory*        protocolHistory = [ProtocolHistory new];
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,history,interventionSysID,relatedID from ProtocolHistory where objectID=?";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferProtocolHistoryData: protocolHistory: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = protocolHistory;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveStatement);
	sqlite3_clear_bindings(retrieveStatement);
	
	return result;
}

- (ResdbResult*)retrieveByIntervention:(NSString*)interventionID {
	ResdbResult*		result			= [ResdbResult new];
	NSMutableArray*		activities			= [NSMutableArray new];
	
	if (retrieveByInterventionStatement == nil) {
		const char* sql = "select objectID,creationTime,description,history,interventionSysID,relatedID from ProtocolHistory where interventionSysID=?";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByInterventionStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveByInterventionStatement, 1, [interventionID UTF8String],    -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveByInterventionStatement) == SQLITE_ROW) {
		ProtocolHistory* protocolHistory = [ProtocolHistory new];
		
		[self transferProtocolHistoryData: protocolHistory: retrieveByInterventionStatement];
		
		[activities addObject: protocolHistory];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode                       = SQLITE_ROW;
		result.resdbCode                        = RESDB_SQL_ROWS;
		result.resdbCollection          = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveByInterventionStatement);
	sqlite3_clear_bindings(retrieveByInterventionStatement);
	
	return result;
}

- (ResdbResult*)retrieveByIntervention:(NSString*)interventionID andRelatedId:(NSString*)relatedID {
    ResdbResult*		result			= [ResdbResult new];
   	NSMutableArray*		activities			= [NSMutableArray new];

   	if (retrieveByInterventionAndRelatedStatement == nil) {
   		const char* sql = "select objectID,creationTime,description,history,interventionSysID,relatedID from ProtocolHistory where interventionSysID=? and relatedID=?";

   		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByInterventionAndRelatedStatement, NULL);

   		if (result.sqliteCode != SQLITE_OK) {
   			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
   			result.resdbCode = RESDB_SQL_ERROR;

   			return result;
   		}
   	}

   	sqlite3_bind_text(retrieveByInterventionAndRelatedStatement, 1, [interventionID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(retrieveByInterventionAndRelatedStatement, 2, [relatedID UTF8String],    -1, SQLITE_TRANSIENT);

   	while (sqlite3_step(retrieveByInterventionAndRelatedStatement) == SQLITE_ROW) {
   		ProtocolHistory* protocolHistory = [ProtocolHistory new];

   		[self transferProtocolHistoryData: protocolHistory: retrieveByInterventionAndRelatedStatement];

   		[activities addObject: protocolHistory];
   	}

   	if ([activities count] > 0) {
   		result.sqliteCode         = SQLITE_ROW;
   		result.resdbCode          = RESDB_SQL_ROWS;
   		result.resdbCollection    = activities;
   	} else {
   		result.resdbCode =  RESDB_SQL_NO_ROWS;
   	}

   	sqlite3_reset(retrieveByInterventionAndRelatedStatement);
   	sqlite3_clear_bindings(retrieveByInterventionAndRelatedStatement);

   	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  activities = [NSMutableArray new];
	
	ResdbResult*     result     = [ResdbResult new];
	
	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,history,interventionSysID,relatedID from ProtocolHistory";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		ProtocolHistory* protocolHistory = [ProtocolHistory new];
		
		[self transferProtocolHistoryData: protocolHistory: retrieveAllStatement];
		
		[activities addObject: protocolHistory];
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

- (ResdbResult*)insert:(ProtocolHistory*)protocolHistory {
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (insertStatement == nil) {
		const char* sql = "INSERT into ProtocolHistory (objectID,description,history,interventionSysID,relatedID) values (?,?,?,?,?)";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(insertStatement,  1, [protocolHistory.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  2, [protocolHistory.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  3, [protocolHistory.history UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  4, [protocolHistory.interventionSysID UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement,  5, [protocolHistory.relatedID UTF8String],   -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);
	
	if (result.sqliteCode != SQLITE_DONE) {
		result.resdbCode = RESDB_SQL_ERROR;
	} else
		result.resdbCode = RESDB_SQL_OK;
	
	sqlite3_reset(insertStatement);
	
	return result;
}

- (ResdbResult*)update:(ProtocolHistory*)protocolHistory {
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (updateStatement == nil) {
		const char* sql = "UPDATE ProtocolHistory SET objectID = ?, description = ?, history = ?, interventionSysID = ?, relatedID = ? WHERE objectID = ?";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(updateStatement,  1, [protocolHistory.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  2, [protocolHistory.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  3, [protocolHistory.history UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  4, [protocolHistory.interventionSysID UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  5, [protocolHistory.relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  6, [protocolHistory.objectID UTF8String], -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from ProtocolHistory";
		
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

- (ResdbResult*)deleteByIntervention:(NSString*)interventionID {
	ResdbResult*     result   = [ResdbResult new];
	
	if (deleteByInterventionStatement == nil) {
		const char* sql = "delete from ProtocolHistory where interventionSysID=?";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByInterventionStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(deleteByInterventionStatement, 1, [interventionID UTF8String], -1, SQLITE_TRANSIENT);
	
	result.sqliteCode = sqlite3_step(deleteByInterventionStatement);
	
	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;
	
	sqlite3_reset(deleteByInterventionStatement);
	sqlite3_clear_bindings(deleteByInterventionStatement);
	
	return result;
}

- (ResdbResult*)deleteByIntervention:(NSString*)interventionID andRelatedId:(NSString *)relatedID {
    ResdbResult*     result   = [ResdbResult new];

   	if (deleteByInterventionStatement == nil) {
   		const char* sql = "delete from ProtocolHistory where interventionSysID=? and relatedID=?";

   		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByInterventionStatement, NULL) != SQLITE_OK) {
   			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
   			result.resdbCode = RESDB_SQL_ERROR;

   			return result;
   		}
   	}

   	sqlite3_bind_text(deleteByInterventionStatement, 1, [interventionID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteByInterventionStatement, 2, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

   	result.sqliteCode = sqlite3_step(deleteByInterventionStatement);

   	if (result.sqliteCode != SQLITE_DONE)
   		result.resdbCode = RESDB_SQL_ERROR;
   	else
   		result.resdbCode = RESDB_SQL_OK;

   	sqlite3_reset(deleteByInterventionStatement);
   	sqlite3_clear_bindings(deleteByInterventionStatement);

   	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {	
	ResdbResult*     result   = [ResdbResult new];
	
	if (deleteStatement == nil) {
		const char* sql = "delete from ProtocolHistory where objectID = ?";
		
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
