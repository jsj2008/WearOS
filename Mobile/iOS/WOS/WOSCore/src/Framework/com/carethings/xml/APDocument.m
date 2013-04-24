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

#import "APDocument.h"
#import "APElement.h"

@interface APXMLBuilder : NSObject {
	APElement*  rootElement;
	APElement*  openElement;
	APElement*  parentElement;
}

- (APElement*) rootElement;

@end

@implementation APXMLBuilder

- (id) init {
	if (self = [super init]) {
		rootElement = nil;
		openElement = nil;
		parentElement = nil;
	}

	return self;
}

- (void) parserDidStartDocument: (__unused NSXMLParser*) parser {
}

- (void) parserDidEndDocument: (__unused NSXMLParser*) parser {
}

- (void) parser: (__unused NSXMLParser*) parser didStartElement: (NSString*) elementName namespaceURI: (__unused NSString*) namespaceURI qualifiedName: (__unused NSString*) qualifiedName attributes: (NSDictionary*) attributeDict {
	APElement* newElement = [APElement elementWithName: elementName attributes: attributeDict];

	if (rootElement == nil)
		rootElement = newElement;

	if (openElement != nil) {
		newElement.parent = openElement;
		parentElement     = openElement;
		openElement       = newElement;
	} else   {
		newElement.parent = parentElement;
		openElement       = newElement;
	}

	if (parentElement != nil)
		[parentElement addChild: openElement];
}

- (void) parser: (__unused NSXMLParser*) parser didEndElement: (__unused NSString*) elementName namespaceURI: (__unused NSString*) namespaceURI qualifiedName: (__unused NSString*) qName {
	if (openElement != nil) {
		openElement   = parentElement;
		parentElement = parentElement.parent;
	}
}

- (void) parser: (__unused NSXMLParser*) parser parseErrorOccurred: (__unused NSError*) parseError {
}

- (void) parser: (__unused NSXMLParser*) parser validationErrorOccurred: (__unused NSError*) validError {
}

- (void) parser: (__unused NSXMLParser*) parser foundCharacters: (NSString*) string {
	[openElement appendValue: string];
}

/*
   Returns the root element of the document that was parsed in.
 */
- (APElement*) rootElement {
	return rootElement;
}

@end

/*
   DOM representation of an XML document
 */
@implementation APDocument

/*
   Returns an APDocument representation of the specified xml. Should be used
   if you want to read in some XML as a document and want to manipulate it as
   such.
 */
+ (id) documentWithXMLString : (NSString*) anXMLString {
	return [[APDocument alloc] initWithString: anXMLString];
}

/*
   Initializes the document with a root element. This should be used
   if you're creating a new document programmatically.
 */
- (id) initWithRootElement: (APElement*) aRootElement {
	if (self = [super init]) {
		rootElement = aRootElement;
	}

	return self;
}

/*
   Initializes the document with an XML string.
 */
- (id) initWithString: (NSString*) anXMLString {
	if (self = [super init]) {
		APXMLBuilder*  builder = [APXMLBuilder new];
		NSXMLParser*   parser = [[NSXMLParser alloc] initWithData:[anXMLString dataUsingEncoding: NSUTF8StringEncoding]];
		[parser setDelegate: (id<NSXMLParserDelegate>)builder];
		[parser parse];

		rootElement = [builder rootElement];
	}

	return self;
}

/*
   Returns the document's root element
 */
- (APElement*) rootElement {
	return rootElement;
}

/*
   Returns a pretty string representation of the document with newlines
   and tabs.
 */
- (NSString*) prettyXML {
	if (rootElement != nil) {
		NSMutableString* result = [NSMutableString new];
		[result appendString: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement prettyXML: 0]];
		return result;
	} else
		return nil;
}

/*
   Returns a compact string representation of the document without newlines
   or tabs.
 */
- (NSString*) xml {
	if (rootElement != nil) {
		NSMutableString* result = [NSMutableString new];
		[result appendString: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement xml]];
		return result;
	} else
		return nil;
}

@end