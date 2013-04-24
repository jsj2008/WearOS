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

#import "PatientDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation PatientDAO

- (id)allocateDaoObject {
    return [Patient new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;

    Patient* patient = (Patient*)daoObject;

    if ((patient == nil) || (sqlRow == nil))
		return;

	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.firstName = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.patientNum = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.gender = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.weight = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.height = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.deviceToken = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.dateOfBirth = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.sample = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.visit1 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.visit2 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.visit3 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.visit4 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.visit5 = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastVisit1Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastVisit2Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastVisit3Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastVisit4Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastVisit5Interaction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.finalReview = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.lastFinalReviewInteraction = [NSURL URLWithString:[NSString stringWithUTF8String: textPtr]];
	patient.visit1Status = sqlite3_column_int(sqlRow,i++);
	patient.visit2Status = sqlite3_column_int(sqlRow,i++);
	patient.visit3Status = sqlite3_column_int(sqlRow,i++);
	patient.visit4Status = sqlite3_column_int(sqlRow,i++);
	patient.visit5Status = sqlite3_column_int(sqlRow,i++);
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.primaryClinic = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		patient.primaryClinicCode = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        patient.rewardPoints = [NSString stringWithUTF8String: textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        patient.points = [NSString stringWithUTF8String: textPtr];
    if (sqlite3_column_bytes(sqlRow,i) > 0)
        patient.photo = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,i) length: sqlite3_column_bytes(sqlRow,i)];
    i++;
    if (sqlite3_column_bytes(sqlRow,i) > 0)
        patient.photo2 = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,i) length: sqlite3_column_bytes(sqlRow,i)];
    i++;
    if (sqlite3_column_bytes(sqlRow,i) > 0)
        patient.photo3 = [NSMutableData dataWithBytes: sqlite3_column_blob(sqlRow,i) length: sqlite3_column_bytes(sqlRow,i)];
    i++;
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        patient.coachFilePath = [NSString stringWithUTF8String: textPtr];
    patient.welcomeCoach = sqlite3_column_int(sqlRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach from Patient where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];
    ResdbResult *   result = [ResdbResult new];

    result = [self findSingleRow:sql withParams:params];

    return result;
}

