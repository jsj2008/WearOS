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

#import "ActivityDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement = nil;
static sqlite3_stmt* insertStatement = nil;
static sqlite3_stmt* retrieveAllStatement = nil;
static sqlite3_stmt* leastRecentActivityWithReasonStatement = nil;
static sqlite3_stmt* mostRecentActivityStatement = nil;
static sqlite3_stmt* mostRecentActivityWithReasonStatement = nil;
static sqlite3_stmt* deleteAllStatement = nil;
static sqlite3_stmt* deleteByRelatedIdStatement = nil;
static sqlite3_stmt* deleteByRelatedIdAndSysIDAndReasonStatement = nil;
static sqlite3_stmt* deleteByRelatedIdAndCodeStatement = nil;
static sqlite3_stmt* deleteByLocationCodeStatement = nil;
static sqlite3_stmt* updateStatement = nil;
static sqlite3_stmt* updateAllArchivedStatement = nil;
static sqlite3_stmt* updateAllUnArchiveStatement = nil;
static sqlite3_stmt* deleteStatement = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement = nil;
static sqlite3_stmt* retrieveByReasonStatement = nil;
static sqlite3_stmt* retrieveByRelatedIdAndCodeStatement = nil;
static sqlite3_stmt* retrieveByRelatedIdAndReasonStatement = nil;
static sqlite3_stmt* retrieveCountByRelatedIdAndCodeStatement = nil;
static sqlite3_stmt* retrieveCountStatement = nil;
static sqlite3_stmt* retrieveCountByRelatedIdAndReasonStatement = nil;
static sqlite3_stmt* retrieveByRelatedIdAndSysIDAndReasonStatement = nil;
static sqlite3_stmt* retrieveByOriginatorAndLocationAndAbstractionDateStatement = nil;
static sqlite3_stmt* retrieveOrderByReasonForRelatedIdAndLocationCodeStatement = nil;
static sqlite3_stmt* retrieveByUnArchivedStatement = nil;
static sqlite3_stmt* retrieveByUnArchivedByRelatedIdStatement = nil;
static sqlite3_stmt* retrieveOrderByRelatedIdReasonForLocationCodeStatement = nil;
static sqlite3_stmt* retrieveOrderByDescCreationForReasonStatement = nil;
static sqlite3_stmt* retrieveAllWithMonthStatement = nil;
static sqlite3_stmt* retrieveAllWithStartTimeMonthStatement = nil;
static sqlite3_stmt* retrieveByUserIdAndRelatedIdStatement = nil;

const NSString* SQL_SELECT		= @"select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location from Activity";
const NSString* SQL_INSERT		= @"INSERT into Activity (objectID,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
const NSString* SQL_DELETE		= @"UPDATE Activity SET objectID = ?, reason = ?, description = ?, type = ?, code = ?, vendorType = ?, value = ?, startTime = ?, endTime = ?, relatedID = ?, sysID=?,archived=?, data = ?,originator = ?,location = ?";


@implementation ActivityDAO

