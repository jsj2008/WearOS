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
#import "WSProtocolModel.h"
#import "WSUCSFProtocolModel.h"
#import "WSWorldModel.h"
#import "WSBlackboardWorldModel.h"
#import "WSModelTriple.h"
#import "WSModelTripleCollection.h"
#import "WSUCSFPetriNetProtocolModel.h"
#import "WSGeneralProtocolHistoryManager.h"



@implementation WSUCSFPetriNetProtocolModel

- (id) initWithCarePlan: (NSString*) careXML andHistoryManager: (id <WSProtocolHistoryManager>) histManager {
	self = [super init];
	
	if (self) {
		protocolFileName_ = careXML;
		
		if (histManager == nil) {
			historyManager_ = [WSGeneralProtocolHistoryManager new];
		} else   {
			historyManager_ = histManager;
		}
	}
	
	return self;
}

- (void) initializeModel {
}

- (void)setCarePlanFileName:(NSString *)fileName {

}

- (WSInteractionHIL *)interactionWithSystemID:(NSString *)sysId {
    return nil;
}

- (NSArray *)queryGoals {
    return nil;
}

- (NSArray *)queryTasks {
    return nil;
}

- (NSArray *)queryRewards {
    return nil;
}

-(NSArray*)queryInterventions {
    return nil;
}


-(int)currentInteractionIndex {
	return 0;
}

-(void)clearHistory {
}

-(void)clearHistoryByContent : (WSInterventionHIL*)intervention {
}

-(void)setupHistoryByContent : (WSInterventionHIL*)intervention {
}

- (WSInterventionHIL*) nextIntervention {
	return nil;
}

- (WSInteractionHIL*) nextInteractionFromIntervention: (WSInterventionHIL*) intervention {
	return nil;
}

- (WSResponse*) nextResponseFromInteraction: (WSInteractionHIL*) interaction {
	return nil;
}

- (WSInteractionHIL*) previousInteractionFromIntervention: (WSInterventionHIL*) intervention {
	return nil;
}

- (void) tellHistory: (WSInterventionHIL*) intervention {
}

- (void) responseIteratorBeginFromInteraction: (WSInteractionHIL*) interaction {
}

- (void) interactionIteratorBeginFromIntervention: (WSInterventionHIL*) intervention {
}

- (void) interventionIteratorBegin {
}

@end
