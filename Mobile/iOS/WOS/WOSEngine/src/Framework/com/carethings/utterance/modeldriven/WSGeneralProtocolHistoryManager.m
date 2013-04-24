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

@class GDataXMLElement;

@implementation WSGeneralProtocolHistoryManager

@synthesize history = history_;

- (NSString*) serializeHistory {
	NSError* error;

	if (history_ != nil) {
		NSData*  serializedStr = [NSPropertyListSerialization dataWithPropertyList:history_ format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
		return [[NSString alloc] initWithData: serializedStr encoding: NSUTF8StringEncoding];
	} else   {
		return nil;
	}
}

- (id) deserializeHistory: (NSString*) historyStr {
	NSError*                                        errorDescription;
	NSPropertyListReadOptions readOptions;

	if ((history_ != nil) && [WSStringUtils isNotEmpty: historyStr]) {
		return [NSPropertyListSerialization propertyListWithData:[historyStr dataUsingEncoding:NSUTF8StringEncoding] options:0 format:(NSPropertyListFormat *) &readOptions error:&errorDescription];
	} else   {
		return nil;
	}
}

- (void) setupWithIntervention: (WSInterventionHIL*) intervention {
	history_ = [NSMutableArray arrayWithCapacity: 5];

    // See if a protocol history already exists.  Load it if it does.
    ResdbResult*                    result;
    ProtocolHistoryDAO*             dao = [ProtocolHistoryDAO new];

    result = [dao retrieveByIntervention:[[intervention systemID] absoluteString] andRelatedId:[OpenPATHContext sharedOpenPATHContext].patient.patientNum];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        ProtocolHistory*  pHistory = (ProtocolHistory*)[result.resdbCollection objectAtIndex: 0];
        history_ = [self deserializeHistory: pHistory.history];
    }
}

- (void) pushInteraction: (NSNumber*) interactionIndex {
	[history_ addObject: interactionIndex];
}

- (int) count {
	return [history_ count];
}

- (void) clearHistory {
	[history_ removeAllObjects];

	ProtocolHistoryDAO*     dao = [ProtocolHistoryDAO new];
	[dao deleteAll];
}

- (void) clearHistoryByIntervention:(WSInterventionHIL*) intervention {
	[history_ removeAllObjects];
	
	ProtocolHistoryDAO*     dao = [ProtocolHistoryDAO new];
	[dao deleteByIntervention:[[intervention systemID] absoluteString]];
}

- (NSNumber*) lastInteraction {
	return [history_ lastObject];
}

- (NSNumber*) popInteraction {
	NSNumber*  interactionIndex = nil;

	if ([history_ count] > 0) {
		interactionIndex = [history_ lastObject];
		[history_ removeLastObject];
	}

	return interactionIndex;
}

- (void) persist: (WSInterventionHIL*) intervention {
	ResdbResult*           result;
	ProtocolHistoryDAO*    dao = [ProtocolHistoryDAO new];
	ProtocolHistory*       pHistory = nil;

	result = [dao retrieveByIntervention:[[intervention systemID] absoluteString]];

	if (result.resdbCode == RESDB_SQL_ROWS) {
		pHistory = (ProtocolHistory*)[result.resdbCollection objectAtIndex: 0];
		pHistory.history = [self serializeHistory];

		[dao update: pHistory];
	} else   {
		pHistory = [ProtocolHistory new];

		[pHistory allocateObjectId];
		pHistory.history             = [self serializeHistory];
		pHistory.interventionSysID   = [intervention.systemID absoluteString];

		[dao insert: pHistory];
	}
}

@end