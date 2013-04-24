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

#import "SiteDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation SiteDAO

- (id)allocateDaoObject {
    return [Site new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
	char*  textPtr = nil;
	
    Site* site = (Site*)daoObject;
	
    if ((site == nil) || (sqlRow == nil))
		return;
	
	int i = 0;
	
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.objectID = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.creationTime = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.description = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.ontology = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.name = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.administrator = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.buildingId = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.address = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.city = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.stateOrProvince = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.zip = [NSString stringWithUTF8String: textPtr];
	if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
		site.country = [NSString stringWithUTF8String: textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,administrator,buildingId,address,city,stateOrProvince,zip,country from Site where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];
	
    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveBySiteName:(NSString*)name {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,administrator,buildingId,address,city,stateOrProvince,zip,country from Site where name=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];
	
    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
	NSString *      sql    = @"select objectID,creationTime,description,ontology,name,administrator,buildingId,address,city,stateOrProvince,zip,country from Site";
	
    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)retrieveCount {
	NSString *      sql    = @"SELECT count(*) from Site";
	
    return [self findCount:sql withParams:nil];
}

- (ResdbResult*)insert:(Site*)site {
	NSString *      sql    = @"INSERT into Site (objectID,description,ontology,name,administrator,buildingId,address,city,stateOrProvince,zip,country) values (?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:site.objectID] ? [NSNull null] : site.objectID),
							  ([StringUtils isEmpty:site.description] ? [NSNull null] : site.description),
							  ([StringUtils isEmpty:site.ontology] ? [NSNull null] : site.ontology),
							  ([StringUtils isEmpty:site.name] ? [NSNull null] : site.name),
							  ([StringUtils isEmpty:site.administrator] ? [NSNull null] : site.administrator),
							  ([StringUtils isEmpty:site.buildingId] ? [NSNull null] : site.buildingId),
							  ([StringUtils isEmpty:site.address] ? [NSNull null] : site.address),
							  ([StringUtils isEmpty:site.city] ? [NSNull null] : site.city),
							  ([StringUtils isEmpty:site.stateOrProvince] ? [NSNull null] : site.stateOrProvince),
							  ([StringUtils isEmpty:site.zip] ? [NSNull null] : site.zip),
							  ([StringUtils isEmpty:site.country] ? [NSNull null] : site.country), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Site*)site {
	NSString *      sql    = @"UPDATE Site SET objectID = ?,description = ?,ontology = ?,name = ?,administrator = ?,buildingId = ?,address = ?,city = ?,stateOrProvince = ?,zip = ?,country = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:site.objectID] ? [NSNull null] : site.objectID),
							  ([StringUtils isEmpty:site.description] ? [NSNull null] : site.description),
							  ([StringUtils isEmpty:site.ontology] ? [NSNull null] : site.ontology),
							  ([StringUtils isEmpty:site.name] ? [NSNull null] : site.name),
							  ([StringUtils isEmpty:site.administrator] ? [NSNull null] : site.administrator),
							  ([StringUtils isEmpty:site.buildingId] ? [NSNull null] : site.buildingId),
							  ([StringUtils isEmpty:site.address] ? [NSNull null] : site.address),
							  ([StringUtils isEmpty:site.city] ? [NSNull null] : site.city),
							  ([StringUtils isEmpty:site.stateOrProvince] ? [NSNull null] : site.stateOrProvince),
							  ([StringUtils isEmpty:site.zip] ? [NSNull null] : site.zip),
							  ([StringUtils isEmpty:site.country] ? [NSNull null] : site.country),
							  ([StringUtils isEmpty:site.objectID] ? [NSNull null] : site.objectID), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteAll {
	NSString *      sql    = @"delete from Site";
	
    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
	NSString *      sql    = @"delete from Site where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)deleteBySiteName:(NSString*)name {
	NSString *      sql    = @"delete from Site where name = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:name] ? [NSNull null] : name), nil];
	
    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end
