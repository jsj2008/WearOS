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

#import "Stack.h"

@implementation	Stack

@synthesize stackSize;
@synthesize stackLimit;
@synthesize top;
@synthesize lastNode;


-(void)initialize {
	top        = nil;
	lastNode   = nil;
	stackSize  = 0;
	stackLimit = 0;
}

-(void)empty {
	while([self size])
		[self pop];
}

-(void)push:(id)anItem {
	
	if ((stackLimit > 0) && (stackSize == stackLimit)) {
		Node* node = self.lastNode;
		
		if ([node prev] != nil) {       //  if we are not at the top of the stack
			self.lastNode = node.prev;
			self.lastNode.next = nil;
			
			node.next = nil;
			node.prev = nil;
		} else {
			top = nil;
			self.lastNode = nil;
		}
	}
	
	Node* node = [[Node alloc] init: anItem];
	
	if (top != nil) {
		top.prev  = node;
		node.next = top;
	}
	
	self.top = node;
	
	++stackSize;
	
	if (stackSize == 1)
		self.lastNode = top;
}

-(Node*)pop {
	Node* oldTop = self.top;
	
	self.top = top.next;
	
	--stackSize;
	
	return oldTop;
}

-(unsigned) size {
	return (unsigned int) stackSize;
}

@end
