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

#import "ProviderDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ProviderPatientDAO.h"
#import "ProviderPatient.h"
#import "PatientDAO.h"

static sqlite3_stmt* retrieveStatement      = nil;
static sqlite3_stmt* insertStatement        = nil;
static sqlite3_stmt* retrieveAllStatement   = nil;
static sqlite3_stmt* deleteAllStatement     = nil;
static sqlite3_stmt* updateStatement        = nil;
static sqlite3_stmt* deleteStatement        = nil;
static sqlite3_stmt* retrieveCountStatement = nil;


@implementation ProviderDAO

- (void)transferProviderData:(Provider*)provider:(sqlite3_stmt*)providerRow {
    char*  textPtr = nil;
	
    if ((provider == nil) || (providerRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(providerRow,0)))
        provider.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,1)))
        provider.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,2)))
        provider.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,3)))
        provider.clinicName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,4)))
        provider.address = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,5)))
        provider.city = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(providerRow,6)))
        provider.state = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Provider*         provider  = [Provider new];
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,clinicName,address,city,state from Provider where objectID=?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferProviderData: provider: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = provider;
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
        const char* sql = "select objectID,creationTime,description,clinicName,address,city,state from Provider";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Provider* provider = [Provider new];
		
        [self transferProviderData: provider: retrieveAllStatement];
		
        [studies addObject: provider];
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
        const char* sql = "SELECT count(*) from Provider";
		
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

- (ResdbResult*)insert:(Provider*)provider {
    ResdbResult*     result   = [ResdbResult new];
	
    if (insertStatement == nil) {
        const char* sql = "INSERT into Provider (objectID,description,clinicName,address,city,state) values (?,?,?,?,?,?)";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(insertStatement, 1, [provider.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [provider.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [provider.clinicName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [provider.address UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [provider.city UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [provider.state UTF8String],      -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(insertStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(insertStatement);
	
    return result;
}

- (ResdbResult*)update:(Provider*)provider {
    ResdbResult*     result   = [ResdbResult new];
	
    if (updateStatement == nil) {
        const char* sql = "UPDATE Provider SET objectID = ?,description = ?,clinicName = ?,address = ?,city = ?,state = ? WHERE objectID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(updateStatement,  1, [provider.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  2, [provider.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  3, [provider.clinicName UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  4, [provider.address UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  5, [provider.city UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  6, [provider.state UTF8String],      -1, SQLITE_TRANSIENT);
	
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
        const char* sql = "delete from Provider";
		
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
        const char* sql = "delete from Provider where objectID = ?";
		
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

- (ResdbResult*)retrievePatients:(NSString*)providerObjectID {
	ProviderPatientDAO*	dao      = [ProviderPatientDAO new];
	NSMutableArray*		patients = [NSMutableArray new];
	ResdbResult*		result   = nil;
	
	result = [dao retrieveAllPatientsOfProvider: providerObjectID];
	
	if (result.resdbCode == RESDB_SQL_ROWS) {
		for (ProviderPatient* providerPatient in result.resdbCollection) {
			PatientDAO*  patientDAO    = [PatientDAO new];
			ResdbResult* patientResult = nil;
			
			patientResult = [patientDAO retrieve:[providerPatient patientID]];
			
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

- (ResdbResult*)retrievePatient:(NSString*)sessionObjectID {
	ProviderDAO*	dao			= [ProviderDAO new];
	ResdbResult*	tempResult	= nil;
	ResdbResult*	result		= [ResdbResult new];
	
	tempResult = [dao retrievePatients: sessionObjectID];
	
	if (tempResult.resdbCode == RESDB_SQL_ROWS) {
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	return result;
}

- (ResdbResult*)addPatient:(NSString*)patientObjectID session:(NSString*)providerObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];
	return [dao insert: providerObjectID patient: patientObjectID];
}

- (ResdbResult*)removePatient:(NSString*)patientObjectID session:(NSString*)providerObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];
	return [dao delete: providerObjectID patient: patientObjectID];
}

- (ResdbResult*)removeAllPatients:(NSString*)sessionObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];
	return [dao deleteAllPatientsOfProvider: sessionObjectID];
}

@end