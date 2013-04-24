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

#import "PatientDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement      = nil;
static sqlite3_stmt* insertStatement        = nil;
static sqlite3_stmt* retrieveAllStatement   = nil;
static sqlite3_stmt* deleteAllStatement     = nil;
static sqlite3_stmt* updateStatement        = nil;
static sqlite3_stmt* deleteStatement        = nil;
static sqlite3_stmt* deleteByPrimaryClinicCodeStatement = nil;
static sqlite3_stmt* retrieveCountStatement = nil;
static sqlite3_stmt* retrieveByPatientNumStatement = nil;
static sqlite3_stmt* retrieveByPrimaryClinicCodeStatement = nil;
static sqlite3_stmt* retrieveByPatientNumAndPrimaryClinicCodeStatement = nil;


@implementation PatientDAO

- (void)transferPatientData:(Patient*)patient:(sqlite3_stmt*)patientRow {
	char*  textPtr = nil;

	if ((patient == nil) || (patientRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.firstName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.patientNum = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.gender = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.weight = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.height = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.deviceToken = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.dateOfBirth = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.sample = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.visit1 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.visit2 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.visit3 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.visit4 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.visit5 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastVisit1Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastVisit2Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastVisit3Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastVisit4Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastVisit5Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.finalReview = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.lastFinalReviewInteraction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	patient.visit1Status = sqlite3_column_int(patientRow,i++);
	patient.visit2Status = sqlite3_column_int(patientRow,i++);
	patient.visit3Status = sqlite3_column_int(patientRow,i++);
	patient.visit4Status = sqlite3_column_int(patientRow,i++);
	patient.visit5Status = sqlite3_column_int(patientRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.primaryClinic = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
		patient.primaryClinicCode = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
        patient.rewardPoints = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(patientRow,i++)))
        patient.points = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	Patient*			patient  = [Patient new];
	ResdbResult*	result   = [ResdbResult new];

	if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge from Patient where objectID=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

	if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
		[self transferPatientData: patient: retrieveStatement];
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = patient;
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveStatement);

	return result;
}

