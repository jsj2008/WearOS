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

#import "WSProtocolModel.h"
#import "WSInteractionHIL.h"

@class Study;
@class GDataXMLElement;
@class BiArrayEnumerator;
@protocol WSProtocolHistoryManager;
@class GDataXMLDocument;

extern NSString* const RESPONSE_TYPE_FREE;                      // The response consists of a multi-line text field.
extern NSString* const RESPONSE_TYPE_FREE_FIXED;                // The response consists of a single line text field.
extern NSString* const RESPONSE_TYPE_DIRECTIVE;                 // The response is indicating a directive.
extern NSString* const RESPONSE_TYPE_FIXED;                     // The response consists of a select control such as a checkbox or radio button
extern NSString* const RESPONSE_TYPE_FIXED_NEXT;                // The response consists of a select control and executes a NEXT after selection.
extern NSString* const RESPONSE_TYPE_FIXED_ASK;                 // The response consists of a select control and processes the response (executes behaviors) but remains on the current interaction.
extern NSString* const RESPONSE_TYPE_GOAL;                      // The response represents a goal until the actual goal system is introduced.
extern NSString* const RESPONSE_TYPE_VAS;                       // The response consists of a visual analog scale.
extern NSString* const RESPONSE_TYPE_DVAS;                      // The response consists of a digital visual analog scale.
extern NSString* const RESPONSE_TYPE_REWARD;
extern NSString* const RESPONSE_TYPE_CAMERA;
extern NSString* const RESPONSE_TYPE_VIDEO;
extern NSString* const RESPONSE_TYPE_SENSOR;
extern NSString* const RESPONSE_TYPE_VISUAL;
extern NSString* const RESPONSE_TYPE_WEBVIEW;
extern NSString* const RESPONSE_TYPE_OCR;
extern NSString* const RESPONSE_TYPE_SCAN;
extern NSString* const RESPONSE_TYPE_COLLECTION;

extern NSString* const NAV_EXIT_ONLY;                           // You can only exit the conversation
extern NSString* const NAV_HOME_ONLY;                           // You can only restart the conversation (go home).
extern NSString* const NAV_NEXT_ONLY;                           // You can only move forward with a conversation.
extern NSString* const NAV_PREV_ONLY;                           // You can only re-live parts of the conversation.
extern NSString* const NAV_NONE;                                // No way to move away from the conversation.
extern NSString* const NAV_SEND;                                // Send transcript of the conversation.
extern NSString* const NAV_SCROLL_DOWN;
extern NSString* const NAV_NEW_ONLY;

extern NSString* const INTERACTION_EXEC_MODE_SEQUENTIAL;
extern NSString* const INTERACTION_EXEC_MODE_PARALLEL;
extern NSString* const INTERACTION_EXEC_MODE_DATAFLOW;
extern NSString* const INTERACTION_EXEC_MODE_USER;

extern NSString* const TYPE_INTERROGATIVE_MULTISELECT;          // Interaction that supports multiple responses from a list of possible responses.
extern NSString* const TYPE_INTERROGATIVE_SINGLESELECT;         // Interaction that supports a single response from a list of possible responses.
extern NSString* const TYPE_INTERROGATIVE_UNSTRUCTURED;         // Interaction that supports an unstructured (text-based) response.
extern NSString* const TYPE_IMPERATIVE;                         // Interaction represents a command to the receiver.
extern NSString* const TYPE_GOAL;                               // Interaction represents a goal to achieve.
extern NSString* const TYPE_DECLARATIVE;                        // Interaction represents a statement of fact or truth.
extern NSString* const INTERACTION_TYPE_RESPONSE;
extern NSString* const INTERACTION_TYPE_PATTERN_OF_BEHAVIOR;
extern NSString* const INTERACTION_TYPE_TASK;
extern NSString* const INTERACTION_TYPE_REWARD;
extern NSString* const INTERACTION_TYPE_COLLECTION;

extern NSString* const RESP_FORMAT_NUMERIC;
extern NSString* const RESP_FORMAT_DATE;
extern NSString* const RESPONSE_FORMAT_ALPHA;
extern NSString* const RESPONSE_FORMAT_DATETIME;
extern NSString* const RESPONSE_FORMAT_VALUE_LIST;
extern NSString* const RESPONSE_FORMAT_DATA_LIST;
extern NSString* const RESPONSE_FORMAT_MONETARY;
extern NSString* const RESPONSE_FORMAT_PHONE;

extern NSString* const DECISIONPOINT_TYPE_AND_SPLIT;
extern NSString* const DECISIONPOINT_TYPE_OR_SPLIT;
extern NSString* const DECISIONPOINT_TYPE_AND_MERGE;
extern NSString* const DECISIONPOINT_TYPE_OR_MERGE;
extern NSString* const DECISIONPOINT_TYPE_XOR_MERGE;


@interface WSUCSFProtocolModel : NSObject <WSProtocolModel> {
	Study*							study_;
    GDataXMLDocument*               doc_;
	GDataXMLElement*				rootProtocolElement_;
	BiArrayEnumerator*				interventionsEnum_;
    BiArrayEnumerator*              goalsEnum_;
    BiArrayEnumerator*              tasksEnum_;
    BiArrayEnumerator*              rewardsEnum_;
	BiArrayEnumerator*				responsesEnum_;
	BiArrayEnumerator*				interactionsEnum_;
	NSString*						protocolXml_;
	NSString*						protocolFileName_;
	NSArray*						interventions_;
    NSArray*                        goals_;
    NSArray*                        tasks_;
    NSArray*                        rewards_;
	id <WSProtocolHistoryManager>	historyManager_;
}

@property (nonatomic) GDataXMLElement* rootProtocolElement;
@property (nonatomic) BiArrayEnumerator* interventionsEnum;
@property (nonatomic) BiArrayEnumerator* responsesEnum;
@property (nonatomic) BiArrayEnumerator* interactionsEnum;
@property (nonatomic) BiArrayEnumerator* goalsEnum;
@property (nonatomic, copy) NSString* protocolXml;
@property (nonatomic, copy) NSString* protocolFileName;
@property (nonatomic) NSArray* interventions;
@property (nonatomic) NSArray* goals;
@property (nonatomic) NSArray* tasks;
@property (nonatomic) NSArray* rewards;
@property (nonatomic) Study* study;
@property (nonatomic) id <WSProtocolHistoryManager> historyManager;

-(void)initializeModel;
-(id)initWithProtocol : (NSString*)careXML andHistoryManager : (id <WSProtocolHistoryManager>)historyManager;
-(WSInteractionHIL*)lastInteractionFromProtocolHistory : (WSInterventionHIL*)intervention;
- (WSInterventionHIL*) decodeInterventionwithXML: (GDataXMLElement*) xml;
- (WSInteractionHIL*) decodeInteractionHILwithXML: (GDataXMLElement*) xml;
- (WSResponse*) decodeResponseWithXML: (GDataXMLElement*) xml;
- (WSResponse*) decodeResponseWithXML: (GDataXMLElement*) xml andResponse:(WSResponse*)response;
- (InteractionHILNavigation) interactionNavigationFromValue: (NSString*) value;

@end