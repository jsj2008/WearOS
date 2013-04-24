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

#import "StudyDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement          = nil;
static sqlite3_stmt* insertStatement            = nil;
static sqlite3_stmt* retrieveAllStatement       = nil;
static sqlite3_stmt* deleteAllStatement         = nil;
static sqlite3_stmt* deleteByStudyIdStatement   = nil;
static sqlite3_stmt* updateStatement            = nil;
static sqlite3_stmt* deleteStatement            = nil;
static sqlite3_stmt* retrieveByStudyIdStatement = nil;
static sqlite3_stmt* retrieveCountStatement     = nil;


@implementation StudyDAO

- (void)transferStudyData:(Study*)study:(sqlite3_stmt*)studyRow {
	char*  textPtr = nil;

	if ((study == nil) || (studyRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.organizationID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyID = [[NSURL alloc] initWithString:[NSString stringWithUTF8String: textPtr]];
	study.calibrated = sqlite3_column_int(studyRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.investigator = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.referredBy = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyType = [NSString stringWithUTF8String: textPtr];
	study.lamportDayClock = sqlite3_column_int(studyRow,i++);
	study.lamportHourClock = sqlite3_column_int(studyRow,i++);
	study.lamportWeekClock = sqlite3_column_int(studyRow,i++);
	study.msStartDate = sqlite3_column_double(studyRow,i++);
	study.useLogicalClock = sqlite3_column_int(studyRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.appVersion = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.clinicalPathwayAuthor = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.clinicalPathwayVersion = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.startDate = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyDuration = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailFrom = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailLogin = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailPass = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailPort = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailSMTP = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailSubject = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyEmailTo = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studyPrimaryResearcher = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.studySecondaryResearcher = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.var1 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.var2 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(studyRow,i++)))
		study.var3 = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Study*           study    = [Study new];

	ResdbResult*     result   = [ResdbResult new];

	if (retrieveStatement == nil) {
		const char* sql = "select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3 from Study where objectID=?";

		result.sqliteCode = sqlite3_prepare([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferStudyData: study: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = study;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByStudyId:(NSString*)studyID {
	Study*           study    = [Study new];

	ResdbResult*     result   = [ResdbResult new];

	if (retrieveByStudyIdStatement == nil) {
		const char* sql = "select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3 from Study where studyID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByStudyIdStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByStudyIdStatement, 1, [studyID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveByStudyIdStatement) == SQLITE_ROW) {
		[self transferStudyData: study: retrieveByStudyIdStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = study;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByStudyIdStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*  studies  = [NSMutableArray new];

	ResdbResult*     result   = [ResdbResult new];

	if (retrieveAllStatement == nil) {
		const char* sql = "select objectID,creationTime,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3 from Study";

		if (sqlite3_prepare([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Study* study = [Study new];

		[self transferStudyData: study: retrieveAllStatement];

		[studies addObject: study];
	}

	if ([studies count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = [[NSArray alloc] initWithArray: studies];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)retrieveCount {

	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Study";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

		NSInteger ruleCount = sqlite3_column_int(retrieveCountStatement,0);

		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [ResdbObject new];
		result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",ruleCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountStatement);

	return result;
}

- (ResdbResult*)insert:(Study*)study {

	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Study (objectID,description,organizationID,studyID,calibrated,investigator,referredBy,studyType,lamportDayClock,lamportHourClock,lamportWeekClock,msStartDate,useLogicalClock,appVersion,clinicalPathwayAuthor,clinicalPathwayVersion,startDate,studyDuration,studyEmailFrom,studyEmailLogin,studyEmailPass,studyEmailPort,studyEmailSMTP,studyEmailSubject,studyEmailTo,studyName,studyPrimaryResearcher,studySecondaryResearcher,var1,var2,var3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	int columnCnt = 1;

	sqlite3_bind_text(insertStatement, columnCnt++, [study.objectID UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.description UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.organizationID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [[study.studyID absoluteString] UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, columnCnt++, study.calibrated);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.investigator UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.referredBy UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyType UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertStatement, columnCnt++, study.lamportDayClock);
	sqlite3_bind_int(insertStatement, columnCnt++, study.lamportHourClock);
	sqlite3_bind_int(insertStatement, columnCnt++, study.lamportWeekClock);
	sqlite3_bind_double(insertStatement, columnCnt++, study.msStartDate);
	sqlite3_bind_int(insertStatement, columnCnt++, study.useLogicalClock);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.appVersion UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.clinicalPathwayAuthor UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.clinicalPathwayVersion UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.startDate UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyDuration UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailFrom UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailLogin UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailPass UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailPort UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailSMTP UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailSubject UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyEmailTo UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyName UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studyPrimaryResearcher UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.studySecondaryResearcher UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.var1 UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.var2 UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, columnCnt++, [study.var3 UTF8String],    -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Study*)study {

	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Study SET objectID = ?,description = ?,organizationID = ?,studyID = ?,calibrated = ?,investigator = ?,referredBy = ?,studyType = ?,lamportDayClock = ?,lamportHourClock = ?,lamportWeekClock = ?,msStartDate = ?,useLogicalClock = ?,appVersion = ?,clinicalPathwayAuthor = ?,clinicalPathwayVersion = ?,startDate = ?,studyDuration = ?,studyEmailFrom = ?,studyEmailLogin = ?,studyEmailPass = ?,studyEmailPort = ?,studyEmailSMTP = ?,studyEmailSubject = ?,studyEmailTo = ?,studyName = ?,studyPrimaryResearcher = ?,studySecondaryResearcher = ?,var1 = ?,var2 = ?,var3 = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	int columnCnt = 1;

	sqlite3_bind_text(updateStatement, columnCnt++, [study.objectID UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.description UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.organizationID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [[study.studyID absoluteString] UTF8String],        -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, columnCnt++, study.calibrated);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.investigator UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.referredBy UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyType UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStatement, columnCnt++, study.lamportDayClock);
	sqlite3_bind_int(updateStatement, columnCnt++, study.lamportHourClock);
	sqlite3_bind_int(updateStatement, columnCnt++, study.lamportWeekClock);
	sqlite3_bind_double(updateStatement, columnCnt++, study.msStartDate);
	sqlite3_bind_int(updateStatement, columnCnt++, study.useLogicalClock);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.appVersion UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.clinicalPathwayAuthor UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.clinicalPathwayVersion UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.startDate UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyDuration UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailFrom UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailLogin UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailPass UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailPort UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailSMTP UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailSubject UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyEmailTo UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyName UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studyPrimaryResearcher UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.studySecondaryResearcher UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.var1 UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.var2 UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.var3 UTF8String],     -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, columnCnt++, [study.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from Study";

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
		const char* sql = "delete from Study where objectID = ?";

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

- (ResdbResult*)deleteByStudyId:(NSString*)studyID {

	ResdbResult*     result   = [ResdbResult new];

	if (deleteByStudyIdStatement == nil) {
		const char* sql = "delete from Study where studyID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByStudyIdStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByStudyIdStatement, 1, [studyID UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByStudyIdStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByStudyIdStatement);

	return result;
}

@end
