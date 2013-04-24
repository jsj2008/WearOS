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

#import "CarePlanCaseDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "CasePatient.h"
#import "CasePatientDAO.h"
#import "PatientDAO.h"
#import "StringUtils.h"


@implementation CarePlanCaseDAO

- (id)allocateDaoObject {
    return [CarePlanCase new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    CarePlanCase* caseObj = (CarePlanCase*)daoObject;

    if ((caseObj == nil) || (sqlRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        caseObj.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        caseObj.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        caseObj.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        caseObj.lastInteractionSysID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        caseObj.carePlanID = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,lastInteractionSysID,carePlanID from Case where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,lastInteractionSysID,carePlanID from Case";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from Case";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(CarePlanCase*)caseObj {
    NSString *      sql    = @"INSERT into Case (objectID,description,lastInteractionSysID,carePlanID) values (?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObj.objectID] ? [NSNull null] : caseObj.objectID),
                                                              ([StringUtils isEmpty:caseObj.description] ? [NSNull null] : caseObj.description),
                                                              ([StringUtils isEmpty:caseObj.lastInteractionSysID] ? [NSNull null] : caseObj.lastInteractionSysID),
                                                              ([StringUtils isEmpty:caseObj.carePlanID] ? [NSNull null] : caseObj.carePlanID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(CarePlanCase*)caseObj {
    NSString *      sql    = @"UPDATE Case SET objectID = ?,description = ?,lastInteractionSysID = ?,carePlanID = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:caseObj.objectID] ? [NSNull null] : caseObj.objectID),
                                                              ([StringUtils isEmpty:caseObj.description] ? [NSNull null] : caseObj.description),
                                                              ([StringUtils isEmpty:caseObj.lastInteractionSysID] ? [NSNull null] : caseObj.lastInteractionSysID),
                                                              ([StringUtils isEmpty:caseObj.carePlanID] ? [NSNull null] : caseObj.carePlanID),
                                                              ([StringUtils isEmpty:caseObj.carePlanID] ? [NSNull null] : caseObj.carePlanID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Case";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Case where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)retrievePatients:(NSString*)caseObjectID {
    CasePatientDAO*     dao    = [CasePatientDAO new];
    NSMutableArray*     patients  = [NSMutableArray new];
    ResdbResult*        result = nil;
	
    result = [dao retrieveAllPatientsOfCase: caseObjectID];
	
    if (result.resdbCode == RESDB_SQL_ROWS) {
		
        for (CasePatient*   casePatient in result.resdbCollection) {
            PatientDAO*     patientDAO    = [PatientDAO new];
            ResdbResult* patientResult = nil;
			
            patientResult = [patientDAO retrieve:[casePatient patientID]];
			
            if (patientResult.resdbCode == RESDB_SQL_ROWS)
                [patients addObject:[patientResult resdbObject]];
        }
    }
	
    if ([patients count] > 0) {
        result.sqliteCode      = SQLITE_ROW;
        result.resdbCode       = RESDB_SQL_ROWS;
        result.resdbCollection = [[NSArray alloc] initWithArray: patients];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    return result;
}

- (ResdbResult*)retrievePatient:(NSString*)caseObjectID {
    CarePlanCaseDAO*        dao = [CarePlanCaseDAO new];
    ResdbResult*            tempResult  = nil;
    ResdbResult*            result      = [ResdbResult new];
	
    tempResult = [dao retrievePatients: caseObjectID];
	
    if (tempResult.resdbCode == RESDB_SQL_ROWS) {
        result.sqliteCode  = SQLITE_ROW;
        result.resdbCode   = RESDB_SQL_ROWS;
        result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
    } else {
        result.resdbCode =  RESDB_SQL_NO_ROWS;
    }
	
    return result;
}

- (ResdbResult*)addPatient:(NSString*)patientObjectID case:(NSString*)caseObjectID {
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao insert: caseObjectID patient: patientObjectID];
}

- (ResdbResult*)removePatient:(NSString*)patientObjectID case:(NSString*)caseObjectID {
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao delete: caseObjectID patient: patientObjectID];
}

- (ResdbResult*)removeAllPatients:(NSString*)caseObjectID {
    CasePatientDAO*    dao = [CasePatientDAO new];
	
    return [dao deleteAllPatientsOfCase: caseObjectID];
}

@end
