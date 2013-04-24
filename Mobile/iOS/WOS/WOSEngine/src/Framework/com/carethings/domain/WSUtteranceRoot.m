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

#import "WSUtteranceRoot.h"
#import "WSSchedule.h"
#import "WSStringUtils.h"
#import "WSScheduleEvent.h"

@implementation WSUtteranceRoot

@synthesize schedule = schedule_;
@synthesize scheduleEvent = scheduleEvent_;
@synthesize controlImage = controlImage_;
@synthesize controlType = controlType_;
@synthesize controlHeight = controlHeight_;
@synthesize controlWidth = controlWidth_;
@synthesize controlItem = controlItem_;
@synthesize controlFontSize = controlFontSize_;
@synthesize controlFontColor = controlFontColor_;
@synthesize controlFontName = controlFontName_;
@synthesize controlTouchX = controlTouchX_;
@synthesize controlTouchY = controlTouchY_;
@synthesize controlTouchWidth = controlTouchWidth_;
@synthesize controlTouchHeight = controlTouchHeight_;
@synthesize skipTo = skipTo_;
@synthesize skipToIntervention = skipToIntervention_;
@synthesize attractor = attractor_;
@synthesize systemSkipTo = systemSkipTo_;
@synthesize skipCondition = skipCondition_;
@synthesize activeCondition = activeCondition_;
@synthesize activeConditionLangType = activeConditionLangType_;
@synthesize behaviorUserApp = behaviorUserApp_;
@synthesize behaviorUserComponent = behaviorUserComponent_;
@synthesize behaviorUserForm = behaviorUserForm_;
@synthesize behaviorUserItem = behaviorUserItem_;
@synthesize directiveInstruction = directiveInstruction_;
@synthesize directiveInstructionResource = directiveInstructionResource_;
@synthesize directiveImage = directiveImage_;
@synthesize directive = directive_;
@synthesize worldModel = worldModel_;
@synthesize preBehavior = preBehavior_;
@synthesize behavior = behavior_;
@synthesize postBehavior = postBehavior_;
@synthesize userID = userID_;
@synthesize systemID = systemID_;
@synthesize instanceID = instanceID_;
@synthesize ontology = ontology_;
@synthesize shortTermMemory = shortTermMemory_;
@synthesize longTermMemory = longTermMemory_;
@synthesize rtcDwell = rtcDwell_;
@synthesize rtcDelay = rtcDelay_;
@synthesize rtcSpeed = rtcSpeed_;
@synthesize rtc1 = rtc1_;
@synthesize rtc2 = rtc2_;
@synthesize userValue1 = userValue1_;
@synthesize userValue2 = userValue2_;
@synthesize userValue3 = userValue3_;

- (void) causeScheduleEvent: (Study*) study {
	if ((schedule_ != nil) && (study != nil)) {
		[schedule_ causeScheduleEvent: study andID:[self.systemID fragment]];
	}
}

- (int) isActiveInStudy: (Study*) study {
	if ((schedule_ != nil) && (study != nil) && (![schedule_ isActiveWithStudy: study andID:[self.systemID fragment]])) {
		return false;
	}

	return true;
}

-(void)addBehaviorWithURL:(NSURL*)behavior {
    if (behavior == nil) {
        return;
    }

    if (behavior_ == nil) {
        behavior_ = [[NSMutableArray alloc] initWithCapacity:10];
    }

    [behavior_ addObject:behavior];

}

-(void)addBehavior:(NSString*)behavior {
    if ([WSStringUtils isEmpty:behavior]) {
        return;
    }

    NSURL* url = [NSURL URLWithString:behavior];

    [self addBehaviorWithURL:url];
}

-(void)addPreBehaviorWithURL:(NSURL*)behavior {
    if (behavior == nil) {
        return;
    }

    if (preBehavior_ == nil) {
        preBehavior_ = [[NSMutableArray alloc] initWithCapacity:10];
    }

    [preBehavior_ addObject:behavior];
}

-(void)addPreBehavior:(NSString*)behavior {
    if ([WSStringUtils isEmpty:behavior]) {
        return;
    }

    NSURL* url = [NSURL URLWithString:behavior];

    [self addPreBehaviorWithURL:url];
}

-(void)addPostBehaviorWithURL:(NSURL*)behavior {
    if (behavior == nil) {
        return;
    }

    if (postBehavior_ == nil) {
        postBehavior_ = [[NSMutableArray alloc] initWithCapacity:10];
    }

    [postBehavior_ addObject:behavior];
}

-(void)addPostBehavior:(NSString*)behavior {
    if ([WSStringUtils isEmpty:behavior]) {
        return;
    }

    NSURL* url = [NSURL URLWithString:behavior];

    [self addPostBehaviorWithURL:url];
}

-(BOOL)isEqual:(WSUtteranceRoot*)utterance {
    if (utterance == nil)
        return false;

    if ((utterance.systemID != nil) && (systemID_ != nil)) {
        NSString* utteranceSysID = [utterance.systemID absoluteString];
        NSString* sysID          = [systemID_ absoluteString];

        return (NSOrderedSame == [WSStringUtils caseInsensitiveCompare:utteranceSysID toString:sysID]) ? true : false;
    }

    if ((utterance.userID != nil) && (userID_ != nil)) {
        NSString* utteranceUserID = [utterance.userID absoluteString];
        NSString* userID          = [userID_ absoluteString];

        return (NSOrderedSame == [WSStringUtils caseInsensitiveCompare:utteranceUserID toString:userID]) ? true : false;
    }

    return false;
}

@end