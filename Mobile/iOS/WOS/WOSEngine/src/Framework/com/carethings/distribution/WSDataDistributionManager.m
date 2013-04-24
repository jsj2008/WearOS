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

#import "WSDataDistributionManager.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSDataDistributionManager

@synthesize persistenceDelegate = persistenceDelegate_;
@synthesize dataChannelDelegate = dataChannelDelegate_;
@synthesize options = options_;
@synthesize social = social_;
@synthesize security = security_;

-(id)initWithPersistenceModel:(id <WSPersistenceModel>)persistenceModel andChannel:(id <WSDataChannel>)channel andOptions:(uint32_t)options withSecurity:(Security*)security withSocial:(Social*)social {
	self = [super init];

	if (self) {
		persistenceDelegate_    = persistenceModel;
		dataChannelDelegate_    = channel;
		options_                = options;
        security_               = security;
        social_                 = social;
	}

	return self;
}

- (NSData *) sendData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	if (dataChannelDelegate_ != nil) {
		[dataChannelDelegate_ sendData: data withOptions: options didFailWithError: error];
	} else   {
		if (error != nil)
			*error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];
	}

    return nil;
}

- (NSData*) retrieveDataWithOptions: (NSData*) data withOptions: (WSDistributionOptions) options didFailWithError: (NSError * *) error {
	if (dataChannelDelegate_ != nil)
		return [dataChannelDelegate_ retrieveDataWithOptions: data withOptions: options didFailWithError: error];

	if (error != nil)
		*error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

	return nil;
}

-(void)login {
    if ((dataChannelDelegate_ != nil) && (security_ != nil))
        [dataChannelDelegate_ loginWithUsername:security_.userName password:security_.password token:security_.securityToken clientIdentifier:security_.clientIdentifier clientSecret:security_.clientSecretKey];
}

-(bool)isLoggedIn {
    if (dataChannelDelegate_ != nil) {
        return [dataChannelDelegate_ isLoggedIn];
    } else{
        return false;
    }
}

-(NSString*)retrieveParticipantIdForParticipant:(NSString*)participant withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveParticipantIdForParticipant:participant withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(NSString*)retrieveParticipantNameForParticipant:(NSString*)participant withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveParticipantNameForParticipant:participant withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(void)retrieveTasksForParticipant:(NSString *)participantId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveTasksForParticipant:participantId withOptions:options didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];
}

-(void)retrieveGoalsForParticipant:(NSString*)participantId withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveGoalsForParticipant:participantId withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];
}

-(NSArray*)retrieveFeedForGroup:(NSString *)group withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveFeedForGroup:group withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(NSArray*)retrieveFeedForPrivateGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveFeedForGroup:social_.privateGroup withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(NSArray*)retrieveFeedForPublicGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ retrieveFeedForGroup:social_.publicGroup withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(NSData*)sendText:(NSString*)msg toGroup:(NSString*)group WithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ sendText:msg toGroup:group withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}


-(NSData*)sendText:(NSString*)msg toPrivateGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ sendText:msg toGroup:social_.privateGroup withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

-(NSData*)sendText:(NSString*)msg toPublicGroupWithOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    if (dataChannelDelegate_ != nil)
        return [dataChannelDelegate_ sendText:msg toGroup:social_.publicGroup withOptions:options  didFailWithError:error];

    if (error != nil)
        *error = [NSError errorWithDomain: @"No data channel" code: 0 userInfo: nil];

    return nil;
}

@end