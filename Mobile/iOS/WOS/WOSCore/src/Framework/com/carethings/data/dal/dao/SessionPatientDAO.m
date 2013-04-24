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

#import "SessionPatientDAO.h"
#import "SessionPatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "StringUtils.h"

@implementation SessionPatientDAO

- (id)allocateDaoObject {
    return [SessionPatient new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    SessionPatient* sessionPatient = (SessionPatient*)daoObject;

    if ((sessionPatient == nil) || (sqlRow == nil))
        return;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        sessionPatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        sessionPatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        sessionPatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        sessionPatient.sessionID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        sessionPatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,sessionID,patientID from SessionPatient where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllPatientIDsOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"select patientID from SessionPatient where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountPatientsOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"SELECT count(*) from SessionPatient where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self findCount:sql withParams:params];
}


- (ResdbResult*)deleteAllPatientsOfSession:(NSString*)sessionObjectID {
    NSString *      sql    = @"delete from SessionPatient where sessionID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)sessionObjectID patient:(NSString*)patientObjectID {
    NSString *      sql    = @"INSERT into SessionPatient (objectID,description,sessionID,patientID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([[ResourceIdentityGenerator generateWithPath:@"SessionPatient"] fragment]),
                                                              @"iRPM Generated Row",
                                                              ([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID),
                                                              ([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs session:(NSString*)sessionObjectID {
    for (NSString* patientID in patientIDs) {
        [self insert: sessionObjectID patient: patientID];
    }

    return nil;
}

- (ResdbResult*)delete:(NSString*)sessionObjectID patient:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from SessionPatient where sessionID = ? and patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:sessionObjectID] ? [NSNull null] : sessionObjectID),
                                                              ([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from SessionPatient where patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
