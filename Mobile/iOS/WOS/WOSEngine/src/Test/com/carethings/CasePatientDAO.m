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

#import "CasePatientDAO.h"
#import "CasePatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "ProtocolCaseDAO.h"

static sqlite3_stmt* retrieveAllPatientsOfCaseStatement   = nil;
static sqlite3_stmt* retrieveAllPatientIDsOfCaseStatement = nil;
static sqlite3_stmt* deleteAllPatientsOfCaseStatement     = nil;
static sqlite3_stmt* retrieveCountPatientsOfCaseStatement = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* deleteByPatientIDStatement           = nil;
static sqlite3_stmt* retrieveAllCasesOfPatientStatement = nil;


@implementation CasePatientDAO

- (void)transferCasePatientData:(CasePatient*)casePatient casePatientRow:(sqlite3_stmt*)casePatientRow {
    char*  textPtr = nil;
	
    if ((casePatient == nil) || (casePatientRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(casePatientRow,0)))
        casePatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(casePatientRow,1)))
        casePatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(casePatientRow,2)))
        casePatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(casePatientRow,3)))
        casePatient.caseID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(casePatientRow,4)))
        casePatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfCase:(NSString*)caseObjectID {
	
    NSMutableArray*  patients    = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveAllPatientsOfCaseStatement == nil) {
        const char* sql = "select objectID,creationTime,description,caseID,patientID from CasePatient where caseID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientsOfCaseStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveAllPatientsOfCaseStatement, 1, [caseObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    while (sqlite3_step(retrieveAllPatientsOfCaseStatement) == SQLITE_ROW) {
        CasePatient* casePatient = [CasePatient new];
		
        [self transferCasePatientData: casePatient casePatientRow: retrieveAllPatientsOfCaseStatement];
		
        [patients addObject: casePatient];
    }
	
    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllPatientsOfCaseStatement);
	
    return result;
}

- (ResdbResult*)retrieveAllCasesOfPatient:(NSString*)patientID {
    NSMutableArray*  cases    = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveAllCasesOfPatientStatement == nil) {
        const char* sql = "select objectID,creationTime,description,caseID,patientID from CasePatient where patientID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllCasesOfPatientStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveAllCasesOfPatientStatement, 1, [patientID UTF8String], -1, SQLITE_TRANSIENT);
	
    while (sqlite3_step(retrieveAllCasesOfPatientStatement) == SQLITE_ROW) {
        CasePatient* casePatient = [CasePatient new];
		
        [self transferCasePatientData: casePatient casePatientRow: retrieveAllPatientsOfCaseStatement];
		
		ProtocolCaseDAO* dao = [ProtocolCaseDAO new];

		result = [dao retrieve:casePatient.caseID];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			 [cases addObject: result.resdbObject];
		}
    }
	
    if ([cases count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: cases];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllPatientsOfCaseStatement);
	
    return result;
}

- (ResdbResult*)retrieveAllPatientIDsOfCase:(NSString*)caseObjectID {
    NSMutableArray*  patientIDs  = [NSMutableArray new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveAllPatientIDsOfCaseStatement == nil) {
        const char* sql = "select patientID from CasePatient where caseID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllPatientIDsOfCaseStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveAllPatientIDsOfCaseStatement, 1, [caseObjectID UTF8String], -1, SQLITE_TRANSIENT);
    char*  textPtr = nil;
	
    while (sqlite3_step(retrieveAllPatientIDsOfCaseStatement) == SQLITE_ROW) {
		
        if ((textPtr = (char*)sqlite3_column_text(retrieveAllPatientIDsOfCaseStatement,0)))
            [patientIDs addObject:[NSString stringWithUTF8String: textPtr]];             //free(textPtr);
    }
	
    if ([patientIDs count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patientIDs];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllPatientIDsOfCaseStatement);
	
    return result;
}

- (ResdbResult*)retrieveCountPatientsOfCase:(NSString*)caseObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveCountPatientsOfCaseStatement == nil) {
        const char* sql = "SELECT count(*) from CasePatient where caseID = ?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountPatientsOfCaseStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveCountPatientsOfCaseStatement, 1, [caseObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveCountPatientsOfCaseStatement) == SQLITE_ROW) {
		
        NSInteger ruleCount = sqlite3_column_int(retrieveCountPatientsOfCaseStatement,0);
		
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",ruleCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveCountPatientsOfCaseStatement);
	
    return result;
}

- (ResdbResult*)deleteAllPatientsOfCase:(NSString*)caseObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteAllPatientsOfCaseStatement == nil) {
        const char* sql = "delete from CasePatient where caseID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteAllPatientsOfCaseStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(deleteAllPatientsOfCaseStatement, 1, [caseObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(deleteAllPatientsOfCaseStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(deleteAllPatientsOfCaseStatement);
	
    return result;
}

- (ResdbResult*)insert:(NSString*)caseObjectID patient:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (insertStatement == nil) {
        const char* sql = "INSERT into CasePatient (objectID,description,caseID,patientID) values (?,?,?,?)";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(insertStatement, 1, [[[ResourceIdentityGenerator generateWithPath:@"CasePatient"] fragment] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [@"iRPM Generated Row" UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [caseObjectID UTF8String],                 -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [patientObjectID UTF8String],                 -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(insertStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(insertStatement);
	
    return result;
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs case:(NSString*)caseObjectID {
	
    ResdbResult* result = nil;
	
    for (NSString* patientID in patientIDs) {
        result = [self insert: caseObjectID patient: patientID];
    }
	
    return result;
}

- (ResdbResult*)delete:(NSString*)caseObjectID study:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteStatement == nil) {
        const char* sql = "delete from CasePatient where caseID = ? and patientID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
	sqlite3_bind_text(deleteStatement, 1, [caseObjectID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(deleteStatement, 2, [patientObjectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(deleteStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(deleteStatement);
	
    return result;
}

- (ResdbResult*)delete:(NSString *)caseObjectID patient:(NSString *)patientObjectID {
	return nil;
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {
    ResdbResult*     result   = [ResdbResult new];
	
    if (deleteByPatientIDStatement == nil) {
        const char* sql = "delete from CasePatient where patientID = ?";
		
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
