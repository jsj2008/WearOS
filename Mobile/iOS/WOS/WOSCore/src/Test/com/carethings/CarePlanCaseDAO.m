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

#import "CarePlanCaseDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "CasePatient.h"
#import "CasePatientDAO.h"
#import "PatientDAO.h"

static sqlite3_stmt* retrieveStatement       = nil;
static sqlite3_stmt* insertStatement         = nil;
static sqlite3_stmt* retrieveAllStatement    = nil;
static sqlite3_stmt* deleteAllStatement      = nil;
static sqlite3_stmt* updateStatement         = nil;
static sqlite3_stmt* deleteStatement         = nil;
static sqlite3_stmt* retrieveCountStatement  = nil;


@implementation CarePlanCaseDAO

- (void)transferCaseData:(CarePlanCase*)caseObj:(sqlite3_stmt*)caseRow {
    char*  textPtr = nil;
	
    if ((caseObj == nil) || (caseRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(caseRow,0)))
        caseObj.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(caseRow,1)))
        caseObj.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(caseRow,2)))
        caseObj.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(caseRow,3)))
        caseObj.lastInteractionSysID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(caseRow,4)))
        caseObj.carePlanID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    CarePlanCase*            caseObj     = [CarePlanCase new];
    ResdbResult*     result   = [ResdbResult new];
	
	
    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastInteractionSysID,carePlanID from Case where objectID=?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferCaseData: caseObj: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = caseObj;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveStatement);
	
    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  studies  = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,lastInteractionSysID,carePlanID from Case";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        CarePlanCase* caseObj = [CarePlanCase new];
		
        [self transferCaseData: caseObj: retrieveAllStatement];
		
        [studies addObject: caseObj];
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
        const char* sql = "SELECT count(*) from Case";
		
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

- (ResdbResult*)insert:(CarePlanCase*)caseObj {
    ResdbResult*     result   = [ResdbResult new];
	
    if (insertStatement == nil) {
        const char* sql = "INSERT into Case (objectID,description,lastInteractionSysID,carePlanID) values (?,?,?,?)";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(insertStatement, 1, [caseObj.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [caseObj.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [caseObj.lastInteractionSysID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [caseObj.carePlanID UTF8String],   -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(insertStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(insertStatement);
	
    return result;
}

- (ResdbResult*)update:(CarePlanCase*)caseObj {
    ResdbResult*     result   = [ResdbResult new];
	
    if (updateStatement == nil) {
        const char* sql = "UPDATE Case SET objectID = ?,description = ?,lastInteractionSysID = ?,carePlanID = ? WHERE objectID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(updateStatement,  1, [caseObj.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  2, [caseObj.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  3, [caseObj.lastInteractionSysID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  4, [caseObj.carePlanID UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [caseObj.objectID UTF8String],    -1, SQLITE_TRANSIENT);
	
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
        const char* sql = "delete from Case";
		
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
        const char* sql = "delete from Case where objectID = ?";
		
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

- (ResdbResult*)retrievePatients:(NSString*)caseObjectID {
    CasePatientDAO*     dao    = [CasePatientDAO new];
    NSMutableArray*     patients  = [NSMutableArray new];
    ResdbResult*        result = nil;
	
    result = [dao retrieveAllPatientsOfCase: caseObjectID];
	
    if (result.resdbCode == RESDB_SQL_ROWS) {
		
        for (CasePatient*   casePatient in result.resdbCollection) {
            PatientDAO*     patientDAO    = [PatientDAO new];
            ResdbResult* patientResult = nil;
			
            patientResult = [patientDAO retrieve:[casePatient patientID]];
			
            if (patientResult.resdbCode == RESDB_SQL_ROWS)
                [patients addObject:[patientResult resdbObject]];
        }
    }
	
    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    return result;
}

- (ResdbResult*)retrievePatient:(NSString*)caseObjectID {
	
    CarePlanCaseDAO*                        dao = [CarePlanCaseDAO new];
    ResdbResult*            tempResult  = nil;
    ResdbResult*        result          = [ResdbResult new];
	
    tempResult = [dao retrievePatients: caseObjectID];
	
    if (tempResult.resdbCode == RESDB_SQL_ROWS) {
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    return result;
}

- (ResdbResult*)addPatient:(NSString*)patientObjectID case:(NSString*)caseObjectID {
	
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao insert: caseObjectID patient: patientObjectID];
}

- (ResdbResult*)removePatient:(NSString*)patientObjectID case:(NSString*)caseObjectID {
	
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao delete: caseObjectID patient: patientObjectID];
}

- (ResdbResult*)removeAllPatients:(NSString*)caseObjectID {
	
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao deleteAllPatientsOfCase: caseObjectID];
}

@end
