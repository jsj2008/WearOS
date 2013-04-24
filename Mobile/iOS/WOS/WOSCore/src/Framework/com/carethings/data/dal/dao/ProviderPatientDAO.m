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

#import "ProviderPatientDAO.h"
#import "ProviderPatient.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ResourceIdentityGenerator.h"
#import "StringUtils.h"


@implementation ProviderPatientDAO

- (id)allocateDaoObject {
    return [ProviderPatient new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    ProviderPatient* providerPatient = (ProviderPatient*)daoObject;

    if ((providerPatient == nil) || (sqlRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        providerPatient.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        providerPatient.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        providerPatient.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        providerPatient.providerID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        providerPatient.patientID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieveAllPatientsOfProvider:(NSString*)providerObjectID {
    NSString *      sql    = @"select objectID,creationTime,description,providerID,patientID from ProviderPatient where providerID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAllPatientIDsOfProvider:(NSString*)providerObjectID {
    NSString *      sql    = @"select patientID from ProviderPatient where providerID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveCountPatientsOfProvider:(NSString*)providerObjectID {
    NSString *      sql    = @"SELECT count(*) from ProviderPatient where providerID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID), nil];

    return [self findCount:sql withParams:params];
}


- (ResdbResult*)deleteAllPatientsOfProvider:(NSString*)providerObjectID {
    NSString *      sql    = @"delete from ProviderPatient where providerID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insert:(NSString*)providerObjectID patient:(NSString*)patientObjectID {
    NSString *      sql    = @"INSERT into ProviderPatient (objectID,description,providerID,patientID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID),
                                                              ([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)insertPatientIDs:(NSArray*)patientIDs provider:(NSString*)providerObjectID {
    for (NSString* patientID in patientIDs) {
        [self insert: providerObjectID patient: patientID];
    }
	
    return nil;
}

- (ResdbResult*)delete:(NSString*)providerObjectID patient:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from ProviderPatient where providerID = ? and patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:providerObjectID] ? [NSNull null] : providerObjectID),
                                                              ([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByPatientID:(NSString*)patientObjectID {
    NSString *      sql    = @"delete from ProviderPatient where patientID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientObjectID] ? [NSNull null] : patientObjectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];

}

@end
