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

#import "WSModelTripleCollection.h"
#import "WSModelTriple.h"
#import "WSStringUtils.h"

@implementation WSModelTripleCollection

@synthesize collection = collection_;

- (void) addTriple: (WSModelTriple*) triple {
	if (collection_ == nil)
		collection_ = [[NSMutableArray alloc] initWithCapacity: 5];

	if (triple != nil)
		[collection_ addObject: triple];
}

- (void) addClauseCollection: (NSArray*) clauseCollection {
	for (NSString* clause in clauseCollection) {
		[self addClause: clause];
	}
}

- (void) addClauseCollectionWithString:(NSString*)clauseCollectionStr {
    if ([WSStringUtils isEmpty:clauseCollectionStr]) {
        return;
    }

    //  We are assuming a comma-separated list of clauses
    NSArray* clauseCollection = [clauseCollectionStr componentsSeparatedByString:@","];

    [self addClauseCollection:clauseCollection];
}

- (NSString*)convertClauseCollectionToString:(NSArray*)clauseCollection {
    return ((clauseCollection == nil) || ([clauseCollection count] == 0)) ? nil : ([clauseCollection componentsJoinedByString:@","]);
}

- (void) addClauseCollection: (NSArray*) clauseCollection withValue: (NSString*) val {
	for (NSString* clause in clauseCollection) {
		[self addClause: clause withValue: val];
	}
}

- (void) addClause: (NSString*) clause {
	WSModelTriple* triple = [[WSModelTriple alloc] initWithClause: clause];

	[self addTriple: triple];
}

- (void) addClause: (NSString*) clause withValue: (NSString*) val {
	NSString*       fullClauseText  = [[NSString alloc] initWithFormat: clause, val];
	WSModelTriple*  triple          = [[WSModelTriple alloc] initWithClause: fullClauseText];

	[self addTriple: triple];
}

- (void) clearCollection {
	if (collection_ != nil) {
		[collection_ removeAllObjects];
		collection_ = nil;
	}
}

- (int) collectionCount {
	if (collection_ != nil)
		return [collection_ count];
	else
		return 0;
}

@end