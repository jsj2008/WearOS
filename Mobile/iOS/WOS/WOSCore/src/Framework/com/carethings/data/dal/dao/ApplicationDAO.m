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
 *  DISCLAIMED. IN NOCount EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ApplicationDAO.h"
#import "WSResourceManager.h"
#import "Application.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation ApplicationDAO

- (id)allocateDaoObject {
    return [Application new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Application* application = (Application*)daoObject;

    if ((application == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.ontology = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.url = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.version = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
        application.image = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,i) length: sqlite3_column_bytes(sqlRow,i)]; i++;
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        application.publisher = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        application.numAnalytic = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.analytic= [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        application.price = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllRecent:(int)numberOfDays {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where (julianday('now') - julianday(creationTime)) < ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:[[NSNumber alloc] initWithInt:numberOfDays], nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByName:(NSString*)applicationName {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where name like ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:applicationName] ? [NSNull null] : applicationName), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByOntology:(NSString*)ontology {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application where ontology=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price from Application order by name";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"select count(*) from Application";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByOntology:(NSString*)ontology {
    NSString *      sql    = @"SELECT count(*) from Application where ontology = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(Application*)application {
    NSString *      sql    = @"INSERT into Application (objectID,description,name,ontology,url,version,image,publisher,numAnalytic,analytic,price) values (?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:application.objectID] ? [NSNull null] : application.objectID),
                                                              ([StringUtils isEmpty:application.description] ? [NSNull null] : application.description),
                                                              ([StringUtils isEmpty:application.name] ? [NSNull null] : application.name),
                                                              ([StringUtils isEmpty:application.ontology] ? [NSNull null] : application.ontology),
                                                              ([StringUtils isEmpty:application.url] ? [NSNull null] : application.url),
                                                              ([StringUtils isEmpty:application.version] ? [NSNull null] : application.version),
                                                              ((application.image == nil) ? [NSNull null] : application.image),
                                                              ([StringUtils isEmpty:application.publisher] ? [NSNull null] : application.publisher),
                                                              ([StringUtils isEmpty:application.numAnalytic] ? [NSNull null] : application.numAnalytic),
                                                              ([StringUtils isEmpty:application.analytic] ? [NSNull null] : application.analytic),
                                                              ([StringUtils isEmpty:application.price] ? [NSNull null] : application.price), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Application*)application {
    NSString *      sql    = @"UPDATE Application SET objectID = ?, description = ?, name = ?, ontology = ?, url = ?, version = ?, image = ?, publisher = ?, numAnalytic = ?, analytic = ?, price = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:application.objectID] ? [NSNull null] : application.objectID),
                                                              ([StringUtils isEmpty:application.description] ? [NSNull null] : application.description),
                                                              ([StringUtils isEmpty:application.name] ? [NSNull null] : application.name),
                                                              ([StringUtils isEmpty:application.ontology] ? [NSNull null] : application.ontology),
                                                              ([StringUtils isEmpty:application.url] ? [NSNull null] : application.url),
                                                              ([StringUtils isEmpty:application.version] ? [NSNull null] : application.version),
                                                              ((application.image != nil) ? [NSNull null] : application.image),
                                                              ([StringUtils isEmpty:application.publisher] ? [NSNull null] : application.publisher),
                                                              ([StringUtils isEmpty:application.numAnalytic] ? [NSNull null] : application.numAnalytic),
                                                              ([StringUtils isEmpty:application.analytic] ? [NSNull null] : application.analytic),
                                                              ([StringUtils isEmpty:application.price] ? [NSNull null] : application.price),
                                                              ([StringUtils isEmpty:application.objectID] ? [NSNull null] : application.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Application";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByName:(NSString*)name {
    NSString *      sql    = @"delete from Application where name = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Application where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByOntology:(NSString*)ontology {
    NSString *      sql    = @"delete from Application where ontology = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ontology] ? [NSNull null] : ontology), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
