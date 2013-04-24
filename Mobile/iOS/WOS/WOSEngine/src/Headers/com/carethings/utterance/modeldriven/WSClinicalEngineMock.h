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

#import "WSUtteranceEngine.h"
#import "WSModelDrivenEngine.h"
#import "WSStopWatch.h"

@class WSInteractionHIL;
@class WSInterventionHIL;
@class WSResponse;
@class WSDBPersistenceModel;
@protocol WSWorldModel;
@protocol WSProtocolModel;
@class WSUtteranceRoot;

typedef uint32_t WSEngineOptions;


@interface WSClinicalEngineMock : NSObject <WSUtteranceEngine, WSModelDrivenEngine>

-(id)initWithWorldModel : (id <WSWorldModel>) worldModel andProtocolModel : (id <WSProtocolModel>)protocol andPersistenceModel : (id <WSPersistenceModel>)persistenceModel withOptions:(__unused WSEngineOptions)options;
-(id)initWithProtocol :(NSString*)protocol andPersistenceModel : (id <WSPersistenceModel>)persistenceModel withOptions:(__unused WSEngineOptions)options;
-(id)initWithRedCapProtocol :(NSString*)protocol andPersistenceModel : (id <WSPersistenceModel>)persistenceModel withOptions:(__unused WSEngineOptions)options;
-(bool)processInteractions;
-(void)setProtocolFileName:(NSString*)fileName;
-(void)reset;
-(void)setUserDelegate:(id)userDelegate;
-(void)setUserSecondaryDelegate:(id)userDelegate;
-(WSIntervention *)getCurrentIntervention;
-(WSInteractionHIL*)getCurrentInteraction;
-(void)setCurrentResponse:(WSResponse*)response;
-(WSResponse*)getCurrentResponse;
-(void) confirmWithContent: (WSInteraction*) interaction;
-(void) disconfirmWithContent: (WSInteraction*) interaction;
-(void) confirmWithTriple: (WSModelTriple*) triple;
-(void) disconfirmWithTriple: (WSModelTriple*) triple;
-(NSData*) tellAllWithOptions: (WSPersistenceOptions) options;
-(NSData*) tellWithContent: (WSUtteranceRoot*) root andOptions: (WSPersistenceOptions) options;
-(NSData*) tellWithContent: (WSUtteranceRoot*) root andResponse: (WSResponse*) response;

@end