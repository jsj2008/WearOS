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

#import "MemoDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation MemoDAO

- (id)allocateDaoObject {
    return [Memo new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Memo* memo = (Memo*)daoObject;

    if ((memo == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        memo.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        memo.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        memo.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        memo.memoID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        memo.fileUrl = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        memo.timeLength = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        memo.fileSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,7)))
        memo.relatedID = [NSString stringWithUTF8String:textPtr];
    if (sqlite3_column_bytes(sqlRow,8) > 0)
        memo.soundData = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,8) length: sqlite3_column_bytes(sqlRow,8)];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,memoID,fileUrl,timeLength,fileSize,relatedID,soundData from Memo where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,memoID,fileUrl,timeLength,fileSize,relatedID,soundData from Memo where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,memoID,fileUrl,timeLength,fileSize,relatedID,soundData from Memo";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(Memo*)memo {
    NSString *      sql    = @"INSERT into Memo (objectID,description,memoID,fileUrl,timeLength,fileSize,relatedID,soundData) values (?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:memo.objectID] ? [NSNull null] : memo.objectID),
                                                              ([StringUtils isEmpty:memo.description] ? [NSNull null] : memo.description),
                                                              ([StringUtils isEmpty:memo.memoID] ? [NSNull null] : memo.memoID),
                                                              ([StringUtils isEmpty:memo.fileUrl] ? [NSNull null] : memo.fileUrl),
                                                              ([StringUtils isEmpty:memo.timeLength] ? [NSNull null] : memo.timeLength),
                                                              ([StringUtils isEmpty:memo.fileSize] ? [NSNull null] : memo.fileSize),
                                                              ([StringUtils isEmpty:memo.relatedID] ? [NSNull null] : memo.relatedID),
                                                              ((memo.soundData == nil) ? [NSNull null] : memo.soundData), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Memo*)memo {
    NSString *      sql    = @"UPDATE Memo SET objectID = ?, description = ?, memoID = ?, fileUrl = ?, timeLength = ?, fileSize = ?, relatedID = ?, soundData = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:memo.objectID] ? [NSNull null] : memo.objectID),
                                                              ([StringUtils isEmpty:memo.description] ? [NSNull null] : memo.description),
                                                              ([StringUtils isEmpty:memo.memoID] ? [NSNull null] : memo.memoID),
                                                              ([StringUtils isEmpty:memo.fileUrl] ? [NSNull null] : memo.fileUrl),
                                                              ([StringUtils isEmpty:memo.timeLength] ? [NSNull null] : memo.timeLength),
                                                              ([StringUtils isEmpty:memo.fileSize] ? [NSNull null] : memo.fileSize),
                                                              ([StringUtils isEmpty:memo.relatedID] ? [NSNull null] : memo.relatedID),
                                                              ((memo.soundData == nil) ? [NSNull null] : memo.soundData),
                                                              ([StringUtils isEmpty:memo.objectID] ? [NSNull null] : memo.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Memo";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
     NSString *      sql    = @"delete from Memo where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Memo where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
