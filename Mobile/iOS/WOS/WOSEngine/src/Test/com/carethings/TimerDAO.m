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

#import "TimerDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement                 = nil;
static sqlite3_stmt* insertStatement                   = nil;
static sqlite3_stmt* retrieveAllStatement              = nil;
static sqlite3_stmt* deleteAllStatement                = nil;
static sqlite3_stmt* updateStatement                   = nil;
static sqlite3_stmt* deleteStatement                   = nil;
static sqlite3_stmt* retrieveByNameStatement           = nil;
static sqlite3_stmt* retrieveByCategoryStatement       = nil;
static sqlite3_stmt* retrieveActiveByCategoryStatement = nil;
static sqlite3_stmt* deleteByCategoryStatement         = nil;
static sqlite3_stmt* retrieveCountByCategoryStatement  = nil;


@implementation TimerDAO

- (void)transferTimerData:(Timer*)timer:(sqlite3_stmt*)timerRow {
	char*  textPtr = nil;
	
    if ((timer == nil) || (timerRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(timerRow,0)))
        timer.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,1)))
        timer.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,2)))
        timer.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,3)))
        timer.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,4)))
        timer.sound = [NSString stringWithUTF8String:textPtr];
    timer.active = sqlite3_column_int(timerRow,5);
    if ((textPtr = (char*)sqlite3_column_text(timerRow,6)))
        timer.startTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,7)))
        timer.category = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,8)))
        timer.repeat = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(timerRow,9)))
        timer.message = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Timer*           timer    = [Timer new];
    
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferTimerData: timer: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = timer;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSMutableArray*  timers   = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveByCategoryStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where category=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByCategoryStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByCategoryStatement) == SQLITE_ROW) {
        Timer* timer = [Timer new];

        [self transferTimerData: timer: retrieveByCategoryStatement];

        [timers addObject: timer];
    }

    if ([timers count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = timers;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByCategoryStatement);

    return result;
}

- (ResdbResult*)retrieveActiveByCategory:(NSString*)category {
    NSMutableArray*  timers   = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveActiveByCategoryStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where category=? and active=1";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveActiveByCategoryStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveActiveByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveActiveByCategoryStatement) == SQLITE_ROW) {
        Timer* timer = [Timer new];

        [self transferTimerData: timer: retrieveActiveByCategoryStatement];

        [timers addObject: timer];
    }

    if ([timers count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = timers;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveActiveByCategoryStatement);

    return result;
}

- (ResdbResult*)retrieveByTimer:(NSString*)timer {
    NSMutableArray*  timers   = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveByNameStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where lookup=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByNameStatement, 1, [timer UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByNameStatement) == SQLITE_ROW) {
        Timer* timer = [Timer new];

        [self transferTimerData: timer: retrieveByNameStatement];

        [timers addObject: timer];
    }

    if ([timers count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = timers;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByNameStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  timers   = [NSMutableArray new];
    
    ResdbResult*     result   = [ResdbResult new];


    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Timer* timer = [Timer new];

        [self transferTimerData: timer: retrieveAllStatement];

        [timers addObject: timer];
    }

    if ([timers count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = timers;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
    
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountByCategoryStatement == nil) {
        const char* sql = "SELECT count(*) from Timer where category = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByCategoryStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountByCategoryStatement) == SQLITE_ROW) {

        NSInteger timerCount = sqlite3_column_int(retrieveCountByCategoryStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",timerCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountByCategoryStatement);

    return result;
}

- (ResdbResult*)insert:(Timer*)timer {
    
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Timer (objectID,description,name,sound,active,startTime,category,repeat,message) values (?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [timer.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [timer.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [timer.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [timer.sound UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, 5, timer.active);
    sqlite3_bind_text(insertStatement, 6, [timer.startTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 7, [timer.category UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 8, [timer.repeat UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 9, [timer.message UTF8String],   -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Timer*)timer {
    
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Timer SET objectID = ?, description = ?, name = ?, sound = ?, active = ?, startTime = ?, category = ?, repeat = ?, message = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [timer.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [timer.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [timer.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [timer.sound UTF8String],       -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, 5, timer.active);
    sqlite3_bind_text(updateStatement,  6, [timer.startTime UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  7, [timer.category UTF8String],  -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  8, [timer.repeat UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement,  9, [timer.message UTF8String],   -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 10, [timer.objectID UTF8String],  -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from Timer";

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
        const char* sql = "delete from Timer where objectID = ?";

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

- (ResdbResult*)deleteByCategory:(NSString*)category {
    
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByCategoryStatement == nil) {
        const char* sql = "delete from Timer where category = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByCategoryStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByCategoryStatement, 1, [category UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByCategoryStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByCategoryStatement);

    return result;
}

@end
