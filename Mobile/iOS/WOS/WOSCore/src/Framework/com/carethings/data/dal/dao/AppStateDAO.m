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

#import "AppStateDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation AppStateDAO

- (id)allocateDaoObject {
    return [AppState new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    AppState* appState = (AppState*)daoObject;

    if ((appState == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        appState.objectID = [NSString stringWithUTF8String: textPtr]; 
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        appState.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        appState.description = [NSString stringWithUTF8String: textPtr];
    appState.active   =  sqlite3_column_int(sqlRow,3);
    appState.simIndex =  sqlite3_column_int(sqlRow,4);
}

- (ResdbResult*)retrieve {
    NSString *      sql    = @"select objectID,creationTime,description,active,simIndex from AppState where objectID=1";

    return [self findSingleRow:sql withParams:nil];
}

- (ResdbResult*)insert:(AppState*)appState {
    NSString *      sql    = @"INSERT into AppState (objectID,description,active,simIndex) values (1,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:appState] ? [NSNull null] : appState), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(AppState*)appState {
    NSString *      sql    = @"UPDATE AppState SET description = ?,active = ?,simIndex = ? WHERE objectID = 1";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:appState] ? [NSNull null] : appState), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
