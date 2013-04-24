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

#import "WSResponse.h"
#import "WSStringUtils.h"

@implementation WSResponse

@synthesize oid = oid_;
@synthesize label = label_;
@synthesize labelResource = labelResource_;
@synthesize code = code_;
@synthesize responseType = responseType_;
@synthesize responseValue = responseValue_;
@synthesize goalName = goalName_;
@synthesize responseData = responseData_;
@synthesize control = control_;


-(id)init {
    if ((self = [super init])) {
        type_ = InteractionHILTypeResponse;
    }
    return self;
}

- (bool) isFreeResponse {
	return (responseType_ == ResponseTypeFree);
}

- (bool) isFreeFixedResponse {
	return (responseType_ == ResponseTypeFreeFixed);
}

- (bool) isDirectiveResponse {
	return (responseType_ == ResponseTypeDirective);
}

- (bool) isUnknownResponse {
	return (responseType_ == ResponseDataTypeUnknown);
}

- (bool) isFixedResponse {
	return (responseType_ == ResponseTypeFixed);
}

- (bool) isFixedNextResponse {
	return (responseType_ == ResponseTypeFixedNext);
}

- (bool) isFixedAskResponse {
	return (responseType_ == ResponseTypeFixedAsk);
}

- (bool) isGoal {
	return (responseType_ == ResponseTypeGoal);
}

- (bool) isTask {
	return (responseType_ == ResponseTypeTask);
}

-(bool)isWebView {
    return (responseType_ == ResponseTypeWebView);
}

- (bool) isReward {
	return (responseType_ == ResponseTypeReward);
}

- (bool) isVasResponse {
	return (responseType_ == ResponseTypeVAS);
}

- (bool) isDvasResponse {
	return (responseType_ == ResponseTypeDVAS);
}

- (bool) isVisualResponse {
	return (responseType_ == ResponseTypeVisual);
}

- (bool) isOCRResponse {
	return (responseType_ == ResponseTypeOCR);
}

- (bool) isBarcodeResponse {
	return (responseType_ == ResponseTypeScan);
}

- (bool) hasVideoControl {
	if ([WSStringUtils isNotEmpty:controlType_] && [controlType_ isEqualToString:@"Video"])
		return true;
	
	return false;
}

- (bool) isResponseValue {
	return (![WSStringUtils isEmpty: responseValue_]);
}

- (NSString*) checkConstraints {
	NSMutableString* constraintError = [NSMutableString new];
	
	if (![self isFreeFixedResponse]) {
		return nil;
	}

	if (![WSStringUtils isEmpty: constraintMinValue_]) {
		if ([self isResponseFormatNumeric]) {
			if (![[NSScanner scannerWithString:responseValue_] scanInt:nil]) {
				return nil;
			}
			
			int minValue  	= [constraintMinValue_ intValue];
			int respVal     = [responseValue_ intValue];

			if (respVal < minValue) {
				if ([WSStringUtils isEmpty: constraintError]) {
					[constraintError appendFormat: @"The value must be greater than %@", constraintMinValue_];
				} else   {
					[constraintError appendFormat: @" and greater than %@", constraintMinValue_];
				}
			}
		}
	}

	if (![WSStringUtils isEmpty: constraintMaxValue_]) {
		if ([self isResponseFormatNumeric]) {
			if (![[NSScanner scannerWithString:responseValue_] scanInt:nil]) {
				return nil;
			}
			
			int maxValue  = [constraintMaxValue_ intValue];
			int respVal     = [responseValue_ intValue];

			if (respVal > maxValue) {
				if ([WSStringUtils isEmpty: constraintError]) {
					[constraintError appendFormat: @"The value must be less than %@", constraintMaxValue_];
				} else   {
					[constraintError appendFormat: @" and less than %@", constraintMaxValue_];
				}
			}
		}
	}

	return constraintError;
}

- (void)addConstraintValue:(NSString *)value {
	if ([WSStringUtils isNotEmpty:value]) {
		if (constraintValueList_ == nil)
            constraintValueList_ = [NSMutableArray arrayWithCapacity: 1];

		[constraintValueList_ addObject: value];
	}
}

- (void)addConstraintValues:(NSArray *)values {
	if (values != nil) {
		if (constraintValueList_ == nil)
            constraintValueList_ = [NSMutableArray arrayWithCapacity: 1];

		[constraintValueList_ addObjectsFromArray: values];
	}
}

@end