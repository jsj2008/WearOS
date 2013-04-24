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

#import "GeozoneDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "Geozone.h"
#import "GeoPointDAO.h"
#import "StringUtils.h"


@implementation GeozoneDAO

- (id)allocateDaoObject {
    return [Geozone new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    Geozone* geozone = (Geozone*)daoObject;

    if ((geozone == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.name = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.relatedID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geozone.alertDistance = [NSString stringWithUTF8String: textPtr];
    geozone.active =     sqlite3_column_int(sqlRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrievePoints:(NSString*)objectID {
    GeoPointDAO* dao = [GeoPointDAO new];

    return [dao retrieveByRelatedId: objectID];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
     NSString *      sql    = @"select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveActiveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone where relatedID=? and active=1";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,name,relatedID,alertDistance,active from Geozone";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"SELECT count(*) from Geozone where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(Geozone*)geozone {
    NSString *      sql    = @"INSERT into Geozone (objectID,description,name,relatedID,alertDistance,active) values (?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:geozone.objectID] ? [NSNull null] : geozone.objectID),
                                                              ([StringUtils isEmpty:geozone.description] ? [NSNull null] : geozone.description),
                                                              ([StringUtils isEmpty:geozone.name] ? [NSNull null] : geozone.name),
                                                              ([StringUtils isEmpty:geozone.relatedID] ? [NSNull null] : geozone.relatedID),
                                                              ([StringUtils isEmpty:geozone.alertDistance] ? [NSNull null] : geozone.alertDistance),
                                                              [[NSNumber alloc] initWithInt:geozone.active], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Geozone*)geozone {
     NSString *      sql    = @"UPDATE Geozone SET objectID = ?,description = ?,name = ?,relatedID = ?,alertDistance = ?,active = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:geozone.objectID] ? [NSNull null] : geozone.objectID),
                                                              ([StringUtils isEmpty:geozone.description] ? [NSNull null] : geozone.description),
                                                              ([StringUtils isEmpty:geozone.name] ? [NSNull null] : geozone.name),
                                                              ([StringUtils isEmpty:geozone.relatedID] ? [NSNull null] : geozone.relatedID),
                                                              ([StringUtils isEmpty:geozone.alertDistance] ? [NSNull null] : geozone.alertDistance),
                                                              [[NSNumber alloc] initWithInt:geozone.active],
                                                              ([StringUtils isEmpty:geozone.objectID] ? [NSNull null] : geozone.alertDistance), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Geozone";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from Geozone where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Geozone where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
