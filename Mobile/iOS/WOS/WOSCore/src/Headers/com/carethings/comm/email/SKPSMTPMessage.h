//
//  SKPSMTPMessage.h
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <CFNetwork/CFNetwork.h>

enum
{
	kSKPSMTPIdle = 0,
	kSKPSMTPConnecting,
	kSKPSMTPWaitingEHLOReply,
	kSKPSMTPWaitingTLSReply,
	kSKPSMTPWaitingLOGINUsernameReply,
	kSKPSMTPWaitingLOGINPasswordReply,
	kSKPSMTPWaitingAuthSuccess,
	kSKPSMTPWaitingFromReply,
	kSKPSMTPWaitingToReply,
	kSKPSMTPWaitingForEnterMail,
	kSKPSMTPWaitingSendSuccess,
	kSKPSMTPWaitingQuitReply,
	kSKPSMTPMessageSent
};
typedef NSUInteger SKPSMTPState;

// Message part keys
extern NSString* kSKPSMTPPartContentDispositionKey;
extern NSString* kSKPSMTPPartContentTypeKey;
extern NSString* kSKPSMTPPartMessageKey;
extern NSString* kSKPSMTPPartContentTransferEncodingKey;

// Error message codes
static const int kSKPSMPTErrorConnectionTimeout       = -5;
static const int kSKPSMTPErrorConnectionFailed        = -3;
static const int kSKPSMTPErrorConnectionInterrupted   = -4;
static const int kSKPSMTPErrorUnsupportedLogin        = -2;
static const int kSKPSMTPErrorTLSFail                 = -1;
static const int kSKPSMTPErrorInvalidUserPass         = 535;
static const int kSKPSMTPErrorInvalidMessage          = 550;
static const int kSKPSMTPErrorNoRelay                 = 530;

@class SKPSMTPMessage;

@protocol SKPSMTPMessageDelegate
@required

- (void)messageSent : (SKPSMTPMessage*)message;
-(void)messageFailed : (SKPSMTPMessage*)message error : (NSError*)error;

@end

@interface SKPSMTPMessage : NSObject <NSCopying, NSStreamDelegate> {
	NSString* login;
	NSString* pass;
	NSString* relayHost;
	NSArray* relayPorts;

	NSString* subject;
	NSString* fromEmail;
	NSString* toEmail;
	NSString* ccEmail;
	NSString* bccEmail;
	NSArray* parts;

	NSOutputStream* outputStream;
	NSInputStream* inputStream;

	BOOL requiresAuth;
	BOOL wantsSecure;
	BOOL validateSSLChain;

	SKPSMTPState sendState;
	BOOL isSecure;
	NSMutableString* inputString;

	// Auth support flags
	BOOL serverAuthCRAMMD5;
	BOOL serverAuthPLAIN;
	BOOL serverAuthLOGIN;
	BOOL serverAuthDIGESTMD5;

	// Content support flags
	BOOL server8bitMessages;

	id <SKPSMTPMessageDelegate> delegate;

	NSTimeInterval connectTimeout;

	NSTimer* connectTimer;
	NSTimer* watchdogTimer;
}

@property (nonatomic, copy) NSString* login;
@property (nonatomic, copy) NSString* pass;
@property (nonatomic, copy) NSString* relayHost;

@property (nonatomic) NSOutputStream* outputStream;
@property (nonatomic) NSInputStream* inputStream;

@property (nonatomic) NSArray* relayPorts;
@property (nonatomic) BOOL requiresAuth;
@property (nonatomic) BOOL wantsSecure;
@property (nonatomic) BOOL validateSSLChain;

@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* fromEmail;
@property (nonatomic, copy) NSString* toEmail;
@property (nonatomic, copy) NSString* ccEmail;
@property (nonatomic, copy) NSString* bccEmail;
@property (nonatomic) NSArray* parts;

@property (nonatomic) NSTimeInterval connectTimeout;

@property (nonatomic) id <SKPSMTPMessageDelegate> delegate;

-(BOOL)send;
-(void)messageSent : (__unused SKPSMTPMessage*)message;
-(void)messageFailed : (__unused SKPSMTPMessage*)message error : (NSError*)error;
-(id)init;

@end