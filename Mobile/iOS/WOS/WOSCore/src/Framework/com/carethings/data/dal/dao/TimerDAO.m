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

#import "TimerDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation TimerDAO

- (id)allocateDaoObject {
    return [Timer new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Timer* timer = (Timer*)daoObject;

    if ((timer == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        timer.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        timer.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        timer.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        timer.name = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        timer.sound = [NSString stringWithUTF8String:textPtr];
    timer.active = sqlite3_column_int(sqlRow,5);
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        timer.startTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,7)))
        timer.category = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,8)))
        timer.repeat = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,9)))
        timer.message = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where category=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveActiveByCategory:(NSString*)category {
    NSString *      sql    = @"select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where category=? and active=1";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByTimer:(NSString*)timer {
    NSString *      sql    = @"select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer where lookup=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:timer] ? [NSNull null] : timer), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,name,sound,active,startTime,category,repeat,message from Timer";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByCategory:(NSString*)category {
    NSString *      sql    = @"SELECT count(*) from Timer where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(Timer*)timer {
    NSString *      sql    = @"INSERT into Timer (objectID,description,name,sound,active,startTime,category,repeat,message) values (?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:timer.objectID] ? [NSNull null] : timer.objectID),
                                                              ([StringUtils isEmpty:timer.description] ? [NSNull null] : timer.description),
                                                              ([StringUtils isEmpty:timer.name] ? [NSNull null] : timer.name),
                                                              ([StringUtils isEmpty:timer.sound] ? [NSNull null] : timer.sound),
                                                              [[NSNumber alloc] initWithInt:timer.active],
                                                              ([StringUtils isEmpty:timer.startTime] ? [NSNull null] : timer.startTime),
                                                              ([StringUtils isEmpty:timer.category] ? [NSNull null] : timer.category),
                                                              ([StringUtils isEmpty:timer.repeat] ? [NSNull null] : timer.repeat),
                                                              ([StringUtils isEmpty:timer.message] ? [NSNull null] : timer.message), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Timer*)timer {
    NSString *      sql    = @"UPDATE Timer SET objectID = ?, description = ?, name = ?, sound = ?, active = ?, startTime = ?, category = ?, repeat = ?, message = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:timer.objectID] ? [NSNull null] : timer.objectID),
                                                              ([StringUtils isEmpty:timer.description] ? [NSNull null] : timer.description),
                                                              ([StringUtils isEmpty:timer.name] ? [NSNull null] : timer.name),
                                                              ([StringUtils isEmpty:timer.sound] ? [NSNull null] : timer.sound),
                                                              [[NSNumber alloc] initWithInt:timer.active],
                                                              ([StringUtils isEmpty:timer.startTime] ? [NSNull null] : timer.startTime),
                                                              ([StringUtils isEmpty:timer.category] ? [NSNull null] : timer.category),
                                                              ([StringUtils isEmpty:timer.repeat] ? [NSNull null] : timer.repeat),
                                                              ([StringUtils isEmpty:timer.message] ? [NSNull null] : timer.message),
                                                              ([StringUtils isEmpty:timer.objectID] ? [NSNull null] : timer.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Timer";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Timer where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByCategory:(NSString*)category {
    NSString *      sql    = @"delete from Timer where category = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:category] ? [NSNull null] : category), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
