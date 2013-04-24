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

#import "CategoryDAO.h"
#import "WSResourceManager.h"
#import "Category.h"

static sqlite3_stmt* retrieveStatement             = nil;
static sqlite3_stmt* retrieveCategoryNameStatement = nil;
static sqlite3_stmt* insertStatement               = nil;
static sqlite3_stmt* retrieveAllStatement          = nil;
static sqlite3_stmt* deleteAllStatement            = nil;
static sqlite3_stmt* updateStatement               = nil;
static sqlite3_stmt* deleteStatement               = nil;
static sqlite3_stmt* deleteByNameStatement         = nil;
static sqlite3_stmt* retrieveByNameStatement       = nil;
static sqlite3_stmt* retrieveCountStatement        = nil;


@implementation CategoryDAO

- (void)transferCategoryData:(Category*)category:(sqlite3_stmt*)categoryRow {
	char*  textPtr = nil;
	
    if ((category == nil) || (categoryRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(categoryRow,0)))
        category.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(categoryRow,1)))
        category.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(categoryRow,2)))
        category.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(categoryRow,3)))
        category.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(categoryRow,4)))
        category.ontology = [NSString stringWithUTF8String:textPtr];
}

+ (NSString*)getCategoryName:(NSString*)objectID {
    NSString*            categoryName = nil;
    ResdbResult*     result           = [ResdbResult new];


    if (retrieveCategoryNameStatement == nil) {
        const char* sql = "select name from Category where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCategoryNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return nil;
        }
    }

    sqlite3_bind_text(retrieveCategoryNameStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveCategoryNameStatement) == SQLITE_ROW) {
        if ((char*)                                               sqlite3_column_text(retrieveCategoryNameStatement,0))
            categoryName = [NSString stringWithUTF8String: (char*)sqlite3_column_text(retrieveCategoryNameStatement,0)];
    } else {
        categoryName = nil;
    }

    sqlite3_reset(retrieveCategoryNameStatement);

    return categoryName;
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    Category*            category = [Category new];
    ResdbResult*     result       = [ResdbResult new];


    if (retrieveStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology from Category where objectID=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveStatement, 1, [objectID UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveStatement) == SQLITE_ROW) {
        [self transferCategoryData: category: retrieveStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = category;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveStatement);

    return result;
}

- (ResdbResult*)retrieveByName:(NSString*)categoryName {
    Category*            category = [Category new];
    ResdbResult*     result       = [ResdbResult new];


    if (retrieveByNameStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology from Category where name=?";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveByNameStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(retrieveByNameStatement, 1, [categoryName UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(retrieveByNameStatement) == SQLITE_ROW) {
        [self transferCategoryData: category: retrieveByNameStatement];
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = category;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveByNameStatement);

    return result;
}

- (ResdbResult*)retrieveAll {
    NSMutableArray*  categories = [NSMutableArray new];
    ResdbResult*     result     = [ResdbResult new];

    if (retrieveAllStatement == nil) {
        const char* sql = "select objectID,creationTime,description,name,ontology from Category";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveAllStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    while (sqlite3_step(retrieveAllStatement) == SQLITE_ROW) {
        Category* category = [Category new];

        [self transferCategoryData: category: retrieveAllStatement];

        [categories addObject: category];
    }

    if ([categories count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = categories;
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveAllStatement);

    return result;
}

- (ResdbResult*)retrieveCount {
    ResdbResult*     result   = [ResdbResult new];

    if (retrieveCountStatement == nil) {
        const char* sql = "select count(*) from Category";

        result.sqliteCode = sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &retrieveCountStatement, NULL);

        if (result.sqliteCode != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    if (sqlite3_step(retrieveCountStatement) == SQLITE_ROW) {

        NSInteger categoryCount = sqlite3_column_int(retrieveCountStatement,0);

        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = (ResdbObject*)[[NSString alloc] initWithFormat: @"%d",categoryCount];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }

    sqlite3_reset(retrieveCountStatement);

    return result;
}

- (ResdbResult*)insert:(Category*)category {
    ResdbResult*     result   = [ResdbResult new];

    if (insertStatement == nil) {
        const char* sql = "INSERT into Category (objectID,description,name,ontology) values (?,?,?,?)";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &insertStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(insertStatement, 1, [category.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [category.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [category.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [category.ontology UTF8String],    -1, SQLITE_TRANSIENT);

    result.sqliteCode = sqlite3_step(insertStatement);

    if (result.sqliteCode != SQLITE_DONE)
        result.resdbCode = RESDB_SQL_ERROR;
    else
        result.resdbCode = RESDB_SQL_OK;

    sqlite3_reset(insertStatement);

    return result;
}

- (ResdbResult*)update:(Category*)category {
    ResdbResult*     result   = [ResdbResult new];

    if (updateStatement == nil) {
        const char* sql = "UPDATE Category SET objectID = ?, description = ?, name = ?, ontology = ? WHERE objectID = ?";

        if (sqlite3_prepare_v2([[WSResourceManager sharedResourceManager] getConnection], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[WSResourceManager sharedResourceManager] getConnection]));
            result.resdbCode = RESDB_SQL_ERROR;

            return result;
        }
    }

    sqlite3_bind_text(updateStatement, 1, [category.objectID UTF8String],    -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [category.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [category.name UTF8String],        -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [category.ontology UTF8String],    -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(updateStatement, 5, [category.objectID UTF8String],    -1, SQLITE_TRANSIENT);

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
        const char* sql = "delete from Category";

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
        const char* sql = "delete from Category where name = ?";

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
        const char* sql = "delete from Category where objectID = ?";

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
