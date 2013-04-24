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

#import "ProviderDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "ProviderPatientDAO.h"
#import "ProviderPatient.h"
#import "PatientDAO.h"
#import "StringUtils.h"


@implementation ProviderDAO

- (id)allocateDaoObject {
    return [Provider new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    Provider* provider = (Provider*)daoObject;

    if ((provider == nil) || (sqlRow == nil))
        return;
	
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,0)))
        provider.objectID = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,1)))
        provider.creationTime = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,2)))
        provider.description = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,3)))
        provider.clinicName = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,4)))
        provider.address = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,5)))
        provider.city = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,6)))
        provider.state = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,clinicName,address,city,state from Provider where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,clinicName,address,city,state from Provider";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
    NSString *      sql    = @"SELECT count(*) from Provider";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Provider*)provider {
    NSString *      sql    = @"INSERT into Provider (objectID,description,clinicName,address,city,state) values (?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:provider.objectID] ? [NSNull null] : provider.objectID),
                                                              ([StringUtils isEmpty:provider.description] ? [NSNull null] : provider.description),
                                                              ([StringUtils isEmpty:provider.clinicName] ? [NSNull null] : provider.clinicName),
                                                              ([StringUtils isEmpty:provider.address] ? [NSNull null] : provider.address),
                                                              ([StringUtils isEmpty:provider.city] ? [NSNull null] : provider.city),
                                                              ([StringUtils isEmpty:provider.state] ? [NSNull null] : provider.state), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Provider*)provider {
    NSString *      sql    = @"UPDATE Provider SET objectID = ?,description = ?,clinicName = ?,address = ?,city = ?,state = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:provider.objectID] ? [NSNull null] : provider.objectID),
                                                              ([StringUtils isEmpty:provider.description] ? [NSNull null] : provider.description),
                                                              ([StringUtils isEmpty:provider.clinicName] ? [NSNull null] : provider.clinicName),
                                                              ([StringUtils isEmpty:provider.address] ? [NSNull null] : provider.address),
                                                              ([StringUtils isEmpty:provider.city] ? [NSNull null] : provider.city),
                                                              ([StringUtils isEmpty:provider.state] ? [NSNull null] : provider.state),
                                                              ([StringUtils isEmpty:provider.objectID] ? [NSNull null] : provider.objectID),nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Provider";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Provider where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)retrievePatients:(NSString*)providerObjectID {
	ProviderPatientDAO*	dao      = [ProviderPatientDAO new];
	NSMutableArray*		patients = [NSMutableArray new];
	ResdbResult*		result   = nil;
	
	result = [dao retrieveAllPatientsOfProvider: providerObjectID];
	
	if (result.resdbCode == RESDB_SQL_ROWS) {
		for (ProviderPatient* providerPatient in result.resdbCollection) {
			PatientDAO*  patientDAO    = [PatientDAO new];
			ResdbResult* patientResult = nil;
			
			patientResult = [patientDAO retrieve:[providerPatient patientID]];
			
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

- (ResdbResult*)retrievePatient:(NSString*)sessionObjectID {
	ProviderDAO*	dao			= [ProviderDAO new];
	ResdbResult*	tempResult	= nil;
	ResdbResult*	result		= [ResdbResult new];
	
	tempResult = [dao retrievePatients: sessionObjectID];
	
	if (tempResult.resdbCode == RESDB_SQL_ROWS) {
		result.sqliteCode  = SQLITE_ROW;
		result.resdbCode   = RESDB_SQL_ROWS;
		result.resdbObject = [tempResult.resdbCollection objectAtIndex: 0];
	} else {
		result.resdbCode =  RESDB_SQL_NO_ROWS;
	}
	
	return result;
}

- (ResdbResult*)addPatient:(NSString*)patientObjectID session:(NSString*)providerObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];

	return [dao insert: providerObjectID patient: patientObjectID];
}

- (ResdbResult*)removePatient:(NSString*)patientObjectID session:(NSString*)providerObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];

	return [dao delete: providerObjectID patient: patientObjectID];
}

- (ResdbResult*)removeAllPatients:(NSString*)sessionObjectID {
	ProviderPatientDAO*    dao = [ProviderPatientDAO new];

	return [dao deleteAllPatientsOfProvider: sessionObjectID];
}

@end