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
#import "WSInteraction.h"

@class WSSchedule;
@class Study;
@class GDataXMLNode;
@class WSDomainObject;


//  Types of possible responses
typedef enum {
	ResponseTypeUnknown,
	ResponseTypeFree,				// The response consists of a multi-line text field.
	ResponseTypeFreeFixed,			// The response consists of a single line text field.
	ResponseTypeDirective,			// The response is indicating a directive.
	ResponseTypeFixed,				// The response consists of a select control such as a checkbox or radio button
	ResponseTypeFixedNext,			// The response consists of a select control and executes a NEXT after selection.
	ResponseTypeFixedAsk,           // The response consists of a select control and processes the response (executes behaviors) but remains on the current interaction.
	ResponseTypeGoal,				// The response represents a goal until the actual goal system is introduced.
    ResponseTypeTask,				// The response represents a task expected from the participant.
    ResponseTypeReward,				// The response represents a reward defined for the participant.
	ResponseTypeVAS,				// The response consists of a visual analog scale.
	ResponseTypeDVAS,				// The response consists of a digital visual analog scale.
	ResponseTypeCamera,				// The response consists of enabling the mobile device camera.
	ResponseTypeVideo,				// The response consists of enabling the video player.
	ResponseTypeSensor,				// The response consists of enabling the sensor.
	ResponseTypeVisual,				// The response consists of a data visualization rendering.
    ResponseTypeWebView,            // The response consists of a webview/browser
	ResponseTypeOCR,				// The response consists of OCR using the camera with transformation.
	ResponseTypeScan,				// The response consists of barcode scanning using the camera with transformat
    ResponseTypeCollection,         // The response represents a collection of interactions
} ResponseType;


@interface WSResponse : WSInteraction {
	@private
	NSString*				oid_;							// ID value defined by the designer.  We don't require uniqueness or any pattern.  Left to the designer.
	NSString*				label_;							// label of the response.
	NSURL*					labelResource_;					// Resource for the label
	NSURL*					goalName_;						// Name of the goal.
    NSURL*				    code_;							// Corresponding code/ontology value for this response.
	ResponseType 			responseType_;				    // Type of the response
	NSMutableString*		responseValue_;
	NSMutableData*			responseData_;
	id						control_;
}

@property (nonatomic, copy) NSString* oid;
@property (nonatomic, copy) NSString* label;
@property (nonatomic) NSURL* labelResource;
@property (nonatomic) NSURL* code;
@property (nonatomic) ResponseType responseType;
@property (nonatomic) NSURL* goalName;
@property (nonatomic, copy) NSMutableString* responseValue;
@property (nonatomic, copy) NSMutableData* responseData;
@property (nonatomic) id control;

-(void)addConstraintValue:(NSString*)value;
-(void)addConstraintValues:(NSArray*)values;
-(bool)isResponseValue;
-(NSString*)checkConstraints;
-(bool)isFreeResponse;
-(bool)isFreeFixedResponse;
-(bool)isUnknownResponse;
-(bool)isGoal;
-(bool)isWebView;
-(bool)isDirectiveResponse;
-(bool)isFixedResponse;
-(bool)isFixedNextResponse;
-(bool)isFixedAskResponse;
-(bool)isVasResponse;
-(bool)isDvasResponse;
-(bool)isVisualResponse;
-(bool)isOCRResponse;
-(bool)isBarcodeResponse;
-(bool)hasVideoControl;

@end