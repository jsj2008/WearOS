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

#import "SecurityDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation SecurityDAO

- (id)allocateDaoObject {
    return [Security new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char *textPtr = nil;

    Security* security = (Security*)daoObject;

    if ((security == nil) || (sqlRow == nil))
        return;
	
    int i = 0;
	
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.password = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.encryptionKey = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.endPointURL = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.endPointPort = [NSString stringWithUTF8String:textPtr];
    security.enforceSecurity  = sqlite3_column_int(sqlRow, i++);
    security.encryption = sqlite3_column_int(sqlRow, i++);
    if (sqlite3_column_bytes(sqlRow,i) > 0)
   		security.securityCertificate = [NSData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
    i++;
    if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.userName = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.adminUserName = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.adminPassword = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.vendor = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.securityToken = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.clientIdentifier = [NSString stringWithUTF8String:textPtr];
	if ((textPtr = (char *) sqlite3_column_text(sqlRow, i++)))
        security.clientSecretKey = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult *)retrieveCertificateById:(NSString *)objectID {
    NSString *      sql    = @"select securityCertificate from Security where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult *)retrieve:(NSString *)objectID {
    NSString *      sql    = @"select objectID,creationTime,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption,securityCertificate,userName,adminUserName,adminPassword,vendor,securityToken,clientIdentifier,clientSecretKey from Security where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult *)retrieveAll {
    NSString *      sql    = @"select objectID,creationTime,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption from Security";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult *)insert:(Security *)security {
    NSString *      sql    = @"INSERT into Security (objectID,description,password,encryptionKey,endPointURL,endPointPort,enforceSecurity,encryption,securityCertificate,userName,adminUserName,adminPassword,vendor,securityToken,clientIdentifier,clientSecretKey) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:security.objectID] ? [NSNull null] : security.objectID),
                                                              ([StringUtils isEmpty:security.description] ? [NSNull null] : security.description),
                                                              ([StringUtils isEmpty:security.password] ? [NSNull null] : security.password),
                                                              ([StringUtils isEmpty:security.encryptionKey] ? [NSNull null] : security.encryptionKey),
                                                              ([StringUtils isEmpty:security.endPointURL] ? [NSNull null] : security.endPointURL),
                                                              ([StringUtils isEmpty:security.endPointPort] ? [NSNull null] : security.endPointPort),
                                                              [[NSNumber alloc] initWithInt:security.enforceSecurity],
                                                              [[NSNumber alloc] initWithInt:security.encryption],
                                                              ((security.securityCertificate == nil) ? [NSNull null] : security.securityCertificate),
							                                  ([StringUtils isEmpty:security.userName] ? [NSNull null] : security.userName),
															  ([StringUtils isEmpty:security.adminUserName] ? [NSNull null] : security.adminUserName),
							                                  ([StringUtils isEmpty:security.adminPassword] ? [NSNull null] : security.adminPassword),
															  ([StringUtils isEmpty:security.vendor] ? [NSNull null] : security.vendor),
							                                  ([StringUtils isEmpty:security.securityToken] ? [NSNull null] : security.securityToken),
							                                  ([StringUtils isEmpty:security.clientIdentifier] ? [NSNull null] : security.clientIdentifier),
							                                  ([StringUtils isEmpty:security.clientSecretKey] ? [NSNull null] : security.clientSecretKey),
                                                              nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult *)update:(Security *)security {
    NSString *      sql    = @"UPDATE Security SET objectID = ?,description = ?,password = ?,encryptionKey = ?,endPointURL = ?,endPointPort = ?,enforceSecurity = ?,encryption = ?,securityCertificate = ?,userName = ?,adminUserName = ?,adminPassword = ?,vendor = ?,securityToken = ?,clientIdentifier = ?,clientSecretKey = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:security.objectID] ? [NSNull null] : security.objectID),
                                                              ([StringUtils isEmpty:security.description] ? [NSNull null] : security.description),
                                                              ([StringUtils isEmpty:security.password] ? [NSNull null] : security.password),
                                                              ([StringUtils isEmpty:security.encryptionKey] ? [NSNull null] : security.encryptionKey),
                                                              ([StringUtils isEmpty:security.endPointURL] ? [NSNull null] : security.endPointURL),
                                                              ([StringUtils isEmpty:security.endPointPort] ? [NSNull null] : security.endPointPort),
                                                              [[NSNumber alloc] initWithInt:security.enforceSecurity],
                                                              [[NSNumber alloc] initWithInt:security.encryption],
                                                              ((security.securityCertificate == nil) ? [NSNull null] : security.securityCertificate),							  
															  ([StringUtils isEmpty:security.userName] ? [NSNull null] : security.userName),
							                                  ([StringUtils isEmpty:security.adminUserName] ? [NSNull null] : security.adminUserName),
							                                  ([StringUtils isEmpty:security.adminPassword] ? [NSNull null] : security.adminPassword),
															  ([StringUtils isEmpty:security.vendor] ? [NSNull null] : security.vendor),
							                                  ([StringUtils isEmpty:security.securityToken] ? [NSNull null] : security.securityToken),
															  ([StringUtils isEmpty:security.clientIdentifier] ? [NSNull null] : security.clientIdentifier),
							                                  ([StringUtils isEmpty:security.clientSecretKey] ? [NSNull null] : security.clientSecretKey),
                                                              ([StringUtils isEmpty:security.objectID] ? [NSNull null] : security.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult *)deleteAll {
    NSString *      sql    = @"delete from Security";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult *)delete:(NSString *)objectID {
    NSString *      sql    = @"delete from Security where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


@end
