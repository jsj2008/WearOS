/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *			When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author	Larry Suarez
 *  @package com.carethings.domain
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

#import "WSRenderingEngine.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSStyle.h"
#import "UIColor+Utilities.h"

@implementation WSRenderingEngine

@synthesize styleDictionary = styleDictionary_;

static WSRenderingEngine* sharedRenderingEngine_ = nil;

+ (WSRenderingEngine*) sharedRenderingEngine {
	@synchronized(self) {
		if (sharedRenderingEngine_ == nil) {
			sharedRenderingEngine_ = [self new];
			
			sharedRenderingEngine_.styleDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
		}
	}
	
	return sharedRenderingEngine_;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
	
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [[self class] colorWithRGBHex:hexNum];
}

+ (id) allocWithZone: (NSZone*) zone {
	@synchronized(self) {
		if (sharedRenderingEngine_ == nil) {
			sharedRenderingEngine_ = [super allocWithZone: zone];
			return sharedRenderingEngine_;
		}
	}
	
	return nil;
}

- (WSStyle*) decodeStyleWithXML: (GDataXMLElement*) xml {
	WSStyle*	style = [WSStyle new];
	NSArray*	styleEnum = [xml children];

    style.type              = @"http://www.carethings.com/styletypes/interaction";
	style.background        = nil;
   	style.textColor         = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
	style.labelTextColor    = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
   	style.fontSize          = 18.0;
   	style.fontFamily        = @"Verdana";
	style.subTextColor      = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
   	style.subFontSize       = 12.0;
   	style.subFontFamily     = @"Verdana";
   	style.headerFontSize    = 20.0;
   	style.headerFontFamily  = @"Verdana";
   	style.headerTextColor   = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];

	for (GDataXMLElement* styleElement in styleEnum) {
		if ([[styleElement name] isEqualToString: @"Type"])   {
			style.type = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"TextColor"]) {
			NSString* rgbColor = [styleElement stringValue];

            if ([rgbColor length] == 6) {
                style.textColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"LabelTextColor"]) {
			NSString* rgbColor = [styleElement stringValue];
			
            if ([rgbColor length] == 6) {
                style.labelTextColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"HeaderTextColor"]) {
			NSString* rgbColor = [styleElement stringValue];
			
            if ([rgbColor length] == 6) {
                style.headerTextColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"SubTextColor"]) {
			NSString* rgbColor = [styleElement stringValue];
			
            if ([rgbColor length] == 6) {
                style.subTextColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"Background"]) {
			style.background = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"TableCellBackgroundImage"]) {
			style.tableCellBackgroundImage = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"TableCellBackgroundSelectedImage"]) {
			style.tableCellBackgroundSelectedImage = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"TableCellBackgroundColor"]) {
			NSString* rgbColor = [styleElement stringValue];
			
            if ([rgbColor length] == 6) {
                style.tableCellBackgroundColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"TableSeparatorColor"]) {
			NSString* rgbColor = [styleElement stringValue];
			
            if ([rgbColor length] == 6) {
                style.tableSeparatorColor = [[self class] colorWithHexString:rgbColor];
            }
		} else if ([[styleElement name] isEqualToString: @"ButtonBackgroundSelectedImage"]) {
			style.buttonBackgroundSelectedImage = [styleElement stringValue];
		}  else if ([[styleElement name] isEqualToString: @"FontSize"])   {
			style.fontSize = [[styleElement stringValue] floatValue];
		} else if ([[styleElement name] isEqualToString: @"HeaderFontSize"])   {
			style.headerFontSize = [[styleElement stringValue] floatValue];
		} else if ([[styleElement name] isEqualToString: @"SubFontSize"])   {
			style.subFontSize = [[styleElement stringValue] floatValue];
		} else if ([[styleElement name] isEqualToString: @"FontFamily"])   {
			style.fontFamily = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"SubFontFamily"])   {
			style.subFontFamily = [styleElement stringValue];
		} else if ([[styleElement name] isEqualToString: @"HeaderFontFamily"])   {
			style.headerFontFamily = [styleElement stringValue];
		}
	}
	
	return style;
}

- (void) parseRenderingPlan {
	NSError* err;
	
    doc_ = [[GDataXMLDocument alloc] initWithXMLString:renderingXml_ options: 0 error: &err];
	
	if (doc_ == nil) {
		return;
	}
	
	NSArray* rootEnum = [[doc_ rootElement] children];
		
	for (GDataXMLElement* rootElement in rootEnum) {
		if ([[rootElement name] isEqualToString: @"Renderings"])   {
			NSArray* renderingsEnum = [rootElement children];
			
			if ([renderingsEnum count] == 0) {
				continue;
			}
									
			for (GDataXMLElement* renderingElement in renderingsEnum) {
				if ([[renderingElement name] isEqualToString: @"Styles"])   {
					NSArray* stylesEnum = [renderingElement children];
					
					if ([stylesEnum count] == 0) {
						continue;
					}
					
					for (GDataXMLElement* styleElement in stylesEnum) {
						WSStyle* style = [self decodeStyleWithXML: styleElement];

                        [styleDictionary_ removeObjectForKey:style.type];
						[styleDictionary_ setObject:style forKey:style.type];
					}
				} 
			}
		} 
	}
}

- (WSStyle*)styleOfType:(NSString*)type {
	if ([StringUtils isEmpty:type]) {
		return nil;
	}
	
	return [styleDictionary_ objectForKey:type];
}

- (NSString*) readRenderingXML {
	NSError*        err = nil;
	
	// We assume the resource file is coming from the main bundle (i.e. the 3rd party)
	NSString*       xmlPath = [[NSBundle mainBundle] pathForResource: renderingXmlFile_ ofType: @"xml"];
	
	if ([StringUtils isEmpty:xmlPath]) {
		return nil;
	}
	
	NSURL*    xmlURL  = [[NSURL alloc] initFileURLWithPath: xmlPath];
	NSString* pathway = [[NSString alloc] initWithContentsOfURL: xmlURL encoding: NSASCIIStringEncoding error: &err];
	
	return pathway;
}

- (void)addDefaultInteractionStyle {
    WSStyle*	style = [WSStyle new];

   	style.type              = @"http://www.carethings.com/styletypes/interaction";
    style.background        = nil;
   	style.textColor         = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
   	style.fontSize          = 18.0;
   	style.fontFamily        = @"Verdana";
	style.subTextColor      = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
   	style.subFontSize       = 12.0;
   	style.subFontFamily     = @"Verdana";
   	style.headerTextColor   = [[UIColor alloc] initWithRed:0.0/255 green:0.0/255 blue:255.0/255 alpha:1.0];
   	style.headerFontSize    = 20.0;
   	style.headerFontFamily  = @"Verdana";

    [styleDictionary_ removeObjectForKey:style.type];
	[styleDictionary_ setObject:style forKey:style.type];
}

- (void)initializeRenderingPlan: (NSString*)renderingXMLFile {
    [self addDefaultInteractionStyle];

	if ([StringUtils isEmpty:renderingXMLFile])  {
        return;
    }
	
	renderingXmlFile_ = renderingXMLFile;
	renderingXml_     = [self readRenderingXML];
	
	if ([StringUtils isEmpty:renderingXml_]) {
		return;
	}
	
	[self parseRenderingPlan];

}

@end
