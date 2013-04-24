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
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation 
 *         and/or other materials provided with the distribution.
 *	3. Neither the name of CareThings nor the names of its contributors may be used to endorse or promote products derived from this software without specific 
 *         prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "WSChatterDataChannel.h"


@implementation WSChatterDataChannel

- (void)loginWithUsername:(NSString *)username password:(NSString *)password token:(NSString *)token clientIdentifier:(NSString *)clientIdentifier clientSecret:(NSString *)clientSecret {

}

- (bool)isLoggedIn {
    return 0;
}

- (NSString *)retrieveParticipantIdForParticipant:(NSString *)participant withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    return nil;
}

- (NSString *)retrieveParticipantNameForParticipant:(NSString *)partId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    return nil;
}

- (void)retrieveTasksForParticipant:(NSString *)participantId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {

}

- (void)retrieveGoalsForParticipant:(NSString *)participantId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {

}

- (NSArray *)retrieveFeedForGroup:(NSString *)group withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    return nil;
}

- (NSData *)sendText:(NSString *)msg toGroup:(NSString *)group withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    return nil;
}

- (void) sendData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
}

- (NSData*) retrieveDataWithOptions: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	return nil;
}

-(void)loginWithUsername:(NSString*)username password:(NSString*)password token:(NSString*)token target:(id)target selector:(SEL)selector {
}

-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

@end