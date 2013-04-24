//
//  CSVParser.m
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "ResponseParser.h"


@implementation ResponseParser

//
// initWithString:separator:hasHeader:fieldNames:
//
// Parameters:
//    aCSVString - the string that will be parsed
//    aSeparatorString - the separator (normally "," or "\t")
//    header - if YES, treats the first row as a list of field names
//    names - a list of field names (will have no effect if header is YES)
//
// returns the initialized object (nil on failure)
//
- (id)initWithString:(NSString *)aCSVString separator:(NSString *)aSeparatorString {
    self = [super init];

    if (self) {
        csvString = aCSVString;

        separator = aSeparatorString;

        NSMutableCharacterSet*  endTextMutableCharacterSet = [[NSCharacterSet newlineCharacterSet] mutableCopy];

        [endTextMutableCharacterSet addCharactersInString:@"\""];
        [endTextMutableCharacterSet addCharactersInString:separator];

        endTextCharacterSet = endTextMutableCharacterSet;

        if ([separator length] == 1) {
            separatorIsSingleChar = YES;
        }
    }

    return self;
}

//
// parseRecord
//
// Attempts to parse a record from the current scan location. The record
// dictionary will use the fieldNames as keys, or FIELD_X for each column
// X-1 if no fieldName exists for a given column.
//
// returns the parsed record as a dictionary, or nil on failure. 
//
- (NSArray *)parseRecord {
    scanner = [NSScanner scannerWithString:csvString];

    //[scanner setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];

    //
    // Special case: return nil if the line is blank. Without this special case,
    // it would parse as a single blank field.
    //
    if ([self parseLineSeparator] || [scanner isAtEnd]) {
        return nil;
    }

    NSString *token = [self parseToken];

    if (!token) {
        return nil;
    }

    NSMutableArray* tokens = [NSMutableArray arrayWithCapacity:100];

    while (token) {

        if (![token isEqualToString:@"\\n"])
             [tokens addObject:token];

        [self skipSeparators];

        token = [self parseField];
    }

    return tokens;
}

//
// parseName
//
// Attempts to parse a name from the current scan location.
//
// returns the name or nil.
//
- (NSString *)parseToken {
    return [self parseField];
}

- (NSString *)parseName {
    return nil;
}

- (NSString *)parseSeparator {
    return nil;
}

//
// parseField
//
// Attempts to parse a field from the current scan location.
//
// returns the field or nil
//
- (NSString *)parseField {
    NSString* escapedString = [self parseEscaped];

    if (escapedString) {
        return escapedString;
    }

    NSString *nonEscapedString = [self parseNonEscaped];
    if (nonEscapedString) {
        return nonEscapedString;
    }

    return nil;
}

//
// parseEscaped
//
// Attempts to parse an escaped field value from the current scan location.
//
// returns the field value or nil.
//
- (NSString *)parseEscaped {
    if (![self parseDoubleQuote]) {
        return nil;
    }

    NSString *accumulatedData = [NSString string];
    while (YES) {
        NSString *fragment = [self parseTextData];
        if (!fragment) {
            fragment = [self parseSeparator];
            if (!fragment) {
                fragment = [self parseLineSeparator];
                if (!fragment) {
                    if ([self parseTwoDoubleQuotes]) {
                        fragment = @"\"";
                    }
                    else {
                        break;
                    }
                }
            }
        }

        accumulatedData = [accumulatedData stringByAppendingString:fragment];
    }

    if (![self parseDoubleQuote]) {
        return nil;
    }

    return accumulatedData;
}

//
// parseNonEscaped
//
// Attempts to parse a non-escaped field value from the current scan location.
//
// returns the field value or nil.
//
- (NSString *)parseNonEscaped {
    return [self parseTextData];
}

//
// parseTwoDoubleQuotes
//
// Attempts to parse two double quotes from the current scan location.
//
// returns a string containing two double quotes or nil.
//
- (NSString *)parseTwoDoubleQuotes {
    if ([scanner scanString:@"\"\"" intoString:NULL]) {
        return @"\"\"";
    }
    return nil;
}

//
// parseDoubleQuote
//
// Attempts to parse a double quote from the current scan location.
//
// returns @"\"" or nil.
//
- (NSString *)parseDoubleQuote {
    if ([scanner scanString:@"\"" intoString:NULL]) {
        return @"\"";
    }
    return nil;
}

//
// parseSeparator
//
// Attempts to parse the separator string from the current scan location.
//
// returns the separator string or nil.
//
- (void)skipSeparators {
    while ([scanner scanString:separator intoString:NULL] || ([self parseLineSeparator] != nil)) {
    }
}

//
// parseLineSeparator
//
// Attempts to parse newline characters from the current scan location.
//
// returns a string containing one or more newline characters or nil.
//
- (NSString *)parseLineSeparator {
    NSString *matchedNewlines = nil;

    [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&matchedNewlines];

    return matchedNewlines;
}

//
// parseTextData
//
// Attempts to parse text data from the current scan location.
//
// returns a non-zero length string or nil.
//
- (NSString *)parseTextData {
    NSString *accumulatedData = [NSString string];
	
	// skip white space
	//[scanner scanUpToCharactersFromSet:endTextCharacterSet

    //while (YES) {
        NSString* fragment;

        if ([scanner scanUpToCharactersFromSet:endTextCharacterSet intoString:&fragment]) {
            accumulatedData = [accumulatedData stringByAppendingString:fragment];
        }

        //
        // If the separator is just a single character (common case) then
        // we know we've reached the end of parseable text
        //
		/*
        if (separatorIsSingleChar) {
            break;
        }

        //
        // Otherwise, we need to consider the case where the first character
        // of the separator is matched but we don't have the full separator.
        //
        NSUInteger location = [scanner scanLocation];
        NSString*  firstCharOfSeparator;

        if ([scanner scanString:[separator substringToIndex:1] intoString:&firstCharOfSeparator]) {
            if ([scanner scanString:[separator substringFromIndex:1] intoString:NULL]) {
                [scanner setScanLocation:location];
                break;
            }

            //
            // We have the first char of the separator but not the whole
            // separator, so just append the char and continue
            //
            accumulatedData = [accumulatedData stringByAppendingString:firstCharOfSeparator];
            continue;
        }
        else {
            break;
        }
		 */
    //}

    if ([accumulatedData length] > 0) {
        return accumulatedData;
    }

    return nil;
}

@end