- (ResdbResult*)retrieveByPatientNum:(NSString*)patientNum {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,isWelcomeCoach,welcomeCoach from Patient where patientNum=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientNum] ? [NSNull null] : patientNum), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByPrimaryClinicCode:(NSString*)clinicCode {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach from Patient where primaryClinicCode=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:clinicCode] ? [NSNull null] : clinicCode), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByPrimaryClinic:(NSString*)clinic {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach,coachPhoto1,coachPhoto2 from Patient where primaryClinic=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:clinic] ? [NSNull null] : clinic), nil];
	
    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveByPatientNum:(NSString *)patientNum andPrimaryClinicCode:(NSString*)clinicCode {
    NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach from Patient where patientNum=? and primaryClinicCode=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patientNum] ? [NSNull null] : patientNum),
                                                              ([StringUtils isEmpty:clinicCode] ? [NSNull null] : clinicCode), nil];

	return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach from Patient";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from Patient";

    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Patient*)patient {
	NSString *      sql    = @"INSERT into Patient (objectID,description,lastName,firstName,patientNum,gender,weight,height,deviceToken,dateOfBirth,sample,visit1,visit2,visit3,visit4,visit5,lastVisit1Interaction,lastVisit2Interaction,lastVisit3Interaction,lastVisit4Interaction,lastVisit5Interaction,finalReview,lastFinalReviewInteraction,visit1Status,visit2Status,visit3Status,visit4Status,visit5Status,primaryClinic,primaryClinicCode,rewardPoints,points,photo,photo2,photo3,coachFilePath,welcomeCoach) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patient.objectID] ? [NSNull null] : patient.objectID),
                                                              ([StringUtils isEmpty:patient.description] ? [NSNull null] : patient.description),
                                                              ([StringUtils isEmpty:patient.lastName] ? [NSNull null] : patient.lastName),
                                                              ([StringUtils isEmpty:patient.firstName] ? [NSNull null] : patient.firstName),
                                                              ([StringUtils isEmpty:patient.patientNum] ? [NSNull null] : patient.patientNum),
                                                              ([StringUtils isEmpty:patient.gender] ? [NSNull null] : patient.gender),
                                                              ([StringUtils isEmpty:patient.weight] ? [NSNull null] : patient.weight),
                                                              ([StringUtils isEmpty:patient.height] ? [NSNull null] : patient.height),
                                                              ([StringUtils isEmpty:patient.deviceToken] ? [NSNull null] : patient.deviceToken),
                                                              ([StringUtils isEmpty:patient.dateOfBirth] ? [NSNull null] : patient.dateOfBirth),
                                                              ([StringUtils isEmpty:patient.sample] ? [NSNull null] : patient.sample),
                                                              ([StringUtils isEmpty:patient.visit1] ? [NSNull null] : patient.visit1),
                                                              ([StringUtils isEmpty:patient.visit2] ? [NSNull null] : patient.visit2),
                                                              ([StringUtils isEmpty:patient.visit3] ? [NSNull null] : patient.visit3),
                                                              ([StringUtils isEmpty:patient.visit4] ? [NSNull null] : patient.visit4),
                                                              ([StringUtils isEmpty:patient.visit5] ? [NSNull null] : patient.visit5),
                                                              ((patient.lastVisit1Interaction == nil) ? [NSNull null] : [patient.lastVisit1Interaction absoluteString]),
                                                              ((patient.lastVisit2Interaction == nil) ? [NSNull null] : [patient.lastVisit2Interaction absoluteString]),
                                                              ((patient.lastVisit3Interaction == nil) ? [NSNull null] : [patient.lastVisit3Interaction absoluteString]),
                                                              ((patient.lastVisit4Interaction == nil) ? [NSNull null] : [patient.lastVisit4Interaction absoluteString]),
                                                              ((patient.lastVisit5Interaction == nil) ? [NSNull null] : [patient.lastVisit5Interaction absoluteString]),
                                                              ([StringUtils isEmpty:patient.finalReview] ? [NSNull null] : patient.finalReview),
                                                              ([StringUtils isEmpty:[patient.lastFinalReviewInteraction absoluteString]] ? [NSNull null] : patient.lastFinalReviewInteraction),
                                                              [[NSNumber alloc] initWithInt:patient.visit1Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit2Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit3Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit4Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit5Status],
                                                              ([StringUtils isEmpty:patient.primaryClinic] ? [NSNull null] : patient.primaryClinic),
                                                              ([StringUtils isEmpty:patient.primaryClinicCode] ? [NSNull null] : patient.primaryClinicCode),
                                                              ([StringUtils isEmpty:patient.rewardPoints] ? [NSNull null] : patient.rewardPoints),
                                                              ([StringUtils isEmpty:patient.points] ? [NSNull null] : patient.points),
                                                              ((patient.photo == nil) ? [NSNull null] : patient.photo),
                                                              ((patient.photo2 == nil) ? [NSNull null] : patient.photo2),
                                                              ((patient.photo3 == nil) ? [NSNull null] : patient.photo3),
                                                              ([StringUtils isEmpty:patient.coachFilePath] ? [NSNull null] : patient.coachFilePath),
                                                              [[NSNumber alloc] initWithInt:patient.welcomeCoach], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Patient*)patient {
		NSString *      sql    = @"UPDATE Patient SET objectID = ?,description = ?,lastName = ?,firstName = ?,patientNum = ?,gender = ?,weight = ?,height = ?,deviceToken = ?,dateOfBirth = ?,sample = ?,visit1 = ?,visit2 = ?,visit3 = ?,visit4 = ?,visit5 = ?,lastVisit1Interaction = ?,lastVisit2Interaction = ?,lastVisit3Interaction = ?,lastVisit4Interaction = ?,lastVisit5Interaction = ?,finalReview = ?,lastFinalReviewInteraction = ?,visit1Status = ?,visit2Status = ?,visit3Status = ?,visit4Status = ?,visit5Status = ?,primaryClinic = ?,primaryClinicCode = ?,rewardPoints = ?,points = ?,photo = ?,photo2 = ?,photo3 = ?,coachFilePath = ?,welcomeCoach = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:patient.objectID] ? [NSNull null] : patient.objectID),
                                                              ([StringUtils isEmpty:patient.description] ? [NSNull null] : patient.description),
                                                              ([StringUtils isEmpty:patient.lastName] ? [NSNull null] : patient.lastName),
                                                              ([StringUtils isEmpty:patient.firstName] ? [NSNull null] : patient.firstName),
                                                              ([StringUtils isEmpty:patient.patientNum] ? [NSNull null] : patient.patientNum),
                                                              ([StringUtils isEmpty:patient.gender] ? [NSNull null] : patient.gender),
                                                              ([StringUtils isEmpty:patient.weight] ? [NSNull null] : patient.weight),
                                                              ([StringUtils isEmpty:patient.height] ? [NSNull null] : patient.height),
                                                              ([StringUtils isEmpty:patient.deviceToken] ? [NSNull null] : patient.deviceToken),
                                                              ([StringUtils isEmpty:patient.dateOfBirth] ? [NSNull null] : patient.dateOfBirth),
                                                              ([StringUtils isEmpty:patient.sample] ? [NSNull null] : patient.sample),
                                                              ([StringUtils isEmpty:patient.visit1] ? [NSNull null] : patient.visit1),
                                                              ([StringUtils isEmpty:patient.visit2] ? [NSNull null] : patient.visit2),
                                                              ([StringUtils isEmpty:patient.visit3] ? [NSNull null] : patient.visit3),
                                                              ([StringUtils isEmpty:patient.visit4] ? [NSNull null] : patient.visit4),
                                                              ([StringUtils isEmpty:patient.visit5] ? [NSNull null] : patient.visit5),
                                                              ((patient.lastVisit1Interaction == nil) ? [NSNull null] : [patient.lastVisit1Interaction absoluteString]),
                                                              ((patient.lastVisit2Interaction == nil) ? [NSNull null] : [patient.lastVisit2Interaction absoluteString]),
                                                              ((patient.lastVisit3Interaction == nil) ? [NSNull null] : [patient.lastVisit3Interaction absoluteString]),
                                                              ((patient.lastVisit4Interaction == nil) ? [NSNull null] : [patient.lastVisit4Interaction absoluteString]),
                                                              ((patient.lastVisit5Interaction == nil) ? [NSNull null] : [patient.lastVisit5Interaction absoluteString]),
                                                              ([StringUtils isEmpty:patient.finalReview] ? [NSNull null] : patient.finalReview),
                                                              ([StringUtils isEmpty:[patient.lastFinalReviewInteraction absoluteString]] ? [NSNull null] : patient.lastFinalReviewInteraction),
                                                              [[NSNumber alloc] initWithInt:patient.visit1Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit2Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit3Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit4Status],
                                                              [[NSNumber alloc] initWithInt:patient.visit5Status],
                                                              ([StringUtils isEmpty:patient.primaryClinic] ? [NSNull null] : patient.primaryClinic),
                                                              ([StringUtils isEmpty:patient.primaryClinicCode] ? [NSNull null] : patient.primaryClinicCode),
                                                              ([StringUtils isEmpty:patient.rewardPoints] ? [NSNull null] : patient.rewardPoints),
                                                              ([StringUtils isEmpty:patient.points] ? [NSNull null] : patient.points),
                                                              ((patient.photo == nil) ? [NSNull null] : patient.photo),
                                                              ((patient.photo2 == nil) ? [NSNull null] : patient.photo2),
                                                              ((patient.photo3 == nil) ? [NSNull null] : patient.photo3),
                                                              ([StringUtils isEmpty:patient.coachFilePath] ? [NSNull null] : patient.coachFilePath),
                                                              [[NSNumber alloc] initWithInt:patient.welcomeCoach],
                                                              ([StringUtils isEmpty:patient.objectID] ? [NSNull null] : patient.objectID),nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Patient";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Patient where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteByPrimaryClinicCode:(NSString*)clinicCode {
	NSString *      sql    = @"delete from Patient where primaryClinicCode = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:clinicCode] ? [NSNull null] : clinicCode), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
