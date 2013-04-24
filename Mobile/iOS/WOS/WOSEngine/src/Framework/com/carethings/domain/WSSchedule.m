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

@implementation WSSchedule

NSString* const SCH_ATMOST_EACHWEEK     = @"EachWeek";
NSString* const SCH_ATMOST_EACHDAY      = @"EachDay";
NSString* const SCH_ATMOST_ONCEADAY     = @"OnceADay";
NSString* const SCH_ATMOST_ONLYONCE     = @"OnlyOnce";

@synthesize atMost = atMost_;
@synthesize day = day_;
@synthesize timeFrom = timeFrom_;
@synthesize timeTo = timeTo_;
@synthesize week = week_;

- (void) causeScheduleEvent: (__unused Study*) study andID: (NSString*) ident {
	if ([WSStringUtils isNotEmpty: atMost_] &&[WSStringUtils isNotEmpty: ident]) {
		if ([atMost_ isEqualToString: @"OnceADay"]) {
			ScheduleEventDAO*       dao = [ScheduleEventDAO new];
			ResdbResult*            result = [dao retrieveAll];

			if (result.resdbCode == RESDB_SQL_ROWS) {
				for (ScheduleEvent* scheduleEvent in result.resdbCollection) {
					if ([scheduleEvent.objectID caseInsensitiveCompare: ident] == 0) {
						scheduleEvent.weekOfStudy               =  [WSClinicalStudy weekOfStudy];
						scheduleEvent.dayInWeekOfStudy  = [WSClinicalStudy dayOfWeekOfStudy];

						[dao update: scheduleEvent];

						return;
					}
				}
			}

			ScheduleEvent* scheduleEvent = [ScheduleEvent new];

			scheduleEvent.objectID			= ident;
			scheduleEvent.dayInWeekOfStudy	= [WSClinicalStudy dayOfWeekOfStudy];
			scheduleEvent.event				= @"OnceADay";
			scheduleEvent.weekOfStudy		= [WSClinicalStudy weekOfStudy];

			[dao insert: scheduleEvent];
		}
	} else if ([atMost_ isEqualToString: @"OnlyOnce"]) {
		ScheduleEventDAO*       dao = [ScheduleEventDAO new];
		ResdbResult*            result = [dao retrieveAll];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			for (ScheduleEvent* scheduleEvent in result.resdbCollection) {
				if ([scheduleEvent.objectID caseInsensitiveCompare: ident] == 0) {
					scheduleEvent.weekOfStudy       =  [WSClinicalStudy weekOfStudy];
					scheduleEvent.dayInWeekOfStudy  = [WSClinicalStudy dayOfWeekOfStudy];
					
					[dao update: scheduleEvent];
					
					return;
				}
			}
		}
		
		ScheduleEvent* scheduleEvent = [ScheduleEvent new];
		
		scheduleEvent.objectID			= ident;
		scheduleEvent.dayInWeekOfStudy	= [WSClinicalStudy dayOfWeekOfStudy];
		scheduleEvent.event				= @"OnlyOnce";
		scheduleEvent.weekOfStudy		= [WSClinicalStudy weekOfStudy];
		
		[dao insert: scheduleEvent];
	}
}

- (bool) isActiveWithStudy: (__unused Study*) study andID: (NSString*) ident {
	if ([WSStringUtils isNotEmpty: week_]) {
		if (![week_ isEqualToString: @"EachWeek"]) {
			if ([week_ intValue] !=[WSClinicalStudy weekOfStudy]) {
				return false;
			}
		}
	}

	if ([WSStringUtils isNotEmpty: day_]) {
		if (![day_ isEqualToString: @"EachDay"]) {
			if ([day_ intValue] !=[WSClinicalStudy dayOfWeekOfStudy]) {
				return false;
			}
		}
	}

	if ([WSStringUtils isNotEmpty: timeFrom_]) {
		if ([timeFrom_ intValue] >[WSClinicalStudy hourOfDay]) {
			return false;
		}
	}

	if ([WSStringUtils isNotEmpty: timeTo_]) {
		if ([timeTo_ intValue] <= [WSClinicalStudy hourOfDay]) {
			return false;
		}
	}

	if ([WSStringUtils isNotEmpty: atMost_] &&[WSStringUtils isNotEmpty: ident]) {
		if ([atMost_ isEqualToString: @"OnceADay"]) {
			ScheduleEventDAO*  dao = [ScheduleEventDAO new];
			ResdbResult*             result = nil;

			result = [dao retrieve:ident];

			if (result.resdbCode == RESDB_SQL_ROWS) {
				ScheduleEvent*  scheduleEvent = (ScheduleEvent*)result.resdbObject;
				
				if ((scheduleEvent.weekOfStudy == [WSClinicalStudy weekOfStudy]) && (scheduleEvent.dayInWeekOfStudy == [WSClinicalStudy dayOfWeekOfStudy])) {
					return false;
				} else   {
					return true;
				}
			}
		} else if ([atMost_ isEqualToString: @"OnlyOnce"]) {
			ScheduleEventDAO*  dao = [ScheduleEventDAO new];
			ResdbResult*             result = nil;
			
			result = [dao retrieve:ident];
			
			if (result.resdbCode == RESDB_SQL_ROWS) {
				return false;
			} else {
				return true;
			}
		}
	}

	return true;
}

@end