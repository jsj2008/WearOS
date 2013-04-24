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

#import "PhysicianNoteDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation PhysicianNoteDAO

- (id)allocateDaoObject {
    return [PhysicianNote new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    PhysicianNote* physicianNote = (PhysicianNote*)daoObject;

    if ((physicianNote == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        physicianNote.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        physicianNote.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        physicianNote.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        physicianNote.note = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        physicianNote.physician = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        physicianNote.relatedID = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        physicianNote.priority = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,7)))
        physicianNote.status = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,8)))
        physicianNote.toParticipant = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,9)))
        physicianNote.urlOfNote = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote from PhysicianNote";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCountByStatus:(NSString*)status {
    NSString *      sql    = @"SELECT count(*) from PhysicianNote where status = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:status] ? [NSNull null] : status), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)retrieveCountByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"SELECT count(*) from PhysicianNote where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)insert:(PhysicianNote*)physicianNote {
    NSString *      sql    = @"INSERT into PhysicianNote (objectID,description,note,physician,relatedID,priority,status,toParticipant,urlOfNote) values (?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:physicianNote.objectID] ? [NSNull null] : physicianNote.objectID),
                                                              ([StringUtils isEmpty:physicianNote.description] ? [NSNull null] : physicianNote.description),
                                                              ([StringUtils isEmpty:physicianNote.note] ? [NSNull null] : physicianNote.note),
                                                              ([StringUtils isEmpty:physicianNote.physician] ? [NSNull null] : physicianNote.physician),
                                                              ([StringUtils isEmpty:physicianNote.relatedID] ? [NSNull null] : physicianNote.relatedID),
                                                              ([StringUtils isEmpty:physicianNote.priority] ? [NSNull null] : physicianNote.priority ),
                                                              ([StringUtils isEmpty:physicianNote.status] ? [NSNull null] : physicianNote.status),
                                                              ([StringUtils isEmpty:physicianNote.toParticipant] ? [NSNull null] : physicianNote.toParticipant),
                                                              ([StringUtils isEmpty:physicianNote.urlOfNote] ? [NSNull null] : physicianNote.urlOfNote), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(PhysicianNote*)physicianNote {
    NSString *      sql    = @"UPDATE PhysicianNote SET objectID = ?, description = ?, note = ?, physician = ?, relatedID = ?, priority = ?, status = ?, toParticipant = ?, urlOfNote = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:physicianNote.objectID] ? [NSNull null] : physicianNote.objectID),
                                                              ([StringUtils isEmpty:physicianNote.description] ? [NSNull null] : physicianNote.description),
                                                              ([StringUtils isEmpty:physicianNote.note] ? [NSNull null] : physicianNote.note),
                                                              ([StringUtils isEmpty:physicianNote.physician] ? [NSNull null] : physicianNote.physician),
                                                              ([StringUtils isEmpty:physicianNote.relatedID] ? [NSNull null] : physicianNote.relatedID),
                                                              ([StringUtils isEmpty:physicianNote.priority] ? [NSNull null] : physicianNote.priority ),
                                                              ([StringUtils isEmpty:physicianNote.status] ? [NSNull null] : physicianNote.status),
                                                              ([StringUtils isEmpty:physicianNote.toParticipant] ? [NSNull null] : physicianNote.toParticipant),
                                                              ([StringUtils isEmpty:physicianNote.urlOfNote] ? [NSNull null] : physicianNote.urlOfNote),
                                                              ([StringUtils isEmpty:physicianNote.objectID] ? [NSNull null] : physicianNote.objectID),nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from PhysicianNote";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from PhysicianNote where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from PhysicianNote where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
