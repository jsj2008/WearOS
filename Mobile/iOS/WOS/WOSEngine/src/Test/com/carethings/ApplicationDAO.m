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

#import "ApplicationDAO.h"
#import "WSResourceManager.h"
#import "Application.h"
#import "ResdbResult.h"

static sqlite3_stmt* retrieveStatement                = nil;
static sqlite3_stmt* insertStatement                  = nil;
static sqlite3_stmt* retrieveAllStatement             = nil;
static sqlite3_stmt* deleteAllStatement               = nil;
static sqlite3_stmt* updateStatement                  = nil;
static sqlite3_stmt* deleteStatement                  = nil;
static sqlite3_stmt* deleteByNameStatement            = nil;
static sqlite3_stmt* retrieveByNameStatement          = nil;
static sqlite3_stmt* retrieveCountStatement           = nil;
static sqlite3_stmt* retrieveByOntologyStatement      = nil;
static sqlite3_stmt* deleteByOntologyStatement        = nil;
static sqlite3_stmt* retrieveCountByOntologyStatement = nil;
static sqlite3_stmt* retrieveAllRecentStatement       = nil;

@implementation ApplicationDAO

- (void)transferApplicationData:(Application*)application:(sqlite3_stmt*)applicationRow {
	char*  textPtr = nil;
	
    if ((application == nil) || (applicationRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.url = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.version = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(applicationRow,i) > 0)
        application.image = [NSMutableData dataWithBytes: sqlite3_column_blob(applicationRow,i) length: sqlite3_column_bytes(applicationRow,i)]; i++;
    if ((textPtr = (char*)sqlite3_column_text(applicationRow, i++)))
        application.publisher = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow, i++)))
        application.numAnalytic = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.analytic= [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(applicationRow,i++)))
        application.price = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Application*     application = [Application new];
    ResdbResult*     result      = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferApplicationData: application: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = application;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveAllRecent:(int)numberOfDays {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];


    if (retrieveAllRecentStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where (julianday('now') - julianday(creationTime)) < ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllRecentStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveAllRecentStatement, 1, [[NSString stringWithFormat: @"%d",numberOfDays] UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveAllRecentStatement) == SQLITE_ROW) {
        Application* application = [Application new];

        [self transferApplicationData: application: retrieveAllRecentStatement];

        [applications addObject: application];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = applications;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllRecentStatement);

    return result;
}

- (ResdbResult*)retrieveByName:(NSString*)applicationName {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];


    if (retrieveByNameStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where name like ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByNameStatement, 1, [applicationName UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByNameStatement) == SQLITE_ROW) {
        Application* application = [Application new];

        [self transferApplicationData: application: retrieveByNameStatement];

        [applications addObject: application];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = applications;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByNameStatement);

    return result;
}

- (ResdbResult*)retrieveByOntology:(NSString*)ontology {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];

    if (retrieveByOntologyStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where ontology=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByOntologyStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByOntologyStatement, 1, [ontology UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(retrieveByOntologyStatement) == SQLITE_ROW) {
        Application* application = [Application new];

        [self transferApplicationData: application: retrieveByOntologyStatement];

        [applications addObject: application];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = applications;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByOntologyStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  applications = [NSMutableArray new];
    ResdbResult*     result       = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application order by name";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Application* application = [Application new];

        [self transferApplicationData: application: retrieveAllStatement];

        [applications addObject: application];
    }

    if ([applications count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = applications;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCount {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStatement == nil) {
        const char* sql = "select count(*) from Application";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

        NSInteger applicationCount = sqlite3_column_int(retrieveCountStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",applicationCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountStatement);

    return result;
}

- (ResdbResult*)retrieveCountByOntology:(NSString*)ontology {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountByOntologyStatement == nil) {
        const char* sql = "SELECT count(*) from Application where ontology = ?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountByOntologyStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveCountByOntologyStatement, 1, [ontology UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCountByOntologyStatement) == SQLITE_ROW) {

        NSInteger applicationCount = sqlite3_column_int(retrieveCountByOntologyStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",applicationCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountByOntologyStatement);

    return result;
}

- (ResdbResult*)insert:(Application*)application {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Application (objectID,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price) values (?,?,?,?,?,?,?,?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [application.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [application.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [application.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [application.ontology UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [application.url UTF8String],         -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [application.version UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, 7, [application.image bytes], [application.image length], SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  8, [application.publisher UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement,  9, [application.numAnalytic UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 10, [application.analytic UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertStatement, 11, [application.price UTF8String],       -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Application*)application {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Application SET objectID = ?, description = ?, name = ?, ontology = ?, url = ?, version = ?, image = ?, publisher = ?, numAnalytic = ?, analytic = ?, price = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [application.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [application.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [application.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [application.ontology UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [application.url UTF8String],         -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [application.version UTF8String],     -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(updateStatement, 7, [application.image bytes], [application.image length], SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  8, [application.publisher UTF8String],   -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement,  9, [application.numAnalytic UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 10, [application.analytic UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 11, [application.price UTF8String],       -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 12, [application.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from Application";

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

- (ResdbResult*)deleteByName:(NSString*)name {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByNameStatement == nil) {
        const char* sql = "delete from Application where name = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByNameStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByNameStatement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByNameStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByNameStatement);

    return result;
}

- (ResdbResult*)delete:(NSString*)objectID {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteStatement == nil) {
        const char* sql = "delete from Application where objectID = ?";

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

- (ResdbResult*)deleteByOntology:(NSString*)ontology {
    ResdbResult*     result   = [ResdbResult new];

    if (deleteByOntologyStatement == nil) {
        const char* sql = "delete from Application where ontology = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &deleteByOntologyStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(deleteByOntologyStatement, 1, [ontology UTF8String], -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(deleteByOntologyStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(deleteByOntologyStatement);

    return result;
}

@end
