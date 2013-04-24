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

#import "RingtoneDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation RingtoneDAO

- (id)allocateDaoObject {
    return [Ringtone new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Ringtone* ringtone = (Ringtone*)daoObject;

    if ((ringtone == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        ringtone.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        ringtone.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        ringtone.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        ringtone.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        ringtone.fileUrl = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        ringtone.timeLength = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        ringtone.fileSize = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,7) > 0)
        ringtone.soundData = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,8) length: sqlite3_column_bytes(sqlRow,7)];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
     NSString *      sql    = @"select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (NSString*)retrieveName:(NSString*)objectID {
    NSString *      sql    = @"select name from Ringtone where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];

}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
   NSString *      sql    = @"select objectID,creationTime,description,name,fileUrl,timeLength,fileSize,soundData from Ringtone";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(Ringtone*)ringtone {
    NSString *      sql    = @"INSERT into Ringtone (objectID,description,name,fileUrl,timeLength,fileSize,soundData) values (?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ringtone.objectID] ? [NSNull null] : ringtone.objectID),
                                                              ([StringUtils isEmpty:ringtone.description] ? [NSNull null] : ringtone.description),
                                                              ([StringUtils isEmpty:ringtone.name] ? [NSNull null] : ringtone.name),
                                                              ([StringUtils isEmpty:ringtone.fileUrl] ? [NSNull null] : ringtone.fileUrl),
                                                              ([StringUtils isEmpty:ringtone.timeLength] ? [NSNull null] : ringtone.timeLength),
                                                              ([StringUtils isEmpty:ringtone.fileSize] ? [NSNull null] : ringtone.fileSize),
                                                              ((ringtone.soundData == nil) ? [NSNull null] : ringtone.soundData), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Ringtone*)ringtone {
     NSString *      sql    = @"UPDATE Ringtone SET objectID = ?, description = ?, name = ?, fileUrl = ?, timeLength = ?, fileSize = ?, soundData = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:ringtone.objectID] ? [NSNull null] : ringtone.objectID),
                                                              ([StringUtils isEmpty:ringtone.description] ? [NSNull null] : ringtone.description),
                                                              ([StringUtils isEmpty:ringtone.name] ? [NSNull null] : ringtone.name),
                                                              ([StringUtils isEmpty:ringtone.fileUrl] ? [NSNull null] : ringtone.fileUrl),
                                                              ([StringUtils isEmpty:ringtone.timeLength] ? [NSNull null] : ringtone.timeLength),
                                                              ([StringUtils isEmpty:ringtone.fileSize] ? [NSNull null] : ringtone.fileSize),
                                                              ((ringtone.soundData == nil) ? [NSNull null] : ringtone.soundData),
                                                              ([StringUtils isEmpty:ringtone.objectID] ? [NSNull null] : ringtone.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Ringtone";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from Ringtone where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Ringtone where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];

}


@end
