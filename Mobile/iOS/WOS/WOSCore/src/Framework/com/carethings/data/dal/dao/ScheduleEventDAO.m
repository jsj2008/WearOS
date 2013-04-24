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

#import "ScheduleEventDAO.h"
#import "WSResourceManager.h"
#import "ScheduleEvent.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation ScheduleEventDAO

- (id)allocateDaoObject {
    return [ScheduleEvent new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    ScheduleEvent* scheduleEvent = (ScheduleEvent*)daoObject;

    if ((scheduleEvent == nil) || (sqlRow == nil))
		return;

	if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
		scheduleEvent.objectID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
		scheduleEvent.creationTime = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
		scheduleEvent.description = [NSString stringWithUTF8String:textPtr];
	scheduleEvent.dayInWeekOfStudy = sqlite3_column_int(sqlRow,3);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
		scheduleEvent.event = [NSString stringWithUTF8String:textPtr];
	scheduleEvent.hourOfDayStudy = sqlite3_column_int(sqlRow,5);
	scheduleEvent.weekOfStudy = sqlite3_column_int(sqlRow,6);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy from ScheduleEvent where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy from ScheduleEvent";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(ScheduleEvent*)scheduleEvent {
	NSString *      sql    = @"INSERT into ScheduleEvent (objectID,description,dayInWeekOfStudy,event,hourOfDayStudy,weekOfStudy) values (?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:scheduleEvent.objectID] ? [NSNull null] : scheduleEvent.objectID),
                                                              ([StringUtils isEmpty:scheduleEvent.description] ? [NSNull null] : scheduleEvent.description),
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.dayInWeekOfStudy],
                                                              ([StringUtils isEmpty:scheduleEvent.event] ? [NSNull null] : scheduleEvent.event),
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.hourOfDayStudy],
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.weekOfStudy], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(ScheduleEvent*)scheduleEvent {
	NSString *      sql    = @"UPDATE ScheduleEvent SET objectID = ?, description = ?, dayInWeekOfStudy = ?,event = ?,hourOfDayStudy = ?,weekOfStudy = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:scheduleEvent.objectID] ? [NSNull null] : scheduleEvent.objectID),
                                                              ([StringUtils isEmpty:scheduleEvent.description] ? [NSNull null] : scheduleEvent.description),
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.dayInWeekOfStudy],
                                                              ([StringUtils isEmpty:scheduleEvent.event] ? [NSNull null] : scheduleEvent.event),
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.hourOfDayStudy],
                                                              [[NSNumber alloc] initWithInt:scheduleEvent.weekOfStudy],
                                                              ([StringUtils isEmpty:scheduleEvent.objectID] ? [NSNull null] : scheduleEvent.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from ScheduleEvent";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from ScheduleEvent where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
