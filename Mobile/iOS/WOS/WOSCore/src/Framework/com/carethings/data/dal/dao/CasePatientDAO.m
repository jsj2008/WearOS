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

#import "CasePatientDAO.h"
#import "CasePatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "CarePlanCaseDAO.h"
#import "StringUtils.h"


@implementation CasePatientDAO

- (id)allocateDaoObject {
    return [CasePatient new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    CasePatient* casePatient = (CasePatient*)daoObject;

    if ((casePatient == nil) || (sqlRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        casePatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        casePatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        casePatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        casePatient.caseID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        casePatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfCase:(NSString*)caseObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,caseID,patientID from CasePatient where caseID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObjectID] ? [NSNull null] : caseObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllCasesOfPatient:(NSString*)patientID {
    NSString *      sql    = @"select objectID,creationTime,description,caseID,patientID from CasePatient where patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientID] ? [NSNull null] : patientID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllPatientIDsOfCase:(NSString*)caseObjectID {
    NSString *      sql    = @"select patientID from CasePatient where caseID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObjectID] ? [NSNull null] : caseObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountPatientsOfCase:(NSString*)caseObjectID {
    NSString *      sql    = @"SELECT count(*) from CasePatient where caseID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObjectID] ? [NSNull null] : caseObjectID), nil];

    return [self findCount:sql withParams:params];
}

- (ResdbResult*)deleteAllPatientsOfCase:(NSString*)caseObjectID {
    NSString *      sql    = @"delete from CasePatient where caseID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObjectID] ? [NSNull null] : caseObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)caseObjectID patient:(NSString*)patientObjectID {
    NSString *      sql    = @"INSERT into CasePatient (objectID,description,caseID,patientID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([[ResourceIdentityGenerator generateWithPath:@"CasePatient"] fragment]),
                                                              @"iRPM Generated Row" ,
                                                              caseObjectID,
                                                              patientObjectID, nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs case:(NSString*)caseObjectID {
	
    ResdbResult* result = nil;
	
    for (NSString* patientID in patientIDs) {
        result = [self insert: caseObjectID patient: patientID];
    }
	
    return result;
}

- (ResdbResult*)delete:(NSString*)caseObjectID study:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from CasePatient where caseID = ? and patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObjectID] ? [NSNull null] : caseObjectID),
                                                              ([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString *)caseObjectID patient:(NSString *)patientObjectID {
	return nil;
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from CasePatient where patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
