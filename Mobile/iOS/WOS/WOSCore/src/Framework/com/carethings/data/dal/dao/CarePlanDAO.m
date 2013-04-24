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

#import "CarePlanDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation CarePlanDAO

- (id)allocateDaoObject {
    return [CarePlan new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    CarePlan* carePlan = (CarePlan*)daoObject;

    if ((carePlan == nil) || (sqlRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        carePlan.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        carePlan.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        carePlan.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        carePlan.xml = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,xml from CarePlan where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,xml from CarePlan";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from CarePlan";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(CarePlan*)carePlan {
    NSString *      sql    = @"INSERT into CarePlan (objectID,description,xml) values (?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:carePlan.objectID] ? [NSNull null] : carePlan.objectID),
                                                              ([StringUtils isEmpty:carePlan.description] ? [NSNull null] : carePlan.description),
                                                              ([StringUtils isEmpty:carePlan.xml] ? [NSNull null] : carePlan.xml), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(CarePlan*)carePlan {
     NSString *      sql    = @"UPDATE CarePlan SET objectID = ?,description = ?,xml = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:carePlan.objectID] ? [NSNull null] : carePlan.objectID),
                                                              ([StringUtils isEmpty:carePlan.description] ? [NSNull null] : carePlan.description),
                                                              ([StringUtils isEmpty:carePlan.xml] ? [NSNull null] : carePlan.xml),
                                                              ([StringUtils isEmpty:carePlan.xml] ? [NSNull null] : carePlan.xml), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from CarePlan";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from CarePlan where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
