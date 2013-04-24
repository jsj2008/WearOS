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

@class WSInterventionHIL;
@class WSInteractionHIL;
@class WSResponse;
@class WSIntervention;

FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_FREE;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_FREE_FIXED;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_DIRECTIVE;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_FIXED;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_FIXED_NEXT;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_FIXED_ASK;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_GOAL;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_VAS;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_DVAS;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_CAMERA;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_VIDEO;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_SENSOR;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_VISUAL;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_WEBVIEW;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_OCR;
FOUNDATION_EXPORT NSString* const RESPONSE_TYPE_SCAN;

FOUNDATION_EXPORT NSString* const NAV_EXIT_ONLY;
FOUNDATION_EXPORT NSString* const NAV_HOME_ONLY;
FOUNDATION_EXPORT NSString* const NAV_NEXT_ONLY;
FOUNDATION_EXPORT NSString* const NAV_PREV_ONLY;
FOUNDATION_EXPORT NSString* const NAV_NONE;
FOUNDATION_EXPORT NSString* const NAV_SEND;
FOUNDATION_EXPORT NSString* const NAV_SCROLL_DOWN;

FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_RESPONSE;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_PATTERN_OF_BEHAVIOR;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_MULTISELECT;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_SINGLESELECT;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_UNSTRUCTURED;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_IMPERATIVE;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_GOAL;
FOUNDATION_EXPORT NSString* const INTERACTION_TYPE_DECLARATIVE;

FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_NUMERIC;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_ALPHA;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_DATE;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_DATETIME;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_VALUE_LIST;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_DATA_LIST;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_MONETARY;
FOUNDATION_EXPORT NSString* const RESPONSE_FORMAT_PHONE;

FOUNDATION_EXPORT NSString* const DECISIONPOINT_TYPE_AND_SPLIT;
FOUNDATION_EXPORT NSString* const DECISIONPOINT_TYPE_OR_SPLIT;
FOUNDATION_EXPORT NSString* const DECISIONPOINT_TYPE_AND_MERGE;
FOUNDATION_EXPORT NSString* const DECISIONPOINT_TYPE_OR_MERGE;
FOUNDATION_EXPORT NSString* const DECISIONPOINT_TYPE_XOR_MERGE;


@protocol WSProtocolModel

-(void)initializeModel;
-(void)setProtocolFileName:(NSString*)fileName;

-(void)interventionIteratorBegin;
-(WSIntervention *)nextIntervention;

-(void)interactionIteratorBeginFromIntervention : (WSInterventionHIL*)intervention;
-(WSInteractionHIL*)nextInteractionFromIntervention : (WSInterventionHIL*)intervention;
-(WSInteractionHIL*)interactionWithSystemID:(NSString*)sysId;
-(WSInteractionHIL*)previousInteractionFromIntervention : (WSInterventionHIL*)intervention;
-(int)currentInteractionIndex;

-(NSArray*)queryGoals;
-(NSArray*)queryTasks;
-(NSArray*)queryRewards;
-(NSArray*)queryInterventions;

-(void)responseIteratorBeginFromInteraction : (WSInteractionHIL*)interaction;
-(WSResponse*)nextResponseFromInteraction : (WSInteractionHIL*)interaction;
-(void)tellHistory : (WSInterventionHIL*)intervention;
-(void)clearHistory;
-(void)clearHistoryByContent : (WSInterventionHIL*)intervention;
-(void)setupHistoryByContent : (WSInterventionHIL*)intervention;

@end