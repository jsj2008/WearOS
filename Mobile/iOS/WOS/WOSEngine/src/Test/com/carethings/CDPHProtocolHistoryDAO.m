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

#import "CDPHProtocolHistoryDAO.h"
#import "WSResourceManager.h"
#import "CDPHProtocolHistory.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement = nil;
static sqlite3_stmt* insertStatement = nil;
static sqlite3_stmt* retrieveAllStatement = nil;
static sqlite3_stmt* deleteAllStatement = nil;
static sqlite3_stmt* updateStatement = nil;
static sqlite3_stmt* deleteStatement = nil;
static sqlite3_stmt* deleteByInterventionStatement = nil;
static sqlite3_stmt* retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement = nil;


@implementation CDPHProtocolHistoryDAO

- (void)transferProtocolHistoryData:(CDPHProtocolHistory*)protocolHistory:(sqlite3_stmt*)protocolHistoryRow {
	char*  textPtr = nil;
	
	if ((protocolHistory == nil) || (protocolHistoryRow == nil))
		return;
	
	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.objectID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.creationTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.description = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.visit = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.abstractionDate = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.clientID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.abstractorID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.siteID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.history = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(protocolHistoryRow, i++)))
		protocolHistory.interventionSysID = [[NSString alloc] initWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	CDPHProtocolHistory*	protocolHistory = [CDPHProtocolHistory new];
	
	ResdbResult*			result   = [ResdbResult new];
	
	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory where objectID=?";
		
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

- (ResdbResult*)retrieveByAbstractionDate:(NSString*)abstractionDate andSiteID:(NSString*)siteID andClientID:(NSString*)clientID  andVisit:(NSString*)visit andIntervention:(NSString*)interventionID {
	
	ResdbResult*		result			= [ResdbResult new];
	NSMutableArray*		activities			= [NSMutableArray new];
	
	if (retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement == nil) {
		const char* sql = "select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory where abstractionDate=? and siteID=? and clientID=? and visit=? and interventionSysID=?";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, 1, [abstractionDate UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, 2, [siteID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, 3, [clientID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, 4, [visit UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement, 5, [interventionID UTF8String],    -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement) == SQLITE_ROW) {
		CDPHProtocolHistory* protocolHistory = [CDPHProtocolHistory new];
		
		[self transferProtocolHistoryData: protocolHistory: retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement];
		
		[activities addObject: protocolHistory];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode                       = SQLITE_ROW;
		result.resdbCode                        = RESDB_SQL_ROWS;
		result.resdbCollection          = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement);
	sqlite3_clear_bindings(retrieveByAbstractionDateandSiteIDandClientIDandVisitandInteventionStatement);
	
	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  activities = [NSMutableArray new];
	
	ResdbResult*     result     = [ResdbResult new];
	
	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID from CDPHProtocolHistory";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		CDPHProtocolHistory* protocolHistory = [CDPHProtocolHistory new];
		
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

- (ResdbResult*)insert:(CDPHProtocolHistory*)protocolHistory {
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (insertStatement == nil) {
		const char* sql = "INSERT into CDPHProtocolHistory (objectID,description,visit,abstractionDate,clientID,abstractorID,siteID,history,interventionSysID) values (?,?,?,?,?,?,?,?,?)";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(insertStatement,  1, [protocolHistory.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  2, [protocolHistory.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  3, [protocolHistory.visit UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  4, [protocolHistory.abstractionDate UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  5, [protocolHistory.clientID UTF8String],  -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  6, [protocolHistory.abstractorID UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  7, [protocolHistory.siteID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  8, [protocolHistory.history UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  9, [protocolHistory.interventionSysID UTF8String],   -1, SQLITE_TRANSIENT);
	
	result.sqliteCode = sqlite3_step(insertStatement);
	
	if (result.sqliteCode != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
		result.resdbCode = RESDB_SQL_ERROR;
	} else
		result.resdbCode = RESDB_SQL_OK;
	
	sqlite3_reset(insertStatement);
	
	return result;
}

- (ResdbResult*)update:(CDPHProtocolHistory*)protocolHistory {
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (updateStatement == nil) {
		const char* sql = "UPDATE CDPHProtocolHistory SET objectID = ?, description = ?, visit = ?, abstractionDate = ?, clientID = ?, abstractorID = ?, siteID = ?, history = ?, interventionSysID = ? WHERE objectID = ?";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(updateStatement,  1, [protocolHistory.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  2, [protocolHistory.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  3, [protocolHistory.visit UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  4, [protocolHistory.abstractionDate UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  5, [protocolHistory.clientID UTF8String],  -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  6, [protocolHistory.abstractorID UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  7, [protocolHistory.siteID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  8, [protocolHistory.history UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  9, [protocolHistory.interventionSysID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 10, [protocolHistory.objectID UTF8String], -1, SQLITE_TRANSIENT);
	
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
		const char* sql = "delete from CDPHProtocolHistory";
		
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

- (ResdbResult*)delete:(NSString*)objectID {
	
	ResdbResult*     result   = [ResdbResult new];
	
	if (deleteStatement == nil) {
		const char* sql = "delete from CDPHProtocolHistory where objectID = ?";
		
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
