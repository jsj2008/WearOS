//
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

#import "WSScheduleEvent.h"
#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSScheduleEvent

@synthesize eventId = eventId_;
@synthesize event = event_;


-(void)causeEvent {
	if ((eventId_ == nil) || [WSStringUtils isEmpty:[eventId_ fragment]]) {
		return;
	}
	
	ScheduleEventDAO*	dao = [ScheduleEventDAO new];
	ResdbResult*		result = [dao retrieve:[eventId_ fragment]];
			
	if (result.resdbCode == RESDB_SQL_ROWS) {
		ScheduleEvent* scheduleEvent = (ScheduleEvent*)result.resdbObject;
		
		scheduleEvent.weekOfStudy		= [WSClinicalStudy weekOfStudy];
		scheduleEvent.dayInWeekOfStudy  = [WSClinicalStudy dayOfWeekOfStudy];
						
		[dao update: scheduleEvent];
	} else {
		ScheduleEvent* scheduleEvent = [ScheduleEvent new];
			
		scheduleEvent.objectID			= [eventId_ fragment];
		scheduleEvent.dayInWeekOfStudy 	= [WSClinicalStudy dayOfWeekOfStudy];
		scheduleEvent.event				= event_;
		scheduleEvent.weekOfStudy		= [WSClinicalStudy weekOfStudy];
			
		[dao insert: scheduleEvent];
	}
}

@end
