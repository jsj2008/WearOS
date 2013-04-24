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

#import "WSDomainObject.h"

@class GDataXMLNode;
@class WSSchedule;
@class Study;
@class WSScheduleEvent;

// Data formats for text-based responses
typedef enum {
	LanguageTypeUnknown,
	LanguageTypeClips,
	LanguageTypeExpression
} LanguageType;


@interface WSUtteranceRoot : WSDomainObject <NSCopying> {
@protected
	WSSchedule*			schedule_;						// Temporal constraints for this domain object.
	WSScheduleEvent*	scheduleEvent_;					// Generates a schedule event as part of domain object processing.
	NSURL*				controlImage_;					// Rendering-hint if this response should be rendered with an image.
	NSString*			controlType_;					// Rendering-hint if this response should be rendered with a specific control.
	NSString*			controlHeight_;					// Rendering-hint for height of control if this response is rendered with a control.
	NSString*			controlWidth_;					// Rendering-hint for width of control if this response is rendered with a control.
	NSString*			controlFontSize_;
	NSString*			controlFontColor_;
	NSString*			controlFontName_;
	NSString*			controlItem_;
	NSString*			controlTouchX_;					// X offset for touch area
	NSString*			controlTouchY_;					// Y offset for touch area
	NSString*			controlTouchWidth_;				// Width of touch area
	NSString*			controlTouchHeight_;			// Height of touch area
    NSString*           attractor_;
	NSURL*				skipTo_;						// Navigate to specific utterance if this response is selected.
	NSURL*              skipToIntervention_;            // Navigate to specific intervention if this response is selected.
	NSURL*				systemSkipTo_;					// Allows the system to temporarily override the user skipTo.  In most cases, transitions are used instead of skipTos.
	NSMutableArray*		skipCondition_;
	NSMutableArray*		activeCondition_;               // Condition in which this interaction/intervention/response is valid or active
    LanguageType        activeConditionLangType_;       // Language used in the active condition string.  Allows the engine to be able to interpret the string.
	NSURL*				behaviorUserApp_;				// Allows the response designer to execute an "app" when processing this response selection.
	NSString*			behaviorUserComponent_;			// Rendering-hint. Allows the response designer to generate a rendering control when processing this response selection.
	NSString*			behaviorUserForm_;				// Rendering-hint. Allows the response designer to generate a rendering form when processing this response.
	NSString*			behaviorUserItem_;
    NSMutableArray*	    preBehavior_;
    NSMutableArray*		behavior_;
    NSMutableArray*		postBehavior_;
	NSString*			directiveInstruction_;
    NSURL*              directiveInstructionResource_;
	NSURL*				directiveImage_;
	NSURL*				directive_;
	NSURL*				userID_;						// ID value defined by the designer.
	NSURL*				systemID_;						// ID value defined for wStack. Used to locate the corresponding Activity for this response in the database.
    NSURL*              instanceID_;
	NSURL*				ontology_;
	NSString*			rtcDwell_;
	NSString*			rtcDelay_;
	NSString*			rtcSpeed_;
	NSString*			rtc1_;
	NSString*			rtc2_;
	NSMutableArray*		worldModel_;					// Changes to the world model if this response is selected
	NSMutableArray*		shortTermMemory_;
	NSMutableArray*		longTermMemory_;
	NSString*			userValue1_;
	NSString*			userValue2_;
	NSString*			userValue3_;
}

@property (nonatomic) WSSchedule* schedule;
@property (nonatomic) WSScheduleEvent* scheduleEvent;
@property (nonatomic) NSURL* controlImage;
@property (nonatomic, copy) NSString* controlType;
@property (nonatomic, copy) NSString* controlHeight;
@property (nonatomic, copy) NSString* controlWidth;
@property (nonatomic, copy) NSString* controlItem;
@property (nonatomic, copy) NSString* controlFontSize;
@property (nonatomic, copy) NSString* controlFontColor;
@property (nonatomic, copy) NSString* controlFontName;
@property (nonatomic, copy) NSString* controlTouchX;
@property (nonatomic, copy) NSString* controlTouchY;
@property (nonatomic, copy) NSString* controlTouchWidth;
@property (nonatomic, copy) NSString* controlTouchHeight;
@property (nonatomic, copy) NSString* attractor;
@property (nonatomic) NSURL* skipTo;
@property (nonatomic) NSURL* skipToIntervention;
@property (nonatomic) NSURL* systemSkipTo;
@property (nonatomic) NSMutableArray* skipCondition;
@property (nonatomic) NSMutableArray* activeCondition;
@property (nonatomic) LanguageType activeConditionLangType;
@property (nonatomic) NSURL* behaviorUserApp;
@property (nonatomic, copy) NSString* behaviorUserComponent;
@property (nonatomic, copy) NSString* behaviorUserForm;
@property (nonatomic, copy) NSString* behaviorUserItem;
@property (nonatomic, copy) NSString* directiveInstruction;
@property (nonatomic) NSURL* directiveInstructionResource;
@property (nonatomic) NSURL* directiveImage;
@property (nonatomic) NSURL* directive;
@property (nonatomic) NSMutableArray* preBehavior;
@property (nonatomic) NSMutableArray* behavior;
@property (nonatomic) NSMutableArray* postBehavior;
@property (nonatomic) NSMutableArray* worldModel;
@property (nonatomic) NSMutableArray* shortTermMemory;
@property (nonatomic) NSMutableArray* longTermMemory;
@property (nonatomic) NSURL* userID;
@property (nonatomic) NSURL* systemID;
@property (nonatomic) NSURL* instanceID;
@property (nonatomic) NSURL* ontology;
@property (nonatomic, copy) NSString* rtcDwell;
@property (nonatomic, copy) NSString* rtcDelay;
@property (nonatomic, copy) NSString* rtcSpeed;
@property (nonatomic, copy) NSString* rtc1;
@property (nonatomic, copy) NSString* rtc2;
@property (nonatomic, copy) NSString* userValue1;
@property (nonatomic, copy) NSString* userValue2;
@property (nonatomic, copy) NSString* userValue3;

/*!
   <#Description#>
   @param element<#element description#>
   @returns <#return value description#>
 */
-(int)isActiveInStudy : (Study*)study;
-(void)causeScheduleEvent : (Study*)study;
-(void)addPreBehaviorWithURL:(NSURL*)behavior;
-(void)addPreBehavior:(NSString*)behavior;
-(void)addBehaviorWithURL:(NSURL*)behavior;
-(void)addBehavior:(NSString*)behavior;
-(void)addPostBehaviorWithURL:(NSURL*)behavior;
-(void)addPostBehavior:(NSString*)behavior;
-(BOOL)isEqual:(WSUtteranceRoot*)utterance;
-(id)copyWithZone:(NSZone*)zone;

@end