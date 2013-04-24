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

#import "WSStudy.h"
#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSStudy

@synthesize study = study_;

-(void)setFromXml:(NSString*)xml {
	if ([WSStringUtils isEmpty:xml])
		return;
	
	NSError*   					err = nil;
	GDataXMLDocument*  	doc = [[GDataXMLDocument alloc] initWithXMLString: xml options:0 error: &err];

	if (doc != nil) {
		NSArray* rootEnum = [[doc rootElement]  children];
	
		for (GDataXMLElement* rootElement in rootEnum) {	
			if ([[rootElement name] isEqualToString: @"BaseSteps"]) {
				[study_ setVar1:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StartDate"]) {
				[study_ setStartDate:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"MsStartDate"]) {
				[study_ setMsStartDate:[[rootElement stringValue] doubleValue]];
			} else if ([[rootElement name] isEqualToString: @"Id"]) {
				[study_ setStudyID:[[NSURL alloc] initWithString:[rootElement stringValue]]];
			} else if ([[rootElement name] isEqualToString: @"AppVersion"]) {
				[study_ setAppVersion:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"PathwayXMLAuthor"]) {
				[study_ setClinicalPathwayAuthor:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"PathwayXMLVersion"]) {
				[study_ setClinicalPathwayVersion:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyPrimaryResearcher"]) {
				[study_ setStudyPrimaryResearcher:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudySecondaryResearcher"]) {
				[study_ setStudySecondaryResearcher:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyName"]) {
				[study_ setStudyName:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyDuration"]) {
				[study_ setStudyDuration:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailFrom"]) {
				[study_ setStudyEmailFrom:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailTo"]) {
				[study_ setStudyEmailTo:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailSubject"]) {
				[study_ setStudyEmailSubject:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailLogin"]) {
				[study_ setStudyEmailLogin:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailPass"]) {
				[study_ setStudyEmailPass:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailSMTP"]) {
				[study_ setStudyEmailSMTP:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyEmailPort"]) {
				[study_ setStudyEmailPort:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyWeek"]) {
				[study_ setStudyWeek:[rootElement stringValue]];
			} else if ([[rootElement name] isEqualToString: @"StudyDay"]) {
				[study_ setStudyDay:[rootElement stringValue]];
			}
		}
	}     
}

- (id)initWithXML:(NSString*)xml {
    self = [super init];
	
    if (self) {
		study_ = [Study new];
		
		[self setFromXml:xml];
    }
    
    return self;
}

- (id) initWithStudy:(Study*) study {
	self = [super init];
	
	if (self) {
		study_ = study;
	}
	
	return self;
}

- (void)updateWithXML:(NSString*)xml {
	[self setFromXml:xml];
}

@end
