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

#import "DateFormatter.h"
#import "StringUtils.h"


@implementation DateFormatter

+ (NSString*) localizedStringFromUSDate : (NSDate*) usDate {
	NSDateFormatter* usDateFormatter = [NSDateFormatter new];

	[usDateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	[usDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	
	NSString *retDate = [usDateFormatter stringFromDate:usDate];
	
	return retDate;
}

+ (NSString*) localizedStringFromUSDateString : (NSString*) usDateString {
	if ([StringUtils isEmpty:usDateString]) {
		return nil;
	}
		
	NSDateFormatter* 	usDateFormatter = [NSDateFormatter new];
	NSDateFormatter*	df 				= [NSDateFormatter new];
	
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
			
	NSDate* usDate = [df dateFromString:usDateString];
	
	[usDateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	[usDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	
	NSString *retDate = [usDateFormatter stringFromDate:usDate];
	
	return retDate;
}

+ (NSString*) localizedStringFromUSDateString :(NSString*)usDateString usingFormat:(NSString*)format {
	if ([StringUtils isEmpty:usDateString] || [StringUtils isEmpty:format]) {
		return nil;
	}
	
	NSDateFormatter* 	usDateFormatter = [NSDateFormatter new];
	NSDateFormatter*	df 				= [NSDateFormatter new];
	
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
	
	NSDate* usDate = [df dateFromString:usDateString];
	
	[usDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[usDateFormatter setDateFormat:format];
	
	NSString *retDate = [usDateFormatter stringFromDate:usDate];
	
	return retDate;
}

+ (NSString*) timeFromDateTime: (NSDate*) usDate {
	NSDateFormatter* usDateFormatter = [NSDateFormatter new];
	
	[usDateFormatter setDateFormat: @"HH:mm:ss"];
	
	NSString* retDate = [usDateFormatter stringFromDate: usDate];
	
	return retDate;
}

+(NSString*)monthDayFromUSDate: (NSDate*) usDate {	
    NSDateFormatter* usDateFormatter = [NSDateFormatter new];
	
   	[usDateFormatter setDateFormat: @"MMM dd"];
	
	//[usDateFormatter setTimeStyle:NSDateFormatterNoStyle];
	//[usDateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
   	NSString* retDate = [usDateFormatter stringFromDate: usDate];
	
   	return retDate;
}

+(NSString*)hourMinFromDateTime: (NSDate*) usDate {
	NSDateFormatter* usDateFormatter = [NSDateFormatter new];
	
	[usDateFormatter setDateFormat: @"HH:mm"];
	
	NSString* retDate = [usDateFormatter stringFromDate: usDate];
	
	return retDate;
}

+(NSString*)hourMinFromDateTimeString: (NSString*) dateTimeString {
    if ([StringUtils isEmpty:dateTimeString]) {
   		return nil;
   	}

    NSDateFormatter* df = [NSDateFormatter new];

   	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];

    NSDate* usDate = [df dateFromString:dateTimeString];

    NSDateFormatter* usDateFormatter = [NSDateFormatter new];

   	[usDateFormatter setDateFormat: @"HH:mm"];

   	NSString* retDate = [usDateFormatter stringFromDate: usDate];

   	return retDate;
}

+(NSString*)monthLongFromDateTimeString: (NSString*) dateTimeString {
    if ([StringUtils isEmpty:dateTimeString]) {
   		return nil;
   	}
	
    NSDateFormatter* df = [NSDateFormatter new];
	
   	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
    NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
	
    NSDate* usDate = [df dateFromString:dateTimeString];	

	NSDateFormatter* usDateFormatter = [NSDateFormatter new];
	
   	[usDateFormatter setDateFormat: @"MMMM"];
	
   	NSString* retDate = [usDateFormatter stringFromDate: usDate];
	
   	return retDate;
}

+(NSString*)monthDayFromDateTimeString: (NSString*) dateTimeString {	
    if ([StringUtils isEmpty:dateTimeString]) {
   		return nil;
   	}
	
    NSDateFormatter* df = [NSDateFormatter new];
	
   	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
    NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
	
    NSDate* usDate = [df dateFromString:dateTimeString];

	return [DateFormatter monthDayFromUSDate:usDate];
}

+(NSString*)dayFromDateTimeString: (NSString*) dateTimeString {
    if ([StringUtils isEmpty:dateTimeString]) {
   		return nil;
   	}
	
    NSDateFormatter* df = [NSDateFormatter new];
	
   	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
    NSTimeZone* gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
	
    NSDate* usDate = [df dateFromString:dateTimeString];
	
    NSDateFormatter* usDateFormatter = [NSDateFormatter new];
	
   	[usDateFormatter setDateFormat: @"dd"];
	
   	NSString* retDate = [usDateFormatter stringFromDate: usDate];
	
   	return retDate;
}

+ (NSString*) timeFromDateTimeString: (NSString*) dateTimeString {
	NSDateFormatter* usDateFormatter = [NSDateFormatter new];

	[usDateFormatter setDateFormat: @"HH:mm:ss"];

	NSDate* usDate = [usDateFormatter dateFromString: dateTimeString];

	NSString* retDate = [usDateFormatter stringFromDate: usDate];

	return retDate;
}

+ (NSString*) emptyLocalizedDateTimeString {
	NSString* language = [[NSLocale preferredLanguages] objectAtIndex: 0];

	if ([language isEqualToString: @"fr"])
		return @"00.00.0000 00:00:00";
	else
		return @"0000-00-00 00:00:00";
}

+ (NSString*) emptyDateTimeString {
	return @"0000-00-00 00:00:00";
}

+ (NSString*) emptyLocalizedDateString {
	NSString* language = [[NSLocale preferredLanguages] objectAtIndex: 0];

	if ([language isEqualToString: @"fr"])
		return @"00.00.0000";
	else
		return @"0000-00-00";
}

+ (NSString*) nowLocalizedDateTimeString {
	NSDate* now = [NSDate date];

	NSString* retDate = [self localizedStringFromUSDate:now];

	return retDate;
}

+ (NSString*) nowDateTimeString {
	NSDate* now = [NSDate date];

	NSString* retDate = [now description];

	return retDate;
}

@end