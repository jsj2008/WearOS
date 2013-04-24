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
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation
 *         and/or other materials provided with the distribution.
 *	3. Neither the name of CareThings nor the names of its contributors may be used to endorse or promote products derived from this software without specific
 *         prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Flag defines
#define  CU_SET_FLAG(flagValue, flagField)             flagField |= (flagValue)
#define  CU_RESET_FLAG(flagValue, flagField)           flagField &= ~(flagValue)
#define  CU_IS_FLAG_SET(flagValue, flagField)          (flagField & (flagValue))

#import "Base64.h"
#import "BiArrayEnumerator.h"
#import "ByteDecoder.h"
#import "CSVSerialization.h"
#import "DateFormatter.h"
#import "GDataXMLNode.h"
#import "JSONSerialization.h"
#import "MemoryUtilities.h"
#import "Node.h"
#import "NSString+JSON.h"
#import "NSString+XMLEntities.h"
#import "Queue.h"
#import "ResourceIdentityGenerator.h"
#import "Stack.h"
#import "StringUtils.h"
#import "SynthesizeSingleton.h"
#import "UIImage+UIImageFunctions.h"

// DDMathParser
#import "_DDFunctionContainer.h"
#import "_DDFunctionExpression.h"
#import "_DDFunctionTerm.h"
#import "_DDFunctionUtilities.h"
#import "_DDGroupTerm.h"
#import "_DDNumberExpression.h"
#import "_DDNumberTerm.h"
#import "_DDOperatorInfo.h"
#import "_DDOperatorTerm.h"
#import "_DDParserTerm.h"
#import "_DDRewriteRule.h"
#import "_DDVariableExpression.h"
#import "_DDVariableTerm.h"
#import "DDExpression.h"
#import "DDMathEvaluator+Private.h"
#import "DDMathEvaluator.h"
#import "DDMathParser.h"
#import "DDMathParserMacros.h"
#import "DDMathStringToken.h"
#import "DDMathStringTokenizer.h"
#import "DDParser.h"
#import "DDParserTypes.h"
#import "DDTypes.h"
#import "NSString+DDMathParsing.h"

