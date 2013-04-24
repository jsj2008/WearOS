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

#import "WSFTPDataChannel.h"
#import "NSData+Encryption.h"
#import "StringUtils.h"
#import "WSDataChannelCommon.h"
#import "CoreUtils.h"

// ChilKat imports
#import "CkoSFtp.h"
#import "CkoSshKey.h"


@implementation WSFTPDataChannel

@synthesize pemFileName = pemFileName_;


- (id)initWithHost:(NSString *)host andPort:(int)port withDirectory:(NSString*)fileDir andFileName:(NSString*)fileName {
    self = [super init];

    if (self) {
        port_ = port;
        host_ = host;
        fileName_ = fileName;
		fileDirectory_ = fileDir;
    }

    return self;
}

- (id)initWithHost :(NSString *)host andPort :(int)port {
    self = [super init];
	
    if (self) {
        port_ = port;
        host_ = host;
		fileName_ = nil;
		fileDirectory_ = nil;
    }
	
    return self;
}

- (void)setEncryptionKey:(void*)key {
	//  Better be null terminated.
	if (strlen(key) > 32)
		return;
	
	strncpy(keyBytes_, key, 33); 
}

- (void)logIntoFtpServerDidFailWithError:(NSError **)error {
    //  Important: It is helpful to send the contents of the
    //  sftp.LastErrorText property when requesting support.
    sftp_ = [CkoSFtp new];

    if ([sftp_ UnlockComponent:@"LARRYSSSH_rqX3dJ665OyG"] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to unlock the FTP software" code:0 userInfo:nil];

        return;
    }

    //  Set some timeouts, in milliseconds:
    sftp_.ConnectTimeoutMs = [NSNumber numberWithInt:5000];
    sftp_.IdleTimeoutMs = [NSNumber numberWithInt:10000];

    if ([sftp_ Connect:host_ port:[NSNumber numberWithInt:port_]] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to connect to the FTP server" code:0 userInfo:nil];

        return;
    }
	
	CkoSshKey*	key = [CkoSshKey new];
	NSString*	privKey;
	
	NSBundle* bundle = [NSBundle mainBundle];
    NSString* path   = [bundle pathForResource:pemFileName_ ofType:@"pem"];
	
	privKey = [key LoadText: path];
	
	if (privKey == nil ) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to extract the contents of the PEM file" code:0 userInfo:nil];
		
		return;
	}
	
	if ([key FromOpenSshPrivateKey: privKey] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to obtain the private key from the PEM file" code:0 userInfo:nil];
		
		return;
	}
		
    //  Authenticate with the SSH server.  Chilkat SFTP supports
    //  both password-based authenication as well as public-key
    //  authentication.  This example uses public-key authenication.
    if ([sftp_ AuthenticatePk:@"bitnami" privateKey:key] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Authentication error when attempting to connect to the FTP server" code:0 userInfo:nil];

        return;
    }

    //  After authenticating, the SFTP subsystem must be initialized:
    if ([sftp_ InitializeSftp] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to initialize the FTP software" code:0 userInfo:nil];

        return;
    }
}
-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

-(void)loginWithUsername : (NSString*)username password:(NSString*)password token:(NSString*)token target:(id)target selector:(SEL)selector {
}

