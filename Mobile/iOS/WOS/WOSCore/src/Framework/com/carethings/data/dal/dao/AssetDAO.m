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

#import "AssetDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation AssetDAO

- (id)allocateDaoObject {
    return [Asset new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char *textPtr = nil;

    Asset* asset = (Asset*)daoObject;

    if ((asset == nil) || (sqlRow == nil))
        return;

    int i = 0;

    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.worldModel = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.assetID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.fileUrl = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.timeLength = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.fileSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.relatedID = [NSString stringWithUTF8String:textPtr];
    //if (sqlite3_column_bytes(sqlRow, i) > 0)
    //    asset.data = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:sqlite3_column_bytes(sqlRow, i)];
    //i++;
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.originator = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.location = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.locationCode = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        asset.patientID = [NSString stringWithUTF8String:textPtr];
    asset.assetType = sqlite3_column_int(sqlRow, i++);
    asset.archived  = (bool) sqlite3_column_int(sqlRow, i++);
    asset.assetArchived = (bool) sqlite3_column_int(sqlRow, i++);
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
            asset.container = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult *)retrieveDataById:(NSString *)objectID {
    NSString *      sql    = @"select data from Asset where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult *)retrieve:(NSString *)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from Asset";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult *)retrieveByRelatedId:(NSString *)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveUnArchived {
    NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where archived=0";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveUnAssetArchived {
    NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where assetArchived=0";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)updateAllArchived {
    NSString *      sql    = @"UPDATE Asset SET archived=1,assetArchived=1";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)updateArchived {
    NSString *      sql    = @"UPDATE Asset SET archived=1";
	
    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)updateAssetArchived {
    NSString *      sql    = @"UPDATE Asset SET assetArchived=1";
	
    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)updateAllUnArchive {
    NSString *      sql    = @"UPDATE Asset SET archived=0,assetArchived=0";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult *)retrieveByPatientId:(NSString *)patientID {
     NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,assetArchived,container from Asset where patientID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientID] ? [NSNull null] : patientID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult *)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,originator,location,locationCode,patientID,assetType,archived,container from Asset";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult *)insert:(Asset *)asset {
    NSString *      sql    = @"INSERT into Asset (objectID,description,worldModel,assetID,fileUrl,timeLength,fileSize,relatedID,data,originator,location,locationCode,patientID,assetType,archived,assetArchived,container) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:asset.objectID] ? [NSNull null] : asset.objectID),
                                                              ([StringUtils isEmpty:asset.description] ? [NSNull null] : asset.description),
                                                              ([StringUtils isEmpty:asset.worldModel] ? [NSNull null] : asset.worldModel),
                                                              ([StringUtils isEmpty:asset.assetID] ? [NSNull null] : asset.assetID),
                                                              ([StringUtils isEmpty:asset.fileUrl] ? [NSNull null] : asset.fileUrl),
                                                              ([StringUtils isEmpty:asset.timeLength] ? [NSNull null] : asset.timeLength),
                                                              ([StringUtils isEmpty:asset.fileSize] ? [NSNull null] : asset.fileSize),
                                                              ([StringUtils isEmpty:asset.relatedID] ? [NSNull null] : asset.relatedID),
                                                              ((asset.data == nil) ? [NSNull null] : asset.data),
                                                              ([StringUtils isEmpty:asset.originator] ? [NSNull null] : asset.originator),
                                                              ([StringUtils isEmpty:asset.location] ? [NSNull null] : asset.location),
                                                              ([StringUtils isEmpty:asset.locationCode] ? [NSNull null] : asset.locationCode),
                                                              ([StringUtils isEmpty:asset.patientID] ? [NSNull null] : asset.patientID),
                                                              [[NSNumber alloc] initWithInt:asset.assetType],
                                                              [[NSNumber alloc] initWithInt:asset.archived],
                                                              [[NSNumber alloc] initWithInt:asset.assetArchived],
                                                              ([StringUtils isEmpty:asset.container] ? [NSNull null] : asset.container), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult *)updateNullPatientId {
    NSString *      sql    = @"UPDATE Asset SET patientID = 'NONE' WHERE patientID isNull";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult *)update:(Asset *)asset {
    NSString *      sql    = @"UPDATE Asset SET objectID = ?, description = ?, worldModel = ?, assetID = ?, fileUrl = ?, timeLength = ?, fileSize = ?, relatedID = ?, data = ?, originator = ?, location = ?, locationCode = ?, patientID = ?, assetType = ?, archived = ?, assetArchived = ?, container = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:asset.objectID] ? [NSNull null] : asset.objectID),
                                                              ([StringUtils isEmpty:asset.description] ? [NSNull null] : asset.description),
                                                              ([StringUtils isEmpty:asset.worldModel] ? [NSNull null] : asset.worldModel),
                                                              ([StringUtils isEmpty:asset.assetID] ? [NSNull null] : asset.assetID),
                                                              ([StringUtils isEmpty:asset.fileUrl] ? [NSNull null] : asset.fileUrl),
                                                              ([StringUtils isEmpty:asset.timeLength] ? [NSNull null] : asset.timeLength),
                                                              ([StringUtils isEmpty:asset.fileSize] ? [NSNull null] : asset.fileSize),
                                                              ([StringUtils isEmpty:asset.relatedID] ? [NSNull null] : asset.relatedID),
                                                              ((asset.data == nil) ? [NSNull null] : asset.data),
                                                              ([StringUtils isEmpty:asset.originator] ? [NSNull null] : asset.originator),
                                                              ([StringUtils isEmpty:asset.location] ? [NSNull null] : asset.location),
                                                              ([StringUtils isEmpty:asset.locationCode] ? [NSNull null] : asset.locationCode),
                                                              ([StringUtils isEmpty:asset.patientID] ? [NSNull null] : asset.patientID),
                                                              [[NSNumber alloc] initWithInt:asset.assetType],
                                                              [[NSNumber alloc] initWithInt:asset.archived],
                                                              [[NSNumber alloc] initWithInt:asset.assetArchived],
                                                              ([StringUtils isEmpty:asset.container] ? [NSNull null] : asset.container),
                                                              ([StringUtils isEmpty:asset.objectID] ? [NSNull null] : asset.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult *)deleteAll {
    NSString *      sql    = @"delete from Asset";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult *)deleteByRelatedId:(NSString *)relatedID {
    NSString *      sql    = @"delete from Asset where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult *)delete:(NSString *)objectID {
    NSString *      sql    = @"delete from Asset where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
