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
#import "StringUtils.h"

@implementation CategoryDAO

- (id)allocateDaoObject {
    return [Category new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Category* category = (Category*)daoObject;

    if ((category == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        category.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        category.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        category.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        category.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        category.ontology = [NSString stringWithUTF8String:textPtr];
}

- (NSString*)getCategoryName:(NSString*)objectID {
    NSString *      sql    = @"select name from Category where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology from Category where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByName:(NSString*)categoryName {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology from Category where name=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:categoryName] ? [NSNull null] : categoryName), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology from Category";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"select count(*) from Category";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Category*)category {
    NSString *      sql    = @"INSERT into Category (objectID,description,name,ontology) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category.objectID] ? [NSNull null] : category.objectID),
                                                              ([StringUtils isEmpty:category.description] ? [NSNull null] : category.description),
                                                              ([StringUtils isEmpty:category.name] ? [NSNull null] : category.name),
                                                              ([StringUtils isEmpty:category.ontology] ? [NSNull null] : category.ontology), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Category*)category {
    NSString *      sql    = @"UPDATE Category SET objectID = ?, description = ?, name = ?, ontology = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category.objectID] ? [NSNull null] : category.objectID),
                                                              ([StringUtils isEmpty:category.description] ? [NSNull null] : category.description),
                                                              ([StringUtils isEmpty:category.name] ? [NSNull null] : category.name),
                                                              ([StringUtils isEmpty:category.ontology] ? [NSNull null] : category.ontology),
                                                              ([StringUtils isEmpty:category.objectID] ? [NSNull null] : category.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Category";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByName:(NSString*)name {
    NSString *      sql    = @"delete from Category where name = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Category where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
