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

#import "WSInteractionHIL.h"
#import "WSStringUtils.h"
#import "WSResponse.h"
#import "WSActor.h"


@implementation WSInteractionHIL

@synthesize navigation = navigation_;
@synthesize responses = responses_;
@synthesize filteredResponses = filteredResponses_;
@synthesize text = text_;
@synthesize textResource = textResource_;
@synthesize textHeight = textHeight_;
@synthesize responseRequired = responseRequired_;
@synthesize selectedResponses = selectedResponses_;
@synthesize enumIndex = enumIndex_;
@synthesize scroll = scroll_;
@synthesize audioResource = audioResource_;
@synthesize actor = actor_;
@synthesize goalActivation = goalActivation_;
@synthesize taskActivation = taskActivation_;
@synthesize groupName = groupName_;
@synthesize members = members_;

-(id)copyWithZone:(NSZone*)zone {
    WSInteractionHIL* newInteractionHIL = [super copyWithZone:zone];

    newInteractionHIL.navigation  = navigation_;

    if ([self memberCount] > 0) {
        newInteractionHIL.members = [[NSMutableArray alloc] initWithArray:members_];
    }

    if ([self hasResponses]) {
        newInteractionHIL.responses = [[NSMutableArray alloc] initWithArray:responses_];
    }

    if ([self filteredResponseCount] > 0) {
        newInteractionHIL.filteredResponses = [[NSMutableArray alloc] initWithArray:filteredResponses_];
    }

    if ([self hasSelectedResponses]) {
        newInteractionHIL.selectedResponses = [[NSMutableArray alloc] initWithArray:selectedResponses_];
    }

    newInteractionHIL.text = text_;

    if (textResource_ != nil) {
        newInteractionHIL.textResource = [[NSURL alloc]  initWithString:[textResource_ absoluteString]];
    }

    if (audioResource_ != nil) {
        newInteractionHIL.audioResource = [[NSURL alloc]  initWithString:[audioResource_ absoluteString]];
    }

    newInteractionHIL.textHeight         = textHeight_;
    newInteractionHIL.scroll             = scroll_;
    newInteractionHIL.responseRequired   = responseRequired_;
    newInteractionHIL.enumIndex          = enumIndex_;
    newInteractionHIL.actor              = actor_;

    if ([self goalActivationCount] > 0) {
        newInteractionHIL.goalActivation = [[NSMutableArray alloc] initWithArray:goalActivation_];
    }

    if ([self taskActivationCount]) {
        newInteractionHIL.taskActivation = [[NSMutableArray alloc] initWithArray:taskActivation_];
    }
    newInteractionHIL.groupName          = groupName_;

    return newInteractionHIL;
}

- (bool) hasSelectedResponses {
	for (WSResponse* response in filteredResponses_) {
		if ([WSStringUtils isNotEmpty: response.responseValue])
			return true;
	}

	return false;
}

- (bool) hasNoSelectedResponses {
	for (WSResponse* response in filteredResponses_) {
		if ([WSStringUtils isNotEmpty: response.responseValue])
			return false;
	}

	return true;
}

- (WSResponse*) getSelectedResponse {
	for (WSResponse* response in filteredResponses_) {
		if ([WSStringUtils isNotEmpty: response.responseValue])
			return response;
	}

	return nil;
}

- (bool) isResponseRequired {
	return responseRequired_;
}

- (bool) hasResponses {
	if ((responses_ != nil) && ([responses_ count] > 0))
		return true;
	else
		return false;
}

- (void) setResponseValue: (NSString*) value atIndex: (int) idx {
	if ((responses_ != nil) && (idx <[responses_ count])) {
		((WSResponse*)[responses_ objectAtIndex:(NSUInteger) idx]).responseValue = [NSMutableString stringWithString: value];
	}
}

- (WSResponse*) getFilteredResponseAtIndex: (int) idx {
    return (filteredResponses_ != nil) && (idx < [filteredResponses_ count]) ? [filteredResponses_ objectAtIndex:(NSUInteger) idx] :nil;
}

- (WSResponse*) getResponseAtIndex: (int) idx {
    return (responses_ != nil) && (idx < [responses_ count]) ? [responses_ objectAtIndex:(NSUInteger) idx] :nil;
}

- (int) responseCount {
	if (responses_ != nil)
		return [responses_ count];
	else
		return 0;
}

- (int) filteredResponseCount {
	return (filteredResponses_ == nil) ? 0 : [filteredResponses_ count];
}

-(int)responsesCount {
    return (responses_ == nil) ? 0 : [responses_ count];
}

- (bool) isScroll {
	return ((scroll_ != nil) && ([scroll_ caseInsensitiveCompare: @"YES"] == 0));
}

-(bool)hasVasResponse {
    for (WSResponse* response in responses_) {
   		if ([response isVasResponse])
   			return YES;
   	}
   
   	return NO;
}

-(bool)hasValueListResponse {
    for (WSResponse* response in responses_) {
        if ([response isResponseFormatValueList])
            return YES;
    }

    return NO;
}

-(bool)isHolon {
    return (actor_ != nil);
}

- (int) selectedResponsesCount {
	return (selectedResponses_ != nil) ? [selectedResponses_ count] : 0;
}

- (void) clearSelectedResponses {
	if (selectedResponses_ != nil)
		[selectedResponses_ removeAllObjects];
}

- (void) addResponse:(WSResponse*) response {
    if (response != nil) {
        if (responses_ == nil)
            responses_ = [[NSMutableArray alloc] initWithCapacity:5];

        [responses_ addObject:response];
    }
}

- (void) addFilteredResponse:(WSResponse*) response {
    if (response != nil) {
        if (filteredResponses_ == nil)
            filteredResponses_ = [[NSMutableArray alloc] initWithCapacity:5];

        [filteredResponses_ addObject:response];
    }
}

- (void) addSelectedResponse: (WSResponse*) response {
	if (response != nil) {
		if (selectedResponses_ == nil)
			selectedResponses_ = [NSMutableArray arrayWithCapacity: 1];

		[selectedResponses_ addObject: response];
	}
}

-(void)addMember:(WSInteractionHIL*)interactionHIL {
    if (interactionHIL != nil) {
        if (members_ == nil)
            members_ = [NSMutableArray arrayWithCapacity: 1];

        [members_ addObject: interactionHIL];
    }
}

-(int)memberCount {
    return (members_ != nil) ? [members_ count] : 0;
}

-(int) goalActivationCount {
    return (goalActivation_ != nil) ? [goalActivation_ count] : 0;
}

-(int) taskActivationCount {
    return (taskActivation_ != nil) ? [taskActivation_ count] : 0;
}

@end