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

#import "WSInteraction.h"

@class  WSSchedule;
@class  GDataXMLNode;
@class  WSUtteranceRoot;
@class  WSResponse;
@class WSActor;

// Indicates how to navigate away from an interaction using HIL resource
typedef enum {
		InteractionHILNavUnknown,   // Default value of 0
		InteractionHILNavExitOnly,  // You can only exit the conversation
		InteractionHILNavHomeOnly,  // You can only restart the conversation or go back (go home).
		InteractionHILNavNextOnly,  // You can only move forward with a conversation.
		InteractionHILNavPrevOnly,  // You can only re-live parts of the conversation.
		InteractionHILNavHomeNext,  // You can only go home or move forward in the conversation.
		InteractionHILNavNone,      // No way to move away from the conversation.
		InteractionHILNavSend,      // Send transcript of the conversation.
		InteractionHILScrollDown,   // Scrolling required.
        InteractionHILNavNewOnly    // New object
} InteractionHILNavigation;


/*! @class Test
 *  @brief A short description.
 *
 *  More text.
 */
@interface WSInteractionHIL : WSInteraction <NSCopying> {
		InteractionHILNavigation	navigation_;          // Indicates how to navigate away from this interaction.
        NSMutableArray*             members_;             // member interactions (micro steps) for this collection.
		NSMutableArray*				responses_;           // List of expected responses.
		NSMutableArray*				filteredResponses_;   // List of filtered responses.  Subset of the "responses" field.
		NSMutableArray*				selectedResponses_;   // If a list of expected responses are provided, pointer to the selected response.
		NSString*					text_;                // Interaction text (the utterance).
		NSURL*						textResource_;        // Resource URL of the text if applicable.
		NSURL*						audioResource_;		  // Resource URL of the audio if applicable.
		NSString*					textHeight_;          // Rendering-hint.  Suggested height of the text to display.
		NSString*					scroll_;              //
		bool						responseRequired_;    // Indicates that a response is required in order to navigate away from this interaction.
		int							enumIndex_;           // Internal value specifying the current interaction within the intervention.
        WSActor*                    actor_;               // Characteristics of the actor (agent) executing this utterance.
        NSMutableArray*             goalActivation_;      // Facts required to activate the goals for this interaction.
        NSMutableArray*             taskActivation_;      // Facts required to activate the tasks for this interaction.
        NSString*                   groupName_;           // Group name for grouping interactions (for example, for matrix questions)
}

@property (nonatomic) InteractionHILNavigation  navigation;
@property (nonatomic) NSMutableArray* responses;
@property (nonatomic) NSMutableArray* filteredResponses;
@property (nonatomic, copy) NSString* text;
@property (nonatomic) NSURL* textResource;
@property (nonatomic, copy) NSString* textHeight;
@property (nonatomic, copy) NSString* scroll;
@property (nonatomic) bool responseRequired;
@property (nonatomic) int enumIndex;
@property (nonatomic) NSMutableArray*   selectedResponses;
@property (nonatomic) NSURL* audioResource;
@property (nonatomic) WSActor* actor;
@property (nonatomic) NSMutableArray* goalActivation;
@property (nonatomic) NSMutableArray* taskActivation;
@property (nonatomic, copy) NSString* groupName;
@property (nonatomic) NSMutableArray* members;

-(bool)hasSelectedResponses;
-(bool)hasNoSelectedResponses;
-(bool)isResponseRequired;
-(WSResponse*)getFilteredResponseAtIndex : (int)idx;
-(WSResponse*)getSelectedResponse;
-(WSResponse*)getResponseAtIndex: (int) idx;
-(void)addResponse:(WSResponse*) response;
-(void)addMember:(WSInteractionHIL*)interactionHIL;
-(int)memberCount;
-(void)addFilteredResponse:(WSResponse*) response;
-(void)addSelectedResponse: (WSResponse*) response;
-(int)filteredResponseCount;
-(int)responsesCount;
-(bool)hasVasResponse;
-(bool)hasValueListResponse;
-(bool)isScroll;
-(bool)isHolon;
-(id)copyWithZone:(NSZone*)zone;
-(int) goalActivationCount;
-(int) taskActivationCount;

@end