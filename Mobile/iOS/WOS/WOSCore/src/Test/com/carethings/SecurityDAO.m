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

#import "SecurityDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt *retrieveStatement = nil;
static sqlite3_stmt *retrieveCertificateByIdStatement = nil;
static sqlite3_stmt *insertStatement = nil;
static sqlite3_stmt *retrieveAllStatement = nil;
static sqlite3_stmt *deleteAllStatement = nil;
static sqlite3_stmt *updateStatement = nil;
static sqlite3_stmt *deleteStatement = nil;


@implementation SecurityDAO

- (void)transferSecurityData:(Security *)Security:(sqlite3_stmt *)SecurityRow {
    char *textPtr = nil;
	
    if ((Security == nil) || (SecurityRow == nil))
        return;
	
    int i = 0;
	
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.password = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.encryptionKey = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.endPointURL = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(SecurityRow, i++)))
        Security.endPointPort = [NSString stringWithUTF8String:textPtr];
    Security.enforceSecurity  = sqlite3_column_int(SecurityRow, i++);
    Security.encryption = sqlite3_column_int(SecurityRow, i++);
}

- (ResdbResult *)retrieveCertificateById:(NSString *)objectID {
    Security*       security  = [Security new];
    ResdbResult* result = [ResdbResult new];
	
    if (retrieveCertificateByIdStatement == nil) {
        const char *sql = "select securityCertificate from Security where objectID=?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCertificateByIdStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveCertificateByIdStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveCertificateByIdStatement) == SQLITE_ROW) {
		security.securityCertificate = [NSMutableData dataWithBytes:sqlite3_column_blob(retrieveCertificateByIdStatement, 0) length:sqlite3_column_bytes(retrieveCertificateByIdStatement, 0)];
		
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = security;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveCertificateByIdStatement);
	
    return result;
}

- (ResdbResult *)retrieve:(NSString *)objectID {
    Security*    security = [Security new];
    ResdbResult* result = [ResdbResult new];
	
	
    if (retrieveStatement == nil) {
        const char *sql = "select objectID,creationTime,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption from Security where objectID=?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferSecurityData:security :retrieveStatement];
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbObject = security;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveStatement);
	
    return result;
}

- (ResdbResult *)retrieveAll {
    NSMutableArray *securities = [NSMutableArray new];
    ResdbResult *result = [ResdbResult new];
	
    if (retrieveAllStatement == nil) {
        const char *sql = "select objectID,creationTime,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption from Security";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Security *security = [Security new];
		
        [self transferSecurityData:security :retrieveAllStatement];
		
        [securities addObject:security];
    }
	
    if ([securities count] > 0) {
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbCollection = securities;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveAllStatement);
	
    return result;
}

- (ResdbResult *)insert:(Security *)security {
    ResdbResult *result = [ResdbResult new];
	
    if (insertStatement == nil) {
        const char *sql = "INSERT into Security (objectID,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption,securityCertificate) values (?,?,?,?,?,?,?,?,?)";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(insertStatement, 1, [security.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [security.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [security.password UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [security.encryptionKey UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [security.endPointURL UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [security.endPointPort UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement,  7, security.enforceSecurity);
    sqlite3_bind_int(insertStatement,  8, security.encryption);
	sqlite3_bind_blob(insertStatement, 9, [security.securityCertificate bytes], [security.securityCertificate length], SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(insertStatement);
	
    return result;
}

- (ResdbResult *)update:(Security *)Security {
    ResdbResult *result = [ResdbResult new];
	
    if (updateStatement == nil) {
        const char *sql = "UPDATE Security SET objectID = ?,description = ?,password = ?,encryptionKey = ?,endPointURL = ?,endPointPort = ?,enforceSecurity = ?,encryption = ?,securityCertificate = ? WHERE objectID = ?";
		
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(updateStatement, 1,  [Security.objectID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2,  [Security.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3,  [Security.password UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4,  [Security.encryptionKey UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5,  [Security.endPointURL UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6,  [Security.endPointPort UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement,  7,  Security.enforceSecurity);
    sqlite3_bind_int(updateStatement,  8,  Security.encryption);
	sqlite3_bind_blob(updateStatement, 9, [Security.securityCertificate bytes], [Security.securityCertificate length], SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [Security.objectID UTF8String], -1, SQLITE_TRANSIENT);
	
    result.sqliteCode = sqlite3_step(updateStatement);
	
    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;
	
    sqlite3_reset(updateStatement);
	
    return result;
}

- (ResdbResult *)deleteAll {
    ResdbResult *result = [ResdbResult new];
	
    if (deleteAllStatement == nil) {
        const char *sql = "delete from Security";
		
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

- (ResdbResult *)delete:(NSString *)objectID {
    ResdbResult *result = [ResdbResult new];
	
    if (deleteStatement == nil) {
        const char *sql = "delete from Security where objectID = ?";
		
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
