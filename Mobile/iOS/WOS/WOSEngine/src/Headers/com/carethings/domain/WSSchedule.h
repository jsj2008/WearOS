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

typedef enum {
	ScheduleOccuranceUnknown,
	ScheduleOccuranceEachWeek,
	ScheduleOccuranceEachDay,
	ScheduleOccuranceOnceADay
} ScheduleOccurance;

extern NSString* const SCH_ATMOST_EACHWEEK;
extern NSString* const SCH_ATMOST_EACHDAY;
extern NSString* const SCH_ATMOST_ONCEADAY;
extern NSString* const SCH_ATMOST_ONLYONCE;

@class Study;
@class GDataXMLNode;


@interface WSSchedule : NSObject {
	@private
	NSString*       atMost_;                         // Occurance of utterance/response.  For example,  utterance can only be made once a day.
	NSString*       day_;                            // Day of week of utterance/response
	NSString*       timeFrom_;                       // Start time of utterance/response
	NSString*       timeTo_;                         // End time of utterance/response
	NSString*       week_;                           // Week of year of utterance/response
}

@property (nonatomic, copy) NSString* atMost;
@property (nonatomic, copy) NSString* day;
@property (nonatomic, copy) NSString* timeFrom;
@property (nonatomic, copy) NSString* timeTo;
@property (nonatomic, copy) NSString* week;

/*!
   <#Description#>
   @param element<#element description#>
   @returns <#return value description#>
 */
-(bool)isActiveWithStudy : (__unused Study*)study andID : (NSString*)ident;
-(void)causeScheduleEvent : (__unused Study*)study andID : (NSString*)ident;

@end