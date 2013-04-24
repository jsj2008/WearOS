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

#import "DBSchemaVersionDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt *retrieveStatement = nil;
static sqlite3_stmt *updateStatement = nil;


@implementation DBSchemaVersionDAO

- (void)transferDBSchemaVersionData:(DBSchemaVersion *)dbSchemaVersion:(sqlite3_stmt *)schemaVersionRow {
    char *textPtr = nil;

    if ((dbSchemaVersion == nil) || (schemaVersionRow == nil))
        return;

    if ((textPtr = (char *) sqlite3_column_text(schemaVersionRow, 0)))
        dbSchemaVersion.schemaVersion = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult *)retrieve {
    DBSchemaVersion*    dbSchemaVersion = [DBSchemaVersion new];
    ResdbResult*        result = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char *sql = "PRAGMA user_version";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferDBSchemaVersionData:dbSchemaVersion :retrieveStatement];
        result.sqliteCode = SQLITE_ROW;
        result.resdbCode = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)dbSchemaVersion;
    } else {
        result.resdbCode = RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult *)insert:(DBSchemaVersion *)asset {
    return nil;
}

- (ResdbResult *)update:(NSString *)schemaVersion {
    ResdbResult*    result = [ResdbResult new];
    NSString*       versionStr = [[NSString alloc] initWithFormat:@"PRAGMA user_version = %@", schemaVersion];

    if (updateStatement == nil) {
        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], [versionStr UTF8String], -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [schemaVersion UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(updateStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(updateStatement);

    return result;
}

@end