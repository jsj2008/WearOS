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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TextFieldCustomCell.h"


@implementation TextFieldCustomCell

static const int kNameLabelTag = 4096;
static const int kTextFieldTag = 4097;

@synthesize nameLabel;
@synthesize textField;

-(id)initWithIdentifier:(NSString*)identifier delegate:(id)del  {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 25)];

	nameLabel.textAlignment = UITextAlignmentLeft;
	nameLabel.tag = kNameLabelTag;
	nameLabel.font = [UIFont boldSystemFontOfSize:14];
	[self.contentView addSubview:nameLabel];

	textField = [[UITextField alloc] initWithFrame: CGRectMake(120, 10, 175, 25)];
	textField.clearsOnBeginEditing = NO;
	textField.returnKeyType = UIReturnKeyDone;
	textField.tag = kTextFieldTag;
	textField.font = [UIFont systemFontOfSize:16];
	textField.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:217.0 alpha:1.0];
	[textField setDelegate:del];
	[textField addTarget:del action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.contentView addSubview:textField];

	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return self;
}

@end
