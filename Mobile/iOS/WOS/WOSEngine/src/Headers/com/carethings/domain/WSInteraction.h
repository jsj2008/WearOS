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

#import "WSUtteranceRoot.h"

@class Study;

//  Types of possible Interactions
typedef enum {
	InteractionTypeUnknown,
    InteractionTypePatternOfBehavior,
	InteractionHILTypeUnknown,
    InteractionHILTypeResponse,
	InteractionHILTypeInterrogativeMultiSelect,
	InteractionHILTypeInterrogativeSingleSelect,
	InteractionHILTypeInterrogativeUnstructured,
	InteractionHILTypeImperative,
	InteractionHILTypeGoal,
    InteractionHILTypeTask,
    InteractionHILTypeReward,
	InteractionHILTypeDeclarative,
    InteractionHILTypeCollection,
} InteractionType;

// Supported modes of execution at the Interaction level
typedef enum {
    InteractionExecutionModeSequential,
    InteractionExecutionModeParallel,
    InteractionExecutionModeDataFlow,
    InteractionExecutionModeUser,
} InteractionExecutionMode;

// Data formats for text-based responses
typedef enum {
	ConstraintDataTypeUnknown,
    ConstraintDataTypeNumeric,
    ConstraintDataTypeAlpha,
    ConstraintDataTypeDate,
    ConstraintDateTypeDateTime,
    ConstraintDataTypeValueList,
    ConstraintDataTypeDataList,
    ConstraintDataTypePhone,
    ConstraintDataTypeMonetary,
    ConstraintDataTypeTime,
    ConstraintDataTypeEmail,
    ConstraintDataTypeZipcode,
    ConstraintDataTypeSSN,
    ConstraintDataTypeInteger
} ConstraintDataType;

// Data formats for text-based responses
typedef enum {
    ResponseDataTypeUnknown,
    ResponseDataTypeNumeric,
    ResponseDataTypeAlpha,
    ResponseDataTypeDate,
    ResponseDateTypeDateTime,
    ResponseDataTypeValueList,
    ResponseDataTypeDataList,
    ResponseDataTypePhone,
    ResponseDataTypeMonetary
} ResponseDataType;


/*! @class Test
 *  @brief A short description.
 *
 *  More text.
 */
@interface WSInteraction : WSUtteranceRoot <NSCopying> {
@protected
	NSURL*					  resource_;			        // Resource charged with the execution of the interaction
    NSString*				  header_;		                // header for the interaction.
	InteractionType			  type_;				        // Type of the interaction.  For example, Declaritive, Imperative, Goal.
    InteractionExecutionMode  executionMode_;               // For interactions of type "Protocol", how to execute the sub-interactions.
    NSString*				  constraintMaxValue_;			// Max value constraint for response.
   	NSString*				  constraintMaxValueText_;		// Text value associated with the max value (e.g. "extreme pain")
    NSString*				  constraintMidValue_;			// Mid value constraint for response.
    NSString*				  constraintMidValueText_;		// Text value associated with the mid value (e.g. "some pain")
    NSString*				  constraintMinMidValue_;		// Min-Mid value constraint for response.
    NSString*				  constraintMinMidValueText_;	// Text value associated with the min-mid value (e.g. "litle pain")
    NSString*				  constraintMidMaxValue_;       // Mid-Max value constraint for response.
    NSString*				  constraintMidMaxValueText_;   // Text value associated with the mid-max value (e.g. "major pain")
   	NSString*				  constraintMinValue_;			// Min value constraint for response.
   	NSString*				  constraintMinValueText_;		// Text value associated with the min value (e.g. "no pain")
   	NSString*				  constraintControlWidth_;		// Rendering-hint for any control generated for this response.
   	NSMutableArray*			  constraintValueList_;			// Domain (list of values) for this response.
   	NSString*				  constraintDataListName_;		// Name of the "data" object containing the list of values. For example, DAO table name.
   	NSURL*					  constraintBehavior_;			// Behavior invoked as part of the constraint processing.
    ConstraintDataType        constraintDataType_;          // Expected domain of the data values for the interaction responses
    NSString*                 constraintFormat_;            // Expected format of the data values
    NSString*                 constraintColor_;             // Color constraint
    ResponseDataType		  format_;		      // Rendering-hint indicating the expected type of response (e.g. numeric).
}

@property (nonatomic) NSURL* resource;
@property (nonatomic) InteractionType type;
@property (nonatomic) InteractionExecutionMode  executionMode;
@property (nonatomic, copy) NSString* header;
@property (nonatomic, copy) NSString* constraintMaxValue;
@property (nonatomic, copy) NSString* constraintMaxValueText;
@property (nonatomic, copy) NSString* constraintMinValue;
@property (nonatomic, copy) NSString* constraintMinValueText;
@property (nonatomic, copy) NSString* constraintMidValue;
@property (nonatomic, copy) NSString* constraintMidValueText;
@property (nonatomic, copy) NSString* constraintMinMidValue;
@property (nonatomic, copy) NSString* constraintMinMidValueText;
@property (nonatomic, copy) NSString* constraintMidMaxValue;
@property (nonatomic, copy) NSString* constraintMidMaxValueText;
@property (nonatomic, copy) NSString* constraintControlWidth;
@property (nonatomic) NSURL* constraintBehavior;
@property (nonatomic) NSMutableArray* constraintValueList;
@property (nonatomic) NSString* constraintDataListName;
@property (nonatomic) ConstraintDataType constraintDataType;
@property (nonatomic, copy) NSString* constraintFormat;
@property (nonatomic, copy) NSString* constraintColor;
@property (nonatomic) ResponseDataType format;

-(bool)isInterrogative;
-(bool)isInterrogativeMulti;
-(bool)isInterrogativeSingle;
-(bool)isInterrogativeUnstructured;
-(bool)isImperative;
-(bool)isGoal;
-(bool)isTask;
-(bool)isReward;
-(bool)isCollection;
-(bool)isNotCollection;
-(bool)isDeclarative;
-(bool)isResponseFormatNumeric;
-(bool)isResponseFormatPhone;
-(bool)isResponseFormatMonetary;
-(bool)isResponseFormatDate;
-(bool)isResponseFormatDateTime;
-(bool)isResponseFormatValueList;
-(bool)isResponseFormatDataList;
-(id)copyWithZone:(NSZone*)zone;

@end