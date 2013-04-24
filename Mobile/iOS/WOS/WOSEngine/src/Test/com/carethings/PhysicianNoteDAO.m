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

#import "PhysicianNoteDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* deleteByRelatedIdStatement        = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByRelatedIdStatement      = nil;
static sqlite3_stmt* retrieveCountByRelatedIdStatement = nil;
static sqlite3_stmt* retrieveCountByStatusStatement    = nil;


@implementation PhysicianNoteDAO

- (void)transferPhysicianNoteData:(PhysicianNote*)physicianNote:(sqlite3_stmt*)physicianNoteRow {
	char*  textPtr = nil;
	
    if ((physicianNote == nil) || (physicianNoteRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,0)))
        physicianNote.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,1)))
        physicianNote.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,2)))
        physicianNote.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,3)))
        physicianNote.note = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,4)))
        physicianNote.physician = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,5)))
        physicianNote.relatedID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,6)))
        physicianNote.priority = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,7)))
        physicianNote.status = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,8)))
        physicianNote.toParticipant = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(physicianNoteRow,9)))
        physicianNote.urlOfNote = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    PhysicianNote*   physicianNote = [PhysicianNote new];
    ResdbResult*     result        = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferPhysicianNoteData: physicianNote: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = physicianNote;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSMutableArray*  physicianNotes = [NSMutableArray new];
    ResdbResult*     result         = [ResdbResult new];


    if (retrieveByRelatedIdStatement == nil) {
        const char* sql = "select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote where relatedID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByRelatedIdStatement) == SQLITE_ROW) {
        PhysicianNote* physicianNote = [PhysicianNote new];

        [self transferPhysicianNoteData: physicianNote: retrieveByRelatedIdStatement];

        [physicianNotes addObject: physicianNote];
    }

    if ([physicianNotes count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = physicianNotes;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByRelatedIdStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  physicianNotes = [NSMutableArray new];
    ResdbResult*     result         = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        PhysicianNote* physicianNote = [PhysicianNote new];

        [self transferPhysicianNoteData: physicianNote: retrieveAllStatement];

        [physicianNotes addObject: physicianNote];
    }

    if ([physicianNotes count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = physicianNotes;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCountByStatus:(NSString*)status {
    ResdbResult*     result   = [ResdbResult new];
	
    if (retrieveCountByStatusStatement == nil) {
        const char* sql = "SELECT count(*) from PhysicianNote where status = ?";
		
        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByStatusStatement, NULL);
		
        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;
			
            return result;
        }
    }
	
    sqlite3_bind_text(retrieveCountByStatusStatement, 1, [status UTF8String], -1, SQLITE_TRANSIENT);
	
    if (sqlite3_step(retrieveCountByStatusStatement) == SQLITE_ROW) {
        NSInteger physicianNoteCount = sqlite3_column_int(retrieveCountByStatusStatement,0);
		
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",physicianNoteCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    sqlite3_reset(retrieveCountByStatusStatement);
	
    return result;
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountByRelatedIdStatement == nil) {
        const char* sql = "SELECT count(*) from PhysicianNote where relatedID = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByRelatedIdStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountByRelatedIdStatement) == SQLITE_ROW) {

        NSInteger physicianNoteCount = sqlite3_column_int(retrieveCountByRelatedIdStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",physicianNoteCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountByRelatedIdStatement);

    return result;
}

- (ResdbResult*)insert:(PhysicianNote*)physicianNote {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into PhysicianNote (objectID,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote) values (?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [physicianNote.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [physicianNote.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [physicianNote.note UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [physicianNote.physician UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [physicianNote.relatedID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 6, [physicianNote.priority UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 7, [physicianNote.status UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 8, [physicianNote.toParticipant UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 9, [physicianNote.urlOfNote UTF8String],   -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(PhysicianNote*)physicianNote {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE PhysicianNote SET objectID = ?, description = ?, note = ?, physician = ?, relatedID = ?, priority = ?, status = ?, toParticipant = ?, urlOfNote = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [physicianNote.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [physicianNote.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [physicianNote.note UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [physicianNote.physician UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [physicianNote.relatedID UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 6, [physicianNote.priority UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 7, [physicianNote.status UTF8String],      -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 8, [physicianNote.toParticipant UTF8String],          -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 9, [physicianNote.urlOfNote UTF8String],         -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [physicianNote.objectID UTF8String],   -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from PhysicianNote";

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

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByRelatedIdStatement == nil) {
        const char* sql = "delete from PhysicianNote where relatedID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByRelatedIdStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByRelatedIdStatement, 1, [relatedID UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByRelatedIdStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByRelatedIdStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from PhysicianNote where objectID = ?";

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
