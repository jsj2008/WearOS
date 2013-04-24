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


#import <sqlite3.h>
#import "Activity.h"

@class ResdbResult;


@interface ActivityDAO : NSObject {

}

- (ResdbResult*)retrieve:(NSString*)objectID;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID;
- (ResdbResult*)retrieveAll;
- (ResdbResult*)retrieveByUserId:(NSString*)userID andRelatedId:(NSString*)relatedId;
- (ResdbResult*)mostRecentActivityByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code;
- (ResdbResult*)mostRecentActivityWithReason:(NSString*)reason;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andCode:(NSString*)code;
- (ResdbResult*)retrieveByInstanceId:(__unused NSString*)instanceID andType:(__unused NSString *)type;
- (ResdbResult*)retrieveByReason:(NSString*)reason;
- (ResdbResult*)retrieveCountByRelatedIdAndCode:(NSString*)relatedID:(NSString*)code;
- (ResdbResult*)retrieveCount;
- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID andReason:(NSString*)reason;
- (ResdbResult*)retrieveCountByRelatedIdAndReason:(NSString*)relatedID:(NSString*)reason;
- (ResdbResult*)retrieveByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason;
- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId;
- (ResdbResult*)retrieveOrderByRelatedIdReasonForLocationCode:(NSString*)locationCode;
- (ResdbResult*)retrieveOrderByReasonForRelatedId:(NSString*)relatedId andLocationCode:(NSString*)locationCode;
- (ResdbResult*)retrieveUnArchived;
- (ResdbResult*)retrieveUnArchivedByRelatedId:(NSString*)relatedID;
- (ResdbResult*)insert:(Activity*)activity;
- (ResdbResult*)update:(Activity*)activity;
- (ResdbResult*)updateAllArchived;
- (ResdbResult*)updateAllUnArchive;
- (ResdbResult*)updateList:(NSArray*)activitiesToSend;
- (ResdbResult*)delete:(NSString*)objectID;
- (ResdbResult*)deleteAll;
- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID;
- (ResdbResult*)deleteByLocationCode:(NSString*)locationCode;
- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID andCode:(NSString*)code;
- (ResdbResult*)deleteByRelatedId:(NSString *)relatedID andSysID:(NSString*)sysID andReason:(NSString*)reason;
- (ResdbResult*)retrieveByOriginator:(NSString*)originator andLocation:(NSString*)location andAbstractionDate:abDate;
- (ResdbResult*)retrieveOrderByDescCreationForReason:(NSString*)reason;
- (ResdbResult*)retrieveAllWithMonth:(NSString*)month;
- (ResdbResult*)retrieveWithType:(NSString*)type andStartTimeMonth:(NSString*)month;

@end
