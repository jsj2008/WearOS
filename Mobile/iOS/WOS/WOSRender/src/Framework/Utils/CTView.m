/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *			When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author	Larry Suarez
 *  @package com.carethings.domain
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

#import "CTView.h"
#import <CoreText/CoreText.h>
#import "MarkupParser.h"
#import "CTColumnView.h"

@implementation CTView

@synthesize attString;
@synthesize frames;
@synthesize images;
@synthesize maxColumns;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMaxColumns:1];
    }
    return self;
}

- (void)buildFrames {
    if (self.maxColumns == 0)
        self.maxColumns = 1;

    frameXOffset = 20; //1
    frameYOffset = 20;
    self.pagingEnabled = YES;
    self.delegate = self;
    self.frames = [NSMutableArray array];

    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset);
    CGPathAddRect(path, NULL, textFrame);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);

    int textPos = 0; //3
    int columnIndex = 0;

    while (textPos < [attString length]) { //4
        CGPoint colOffset = CGPointMake((columnIndex + 1) * frameXOffset + columnIndex * (textFrame.size.width / maxColumns), 20);
        CGRect colRect = CGRectMake(0, 0, textFrame.size.width / 2 - 10, textFrame.size.height - 40);

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);

        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5

        //create an empty column view
        CTColumnView *content = [[CTColumnView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height);

        //set the column view contents and add it as subview
        [content setCTFrame:(__bridge id) frame];  //6
        //[self attachImagesWithFrame:frame inColumnView:content];
        [self.frames addObject:(__bridge id) frame];
        [self addSubview:content];

        //prepare for next frame
        textPos += frameRange.length;

        //CFRelease(frame);
        CFRelease(path);

        columnIndex++;
    }

    //set the total width of the scroll view
    int totalPages = (columnIndex + 1) / maxColumns; //7
    self.contentSize = CGSizeMake(totalPages * self.bounds.size.width, textFrame.size.height);
}

- (void)setAttString:(NSAttributedString *)string withImages:(NSArray *)imgs {
    self.attString = string;
    self.images = imgs;
}

- (void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView *)col {
    //drawing images
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(f); //1

    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2

    int imgIndex = 0; //3
    NSDictionary *nextImage = [self.images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];

    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while (imgLocation < frameRange.location) {
        imgIndex++;
        if (imgIndex >= [self.images count]) return; //quit if no images for this column
        nextImage = [self.images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }

    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef) lineObj;

        for (id runObj in (__bridge NSArray *) CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef) runObj;
            CFRange runRange = CTRunGetStringRange(run);

            if (runRange.location <= imgLocation && runRange.location + runRange.length > imgLocation) { //7
                CGRect runBounds;
                CGFloat ascent;//height above the baseline
                CGFloat descent;//height below the baseline
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
                runBounds.size.height = ascent + descent;

                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
                runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset + frameXOffset;
                runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + frameYOffset;
                runBounds.origin.y -= descent;

                UIImage *img = [UIImage imageNamed:[nextImage objectForKey:@"fileName"]];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);

                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x - frameXOffset - self.contentOffset.x, colRect.origin.y - frameYOffset - self.frame.origin.y);
                [col.images addObject: //11
                                       [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds), nil]
                ];
                //load the next image //12
                imgIndex++;
                if (imgIndex < [self.images count]) {
                    nextImage = [self.images objectAtIndex:imgIndex];
                    imgLocation = [[nextImage objectForKey:@"location"] intValue];
                }

            }
        }
        lineIndex++;
    }
}

- (void)dealloc {
    self.attString = nil;
    self.frames = nil;
    self.images = nil;
}

@end
