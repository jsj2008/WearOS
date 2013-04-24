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

#import "SessionStudyDAO.h"
#import "SessionStudy.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "StringUtils.h"


@implementation SessionStudyDAO

- (id)allocateDaoObject {
    return [SessionStudy new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    SessionStudy* sessionStudy = (SessionStudy*)daoObject;

    if ((sessionStudy == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        sessionStudy.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        sessionStudy.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        sessionStudy.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        sessionStudy.sessionID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        sessionStudy.studyID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveCountStudiesOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"SELECT count(*) from SessionStudy where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)retrieveAllStudiesOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,sessionID,studyID from SessionStudy where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllStudyIDsOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"select studyID from SessionStudy where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)deleteAllStudiesOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"delete from SessionStudy where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)sessionObjectID study:(NSString*)studyObjectID {
    NSString *      sql    = @"INSERT into SessionStudy (objectID,description,sessionID,studyID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([[ResourceIdentityGenerator generateWithPath:@"SessionStudy"] fragment]),
                                                               @"iRPM Generated Row",
                                                               ([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID),
                                                               ([StringUtils isEmpty:studyObjectID] ? [NSNull null] : studyObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertStudyIDs:(NSArray*)studyIDs session:(NSString*)sessionObjectID {

    ResdbResult* result = nil;

    for (NSString* studyID in studyIDs) {
        result = [self insert: sessionObjectID study: studyID];
    }

    return result;
}

- (ResdbResult*)delete:(NSString*)sessionObjectID study:(NSString*)studyObjectID {
    NSString *      sql    = @"delete from SessionStudy where sessionID = ? and studyID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID),
                                                              ([StringUtils isEmpty:studyObjectID] ? [NSNull null] : studyObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByStudyID:(NSString*)studyObjectID {
    NSString *      sql    = @"delete from SessionStudy where studyID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:studyObjectID] ? [NSNull null] : studyObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
