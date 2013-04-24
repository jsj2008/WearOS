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

#import "CoordinateCustomCell.h"


@implementation CoordinateCustomCell

static const int kNameLabelTag = 4096;
static const int kLabelTag = 4097;

@synthesize nameLabel;
@synthesize label;

-(id)initWithIdentifier:(NSString*) identifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	
	nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 190, 25)];
	nameLabel.textAlignment = UITextAlignmentLeft;
	nameLabel.tag = kNameLabelTag;
	nameLabel.font = [UIFont boldSystemFontOfSize:14];
	[self.contentView addSubview:nameLabel];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(218, 10, 60, 25)];
	label.textAlignment = UITextAlignmentLeft;
	label.tag = kLabelTag;
	label.font = [UIFont systemFontOfSize:16];
	label.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:217.0 alpha:1.0];
	[self.contentView addSubview:label];
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return self;
}

@end