- (ResdbResult*)retrieveByPatientNum:(NSString*)patientNum {
	NSMutableArray*		patients  = [NSMutableArray arrayWithCapacity:10];
	ResdbResult*		result   = [ResdbResult new];

	if (retrieveByPatientNumStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge from Patient where patientNum=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByPatientNumStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByPatientNumStatement, 1, [patientNum UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByPatientNumStatement) == SQLITE_ROW) {
		Patient* patient = [Patient new];

		[self transferPatientData: patient: retrieveByPatientNumStatement];

		[patients addObject: patient];
	}

	if ([patients count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = [[NSArray alloc] initWithArray: patients];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByPatientNumStatement);

	return result;
}

- (ResdbResult*)retrieveByPrimaryClinicCode:(NSString*)clinicCode {
	NSMutableArray*		patients  = [NSMutableArray arrayWithCapacity:10];
	ResdbResult*		result   = [ResdbResult new];

	if (retrieveByPrimaryClinicCodeStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge from Patient where primaryClinicCode=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByPrimaryClinicCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByPrimaryClinicCodeStatement, 1, [clinicCode UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByPrimaryClinicCodeStatement) == SQLITE_ROW) {
		Patient* patient = [Patient new];

		[self transferPatientData: patient: retrieveByPrimaryClinicCodeStatement];

		[patients addObject: patient];
	}

	if ([patients count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = [[NSArray alloc] initWithArray: patients];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByPrimaryClinicCodeStatement);

	return result;

}

- (ResdbResult*)retrieveByPatientNum:(NSString *)patientNum andPrimaryClinicCode:(NSString*)clinicCode {
	NSMutableArray*		patients  = [NSMutableArray arrayWithCapacity:10];
	ResdbResult*		result    = [ResdbResult new];

	if (retrieveByPatientNumAndPrimaryClinicCodeStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge from Patient where patientNum=? and primaryClinicCode=?";

		result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByPatientNumAndPrimaryClinicCodeStatement, NULL);

		if (result.sqliteCode != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(retrieveByPatientNumAndPrimaryClinicCodeStatement, 1, [patientNum UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(retrieveByPatientNumAndPrimaryClinicCodeStatement, 2, [clinicCode UTF8String], -1, SQLITE_TRANSIENT);

	while (sqlite3_step(retrieveByPatientNumAndPrimaryClinicCodeStatement) == SQLITE_ROW) {
		Patient* patient = [Patient new];

		[self transferPatientData: patient: retrieveByPatientNumAndPrimaryClinicCodeStatement];

		[patients addObject: patient];
	}

	if ([patients count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = [[NSArray alloc] initWithArray: patients];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveByPatientNumAndPrimaryClinicCodeStatement);

	return result;
}

- (ResdbResult*)retrieveAll {
	NSMutableArray*		patients  = [NSMutableArray arrayWithCapacity:10];
	ResdbResult*		result   = [ResdbResult new];

	if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge from Patient";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
		Patient* patient = [Patient new];

		[self transferPatientData: patient: retrieveAllStatement];

		[patients addObject: patient];
	}

	if ([patients count] > 0) {
		result.sqliteCode      = SQLITE_ROW;
		result.resdbCode       = RESDB_SQL_ROWS;
		result.resdbCollection = [[NSArray alloc] initWithArray: patients];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveAllStatement);

	return result;
}

- (ResdbResult*)retrieveCount {
	ResdbResult*     result   = [ResdbResult new];

	if (retrieveCountStatement == nil) {
		const char* sql = "SELECT count(*) from Patient";

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
		result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}

	sqlite3_reset(retrieveCountStatement);

	return result;
}

- (ResdbResult*)insert:(Patient*)patient {
	ResdbResult*     result   = [ResdbResult new];

	if (insertStatement == nil) {
		const char* sql = "INSERT into Patient (objectID,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,rewardBadge) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

    int i = 1;

    sqlite3_bind_text(insertStatement, i++, [patient.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.lastName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.firstName UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.patientNum UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.gender UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.weight UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.height UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.deviceToken UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.dateOfBirth UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.sample UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.visit1 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.visit2 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.visit3 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.visit4 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.visit5 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastVisit1Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastVisit2Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastVisit3Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastVisit4Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastVisit5Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.finalReview UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [[patient.lastFinalReviewInteraction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, i++, patient.visit1Status);
    sqlite3_bind_int(insertStatement, i++, patient.visit2Status);
    sqlite3_bind_int(insertStatement, i++, patient.visit3Status);
    sqlite3_bind_int(insertStatement, i++, patient.visit4Status);
    sqlite3_bind_int(insertStatement, i++, patient.visit5Status);
    sqlite3_bind_text(insertStatement, i++, [patient.primaryClinic UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.primaryClinicCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.rewardPoints UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, i++, [patient.rewardBadge UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(insertStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(insertStatement);

	return result;
}

- (ResdbResult*)update:(Patient*)patient {
	ResdbResult*     result   = [ResdbResult new];

	if (updateStatement == nil) {
		const char* sql = "UPDATE Patient SET objectID = ?,description = ?,lastName = ?,firstName = ?,patientNum = ?,gender = ?,weight = ?,height = ?,deviceToken = ?,dateOfBirth = ?,sample = ?,visit1 = ?,visit2 = ?,visit3 = ?,visit4 = ?,visit5 = ?,lastVisit1Interaction = ?,lastVisit2Interaction = ?,lastVisit3Interaction = ?,lastVisit4Interaction = ?,lastVisit5Interaction = ?,finalReview = ?,lastFinalReviewInteraction = ?,visit1Status = ?,visit2Status = ?,visit3Status = ?,visit4Status = ?,visit5Status = ?,primaryClinic = ?,primaryClinicCode = ?,rewardPoints = ?,rewardBadge = ? WHERE objectID = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

    int i = 1;

    sqlite3_bind_text(updateStatement,  i++, [patient.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.lastName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.firstName UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.patientNum UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.gender UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.weight UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.height UTF8String],      -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  i++, [patient.deviceToken UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.dateOfBirth UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.sample UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.visit1 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.visit2 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.visit3 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.visit4 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.visit5 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastVisit1Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastVisit2Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastVisit3Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastVisit4Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastVisit5Interaction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.finalReview UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [[patient.lastFinalReviewInteraction absoluteString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, i++, patient.visit1Status);
    sqlite3_bind_int(updateStatement, i++, patient.visit2Status);
    sqlite3_bind_int(updateStatement, i++, patient.visit3Status);
    sqlite3_bind_int(updateStatement, i++, patient.visit4Status);
    sqlite3_bind_int(updateStatement, i++, patient.visit5Status);
    sqlite3_bind_text(updateStatement, i++, [patient.primaryClinic UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.primaryClinicCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.rewardPoints UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.rewardBadge UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, i++, [patient.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
		const char* sql = "delete from Patient";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));

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
		const char* sql = "delete from Patient where objectID = ?";

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

- (ResdbResult*)deleteByPrimaryClinicCode:(NSString*)clinicCode {
	ResdbResult*	result          = [ResdbResult new];

	if (deleteByPrimaryClinicCodeStatement == nil) {
		const char* sql = "delete from Patient where primaryClinicCode = ?";

		if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByPrimaryClinicCodeStatement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
			result.resdbCode = RESDB_SQL_ERROR;

			return result;
		}
	}

	sqlite3_bind_text(deleteByPrimaryClinicCodeStatement, 1, [clinicCode UTF8String], -1, SQLITE_TRANSIENT);

	result.sqliteCode = sqlite3_step(deleteByPrimaryClinicCodeStatement);

	if (result.sqliteCode != SQLITE_DONE)
		result.resdbCode = RESDB_SQL_ERROR;
	else
		result.resdbCode = RESDB_SQL_OK;

	sqlite3_reset(deleteByPrimaryClinicCodeStatement);

	return result;
}

@end
