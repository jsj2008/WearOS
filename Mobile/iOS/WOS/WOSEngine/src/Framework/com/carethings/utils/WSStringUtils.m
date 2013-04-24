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
 * This code  is the  sole  property of CareThings, Inc. and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade secret, not to be disclosed 
 * without written authorization from CareThings.  Any  use, duplication, or  disclosure of this program  
 * by other than CareThings and its assigned licensees is strictly forbidden by law.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"
#import <time.h>


@implementation WSStringUtils;

+ (bool) isEmpty : (NSString*) str {
	return ((str == nil) || ([str length] == 0));
}

+ (bool) isNotEmpty: (NSString*) str {
	return ((str != nil) && ([str length] > 0));
}

+ (NSComparisonResult) caseInsensitiveCompare: (NSString*) op1 toString: (NSString*) op2 {
	return ([WSStringUtils isEmpty: op1] ||[WSStringUtils isEmpty: op2]) ? NSOrderedAscending : [op1 caseInsensitiveCompare: op2];
}

+ (NSString*)displayString:(NSString*) str {
    return ([self isEmpty:str] ? @"Unknown" : str);
}

+ (NSString*) decodeFormattedString:(NSString*)rawString {
    NSArray*          stringComp = [rawString componentsSeparatedByString:@"%"];
    NSMutableString*  finalString = [[NSMutableString alloc] initWithCapacity:100];

    if ([stringComp count] > 0) {
        for (NSString* comp in stringComp) {
            if ([WSStringUtils caseInsensitiveCompare:comp toString:@"FIRST_NAME"] == NSOrderedSame) {
                if ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.firstName]) {
                    [finalString appendString:[OpenPATHContext sharedOpenPATHContext].activePatient.firstName];
                }
            } else if ([WSStringUtils caseInsensitiveCompare:comp toString:@"PERIOD_OF_DAY"] == NSOrderedSame) {
                NSDateFormatter*  formatter;
                NSString*         dateString;
                NSLocale*         en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

                formatter = [[NSDateFormatter alloc] init];

                [formatter setLocale:en_US_POSIX];   // force 24hr clock even though user has set the mobile device to 12hr time

                [formatter setDateFormat:@"HH"];

                dateString = [formatter stringFromDate:[NSDate date]];

                int hour = [dateString intValue];

                if (hour < 12) {
                    [finalString appendString:@"Morning"];
                } else if (hour < 18) {
                    [finalString appendString:@"Afternoon"];
                } else {
                    [finalString appendString:@"Evening"];
                }
            } else if ([WSStringUtils caseInsensitiveCompare:comp toString:@"RESEARCHER"] == NSOrderedSame) {
                [finalString appendString:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher];
            } else {
                [finalString appendString:comp];
            }
        }
    }

    return finalString;
}

@end