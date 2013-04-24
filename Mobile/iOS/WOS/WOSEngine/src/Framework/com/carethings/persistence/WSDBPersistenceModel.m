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
 * This code  is the  sole  property of CareThings, Inc. and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade secret, not to be disclosed
 * without written authorization from CareThings.  Any  use, duplication, or  disclosure of this program
 * by other than CareThings and its assigned licensees is strictly forbidden by law.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"


@implementation WSDBPersistenceModel

const char keyBytes[] = {
	0x75, 0xed, 0xb3, 0x56,
	0xd7, 0xea, 0xf7, 0x09,
	0x3b, 0x61, 0x92, 0xca,
	0x3a, 0xe1, 0x88, 0x6e,
	0x44, 0x9b, 0xd1, 0x68,
	0xaa, 0x30, 0xaf, 0x91,
	0x4d, 0x09, 0x35, 0xd4,
	0x57, 0x9a, 0x19, 0xcb,
	0x00
};

- (void) informWithContent: (WSUtteranceRoot*) root {
    if (![root isKindOfClass:[WSInteractionHIL class]]) {
        return;
    }

    WSInteractionHIL* interaction = (WSInteractionHIL*)root;

	if ([interaction isInterrogative]) {
		for (WSResponse* response in[interaction responses]) {
			if (([WSStringUtils isNotEmpty:[response responseValue]] || (response.responseData != nil)) && ([response systemID] != nil)) {
				ResdbResult*            result;
				ActivityDAO*                    dao = [ActivityDAO new];

				// Determine if the activity already exists
				result = [dao retrieveByRelatedId:[[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString] andCode:[[response systemID] absoluteString]];

				if (result.resdbCode ==  RESDB_SQL_NO_ROWS) {
					Activity* activity = [Activity new];

					[activity allocateObjectId];

					activity.relatedID                      = [[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString];
					activity.type                           = [interaction text];
					activity.code                           = [response.systemID absoluteString];
					activity.userCode                       = [response.code absoluteString];
					activity.data                           = [response responseData];

					if ([WSStringUtils isEmpty: response.responseValue])
						activity.value = @"0";
					else
						activity.value = [response responseValue];

					activity.archived               = false;
					activity.sysID                  = [[response systemID] absoluteString];
					activity.userID         = [[interaction userID] fragment];

					[dao insert: activity];
				} else   {
					if ([result.resdbCollection count] == 0) {
						return;
					}

					Activity* activity = [result.resdbCollection objectAtIndex: 0];

					if ([WSStringUtils isEmpty: response.responseValue])
						activity.value = @"0";
					else
						activity.value = [response responseValue];

					[dao update: activity];
				}
			} else   {
				[self disinformWithContent: interaction andResponse: response];
			}
		}
	}
}

- (void) disinformWithContent: (WSUtteranceRoot*) root andResponse: (WSResponse*) response {
    if (![root isKindOfClass:[WSInteractionHIL class]]) {
        return;
    }

	//  Delete any old values
	ActivityDAO*        dao = [ActivityDAO new];

	if ([response systemID] != nil)
		[dao deleteByRelatedId:[[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString] andCode:[[response systemID] absoluteString]];
}

- (void) disinformAll {
	ActivityDAO* dao = [ActivityDAO new];

	[dao deleteAll];
}

- (void) disinformAllResponsesWithContent: (WSUtteranceRoot*) root {
    if (![root isKindOfClass:[WSInteractionHIL class]]) {
        return;
    }

    WSInteractionHIL* interaction = (WSInteractionHIL*)root;

	if ([interaction isInterrogative]) {
		for (WSResponse* response in[interaction responses]) {
			[self disinformWithContent: interaction andResponse: response];
		}
	}
}

- (NSData*) tellAllWithOptions: (WSPersistenceOptions) options {
	ActivityDAO*            dao = [ActivityDAO new];
	NSMutableString*        csvOut = [[NSMutableString alloc] initWithCapacity: 100];
	ResdbResult*            result;

	[csvOut appendString: @"CreationTime, Patient System ID, Question ID, Response Code, Response Value, Response Data\n"];

	if (WS_IS_FLAG_SET(WSOptionPersistenceUnarchivedData, options)) {
		result = [dao retrieveUnArchived];
	} else   {
		result = [dao retrieveAll];
	}

	if (result.resdbCode ==  RESDB_SQL_ROWS) {
		for (Activity* activity in result.resdbCollection) {
			[csvOut appendFormat: @"%@,%@,%@,%@,%@,%@\n", activity.creationTime, activity.relatedID, activity.userID, activity.userCode, activity.value, activity.data];
		}
	}

	NSData*         csvData = [csvOut dataUsingEncoding: NSUTF8StringEncoding];
	NSData*         finalCsvData;

	if (WS_IS_FLAG_SET(WSOptionPersistenceEncrypt, options)) {
		finalCsvData = [csvData AES256EncryptWithKey: (void*)keyBytes];
	} else   {
		finalCsvData = csvData;
	}

	return finalCsvData;
}

- (NSData*) tellWithContent: (WSUtteranceRoot*) root andOptions: (WSPersistenceOptions) options {
    if (![root isKindOfClass:[WSInteractionHIL class]]) {
        return nil;
    }

	ActivityDAO*            dao = [ActivityDAO new];
	NSMutableString*        csvOut = [[NSMutableString alloc] initWithCapacity: 100];
	ResdbResult*            result;

	[csvOut appendString: @"CreationTime, Patient System ID, Question ID, Response Code, Response Value, Response Data\n"];

	if (WS_IS_FLAG_SET(WSOptionPersistenceUnarchivedData, options)) {
		result = [dao retrieveUnArchivedByRelatedId:[[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString]];
	} else   {
		result = [dao retrieveAll];
	}

	if (result.resdbCode ==  RESDB_SQL_ROWS) {
		for (Activity* activity in result.resdbCollection) {
			[csvOut appendFormat: @"%@,%@,%@,%@,%@,%@\n", activity.creationTime, activity.relatedID, activity.userID, activity.userCode, activity.value, activity.data];
		}
	}

	NSData*         csvData = [csvOut dataUsingEncoding: NSUTF8StringEncoding];
	NSData*         finalCsvData;

	if (WS_IS_FLAG_SET(WSOptionPersistenceEncrypt, options)) {
		finalCsvData = [csvData AES256EncryptWithKey: (void*)keyBytes];
	} else   {
		finalCsvData = csvData;
	}

	return finalCsvData;
}

- (int)informCount:(WSUtteranceRoot *)root {
    return 0;
}

- (int)informComplete {
    return 0;
}


- (NSData*) tellWithContent: (WSUtteranceRoot*) root andResponse: (WSResponse*) response {
    if (![root isKindOfClass:[WSInteractionHIL class]]) {
        return nil;
    }

	ActivityDAO*      dao = [ActivityDAO new];
	ResdbResult*      result;

	result = [dao retrieveByRelatedId:[[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString] andCode:[[response systemID] absoluteString]];

	if ((result != nil) && (result.resdbCode == RESDB_SQL_ROWS)) {
		Activity*  rowActivity = (Activity*)[result.resdbCollection objectAtIndex: 0];

		response.responseValue  = [NSMutableString stringWithString: rowActivity.value];
		response.responseData   = rowActivity.data;
	} else   {
		response.responseValue  = nil;
		response.responseData   = nil;
	}

	return nil;
}

- (void) setOptions {
}

@end