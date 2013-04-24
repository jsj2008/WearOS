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


#import "WSDataDistributionCommon.h"
#import "WOSCore/OpenPATHCore.h"

@protocol WSPersistenceModel;
@protocol WSDataChannel;
@class    Security;
@class    Social;


@interface WSDataDistributionManager : NSObject {
	id <WSPersistenceModel>          persistenceDelegate_;
	id <WSDataChannel>               dataChannelDelegate_;
	WSDistributionOptions            options_;
    Security*                        security_;
    Social*                          social_;
}

@property (nonatomic) id <WSPersistenceModel> persistenceDelegate;
@property (nonatomic) id <WSDataChannel> dataChannelDelegate;
@property (nonatomic) WSDistributionOptions options;
@property (nonatomic) Social* social;
@property (nonatomic) Security* security;

-(id)initWithPersistenceModel:(id <WSPersistenceModel>)persistenceModel andChannel:(id <WSDataChannel>)channel andOptions:(uint32_t)options withSecurity:(Security*)security withSocial:(Social*)social;
-(void)login;
-(bool)isLoggedIn;
-(NSData*)sendData:(NSData*)data withOptions : (WSChannelOptions) options didFailWithError : (NSError**)error;
-(NSData*)retrieveDataWithOptions:(NSData*)data withOptions : (WSChannelOptions) options didFailWithError : (NSError**)error;
-(NSString*)retrieveParticipantIdForParticipant:(NSString*)participant withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSString*)retrieveParticipantNameForParticipant:(NSString*)participant withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(void)retrieveTasksForParticipant:(NSString *)participantId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error;
-(void)retrieveGoalsForParticipant:(NSString*)participantId withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSArray*)retrieveFeedForGroup:(NSString *)group withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSArray*)retrieveFeedForPrivateGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSArray*)retrieveFeedForPublicGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSData*)sendText:(NSString*)msg toGroup:(NSString*)group WithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSData*)sendText:(NSString*)msg toPrivateGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;
-(NSData*)sendText:(NSString*)msg toPublicGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error;


@end