- (void)transferActivityData:(Activity*)activity:(sqlite3_stmt*)activityRow {
	char*  textPtr = nil;

	if ((activity == nil) || (activityRow == nil))
		return;

    int i = 0;

	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.objectID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.creationTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.reason = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.description = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.type = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.code = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.vendorType = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.value = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.startTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.endTime = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.relatedID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.sysID = [[NSString alloc] initWithUTF8String: textPtr];
	activity.archived = (bool) sqlite3_column_int(activityRow,i++);
	if (sqlite3_column_bytes(activityRow, i) > 0)
		activity.data = [NSMutableData dataWithBytes: sqlite3_column_blob(activityRow, i) length: sqlite3_column_bytes(activityRow, i)];
    i++;
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.originator = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.location = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.userCode = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.userID = [[NSString alloc] initWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.locationCode = [[NSString alloc] initWithUTF8String: textPtr];
	activity.dayOfWeekOfStudy = sqlite3_column_int(activityRow, i++);
	activity.hourOfDayOfStudy = sqlite3_column_int(activityRow, i++);
	activity.numberOfSteps = sqlite3_column_int(activityRow, i++);
	activity.weekOfStudy = sqlite3_column_int(activityRow, i++);
	activity.weeklyGoal = sqlite3_column_int(activityRow, i++);
	if ((textPtr = (char*)sqlite3_column_text(activityRow, i++)))
		activity.instanceID = [[NSString alloc] initWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Activity*        activity = [Activity new];
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferActivityData: activity: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = activity;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);
	sqlite3_clear_bindings(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
	NSMutableArray*  activities = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];

	if (retrieveByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByRelatedIdStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdStatement);
	sqlite3_clear_bindings(retrieveByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveByUserId:(NSString*)userID andRelatedId:(NSString*)relatedId {
    NSMutableArray*		activities = [NSMutableArray new];
   	ResdbResult*		result     = [ResdbResult new];

   	if (retrieveByUserIdAndRelatedIdStatement == nil) {
   		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where userID=? and relatedID=?";

   		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByUserIdAndRelatedIdStatement, NULL);

   		if (result.sqliteCode != SQLITE_OK) {
   			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
   			result.resdbCode = RESDB_SQL_ERROR;

   			return result;
   		}
   	}

   	sqlite3_bind_text(retrieveByUserIdAndRelatedIdStatement, 1, [userID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(retrieveByUserIdAndRelatedIdStatement, 2, [relatedId UTF8String], -1, SQLITE_TRANSIENT);

   	while (sqlite3_step(retrieveByUserIdAndRelatedIdStatement) == SQLITE_ROW) {
   		Activity* activity = [Activity new];

   		[self transferActivityData: activity: retrieveByUserIdAndRelatedIdStatement];

   		[activities addObject: activity];
   	}

   	if ([activities count] > 0) {
   		result.sqliteCode      = SQLITE_ROW;
   		result.resdbCode       = RESDB_SQL_ROWS;
   		result.resdbCollection = activities;
   	} else {
   		result.resdbCode =  RESDB_SQL_NO_ROWS;
   	}

   	sqlite3_reset(retrieveByUserIdAndRelatedIdStatement);
   	sqlite3_clear_bindings(retrieveByUserIdAndRelatedIdStatement);

   	return result;
}

- (ResdbResult*)retrieveByReason:(NSString*)reason {
	NSMutableArray*		activities = [NSMutableArray new];
	ResdbResult*		result     = [ResdbResult new];
	
	if (retrieveByReasonStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where reason=?";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByReasonStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveByReasonStatement, 1, [reason UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveByReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: retrieveByReasonStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveByReasonStatement);
	sqlite3_clear_bindings(retrieveByReasonStatement);
	
	return result;
}

- (ResdbResult*)retrieveUnArchived {
	NSMutableArray*         activities              = [NSMutableArray new];
	ResdbResult*               result          = [ResdbResult new];

	if (retrieveByUnArchivedStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where archived=0";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByUnArchivedStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveByUnArchivedStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByUnArchivedStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByUnArchivedStatement);
	sqlite3_clear_bindings(retrieveByUnArchivedStatement);

	return result;
}

- (ResdbResult*)retrieveOrderByRelatedIdReasonForLocationCode:(NSString*)locationCode {
	NSMutableArray*                 activities              = [NSMutableArray new];
	ResdbResult*                    result          = [ResdbResult new];

	if (retrieveOrderByRelatedIdReasonForLocationCodeStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where locationCode=? order by relatedID, reason";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveOrderByRelatedIdReasonForLocationCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveOrderByRelatedIdReasonForLocationCodeStatement, 1, [locationCode UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveOrderByRelatedIdReasonForLocationCodeStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveOrderByRelatedIdReasonForLocationCodeStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveOrderByRelatedIdReasonForLocationCodeStatement);
	sqlite3_clear_bindings(retrieveOrderByRelatedIdReasonForLocationCodeStatement);

	return result;
}

- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId andLocationCode:(NSString*)locationCode {
	NSMutableArray*                 activities              = [NSMutableArray new];
	ResdbResult*                    result          = [ResdbResult new];

	if (retrieveOrderByRelatedIdReasonForLocationCodeStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and locationCode=? order by reason";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveOrderByRelatedIdReasonForLocationCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveOrderByRelatedIdReasonForLocationCodeStatement, 1, [relatedId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveOrderByRelatedIdReasonForLocationCodeStatement, 2, [locationCode UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveOrderByRelatedIdReasonForLocationCodeStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveOrderByRelatedIdReasonForLocationCodeStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveOrderByRelatedIdReasonForLocationCodeStatement);
	sqlite3_clear_bindings(retrieveOrderByRelatedIdReasonForLocationCodeStatement);

	return result;
}

- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedID {
	NSMutableArray*         activities              = [NSMutableArray new];
	ResdbResult*            result          = [ResdbResult new];

	if (retrieveOrderByReasonForRelatedIdAndLocationCodeStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? order by reason";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveOrderByReasonForRelatedIdAndLocationCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveOrderByReasonForRelatedIdAndLocationCodeStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveOrderByReasonForRelatedIdAndLocationCodeStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveOrderByReasonForRelatedIdAndLocationCodeStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveOrderByReasonForRelatedIdAndLocationCodeStatement);
	sqlite3_clear_bindings(retrieveOrderByReasonForRelatedIdAndLocationCodeStatement);

	return result;
}

- (ResdbResult*)mostRecentActivityByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code {
	Activity*        activity = [Activity new];
	ResdbResult*     result   = [ResdbResult new];

	if (mostRecentActivityStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where code = ? and relatedID = ? and creationTime = (select max(creationTime) from Activity)";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &mostRecentActivityStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(mostRecentActivityStatement, 1, [code UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(mostRecentActivityStatement, 2, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(mostRecentActivityStatement) == SQLITE_ROW) {
		[self transferActivityData: activity: mostRecentActivityStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = activity;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(mostRecentActivityStatement);
	sqlite3_clear_bindings(mostRecentActivityStatement);

	return result;
}


- (ResdbResult*)leastRecentActivityWithReason:(NSString*)reason {
	NSMutableArray*		activities = [NSMutableArray new];
	ResdbResult*			result   = [ResdbResult new];
	
	if (leastRecentActivityWithReasonStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where creationTime = (select min(creationTime) from Activity where reason = ?)";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &leastRecentActivityWithReasonStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(leastRecentActivityWithReasonStatement, 1, [reason UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(leastRecentActivityWithReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: leastRecentActivityWithReasonStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode			= SQLITE_ROW;
		result.resdbCode			= RESDB_SQL_ROWS;
		result.resdbCollection	= activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(leastRecentActivityWithReasonStatement);
	sqlite3_clear_bindings(leastRecentActivityWithReasonStatement);
	
	return result;
}

- (ResdbResult*)mostRecentActivityWithReason:(NSString*)reason {
	NSMutableArray*		activities = [NSMutableArray new];
	ResdbResult*			result   = [ResdbResult new];
	
	if (mostRecentActivityWithReasonStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where creationTime = (select max(creationTime) from Activity where reason = ?)";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &mostRecentActivityWithReasonStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(mostRecentActivityWithReasonStatement, 1, [reason UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(mostRecentActivityWithReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: mostRecentActivityWithReasonStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode			= SQLITE_ROW;
		result.resdbCode			= RESDB_SQL_ROWS;
		result.resdbCollection	= activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(mostRecentActivityWithReasonStatement);
	sqlite3_clear_bindings(mostRecentActivityWithReasonStatement);
	
	return result;
}

- (ResdbResult*)retrieveOrderByDescCreationForReason:(NSString*)reason {
	NSMutableArray*		activities = [NSMutableArray new];
	ResdbResult*			result   = [ResdbResult new];
	
	if (retrieveOrderByDescCreationForReasonStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where reason = ? order by creationTime desc";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveOrderByDescCreationForReasonStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveOrderByDescCreationForReasonStatement, 1, [reason UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveOrderByDescCreationForReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: retrieveOrderByDescCreationForReasonStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode			= SQLITE_ROW;
		result.resdbCode			= RESDB_SQL_ROWS;
		result.resdbCollection	= activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveOrderByDescCreationForReasonStatement);
	sqlite3_clear_bindings(retrieveOrderByDescCreationForReasonStatement);
	
	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andCode:(NSString*)code {
	ResdbResult*     result     = [ResdbResult new];
	NSMutableArray*  activities = [NSMutableArray new];

	if (retrieveByRelatedIdAndCodeStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where code = ? and relatedID = ?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdAndCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdAndCodeStatement, 1, [code UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByRelatedIdAndCodeStatement, 2, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdAndCodeStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByRelatedIdAndCodeStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdAndCodeStatement);
	sqlite3_clear_bindings(retrieveByRelatedIdAndCodeStatement);

	return result;
}

- (ResdbResult *)retrieveByInstanceId:(__unused NSString *)instanceID andType:(__unused NSString *)type {
    return nil;
}


- (ResdbResult*)retrieveWithType:(NSString*)type andStartTimeMonth:(NSString*)month {
	NSMutableArray*  activities = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];
	
	if (retrieveAllWithStartTimeMonthStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where type = ? and strftime('%m', startTime) = ? order by startTime";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllWithStartTimeMonthStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}

	sqlite3_bind_text(retrieveAllWithStartTimeMonthStatement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveAllWithStartTimeMonthStatement, 2, [month UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveAllWithStartTimeMonthStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: retrieveAllWithStartTimeMonthStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveAllWithStartTimeMonthStatement);
	sqlite3_clear_bindings(retrieveAllWithStartTimeMonthStatement);
	
	return result;
}

- (ResdbResult*)retrieveAllWithMonth:(NSString*)month {
	NSMutableArray*  activities = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];
	
	if (retrieveAllWithMonthStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where strftime('%m', creationTime) = ?";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllWithMonthStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
	
	sqlite3_bind_text(retrieveAllWithMonthStatement, 1, [month UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(retrieveAllWithMonthStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];
		
		[self transferActivityData: activity: retrieveAllWithMonthStatement];
		
		[activities addObject: activity];
	}
	
	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveAllWithMonthStatement);
	sqlite3_clear_bindings(retrieveAllWithMonthStatement);
	
	return result;
}

- (ResdbResult*)retrieveByOriginator:(NSString*)originator andLocation:(NSString*)location andAbstractionDate:abDate {
	ResdbResult*                        result          = [ResdbResult new];
	NSMutableArray*             activities              = [NSMutableArray new];

	if (retrieveByOriginatorAndLocationAndAbstractionDateStatement == nil) {
		const char* sql = "SELECT objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where originator = ? and location = ? and startTime = ?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByOriginatorAndLocationAndAbstractionDateStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByOriginatorAndLocationAndAbstractionDateStatement, 1, [originator UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByOriginatorAndLocationAndAbstractionDateStatement, 2, [location UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByOriginatorAndLocationAndAbstractionDateStatement, 3, [abDate UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByOriginatorAndLocationAndAbstractionDateStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByOriginatorAndLocationAndAbstractionDateStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByOriginatorAndLocationAndAbstractionDateStatement);
	sqlite3_clear_bindings(retrieveByOriginatorAndLocationAndAbstractionDateStatement);

	return result;
}

- (ResdbResult*)retrieveCountByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountByRelatedIdAndCodeStatement == nil) {
		const char* sql = "SELECT count(*) from Activity where code = ? and relatedID = ?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByRelatedIdAndCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveCountByRelatedIdAndCodeStatement, 1, [code UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveCountByRelatedIdAndCodeStatement, 2, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveCountByRelatedIdAndCodeStatement) == SQLITE_ROW) {
		NSInteger actCount = sqlite3_column_int(retrieveCountByRelatedIdAndCodeStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [ResdbObject new];
		result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",actCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountByRelatedIdAndCodeStatement);
	sqlite3_clear_bindings(retrieveCountByRelatedIdAndCodeStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andReason:(NSString*)reason {
	ResdbResult*     result     = [ResdbResult new];
	NSMutableArray*  activities = [NSMutableArray new];

	if (retrieveByRelatedIdAndReasonStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and reason=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdAndReasonStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdAndReasonStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByRelatedIdAndReasonStatement, 2, [reason UTF8String],    -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdAndReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByRelatedIdAndReasonStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdAndReasonStatement);
	sqlite3_clear_bindings(retrieveByRelatedIdAndReasonStatement);

	return result;
}

- (ResdbResult*)retrieveUnArchivedByRelatedId:(NSString*)relatedID {
	ResdbResult*            result          = [ResdbResult new];
	NSMutableArray*         activities              = [NSMutableArray new];

	if (retrieveByUnArchivedByRelatedIdStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and archived=0";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByUnArchivedByRelatedIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByUnArchivedByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByUnArchivedByRelatedIdStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByUnArchivedByRelatedIdStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode                       = SQLITE_ROW;
		result.resdbCode                        = RESDB_SQL_ROWS;
		result.resdbCollection          = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByUnArchivedByRelatedIdStatement);
	sqlite3_clear_bindings(retrieveByUnArchivedByRelatedIdStatement);

	return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason {
	ResdbResult*            result          = [ResdbResult new];
	NSMutableArray*         activities              = [NSMutableArray new];

	if (retrieveByRelatedIdAndSysIDAndReasonStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity where relatedID=? and sysID=? and reason=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdAndSysIDAndReasonStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByRelatedIdAndSysIDAndReasonStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByRelatedIdAndSysIDAndReasonStatement, 2, [sysID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByRelatedIdAndSysIDAndReasonStatement, 3, [reason UTF8String],    -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByRelatedIdAndSysIDAndReasonStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveByRelatedIdAndSysIDAndReasonStatement];

		[activities addObject: activity];
	}

	if ([activities count] > 0) {
		result.sqliteCode                       = SQLITE_ROW;
		result.resdbCode                        = RESDB_SQL_ROWS;
		result.resdbCollection          = activities;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByRelatedIdAndSysIDAndReasonStatement);
	sqlite3_clear_bindings(retrieveByRelatedIdAndSysIDAndReasonStatement);

	return result;
}

- (ResdbResult*)retrieveCountByRelatedIdAndReason:(NSString*)relatedID:(NSString*)reason {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountByRelatedIdAndReasonStatement == nil) {
		const char* sql = "SELECT count(*) from Activity where relatedID = ? and reason = ?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByRelatedIdAndReasonStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveCountByRelatedIdAndReasonStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveCountByRelatedIdAndReasonStatement, 2, [reason UTF8String],    -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveCountByRelatedIdAndReasonStatement) == SQLITE_ROW) {
		NSInteger actCount = sqlite3_column_int(retrieveCountByRelatedIdAndReasonStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [ResdbObject new];
		result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",actCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountByRelatedIdAndReasonStatement);
	sqlite3_clear_bindings(retrieveCountByRelatedIdAndReasonStatement);

	return result;
}

- (ResdbResult*)retrieveCount {
	ResdbResult*  result   = [ResdbResult new];
	
	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Activity";
		
		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);
		
		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
		
	if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {
		NSInteger actCount = sqlite3_column_int(retrieveCountStatement,0);
		
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",actCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	sqlite3_reset(retrieveCountStatement);
	sqlite3_clear_bindings(retrieveCountStatement);
	
	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  activities = [NSMutableArray new];
	ResdbResult*     result     = [ResdbResult new];

	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID from Activity";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Activity* activity = [Activity new];

		[self transferActivityData: activity: retrieveAllStatement];

		[activities addObject: activity];
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

- (ResdbResult*)insert:(Activity*)activity {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Activity (objectID,reason,description,type,code,vendorType,value,startTime,endTime,relatedID,sysID,archived,data,originator,location,userCode,userID,locationCode,dayOfWeekOfStudy,hourOfDayOfStudy,numberOfSteps,weekOfStudy,weeklyGoal,instanceID) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(insertStatement,  1, [activity.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  2, [activity.reason UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  3, [activity.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  4, [activity.type UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  5, [activity.code UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  6, [activity.vendorType UTF8String],  -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  7, [activity.value UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  8, [activity.startTime UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  9, [activity.endTime UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 10, [activity.relatedID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 11, [activity.sysID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, 12, activity.archived);
	sqlite3_bind_blob(insertStatement, 13, [activity.data bytes], [activity.data length], SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 14, [activity.originator UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 15, [activity.location UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 16, [activity.userCode UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 17, [activity.userID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 18, [activity.locationCode UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, 19, activity.dayOfWeekOfStudy);
	sqlite3_bind_int(insertStatement, 20, activity.hourOfDayOfStudy);
	sqlite3_bind_int(insertStatement, 21, activity.numberOfSteps);
	sqlite3_bind_int(insertStatement, 22, activity.weekOfStudy);
	sqlite3_bind_int(insertStatement, 23, activity.weeklyGoal);
    sqlite3_bind_text(insertStatement, 24, [activity.instanceID UTF8String], -1, SQLITE_TRANSIENT);
	
	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE) {
		result.resdbCode = RESDB_SQL_ERROR;
	} else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Activity*)activity {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Activity SET objectID = ?, reason = ?, description = ?, type = ?, code = ?, vendorType = ?, value = ?, startTime = ?, endTime = ?, relatedID = ?, sysID=?,archived=?, data = ?,originator = ?,location = ?,userCode=?,userID=?,locationCode=?,dayOfWeekOfStudy=?,hourOfDayOfStudy=?,numberOfSteps=?,weekOfStudy=?,weeklyGoal=?,instanceID=? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(updateStatement,  1, [activity.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  2, [activity.reason UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  3, [activity.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  4, [activity.type UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  5, [activity.code UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  6, [activity.vendorType UTF8String],  -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  7, [activity.value UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  8, [activity.startTime UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  9, [activity.endTime UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 10, [activity.relatedID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 11, [activity.sysID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, 12, activity.archived);
	sqlite3_bind_blob(updateStatement, 13, [activity.data bytes], [activity.data length], SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 14, [activity.originator UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 15, [activity.location UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 16, [activity.userCode UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 17, [activity.userID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 18, [activity.locationCode UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, 19, activity.dayOfWeekOfStudy);
	sqlite3_bind_int(updateStatement, 20, activity.hourOfDayOfStudy);
	sqlite3_bind_int(updateStatement, 21, activity.numberOfSteps);
	sqlite3_bind_int(updateStatement, 22, activity.weekOfStudy);
	sqlite3_bind_int(updateStatement, 23, activity.weeklyGoal);
    sqlite3_bind_text(updateStatement, 24, [activity.instanceID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 25, [activity.objectID UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(updateStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateStatement);
	sqlite3_clear_bindings(updateStatement);

	return result;
}

- (ResdbResult*)updateAllArchived {
	ResdbResult*     result   = [ResdbResult new];
	
	if (updateAllArchivedStatement == nil) {
		const char* sql = "UPDATE Activity SET archived=1";
		
		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateAllArchivedStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;
			
			return result;
		}
	}
		
	result.sqliteCode = sqlite3_step(updateAllArchivedStatement);
	
	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;
	
	sqlite3_reset(updateAllArchivedStatement);
	sqlite3_clear_bindings(updateAllArchivedStatement);
	
	return result;
}

- (ResdbResult*)updateAllUnArchive {
	ResdbResult*     result   = [ResdbResult new];

	if (updateAllUnArchiveStatement == nil) {
		const char* sql = "UPDATE Activity SET archived=0";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateAllUnArchiveStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	result.sqliteCode = sqlite3_step(updateAllUnArchiveStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(updateAllUnArchiveStatement);
	sqlite3_clear_bindings(updateAllUnArchiveStatement);

	return result;
}

- (ResdbResult*)updateList:(NSArray*)activitiesToSend {
	for (Activity* activity in activitiesToSend) {
		[self update:activity];
	}

	ResdbResult* result = [ResdbResult new];

	result.resdbCode = RESDB_SQL_OK;

	return result;
}

- (ResdbResult*)deleteAll {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteAllStatement == nil) {
		const char* sql = "delete from Activity";

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

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteByRelatedIdStatement == nil) {
		const char* sql = "delete from Activity where relatedID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByRelatedIdStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByRelatedIdStatement);
	sqlite3_clear_bindings(deleteByRelatedIdStatement);

	return result;
}

- (ResdbResult*)deleteByLocationCode:(NSString*)locationCode {
	ResdbResult*            result          = [ResdbResult new];

	if (deleteByLocationCodeStatement == nil) {
		const char* sql = "delete from Activity where locationCode = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByLocationCodeStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByLocationCodeStatement, 1, [locationCode UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByLocationCodeStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByLocationCodeStatement);
	sqlite3_clear_bindings(deleteByLocationCodeStatement);

	return result;
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code {
	ResdbResult*                    result   = [ResdbResult new];

	if (deleteByRelatedIdAndCodeStatement == nil) {
		const char* sql = "delete from Activity where relatedID = ? and code = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdAndCodeStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByRelatedIdAndCodeStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(deleteByRelatedIdAndCodeStatement, 2, [code UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByRelatedIdAndCodeStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByRelatedIdAndCodeStatement);
	sqlite3_clear_bindings(deleteByRelatedIdAndCodeStatement);

	return result;
}

- (ResdbResult*)deleteByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason {
	ResdbResult*            result   = [ResdbResult new];

	if (deleteByRelatedIdAndSysIDAndReasonStatement == nil) {
		const char* sql = "delete from Activity where relatedID = ? and sysID = ? and reason = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdAndSysIDAndReasonStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByRelatedIdAndSysIDAndReasonStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(deleteByRelatedIdAndSysIDAndReasonStatement, 2, [sysID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(deleteByRelatedIdAndSysIDAndReasonStatement, 3, [reason UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByRelatedIdAndSysIDAndReasonStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByRelatedIdAndSysIDAndReasonStatement);
	sqlite3_clear_bindings(deleteByRelatedIdAndSysIDAndReasonStatement);

	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteStatement == nil) {
		const char* sql = "delete from Activity where objectID = ?";

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
