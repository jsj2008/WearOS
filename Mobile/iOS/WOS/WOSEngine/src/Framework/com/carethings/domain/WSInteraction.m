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

#import "WSInteraction.h"

@implementation WSInteraction;

@synthesize resource = resource_;
@synthesize type = type_;
@synthesize executionMode = executionMode_;
@synthesize header = header_;
@synthesize constraintMaxValue = constraintMaxValue_;
@synthesize constraintMaxValueText = constraintMaxValueText_;
@synthesize constraintMinValue = constraintMinValue_;
@synthesize constraintMinValueText = constraintMinValueText_;
@synthesize constraintMidValue = constraintMidValue_;
@synthesize constraintMidValueText = constraintMidValueText_;
@synthesize constraintMinMidValue = constraintMinMidValue_;
@synthesize constraintMinMidValueText = constraintMinMidValueText_;
@synthesize constraintMidMaxValue = constraintMidMaxValue_;
@synthesize constraintMidMaxValueText = constraintMidMaxValueText_;
@synthesize constraintControlWidth = constraintControlWidth_;
@synthesize constraintBehavior = constraintBehavior_;
@synthesize constraintValueList = constraintValueList_;
@synthesize constraintDataListName = constraintDataListName_;
@synthesize constraintDataType = constraintDataType_;
@synthesize constraintFormat = constraintFormat_;
@synthesize constraintColor = constraintColor_;
@synthesize format = format_;


-(id)copyWithZone:(NSZone*)zone {
    WSInteraction* newInteraction = [super copyWithZone:zone];

    if (resource_ != nil) {
        newInteraction.resource = [[NSURL alloc] initWithString:[resource_ absoluteString]];
    }

    newInteraction.header                       = header_;
    newInteraction.type                         = type_;
    newInteraction.constraintMaxValue           = constraintMaxValue_;
    newInteraction.constraintMaxValueText       = constraintMaxValueText_;
    newInteraction.constraintMidValue           = constraintMidValue_;
    newInteraction.constraintMidValueText       = constraintMidValueText_;
    newInteraction.constraintMinMidValue        = constraintMinMidValue_;
    newInteraction.constraintMinMidValueText    = constraintMinMidValueText_;
    newInteraction.constraintMidMaxValue        = constraintMidMaxValue_;
    newInteraction.constraintMidMaxValueText    = constraintMidMaxValueText_;
    newInteraction.constraintMinValue           = constraintMinValue_;
    newInteraction.constraintMinValueText       = constraintMinValueText_;
    newInteraction.constraintControlWidth       = constraintControlWidth_;
    newInteraction.constraintValueList          = constraintValueList_;
    newInteraction.constraintDataListName       = constraintDataListName_;

    if (constraintBehavior_ != nil) {
        newInteraction.constraintBehavior = [[NSURL alloc] initWithString:[constraintBehavior_ absoluteString]];
    }

    newInteraction.constraintDataType           = constraintDataType_;
    newInteraction.constraintFormat             = constraintFormat_;
    newInteraction.constraintColor              = constraintColor_;

    return newInteraction;
}

- (bool) isInterrogative {
	return (type_ == InteractionHILTypeInterrogativeSingleSelect) || (type_ == InteractionHILTypeInterrogativeMultiSelect) || (type_ == InteractionHILTypeInterrogativeUnstructured)
	? true
	: false;
}

- (bool) isInterrogativeMulti {
	return (type_ == InteractionHILTypeInterrogativeMultiSelect)
	? true
	: false;
}

- (bool) isInterrogativeSingle {
	return (type_ == InteractionHILTypeInterrogativeSingleSelect)
	? true
	: false;
}

- (bool) isInterrogativeUnstructured {
	return (type_ == InteractionHILTypeInterrogativeUnstructured)
	? true
	: false;
}

- (bool) isGoal {
	return (type_ == InteractionHILTypeGoal)
	? true
	: false;
}

- (bool) isTask {
	return (type_ == InteractionHILTypeTask)
	? true
	: false;
}

- (bool) isReward {
	return (type_ == InteractionHILTypeReward)
	? true
	: false;
}

- (bool) isDeclarative {
	return (type_ == InteractionHILTypeDeclarative)
	? true
	: false;
}

-(bool)isImperative {
	return (type_ == InteractionHILTypeImperative)
	? true
	: false;
}

-(bool)isCollection {
	return (type_ == InteractionHILTypeCollection)
	? true
	: false;
}

-(bool)isNotCollection {
    return (type_ != InteractionHILTypeCollection)
            ? true
            : false;
}

- (bool) isResponseFormatNumeric {
    return (format_ == ResponseDataTypeNumeric);
}

- (bool) isResponseFormatPhone {
    return (format_ == ResponseDataTypePhone);
}

- (bool) isResponseFormatMonetary {
    return (format_ == ResponseDataTypeMonetary);
}

- (bool) isResponseFormatDate {
    return (format_ == ResponseDataTypeDate);
}

- (bool) isResponseFormatDateTime {
    return (format_ == ResponseDateTypeDateTime);
}

- (bool) isResponseFormatValueList {
    return (format_ == ResponseDataTypeValueList);   //return ((constraintValueList_ != nil) && ([constraintValueList_ count] > 0)) ? true : false;
}

- (bool) isResponseFormatDataList {
    return (format_ == ResponseDataTypeDataList);
}

@end