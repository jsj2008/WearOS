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

#import "ObjectDAO.h"
#import "ResdbResult.h"
#import "WSResourceManager.h"
#import "ResdbObject.h"


@implementation ObjectDAO

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
}

- (id)allocateDaoObject {
    return nil;
}

- (void)executeStatement:(NSString*)sql withParams:(NSMutableArray*)params andStatement:(sqlite3_stmt**)sqlStatement {
    ResdbResult* result = [ResdbResult new];

    if (*sqlStatement == nil) {
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], [sql UTF8String], -1, sqlStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return;
        }
    }

    int i = 1;

    for(id param in params) {
        if ([param isKindOfClass:[NSString class]]) {
            sqlite3_bind_text(*sqlStatement, i++, [param UTF8String], -1, SQLITE_TRANSIENT);
        } else if ([param isKindOfClass:[NSNumber class]]) {
            if (strcmp([((NSNumber*)param) objCType], @encode(BOOL)) == 0) {
                sqlite3_bind_int(*sqlStatement, i++, [((NSNumber *)param) intValue]);
            } else if (strcmp([((NSNumber*)param) objCType], @encode(int)) == 0) {
                sqlite3_bind_int(*sqlStatement, i++, [((NSNumber *)param) intValue]);
            } else if (strcmp([((NSNumber*)param) objCType], @encode(double)) == 0) {
				double temp = [((NSNumber *)param) doubleValue];
                sqlite3_bind_double(*sqlStatement, i++, temp);
            } else if (strcmp([((NSNumber*)param) objCType], @encode(float)) == 0) {
                sqlite3_bind_double(*sqlStatement, i++, [((NSNumber *)param) floatValue]);
            } else if (strcmp([((NSNumber*)param) objCType], @encode(int)) == 0) {
                sqlite3_bind_int(*sqlStatement, i++, [((NSNumber *)param) intValue]);
            }
        } else if ([param isKindOfClass:[NSData class]] || [param isKindOfClass:[NSMutableArray class]]) {
            sqlite3_bind_blob(*sqlStatement, i++, [param bytes], [param length], SQLITE_TRANSIENT);
        } else if ([param isKindOfClass:[NSNull class]]) {
            sqlite3_bind_text(*sqlStatement, i++, "", -1, SQLITE_TRANSIENT);
        }
    }
}

- (ResdbResult*)findSingleRow:(NSString*)sql withParams:(NSMutableArray*)params {
    sqlite3_stmt*    sqlStatement = nil;
    id               daoObject   = [self allocateDaoObject];
    ResdbResult*     result      = [[ResdbResult alloc] init];

    [self executeStatement:sql withParams:params andStatement:&sqlStatement];

    if (sqlite3_step(sqlStatement) == SQLITE_ROW) {
        [self transferData:daoObject :sqlStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = daoObject;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(sqlStatement);

    if (params)
        sqlite3_clear_bindings(sqlStatement);

    return result;
}

- (ResdbResult*)findMultiRow:(NSString *)sql withParams:(NSMutableArray*)params {
    NSMutableArray*  daoObjects   = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];
    sqlite3_stmt*    sqlStatement = nil;

    [self executeStatement:sql withParams:params andStatement:&sqlStatement];

    while (sqlite3_step(sqlStatement) == SQLITE_ROW) {
        id daoObject = [self allocateDaoObject];

        [self transferData:daoObject :sqlStatement];

        [daoObjects addObject: daoObject];
    }

    if ([daoObjects count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = daoObjects;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(sqlStatement);

    if (params)
        sqlite3_clear_bindings(sqlStatement);

    return result;
}

- (ResdbResult*)findCount:(NSString*)sql withParams:(NSMutableArray*)params {
    ResdbResult*     result = [ResdbResult new];
    sqlite3_stmt*    sqlStatement = nil;

    [self executeStatement:sql withParams:params andStatement:&sqlStatement];

    if (sqlite3_step(sqlStatement) == SQLITE_ROW) {
        NSInteger actCount = sqlite3_column_int(sqlStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = [ResdbObject new];
        result.resdbObject.description = [[NSString alloc] initWithFormat: @"%d",actCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(sqlStatement);

    if (params)
        sqlite3_clear_bindings(sqlStatement);

    return result;
}

- (ResdbResult*)insertUpdateDeleteRow:(NSString*)sql withParams:(NSMutableArray*)params {
    ResdbResult*     result   = [ResdbResult new];
    sqlite3_stmt*    sqlStatement = nil;

    [self executeStatement:sql withParams:params andStatement:&sqlStatement];

    result.sqliteCode = sqlite3_step(sqlStatement);

    if (result.sqliteCode != SQLITE_DONE) {
        result.resdbCode = RESDB_SQL_ERROR;
        NSAssert1(0, @"Error: failed to insert-update-delete with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
    } else {
        result.resdbCode = RESDB_SQL_OK;
    }

    sqlite3_reset(sqlStatement);

    return result;
}

@end