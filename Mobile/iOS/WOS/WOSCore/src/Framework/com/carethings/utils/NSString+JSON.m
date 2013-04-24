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

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (NSString*) stringByDecodingJSON {
	return nil;
}

// Needs more work to encode more entities
- (NSString*) stringByEncodingJSON {
	NSScanner*        scanner = [[NSScanner alloc] initWithString: self];
	NSMutableString*  result = [[NSMutableString alloc] init];
	NSCharacterSet*   characters = [NSCharacterSet characterSetWithCharactersInString: @"\"/\n\b\f\r\t"];
	NSString*         temp;
	
	[scanner setCharactersToBeSkipped: nil];

	while (![scanner isAtEnd]) {
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet: characters intoString: &temp];

		if (temp) [result appendString: temp];

		// Replace with encoded entities
		if ([scanner scanString:@"\"" intoString: NULL]) 
			[result appendString: @"\\\""];
		if ([scanner scanString:@"/" intoString: NULL]) 
			[result appendString: @"\\/"];
		if ([scanner scanString:@"\n" intoString: NULL]) 
			[result appendString: @"\\n"];
		if ([scanner scanString:@"\b" intoString: NULL]) 
			[result appendString: @"\\b"];
		if ([scanner scanString:@"\f" intoString: NULL]) 
			[result appendString: @"\\f"];
		if ([scanner scanString:@"\r" intoString: NULL]) 
			[result appendString: @"\\r"];
		if ([scanner scanString:@"\t" intoString: NULL]) 
			[result appendString: @"\\t"];
	}

	return [NSString stringWithString: result];
}

- (NSString*) stringWithNewLinesAsBRs {
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029

	// Scanner
	NSScanner* scanner = [[NSScanner alloc] initWithString: self];
	[scanner setCharactersToBeSkipped: nil];
	NSMutableString* result = [[NSMutableString alloc] init];
	NSString* temp;
	NSCharacterSet* newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
	                                     [NSString stringWithFormat: @"\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];

	// Scan
	do {
		// Get non new line characters
		temp = nil;
		[scanner scanUpToCharactersFromSet: newLineCharacters intoString: &temp];

		if (temp) [result appendString: temp];

		temp = nil;

		// Add <br /> s
		if ([scanner scanString: @"\r\n" intoString: nil]) {
			// Combine \r\n into just 1 <br />
			[result appendString: @"<br />"];
		} else if ([scanner scanCharactersFromSet: newLineCharacters intoString: &temp])   {
			// Scan other new line characters and add <br /> s
			if (temp) {
				for (int i = 0; i < temp.length; i++) {
					[result appendString: @"<br />"];
				}
			}
		}
	}
	while (![scanner isAtEnd]);

	NSString* retString = [NSString stringWithString: result];
	
	return retString;
}

- (NSString*) stringByRemovingNewLinesAndWhitespace {
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029

	// Scanner
	NSScanner* scanner = [[NSScanner alloc] initWithString: self];
	[scanner setCharactersToBeSkipped: nil];
	NSMutableString* result = [[NSMutableString alloc] init];
	NSString* temp;
	NSCharacterSet* newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
	                                                  [NSString stringWithFormat: @" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];

	// Scan
	while (![scanner isAtEnd]) {
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet: newLineAndWhitespaceCharacters intoString: &temp];

		if (temp) [result appendString: temp];

		// Replace with a space
		if ([scanner scanCharactersFromSet: newLineAndWhitespaceCharacters intoString: NULL]) {
			if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
				[result appendString: @" "];
		}
	}

	// Return
	NSString* retString = [NSString stringWithString: result];
	
	return retString;
}

@end