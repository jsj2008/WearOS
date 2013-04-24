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

#import "WSMailDataChannel.h"
#import "NSData+Base64Additions.h"
#import "WSDataChannelCommon.h"


@implementation WSMailDataChannel

@synthesize subject = subject_;
@synthesize body = body_;
@synthesize message = message_;
@synthesize attachmentName = attachmentName_;
@synthesize emailAddress = emailAddress_;


-(void)loginWithUsername : (NSString*)username password:(NSString*)password token:(NSString*)token target:(id)target selector:(SEL)selector {
}

-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

- (void) sendData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	message_ = [SKPSMTPMessage new];

	message_.fromEmail              = @"wstack@carethings.com";
	message_.toEmail                = emailAddress_;
	message_.relayHost              = @"smtp.comcast.net";
	message_.requiresAuth   = YES;
	message_.login                  = @"lsuarez";
	message_.pass                   = @"carethings.com";
	message_.subject                = subject_;
	message_.wantsSecure    = YES; // smtp.gmail.com doesn't work without TLS!

	// Only do this for self-signed certs!
	// testMsg.validateSSLChain = NO;
	message_.delegate = self;

	NSDictionary*   plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
	                             @"text/plain", kSKPSMTPPartContentTypeKey,
	                             body_,                 kSKPSMTPPartMessageKey,
	                             @"8bit",                       kSKPSMTPPartContentTransferEncodingKey,
	                             nil];
	NSString*        attachFileName  = [[NSString alloc] initWithFormat: @"attachment;\r\n\tfilename=\"%@\"", attachmentName_];
	NSString*        contentType     = [[NSString alloc] initWithFormat: @"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"", attachmentName_];
	NSDictionary*    vcfPart         = [NSDictionary dictionaryWithObjectsAndKeys:
	                           contentType,                kSKPSMTPPartContentTypeKey,
	                           attachFileName,             kSKPSMTPPartContentDispositionKey,
	                           [data encodeBase64ForData], kSKPSMTPPartMessageKey,
	                           @"base64",                  kSKPSMTPPartContentTransferEncodingKey,
	                           nil];

	message_.parts = [NSArray arrayWithObjects: plainPart, vcfPart, nil];

	[self performSelectorOnMainThread: @selector(sendMessage) withObject: nil waitUntilDone: false];
}

- (void) sendMessage {
	[message_ send];
}

- (void) messageSent: (SKPSMTPMessage*) message {
	NSLog(@"delegate - message sent");
}

- (void) messageFailed: (SKPSMTPMessage*) message error: (NSError*) error {
	NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}

- (NSData*) retrieveDataWithOptions: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	return nil;
}

@end