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

#import "ProviderPatientDAO.h"
#import "ProviderPatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"

static sqlite3_stmt* retrieveAllPatientsOfProviderStatement   = nil;
static sqlite3_stmt* retrieveAllPatientIDsOfProviderStatement = nil;
static sqlite3_stmt* deleteAllPatientsOfProviderStatement     = nil;
static sqlite3_stmt* retrieveCountPatientsOfProviderStatement = nil;
static sqlite3_stmt* insertStatement                         = nil;
static sqlite3_stmt* deleteStatement                         = nil;
static sqlite3_stmt* deleteByPatientIDStatement              = nil;


@implementation ProviderPatientDAO

- (void)transferProviderPatientData:(ProviderPatient*)providerPatient providerPatientRow:(sqlite3_stmt*)providerPatientRow {
    char*  textPtr = nil;
	
    if ((providerPatient == nil) || (providerPatientRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(providerPatientRow,0)))
        providerPatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerPatientRow,1)))
        providerPatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerPatientRow,2)))
        providerPatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerPatientRow,3)))
        providerPatient.providerID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerPatientRow,4)))
        providerPatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfProvider:(NSString*)providerObjectID {
	
    NSMutableArray*  patients = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveAllPatientsOfProviderStatement == nil) {
        const char* sql = "select objectID,creationTime,description,providerID,patientID from ProviderPatient where providerID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientsOfProviderStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveAllPatientsOfProviderStatement, 1, [providerObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    while (sqlite3_step(retrieveAllPatientsOfProviderStatement) == SQLITE_ROW) {
        ProviderPatient* providerPatient = [ProviderPatient new];
		
        [self transferProviderPatientData: providerPatient providerPatientRow: retrieveAllPatientsOfProviderStatement];
		
        [patients addObject: providerPatient];
    }
	
    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllPatientsOfProviderStatement);
	
    return result;
}

- (ResdbResult*)retrieveAllPatientIDsOfProvider:(NSString*)providerObjectID {
    NSMutableArray*  patientIDs = [NSMutableArray new];
    ResdbResult*     result     = [ResdbResult new];
	
    if (retrieveAllPatientIDsOfProviderStatement == nil) {
        const char* sql = "select patientID from ProviderPatient where providerID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientIDsOfProviderStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveAllPatientIDsOfProviderStatement, 1, [providerObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;
	
    while (sqlite3_step(retrieveAllPatientIDsOfProviderStatement) == SQLITE_ROW) {
		
        if ((textPtr = (char*)sqlite3_column_text(retrieveAllPatientIDsOfProviderStatement,0)))
            [patientIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }
	
    if ([patientIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patientIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllPatientIDsOfProviderStatement);
	
    return result;
}

- (ResdbResult*)retrieveCountPatientsOfProvider:(NSString*)providerObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveCountPatientsOfProviderStatement == nil) {
        const char* sql = "SELECT count(*) from ProviderPatient where providerID = ?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountPatientsOfProviderStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveCountPatientsOfProviderStatement, 1, [providerObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveCountPatientsOfProviderStatement) == SQLITE_ROW) {
		
        NSInteger ruleCount = sqlite3_column_int(retrieveCountPatientsOfProviderStatement,0);
		
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveCountPatientsOfProviderStatement);
	
    return result;
}


- (ResdbResult*)deleteAllPatientsOfProvider:(NSString*)providerObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteAllPatientsOfProviderStatement == nil) {
        const char* sql = "delete from ProviderPatient where providerID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllPatientsOfProviderStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(deleteAllPatientsOfProviderStatement, 1, [providerObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(deleteAllPatientsOfProviderStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(deleteAllPatientsOfProviderStatement);
	
    return result;
}

- (ResdbResult*)insert:(NSString*)providerObjectID patient:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (insertStatement == nil) {
        const char* sql = "INSERT into ProviderPatient (objectID,description,providerID,patientID) values (?,?,?,?)";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"ProviderPatient"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [providerObjectID UTF8String],              -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [patientObjectID UTF8String],              -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(insertStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(insertStatement);
	
    return result;
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs provider:(NSString*)providerObjectID {
    for (NSString* patientID in patientIDs) {
        [self insert: providerObjectID patient: patientID];
    }
	
    return nil;
}

- (ResdbResult*)delete:(NSString*)providerObjectID patient:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteStatement == nil) {
        const char* sql = "delete from ProviderPatient where providerID = ? and patientID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(deleteStatement, 1, [providerObjectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteStatement, 2, [patientObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(deleteStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(deleteStatement);
	
    return result;
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteByPatientIDStatement == nil) {
        const char* sql = "delete from ProviderPatient where patientID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByPatientIDStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(deleteByPatientIDStatement, 1, [patientObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(deleteByPatientIDStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(deleteByPatientIDStatement);
	
    return result;
}

@end
