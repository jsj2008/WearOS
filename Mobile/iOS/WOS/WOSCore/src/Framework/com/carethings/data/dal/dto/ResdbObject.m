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

#import "ResdbObject.h"


@implementation ResdbObject

@synthesize objectID;
@synthesize creationTime;
@synthesize description;	
@synthesize ontology;
@synthesize worldModel;


+ (NSString*) generateObjectId {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	
	//get the string representation of the UUID
	NSString* uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	
	CFRelease(uuidObj);
	
	return uuidString;
}

- (NSString *)appStoreURL {
	// The description and the app's appStore URL are sharing the same description field
	// The seperator of the 2 entities is "::"
	// Example of a description: "Calorie Counter::http://itunes.apple.com/us/app/calorie-counter-by-fatsecret/id347184248?mt=8"
	NSArray *strs = [description componentsSeparatedByString:@"::"];
	
	if (strs.count > 1)
		return [NSString stringWithString: [strs objectAtIndex:1]];
	return nil;
}

- (void) allocateObjectId {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	
	//get the string representation of the UUID
	NSString* uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	
	CFRelease(uuidObj);
	
	[self setObjectID:uuidString];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	//  Default.  Do nothing.
	return self;
}

@end
