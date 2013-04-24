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

#import "WSBlackboardWorldModel.h"
#import "WSinteraction.h"
#import "WSModelTriple.h"
#import "BRSEngine.h"
#import "WSModelTripleCollection.h"

@implementation WSBlackboardWorldModel

@synthesize ruleEngine = ruleEngine_;

- (id) init {
	self = [super init];

	if (self) {
		//  Construct a local rule engine.
		ruleEngine_ = [BRSEngine new];
		[ruleEngine_ initializeRuleBase];
	}

	return self;
}

- (void) initializeWorldModel {
	if (ruleEngine_ != nil)
		[ruleEngine_ initializeRuleBase];
}

- (void) confirmUsingContent: (WSInteraction*) interaction {
}

- (void) disconfirmUsingContent: (WSInteraction*) interaction {
}

- (void) confirmUsingTriple: (WSModelTriple*) triple {
	NSString* fact = [[NSString alloc] initWithFormat: @"(%@ %@ %@)", triple.subject, triple.predicate, triple.object];

	[ruleEngine_ addFact: fact factTemplate: nil];
}

- (void) confirmUsingTripleCollection: (WSModelTripleCollection*) tripleColl {
	if (tripleColl != nil) {
		NSArray* collection = [tripleColl collection];

		for (WSModelTriple* triple in collection) {
			[self confirmUsingTriple: triple];
		}
	}
}

- (void) disconfirmUsingTriple: (WSModelTriple*) triple {
	NSString* fact = [[NSString alloc] initWithFormat: @"(%@ %@ %@)", triple.subject, triple.predicate, triple.object];

	[ruleEngine_ retractFact: fact factTemplate: nil];
}

- (void) disconfirmUsingTripleCollection: (WSModelTripleCollection*) tripleColl {
	if (tripleColl != nil) {
		NSArray* collection = [tripleColl collection];

		for (WSModelTriple* triple in collection) {
			[self disconfirmUsingTriple: triple];
		}
	}
}

- (void) analyseUsingTripleCollection: (WSModelTripleCollection*) ruleColl {
	if (ruleColl != nil) {
		NSArray* collection = [ruleColl collection];

		for (WSModelTriple* triple in collection) {
			[self analyseUsingTriple: triple];
		}
	}
}

- (void) analyseUsingTriple: (WSModelTriple*) rule {
	NSString* ruleStr = [[NSString alloc] initWithFormat: @"(%@ %@ %@)", rule.subject, rule.predicate, rule.object];

	[ruleEngine_ addRule: ruleStr];
}

- (int) analyse {
	return [ruleEngine_ run];
}

@end