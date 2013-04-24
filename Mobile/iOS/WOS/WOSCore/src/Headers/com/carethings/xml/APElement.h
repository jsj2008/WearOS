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


@class APAttribute;


@interface APElement : NSObject {
	NSString*             name;
	NSMutableString*      value;
	APElement*            parent;
	NSMutableDictionary*  attributes;
	NSMutableArray*       childElements;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSMutableString* value;
@property (nonatomic) APElement* parent;

+(id)elementWithName : (NSString*)aName;
+(id)elementWithName : (NSString*)aName withValue : (NSString*)aValue;
+(id)elementWithName : (NSString*)aName attributes : (NSDictionary*)someAttributes;
-(id)initWithName : (NSString*)aName;
-(void)addAttribute : (APAttribute*)anAttribute;
-(void)addAttributeNamed : (NSString*)aName withValue : (NSString*)aValue;
-(void)addAttributes : (NSDictionary*)someAttributes;
-(void)addChild : (APElement*)anElement;
-(void)appendValue : (NSString*)aValue;
-(int)attributeCount;
-(int)childCount;
-(NSArray*)childElements;
-(NSMutableArray*)childElements : (NSString*)aName;
-(APElement*)firstChildElement;
-(APElement*)firstChildElementNamed : (NSString*)aName;
-(NSMutableString *)value;
-(NSString*)valueForAttributeNamed : (NSString*)aName;
-(NSString*)encodeEntities : (NSMutableString*)aString;
-(NSString*)prettyXML : (int)tabs;
-(NSString*)xml;

@end