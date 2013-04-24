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

#import "RenderStyleDAO.h"
#import "WSResourceManager.h"
#import "RenderStyle.h"
#import "ResdbResult.h"
#import "StringUtils.h"


@implementation RenderStyleDAO

- (id)allocateDaoObject {
    return [RenderStyle new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    RenderStyle* renderStyle = (RenderStyle*)daoObject;

    if ((renderStyle == nil) || (sqlRow == nil))
        return;

    int i = 0;

    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.textColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.textFontSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.textFontFamily = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.questionColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.questionFontSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.questionFontFamily = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.headerColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.headerFontSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.headerFontFamily = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.choiceTextColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.choiceFontSize = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.choiceFontFamily = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.responseBorderColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.backgroundColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.separatorColor = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.nextButtonText = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.previousButtonText = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.homeButtonText = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow, i++)))
        renderStyle.theme = [NSString stringWithUTF8String:textPtr];
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID,creationTime, description, textColor, textFontSize, textFontFamily, questionColor, questionFontSize, questionFontFamily, headerColor, headerFontSize, headerFontFamily, choiceTextColor, choiceFontSize, choiceFontFamily, responseBorderColor, backgroundColor, separatorColor, nextButtonText, previousButtonText, homeButtonText, theme from RenderStyle where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:objectID, nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
    NSString* sql = @"select objectID, creationTime, description, textColor, textFontSize, textFontFamily, questionColor, questionFontSize, questionFontFamily, headerColor, headerFontSize, headerFontFamily, choiceTextColor, choiceFontSize, choiceFontFamily, responseBorderColor, backgroundColor, separatorColor, nextButtonText, previousButtonText, homeButtonText, theme from RenderStyle";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(RenderStyle*)renderStyle {
    NSString*       sql    = @"INSERT into RenderStyle (objectID, description, textColor, textFontSize, textFontFamily, questionColor, questionFontSize, questionFontFamily, headerColor, headerFontSize, headerFontFamily, choiceTextColor, choiceFontSize, choiceFontFamily, responseBorderColor, backgroundColor, separatorColor, nextButtonText, previousButtonText, homeButtonText, theme) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSMutableArray *params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:renderStyle.objectID] ? [NSNull null] : renderStyle.objectID),
                                                              ([StringUtils isEmpty:renderStyle.description] ? [NSNull null] : renderStyle.description),
                                                              ([StringUtils isEmpty:renderStyle.textColor] ? [NSNull null] : renderStyle.textColor),
                                                              ([StringUtils isEmpty:renderStyle.textFontSize] ? [NSNull null] : renderStyle.textFontSize),
                                                              ([StringUtils isEmpty:renderStyle.textFontFamily] ? [NSNull null] : renderStyle.textFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.questionColor] ? [NSNull null] : renderStyle.questionColor),
                                                              ([StringUtils isEmpty:renderStyle.questionFontSize] ? [NSNull null] : renderStyle.questionFontSize),
                                                              ([StringUtils isEmpty:renderStyle.questionFontFamily] ? [NSNull null] : renderStyle.questionFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.headerColor] ? [NSNull null] : renderStyle.headerColor),
                                                              ([StringUtils isEmpty:renderStyle.headerFontSize] ? [NSNull null] : renderStyle.headerFontSize),
                                                              ([StringUtils isEmpty:renderStyle.headerFontFamily] ? [NSNull null] : renderStyle.headerFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.choiceTextColor] ? [NSNull null] : renderStyle.choiceTextColor),
                                                              ([StringUtils isEmpty:renderStyle.choiceFontSize] ? [NSNull null] : renderStyle.choiceFontSize),
                                                              ([StringUtils isEmpty:renderStyle.choiceFontFamily] ? [NSNull null] : renderStyle.choiceFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.responseBorderColor] ? [NSNull null] : renderStyle.responseBorderColor),
                                                              ([StringUtils isEmpty:renderStyle.backgroundColor] ? [NSNull null] : renderStyle.backgroundColor),
                                                              ([StringUtils isEmpty:renderStyle.separatorColor] ? [NSNull null] : renderStyle.separatorColor),
                                                              ([StringUtils isEmpty:renderStyle.nextButtonText] ? [NSNull null] : renderStyle.nextButtonText),
                                                              ([StringUtils isEmpty:renderStyle.previousButtonText] ? [NSNull null] : renderStyle.previousButtonText),
                                                              ([StringUtils isEmpty:renderStyle.homeButtonText] ? [NSNull null] : renderStyle.homeButtonText),
                                                              ([StringUtils isEmpty:renderStyle.theme] ? [NSNull null] : renderStyle.theme), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(RenderStyle*)renderStyle {
    NSString*       sql = @"UPDATE RenderStyle SET objectID = ?, description = ?, textColor = ?, textFontSize = ?, textFontFamily = ?, questionColor = ?, questionFontSize = ?, questionFontFamily = ?, headerColor = ?, headerFontSize = ?, headerFontFamily = ?, choiceTextColor = ?, choiceFontSize = ?, choiceFontFamily = ?, responseBorderColor = ?, backgroundColor = ?, separatorColor = ?, nextButtonText = ?, previousButtonText = ?, homeButtonText = ?, theme = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:renderStyle.objectID] ? [NSNull null] : renderStyle.objectID),
                                                              ([StringUtils isEmpty:renderStyle.description] ? [NSNull null] : renderStyle.description),
                                                              ([StringUtils isEmpty:renderStyle.textColor] ? [NSNull null] : renderStyle.textColor),
                                                              ([StringUtils isEmpty:renderStyle.textFontSize] ? [NSNull null] : renderStyle.textFontSize),
                                                              ([StringUtils isEmpty:renderStyle.textFontFamily] ? [NSNull null] : renderStyle.textFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.questionColor] ? [NSNull null] : renderStyle.questionColor),
                                                              ([StringUtils isEmpty:renderStyle.questionFontSize] ? [NSNull null] : renderStyle.questionFontSize),
                                                              ([StringUtils isEmpty:renderStyle.questionFontFamily] ? [NSNull null] : renderStyle.questionFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.headerColor] ? [NSNull null] : renderStyle.headerColor),
                                                              ([StringUtils isEmpty:renderStyle.headerFontSize] ? [NSNull null] : renderStyle.headerFontSize),
                                                              ([StringUtils isEmpty:renderStyle.headerFontFamily] ? [NSNull null] : renderStyle.headerFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.choiceTextColor] ? [NSNull null] : renderStyle.choiceTextColor),
                                                              ([StringUtils isEmpty:renderStyle.choiceFontSize] ? [NSNull null] : renderStyle.choiceFontSize),
                                                              ([StringUtils isEmpty:renderStyle.choiceFontFamily] ? [NSNull null] : renderStyle.choiceFontFamily),
                                                              ([StringUtils isEmpty:renderStyle.responseBorderColor] ? [NSNull null] : renderStyle.responseBorderColor),
                                                              ([StringUtils isEmpty:renderStyle.backgroundColor] ? [NSNull null] : renderStyle.backgroundColor),
                                                              ([StringUtils isEmpty:renderStyle.separatorColor] ? [NSNull null] : renderStyle.separatorColor),
                                                              ([StringUtils isEmpty:renderStyle.nextButtonText] ? [NSNull null] : renderStyle.nextButtonText),
                                                              ([StringUtils isEmpty:renderStyle.previousButtonText] ? [NSNull null] : renderStyle.previousButtonText),
                                                              ([StringUtils isEmpty:renderStyle.homeButtonText] ? [NSNull null] : renderStyle.homeButtonText),
                                                              ([StringUtils isEmpty:renderStyle.theme] ? [NSNull null] : renderStyle.theme),
                                                              ([StringUtils isEmpty:renderStyle.objectID] ? [NSNull null] : renderStyle.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:nil];
}


- (ResdbResult*)deleteAll {
    NSString* sql = @"delete from RenderStyle";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString*       sql    = @"delete from RenderStyle where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:objectID, nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end