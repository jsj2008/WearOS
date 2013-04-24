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

#import "ScheduleEventDAO.h"
#import "WSResourceManager.h"
#import "ScheduleEvent.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;

@implementation ScheduleEventDAO

- (void)transferScheduleEventData:(ScheduleEvent*)scheduleEvent:(sqlite3_stmt*)scheduleEventRow {
	char*  textPtr = nil;

	if ((scheduleEvent == nil) || (scheduleEventRow == nil))
		return;

	if ((textPtr = (char*)sqlite3_column_text(scheduleEventRow,0)))
		scheduleEvent.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(scheduleEventRow,1)))
		scheduleEvent.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(scheduleEventRow,2)))
		scheduleEvent.description = [NSString stringWithUTF8String:textPtr];
	scheduleEvent.dayInWeekOfStudy = sqlite3_column_int(scheduleEventRow,3);
	if ((textPtr = (char*)sqlite3_column_text(scheduleEventRow,4)))
		scheduleEvent.event = [NSString stringWithUTF8String:textPtr];
	scheduleEvent.hourOfDayStudy = sqlite3_column_int(scheduleEventRow,5);
	scheduleEvent.weekOfStudy = sqlite3_column_int(scheduleEventRow,6);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	ScheduleEvent*           scheduleEvent    = [ScheduleEvent new];
	ResdbResult*     result   = [ResdbResult new];


	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy from ScheduleEvent where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferScheduleEventData: scheduleEvent: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = scheduleEvent;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  scheduleEvents   = [NSMutableArray new];
	ResdbResult*     result   = [ResdbResult new];


	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy from ScheduleEvent";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		ScheduleEvent* scheduleEvent = [ScheduleEvent new];

		[self transferScheduleEventData: scheduleEvent: retrieveAllStatement];

		[scheduleEvents addObject: scheduleEvent];
	}

	if ([scheduleEvents count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = scheduleEvents;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)insert:(ScheduleEvent*)scheduleEvent {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into ScheduleEvent (objectID,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy) values (?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(insertStatement, 1, [scheduleEvent.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 2, [scheduleEvent.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, 3, scheduleEvent.dayInWeekOfStudy);
	sqlite3_bind_text(insertStatement, 4, [scheduleEvent.event UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, 5, scheduleEvent.hourOfDayStudy);
	sqlite3_bind_int(insertStatement, 6, scheduleEvent.weekOfStudy);


	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(ScheduleEvent*)scheduleEvent {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE ScheduleEvent SET objectID = ?, description = ?, dayInWeekOfStudy = ?,event = ?,hourOfDayStudy = ?,weekOfStudy = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(updateStatement, 1, [scheduleEvent.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 2, [scheduleEvent.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, 3, scheduleEvent.dayInWeekOfStudy);
	sqlite3_bind_text(updateStatement,  4, [scheduleEvent.event UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, 5, scheduleEvent.hourOfDayStudy);
	sqlite3_bind_int(updateStatement, 6, scheduleEvent.weekOfStudy);
	sqlite3_bind_text(updateStatement, 7, [scheduleEvent.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from ScheduleEvent";

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

	return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
	ResdbResult*     result   = [ResdbResult new];

	if (deleteStatement == nil) {
		const char* sql = "delete from ScheduleEvent where objectID = ?";

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

	return result;
}

@end
