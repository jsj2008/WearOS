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


#import "WSActivity.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSActivity

@synthesize  activity = activity_;


- (id)initWithXML: (NSString*)xml {
		self = [super init];

		if (self) {
				activity_ = [Activity new];

				NSError*          err = nil;
				GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithXMLString: xml options: 0 error: &err];

				if (doc != nil) {
						NSArray* rootEnum = [[doc rootElement]  children];

						for (GDataXMLElement* rootElement in rootEnum) {
								if ([[rootElement name] isEqualToString: @"Reason"]) {
										[activity_ setReason:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Type"]) {
										[activity_ setType:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Code"]) {
										[activity_ setCode:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"UserCode"]) {
										[activity_ setUserCode:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"VendorType"]) {
										[activity_ setVendorType:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Value"]) {
										[activity_ setValue:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"StartTime"]) {
										[activity_ setStartTime:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"EndTime"]) {
										[activity_ setEndTime:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"RelatedID"]) {
										[activity_ setRelatedID:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Archived"]) {
										[activity_ setArchived:(bool) [[rootElement stringValue] intValue]];
								} else if ([[rootElement name] isEqualToString: @"SysID"]) {
										[activity_ setSysID:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"UserID"]) {
										[activity_ setUserID:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Data"]) {
									[activity_ setData:[[NSMutableData alloc] initWithData:[[rootElement stringValue] dataUsingEncoding: NSUTF8StringEncoding]]];
								} else if ([[rootElement name] isEqualToString: @"Originator"]) {
										[activity_ setOriginator:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"Location"]) {
										[activity_ setLocation:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"LocationCode"]) {
										[activity_ setLocationCode:[rootElement stringValue]];
								} else if ([[rootElement name] isEqualToString: @"DayOfWeekOfStudy"]) {
										[activity_ setDayOfWeekOfStudy:[[rootElement stringValue] intValue]];
								} else if ([[rootElement name] isEqualToString: @"HourOfDayOfStudy"]) {
										[activity_ setHourOfDayOfStudy:[[rootElement stringValue] intValue]];
								} else if ([[rootElement name] isEqualToString: @"NumberOfSteps"]) {
										[activity_ setNumberOfSteps:[[rootElement stringValue] intValue]];
								} else if ([[rootElement name] isEqualToString: @"WeekOfStudy"]) {
										[activity_ setWeekOfStudy:[[rootElement stringValue] intValue]];
								} else if ([[rootElement name] isEqualToString: @"WeeklyGoal"]) {
										[activity_ setWeeklyGoal:[[rootElement stringValue] intValue]];
								}
						}
				}
		}

		return self;
}

- (id) initWithActivity: (Activity*) activity {
		self = [super init];

		if (self) {
				activity_ = activity;
		}

		return self;
}

/*
- (NSString*) generateJsonValue {
	NSMutableString* dataPoint = [NSMutableString alloc] initWithCapacity:10];
		
	if ([WSStringUtils isNotEmpty: activity_.value]) {
		[dataPoint setString: [NSString alloc] initWithFormat:@"\"%@\" : \"", [self valueForKey:@"emName"]]];
		[dataPoint appendString: @"	      \"value\" : \""];
		[dataPoint appendString: activity_.value];
		[dataPoint appendString: @"\",\n"];
	}
	
	return dataPoint;
}
 */

+ (NSString*) generateCSVHeader {
	return @"name,objectid,reason,type,code,value,endtime,relatedid,dayofweekofstudy,hourofdayofstudy,weekofstudy,location,locationcode,originator,usercode,userid,starttime";
}

- (NSString*) generateCSV {
	NSMutableString* act = [[NSMutableString alloc] initWithCapacity:100];
    
	[act appendString: @"DummyName,"];   // "Name" is required at this point
	[act appendString: [CSVSerialization encodeCSVString:activity_.sysID]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.reason]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.type]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.code]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.value]];
    [act appendString: [CSVSerialization encodeCSVDateString:activity_.endTime]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.relatedID]];
    [act appendString: [CSVSerialization encodeCSVNumeric:activity_.dayOfWeekOfStudy]];
    [act appendString: [CSVSerialization encodeCSVNumeric:activity_.hourOfDayOfStudy]];
    [act appendString: [CSVSerialization encodeCSVNumeric:activity_.weekOfStudy]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.location]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.locationCode]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.originator]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.userCode]];
    [act appendString: [CSVSerialization encodeCSVString:activity_.userID]];
    [act appendString: [CSVSerialization encodeCSVDateString:activity_.creationTime]];

    [act deleteCharactersInRange:NSMakeRange([act length] - 1, 1)];  // remote the trailing comma
	
	return act;
}

- (NSString*) generateJson {
	NSMutableString* act = [[NSMutableString alloc] initWithString: @"{"];

    [act appendString:[JSONSerialization encodeJSONString:activity_.sysID name:@"objectID"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.reason name:@"reason"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.type name:@"type"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.code name:@"code"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.userCode name:@"userCode"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.userID name:@"userID"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.originator name:@"originator"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.location name:@"location"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.locationCode name:@"locationCode"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.endTime name:@"endTime"]];

	NSUserDefaults*		prefs	= [NSUserDefaults standardUserDefaults];
	Boolean				trial	= [prefs boolForKey:@"studyType"];

    [act appendString:trial ? @"	      \"vendorType\" : \"Trial\"," : @"	      \"vendorType\" : \"RunIn\","];

    [act appendString:[JSONSerialization encodeJSONString:activity_.value name:@"value"]];
    [act appendString:[JSONSerialization encodeJSONNumeric:activity_.dayOfWeekOfStudy name:@"dayOfWeekOfStudy"]];
    [act appendString:[JSONSerialization encodeJSONNumeric:activity_.hourOfDayOfStudy name:@"hourOfDayOfStudy"]];
    [act appendString:[JSONSerialization encodeJSONNumeric:activity_.weekOfStudy name:@"weekOfStudy"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.relatedID name:@"relatedID"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.goalID name:@"goalID"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.taskID name:@"taskID"]];
    [act appendString:[JSONSerialization encodeJSONString:activity_.rewardID name:@"rewardID"]];
    [act appendString:[JSONSerialization encodeJSONDateString:activity_.creationTime name:@"creationTime"]];

    [act deleteCharactersInRange:NSMakeRange([act length] - 1, 1)];  // remote the trailing comma

	[act appendString: @"}"];

	return act;
}

@end