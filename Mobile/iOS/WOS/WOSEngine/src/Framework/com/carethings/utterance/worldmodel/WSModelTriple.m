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

#import "WSModelTriple.h"
#import "WSStringUtils.h"


@implementation WSModelTriple

@synthesize subject = subject_;
@synthesize predicate = predicate_;
@synthesize object = object_;
@synthesize ontology = ontology_;
@synthesize language = language_;

- (id) initWithSubject: (NSURL*) subject andPredicate: (NSURL*) predicate andObject: (NSURL*) object {
	self = [super init];

	if (self) {
		subject_                = subject;
		predicate_      = predicate;
		object_         = object;
	}

	return self;
}

- (id) initWithClause: (NSString*) clause {
	self = [super init];

	if (self) {
		if ([WSStringUtils isNotEmpty: clause]) {
			// expecting strings of format "(subject predicate object)"
			NSCharacterSet* 		set = [NSCharacterSet characterSetWithCharactersInString: @"() "];
			NSArray*				triple = [clause componentsSeparatedByCharactersInSet: set];

			if ([triple count] == 5) {
				subject_		= [[NSURL alloc] initWithString:[triple objectAtIndex: 2]];
				predicate_      = [[NSURL alloc] initWithString:[triple objectAtIndex: 1]];
				object_			= [[NSURL alloc] initWithString:[triple objectAtIndex: 3]];
			} else   {
				//  Must be in some other form.  Support it.
				subject_		= [[NSURL alloc] initWithString:@""];
				predicate_		= [[NSURL alloc] initWithString:@""];
				object_			= [[NSURL alloc] initWithString:clause];
			}
		}
	}

	return self;
}

@end