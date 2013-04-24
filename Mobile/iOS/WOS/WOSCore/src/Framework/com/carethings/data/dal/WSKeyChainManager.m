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

#import "WSKeyChainManager.h"

static NSString*        serviceName = @"edu.ucsf.KEY";


@implementation WSKeyChainManager

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
	NSMutableDictionary*		searchDictionary = [NSMutableDictionary new];

	[searchDictionary setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id)kSecClass];

	NSData*		encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	
	[searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
	[searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
	[searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];

	return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
	NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];

	// Add search attributes
	[searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

	// Add search return types
	[searchDictionary setObject:(id) kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

	NSData *result = nil;
	//SecItemCopyMatching((CFDictionaryRef)searchDictionary), &result);

	return result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
	NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];

	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	[dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);

	if (status == errSecSuccess) {
		return YES;
	}
	return NO;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
	NSMutableDictionary*		searchDictionary	= [self newSearchDictionary:identifier];
	NSMutableDictionary*		updateDictionary	= [NSMutableDictionary new];
	NSData*					    passwordData	    = [password dataUsingEncoding:NSUTF8StringEncoding];
	
	[updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

	OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);

	if (status == errSecSuccess) {
		return YES;
	}
	
	return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier {
	NSMutableDictionary*		searchDictionary = [self newSearchDictionary:identifier];
	
	SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

@end