- (void)sendData:(NSData *)data withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    if (data == nil) {
        return;
    }

    if ([StringUtils isEmpty:fileName_] || [StringUtils isEmpty:host_] || [StringUtils isEmpty:fileDirectory_])
        return;

    if (port_ == 0)
        port_ = 22;

    NSData *finalData;

    if (CU_IS_FLAG_SET(options, WSChannelOptionEncrypt)) {
        finalData = [data AES256EncryptWithKey:(void *) keyBytes_];

        if (finalData == nil) {
            if (error != nil)
                *error = [NSError errorWithDomain:@"Unable to encrypt the data" code:0 userInfo:nil];

            return;
        }
    } else {
        finalData = data;
    }

    NSError *loginErr = nil;

    [self logIntoFtpServerDidFailWithError:&loginErr];

    if (loginErr != nil) {
        if (error != nil)
            *error = [NSError errorWithDomain:[loginErr domain] code:0 userInfo:nil];

        return;
    }
	
	//  Create a new directory:
	if ([StringUtils isNotEmpty:fileDirectory_]) {
		[sftp_ CreateDir:fileDirectory_];
		[sftp_ SetPermissions:fileDirectory_ bIsHandle:NO perm:[[NSNumber alloc] initWithInt:511]];
	}
    
    NSString* fullFileName = [[NSString alloc] initWithFormat:@"%@/%@", fileDirectory_, fileName_];

    //  Open a file on the server for writing.
    //  "createTruncate" means that a new file is created; if the file already exists, it is opened and truncated.
    NSString *handle = [sftp_ OpenFile:fullFileName access:@"writeOnly" createDisp:@"createTruncate"];

    if (handle == nil) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to create the data file on the FTP server" code:0 userInfo:nil];

        return;
    }

    if ([sftp_ WriteFileBytes:handle data:finalData] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to write the data to FTP server" code:0 userInfo:nil];

        return;
    }

    if ([sftp_ CloseHandle:handle] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Failed to close the data file on the FTP server" code:0 userInfo:nil];

        return;
    }
}

- (NSData *)retrieveDataWithOptions:(NSData *)data withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    if ([StringUtils isEmpty:fileName_] || [StringUtils isEmpty:host_] || [StringUtils isEmpty:fileName_])
        return nil;

    if (port_ == 0)
        port_ = 22;

    NSError *loginErr = nil;

    [self logIntoFtpServerDidFailWithError:&loginErr];

    if (loginErr != nil) {
        if (error != nil)
            *error = [NSError errorWithDomain:[loginErr domain] code:0 userInfo:nil];

        return nil;
    }

    NSString* fullFileName = [[NSString alloc] initWithFormat:@"%@/%@", fileDirectory_, fileName_];

    //  Open a file on the server:
    NSString *handle = [sftp_ OpenFile:fullFileName access:@"readOnly" createDisp:@"openExisting"];

    if (handle == nil) {
        if (error != nil)
            *error = [NSError errorWithDomain:[[NSString alloc] initWithFormat:@"Unable to locate the data file '%@' on the FTP server", fileName_] code:0 userInfo:nil];

        return nil;
    }

    //  Get the total size of this file (in bytes)
    BOOL bFollowLinks = NO;
    BOOL bIsHandle = YES;
    NSNumber *numBytes;

    //  bFollowLinks is ignored because we are passing a handle
    //  and not a remote filename.
    //  There are atlernative methods for handling file sizes
    //  greater than 32-bit.  (See the reference documentation.)
    numBytes = [sftp_ GetFileSize64:handle bFollowLinks:bFollowLinks bIsHandle:bIsHandle];

    if ((NSNumber *) 0 > numBytes) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to determine the size of the data file on the FTP server" code:0 userInfo:nil];

        return nil;
    }

    NSData *netBuffer = [sftp_ ReadFileBytes:handle numBytes:numBytes];

    if (netBuffer == nil) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to read the data file on the FTP server" code:0 userInfo:nil];

        return nil;
    }

    if ([sftp_ CloseHandle:handle] != YES) {
        if (error != nil)
            *error = [NSError errorWithDomain:@"Unable to close the data file on the FTP server" code:0 userInfo:nil];

        return nil;
    }
	
    NSData *finalData;

    if (CU_IS_FLAG_SET(options, WSChannelOptionEncrypt)) {
        finalData = [netBuffer AES256DecryptWithKey:(void *) keyBytes_];

        if (finalData == nil) {
            if (error != nil)
                *error = [NSError errorWithDomain:@"Unable to decrypt the data" code:0 userInfo:nil];

            return nil;
        }
    } else {
        finalData = netBuffer;
    }

    return finalData;
}

@end