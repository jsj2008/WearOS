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

#import "APElement.h"
#import "APAttribute.h"


@implementation APElement

@synthesize name;
@synthesize parent;
@synthesize value;

/*
   Returns a new element with the specified tag name
 */
+ (id) elementWithName : (NSString*) aName {
	return [[APElement alloc] initWithName: aName];
}

+ (id) elementWithName: (NSString*) aName withValue: (NSString*) aValue {
	APElement* element = [[APElement alloc] initWithName: aName];
	element.value = (NSMutableString*)aValue;

	return element;
}

/*
   Returns a new element with the specified tag name and attributes
 */
+ (id) elementWithName: (NSString*) aName attributes: (NSDictionary*) someAttributes {
	APElement* anElement = [[APElement alloc] initWithName: aName];
	[anElement addAttributes: someAttributes];

	return anElement;
}

/*
   Initializes the element with the specified tag name
 */
- (id) initWithName: (NSString*) aName {
	if (self = [super init]) {
		name = [[NSString alloc] initWithString: aName];
		//value = [NSMutableString new];
		parent  = nil;
		attributes = [NSMutableDictionary new];
		childElements = [NSMutableArray new];
	}

	return self;
}

/*
   Adds the specified attribute to the element
 */
- (void) addAttribute: (APAttribute*) anAttribute {
	[attributes setObject: anAttribute.value forKey: anAttribute.name];
}

/*
   Adds the specified name and value as an attribute for the element
 */
- (void) addAttributeNamed: (NSString*) aName withValue: (NSString*) aValue {
	[attributes setObject: aValue forKey: aName];
}

/*
   Adds a dictionary of name/values to the element.
   All keys and values in the supplied dictionary must be of type NSString*
 */
- (void) addAttributes: (NSDictionary*) someAttributes {
	if (someAttributes != nil) {
		[attributes addEntriesFromDictionary: someAttributes];
	}
}

/*
   Adds the specified element as a child of the receiver.
 */
- (void) addChild: (APElement*) anElement {
	[childElements addObject: anElement];
}

/*
   Appends the specified string to the element's text value
 */
- (void) appendValue: (NSString*) aValue {
	if (value == nil)
		value = [NSMutableString new];

	[value appendString: aValue];
}

/*
   Returns the number of attributes on this element
 */
- (int) attributeCount {
	return [attributes count];
}

/*
   Returns the number of child elements
 */
- (int) childCount {
	return [childElements count];
}

/*
   Returns an array of APElements that are direct descendants of this element.
   Returns an empty array if the element has no children.
 */
- (NSArray*) childElements {
	return [NSArray arrayWithArray: childElements];
}

/*
   Returns an array of APElements that are direct descendants of this element
   and have the specified tag name.
   Returns an empty array if the element has no children.
 */
- (NSMutableArray*) childElements: (NSString*) aName {
	NSMutableArray* result = [NSMutableArray new];

	int numElements = [childElements count];

	for (int i = 0; i < numElements; i++) {
        APElement* currElement;
        currElement = [childElements objectAtIndex:(NSUInteger) i];

		if ([currElement.name isEqual: aName])
			[result addObject: currElement];
	}

	return result;
}

/*
   Returns the first direct descendant of this element.
   Returns nil if the element has no children.
 */
- (APElement*) firstChildElement {
	if ([childElements count] > 0)
		return [childElements objectAtIndex: 0];
	else
		return nil;
}

/*
   Returns the first direct descendant with the specified tag name.
   Returns nil if the element has no matching child.
 */
- (APElement*) firstChildElementNamed: (NSString*) aName {
	int numElements = [childElements count];

	for (int i = 0; i < numElements; i++) {
		APElement* currElement = [childElements objectAtIndex:(NSUInteger) i];

		if ([currElement.name isEqual: aName])
			return currElement;
	}

	return nil;
}

/*
   Returns the text content of the element, or nil if there is none.
 */
- (NSMutableString *) value {
	if (value == nil)
		return nil;
	else
		return (NSMutableString *) [NSString stringWithString: value];
}

/*
   Returns the value for the specified attribute name.
   Returns nil if no such attribute exists
 */
- (NSString*) valueForAttributeNamed: (NSString*) aName {
	return [attributes objectForKey: aName];
}

/*
   Returns a human readable description of this element
 */
- (NSString*) description {
	return name;
}

/*
   Returns an xml string of the element, its attributes and children.
   Useful for debugging.
   Simply specify 0 for the tabs argument.
 */
- (NSString*) prettyXML: (int) tabs {
	NSMutableString* xmlResult = [NSMutableString new];

	// append open bracket and element name
	for (int i = 0; i < tabs; i++)
		[xmlResult appendFormat: @"\t"];

	[xmlResult appendFormat: @"<%@", name];

	for (NSString* key in attributes) {
		[xmlResult appendFormat: @" %@=\"%@\"", key, [attributes objectForKey: key]];
	}

	int numChildren = [childElements count];

	if (numChildren == 0 && value == nil) {
		[xmlResult appendFormat: @" />\n"];
		return xmlResult;
	}

	if (numChildren != 0) {
		[xmlResult appendString: @">\n"];

		for (int i = 0; i < numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:(NSUInteger) i] prettyXML: (tabs + 1)]];

		for (int i = 0; i < tabs; i++)
			[xmlResult appendFormat: @"\t"];

		[xmlResult appendFormat: @"</%@>\n", name];

		return xmlResult;
	} else   { // there must be a value
		[xmlResult appendFormat: @">%@</%@>\n", [self encodeEntities: value], name];
		return xmlResult;
	}
}

/*
   Returns an xml string containing a compact representation of this element, its attributes
   and children.
 */
- (NSString*) xml {
	NSMutableString* xmlResult = [NSMutableString new];
	// append open bracket and element name
	[xmlResult appendFormat: @"<%@", name];

	for (NSString* key in attributes) {
		[xmlResult appendFormat: @" %@=\"%@\"", key, [attributes objectForKey: key]];
	}

	// append closing bracket and value
	int numChildren = [childElements count];

	if (numChildren == 0 && value == nil) {
		[xmlResult appendFormat: @"/>"];
		return xmlResult;
	}

	if (numChildren != 0) {
		[xmlResult appendString: @">"];

		for (int i = 0; i < numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:(NSUInteger) i] xml]];

		[xmlResult appendFormat: @"</%@>", name];

		return xmlResult;
	} else   { // there must be a value
		[xmlResult appendFormat: @">%@</%@>", [self encodeEntities: value], name];
		return xmlResult;
	}
}

/*
   Encodes the predeclared entities in the specified string, and returns a new encoded
   string.
 */
- (NSString*) encodeEntities: (NSMutableString*) aString {
	if (aString == nil ||[aString length] == 0)
		return nil;

    NSMutableString *result = [NSMutableString new];
    [result appendString:aString];
    [result replaceOccurrencesOfString:@"&"
                            withString:@"&amp;"
                               options:(NSStringCompareOptions) 0
                                 range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<"
                            withString:@"&lt;"
                               options:(NSStringCompareOptions) 0
                                 range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">"
                            withString:@"&gt;"
                               options:(NSStringCompareOptions) 0
                                 range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'"
                            withString:@"&apos;"
                               options:(NSStringCompareOptions) 0
                                 range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\""
                            withString:@"&quot;"
                               options:(NSStringCompareOptions) 0
                                 range:NSMakeRange(0, [result length])];

	return result;
	//return result;
}

@end