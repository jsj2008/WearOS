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

#import "GeoPointDAO.h"
#import "WSResourceManager.h"
#import "GeoPoint.h"
#import "StringUtils.h"


@implementation GeoPointDAO

- (id)allocateDaoObject {
    return [GeoPoint new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    GeoPoint* geoPoint = (GeoPoint*)daoObject;

    if ((geoPoint == nil) || (sqlRow == nil))
        return;

	int i = 0;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		geoPoint.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geoPoint.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geoPoint.description = [NSString stringWithUTF8String: textPtr];
    geoPoint.latitude  = sqlite3_column_double(sqlRow,i++);
    geoPoint.longitude = sqlite3_column_double(sqlRow,i++);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        geoPoint.relatedID = [NSString stringWithUTF8String: textPtr];
    geoPoint.accuracy = sqlite3_column_double(sqlRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
     NSString *      sql    = @"select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
     NSString *      sql    = @"select objectID,creationTime,description,latitude,longitude,relatedID,accuracy from GeoPoint";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"SELECT count(*) from GeoPoint where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(GeoPoint*)geoPoint {
    NSString *      sql    = @"INSERT into GeoPoint (objectID,description,latitude,longitude,relatedID,accuracy) values (?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:geoPoint.objectID] ? [NSNull null] : geoPoint.objectID),
                                                              ([StringUtils isEmpty:geoPoint.description] ? [NSNull null] : geoPoint.description),
                                                              [[NSNumber alloc] initWithDouble:geoPoint.latitude],
                                                              [[NSNumber alloc] initWithDouble:geoPoint.longitude],
                                                              ([StringUtils isEmpty:geoPoint.relatedID] ? [NSNull null] : geoPoint.relatedID),
                                                              [[NSNumber alloc] initWithDouble:geoPoint.accuracy], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertByArray:(NSArray*)points {
    for (GeoPoint* point in points) {
        [self insert: point];
    }

    return nil;
}

- (ResdbResult*)update:(GeoPoint*)geoPoint {
    NSString *      sql    = @"UPDATE GeoPoint SET objectID = ?,description = ?,latitude = ?,longitude = ?,relatedID = ?,accuracy = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:geoPoint.objectID] ? [NSNull null] : geoPoint.objectID),
                                                              ([StringUtils isEmpty:geoPoint.description] ? [NSNull null] : geoPoint.description),
                                                              [[NSNumber alloc] initWithDouble:geoPoint.latitude],
                                                              [[NSNumber alloc] initWithDouble:geoPoint.longitude],
                                                              ([StringUtils isEmpty:geoPoint.relatedID] ? [NSNull null] : geoPoint.relatedID),
                                                              [[NSNumber alloc] initWithDouble:geoPoint.accuracy],
                                                              ([StringUtils isEmpty:geoPoint.objectID] ? [NSNull null] : geoPoint.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from GeoPoint";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from GeoPoint where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from GeoPoint where objectID = ?";

    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end