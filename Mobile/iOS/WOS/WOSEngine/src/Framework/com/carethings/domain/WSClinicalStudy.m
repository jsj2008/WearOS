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

#import "WSClinicalStudy.h"
#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"


@implementation WSClinicalStudy

+ (int) daysOfStudy {
	if ([OpenPATHContext sharedOpenPATHContext].activeStudy == nil)
		return 0;

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate == 0) {
		return 0;
	}
	
	NSDate* today 		= [NSDate date];
	NSDate* startDate 	= [[NSDate alloc] initWithTimeIntervalSince1970:[OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate];
	int 	days 		= (int) ([today timeIntervalSinceDate: startDate] / SECONDS_PER_DAY);

	return days;
}

+ (int) weekOfStudy {
	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate == 0) {
		return 0;
	}

	int days  =    [WSClinicalStudy daysOfStudy];

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.useLogicalClock == 1) {
		return [OpenPATHContext sharedOpenPATHContext].activeStudy.lamportWeekClock;
	} else   {
		return (days / 7) + 1;
	}
}

+ (NSDate*) dateWithWeek: (int) week andDay: (int) day {
	int 		daysSinceStart	= (7 * (week - 1)) + (day - 1);
	double 	sSinceStart			= daysSinceStart * SECONDS_PER_DAY;
	double 	sSinceEpoch      	= [OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate + sSinceStart;

	return [NSDate dateWithTimeIntervalSince1970: sSinceEpoch];
}

+ (NSString*) shortDateWithWeek: (int) week andDay: (int) day {
	NSCalendar*			gregorian			= [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
	NSDateComponents*  	dateComponents		= [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[WSClinicalStudy dateWithWeek: week andDay: day]];
	
	return [[NSString alloc] initWithFormat: @"%i/%i", [dateComponents month], [dateComponents day]];
}

+ (NSString*) shortDayWithWeek: (int) week andDay: (int) day {
	NSCalendar*               gregorian				= [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
	NSDateComponents* 	dateComponents  	= [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[WSClinicalStudy dateWithWeek: week andDay: day]];

	NSString* dateStr = [[NSString alloc] initWithFormat: @"/%i", [dateComponents day]];

	return dateStr;
}

+ (int) dayOfWeekOfStudy {
	int days  =    [WSClinicalStudy daysOfStudy];

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate == 0) {
		return 0;
	}

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.useLogicalClock == 1) {
		return [OpenPATHContext sharedOpenPATHContext].activeStudy.lamportDayClock;
	} else   {
		return (days % 7) + 1;
	}
}

+ (int) hourOfDay {
	NSCalendar*        gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
	NSDateComponents*  dateComponents  = [gregorian components: NSHourCalendarUnit fromDate:[NSDate date]];

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.msStartDate == 0) {
		return 0;
	}

	if ([OpenPATHContext sharedOpenPATHContext].activeStudy.useLogicalClock == 1) {
		return [OpenPATHContext sharedOpenPATHContext].activeStudy.lamportHourClock;
	} else   {
		return [dateComponents hour];
	}
}

+ (int)weeklyGoal {
	NSString* baseSteps = [[OpenPATHContext sharedOpenPATHContext] activeStudy].var1;
	
	if ([WSStringUtils isNotEmpty:baseSteps]) {
		int		goal		        =  [baseSteps intValue];
		int 	weekNumber	=  [WSClinicalStudy weekOfStudy];
		
		for (int i = 0; i < weekNumber; i++) {
			goal = goal * 120 / 100;
		}
		
		if (goal > 10000)
			return 10000;
		else
			return goal;			
	} else
		return 0;
}

+ (Activity*)getLastStepsActivity {
	ActivityDAO*   dao = [ActivityDAO new];
	ResdbResult*   result = nil;
	
	result = [dao mostRecentActivityWithReason:@"1DQT_Steps"];
	
    if (result.resdbCode == RESDB_SQL_ROWS) {
        return [result.resdbCollection objectAtIndex:0];
	} else {
		return nil;
	}
}

@end