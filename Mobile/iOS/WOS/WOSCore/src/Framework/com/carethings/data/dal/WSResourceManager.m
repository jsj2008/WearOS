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

#import "WSResourceManager.h"
#import "StringUtils.h"
#import "DBSchemaVersionDAO.h"
#import "ResdbResult.h"
#import "CoreUtils.h"

@implementation WSResourceManager

// taken from sqlite3.h to prevent warning
SQLITE_API int sqlite3_key(
						   sqlite3 *db,                   /* Database to be rekeyed */
						   const void *pKey, int nKey     /* The key */
						   );

@synthesize ucsfDatabase = ucsfDatabase_;
@synthesize cipher = cipher_;
@synthesize iterations = iterations_;
@synthesize password = password_;
@synthesize options = options_;
@synthesize userSchema = userSchema_;
@synthesize phrManager = phrManager_;


static WSResourceManager* sharedResourceManager_ = nil;

+ (WSResourceManager *)sharedResourceManager { 
	@synchronized(self) { 
		if (sharedResourceManager_ == nil) { 
			sharedResourceManager_					= [self new]; 
			sharedResourceManager_.ucsfDatabase		= nil;
			sharedResourceManager_.cipher			= nil;
			sharedResourceManager_.iterations		= nil;
			sharedResourceManager_.password			= nil;
			sharedResourceManager_.options			= WSOptionResourceNoOptions;
			sharedResourceManager_.userSchema		= nil;
            sharedResourceManager_.phrManager       = nil;
		} 
	} 
	
	return sharedResourceManager_; 
}

- (void)setupWithPHRManager:(WSPHRManager*)manager andCipher:(NSString*)cipher andIterations:(NSString*)iterations andUserSchema:(NSArray*)schema withPassword:(NSString*)password options:(WSResourceOptions)options {
	sharedResourceManager_.cipher		= cipher;
	sharedResourceManager_.iterations	= iterations;
	sharedResourceManager_.password		= password;
	sharedResourceManager_.options		= options;
	sharedResourceManager_.userSchema	= schema;
    sharedResourceManager_.phrManager   = manager;
}

+ (void)initWithCipher:(NSString*)cipher andIterations:(NSString*)iterations andUserSchema:(NSArray*)schema withPassword:(NSString*)password options:(WSResourceOptions)options {
    [self sharedResourceManager];

    WSPHRManager* manager = [WSPHRManager  new];

    [sharedResourceManager_ setupWithPHRManager:manager andCipher:cipher andIterations:iterations andUserSchema:schema withPassword:password options:options];
}

+ (void)initWithPHRManager:(WSPHRManager*)manager andCipher:(NSString*)cipher andIterations:(NSString*)iterations andUserSchema:(NSArray*)schema withPassword:(NSString*)password options:(WSResourceOptions)options {
    [self sharedResourceManager];

    [sharedResourceManager_ setupWithPHRManager:manager andCipher:cipher andIterations:iterations andUserSchema:schema withPassword:password options:options];
}

- (void)closeDatabase {
	sqlite3_close(ucsfDatabase_);
	ucsfDatabase_ = nil;
}

- (void)reallyCloseDatabase {
	if (sqlite3_close(ucsfDatabase_) == SQLITE_BUSY) {
		// you're not too busy for us, buddy
		sqlite3_interrupt(ucsfDatabase_);
		sqlite3_close(ucsfDatabase_);
	}
	ucsfDatabase_ = nil;
}

- (sqlite3*)getConnection {
	if (ucsfDatabase_ == nil) {
		NSArray*                paths                           = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString*               documentsDirectory      = [paths objectAtIndex: 0];
		NSString*               writableDBPath          = [documentsDirectory stringByAppendingPathComponent: @"ucsfdb.sqlite"];

		if (sqlite3_open([writableDBPath UTF8String], &ucsfDatabase_) != SQLITE_OK)  {
			sqlite3_close(ucsfDatabase_);
			ucsfDatabase_ = nil;
			NSAssert1(0,@"Failed to open the database with message '%s'.", sqlite3_errmsg(ucsfDatabase_));
		} else {
			if (CU_IS_FLAG_SET(options_, WSOptionResourceEncrypt)) {
				/*
				 NSData *passwordData = [self searchKeychainCopyMatching:@"password"];
				 if (passwordData) {
				 NSString *password = [NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
				 [passwordData;
				 }
				 */
				
				// submit the password
				const char*     key = [password_ UTF8String];
				sqlite3_key(ucsfDatabase_, key, strlen(key));

				if ([StringUtils isNotEmpty: cipher_]) {
					sqlite3_exec(ucsfDatabase_, (const char*)[[NSString stringWithFormat:@"PRAGMA cipher='%@';", cipher_] UTF8String], NULL, NULL, NULL);
				}

				if ([StringUtils isNotEmpty:iterations_]) {
					sqlite3_exec(ucsfDatabase_, (const char*)[[NSString stringWithFormat:@"PRAGMA kdf_iter='%@';", iterations_] UTF8String], NULL, NULL, NULL);
				}
			}

			if (sqlite3_exec(ucsfDatabase_, "SELECT count(*) FROM PATIENT", NULL, NULL, NULL) != SQLITE_OK) {
				[phrManager_ initializePHR];
				
				if (userSchema_ != nil) {
					NSError*  err = nil;
					
					for (NSString* command in userSchema_) {
						[phrManager_ execute:command error:&err];
					}
				}
			} else {
            	DBSchemaVersionDAO* dao = [DBSchemaVersionDAO new] ;
                ResdbResult*        result = nil;

                result =[dao retrieve];

                if (result.resdbCode == RESDB_SQL_ROWS) {
                    int schemaVersion = [((DBSchemaVersion*)result.resdbObject).schemaVersion intValue];

                    if (schemaVersion != WS_PHR_SCHEMA_VERSION) {
                        [phrManager_ checkForSchemaUpdates:schemaVersion];

                        [dao update:WS_PHR_SCHEMA_VERSION_STR];
                    }
                }
            }
		}
	}

	return ucsfDatabase_;
}

@end
