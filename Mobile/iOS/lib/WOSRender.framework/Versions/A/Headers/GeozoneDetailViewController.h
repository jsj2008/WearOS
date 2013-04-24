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

#import <UIKit/UIKit.h>
#import "NextLevelViewController.h"

@class Geozone;

// The following values represent keys in the tempValues dictionary.  The values are essentially
// the section number and row number of the field in the table view.  The section number is a mulitple of 100 added
// to the row of the field in that section.  Hence, 101 represents a field in section 1 at row 1.

#define kGeozoneNameRowIndex           0
#define  kGeozoneDescriptionRowIndex   1
#define kGeozoneAlertDistanceRowIndex  2
#define kGeozoneActiveRowIndex         3


@interface GeozoneDetailViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate> {
    Geozone*                geozone;
	Geozone*                tempGeozone;
	NSMutableArray*         geoPointsData;
    NSMutableArray*         fieldLabels;
    UITextField*            textFieldBeingEdited;
	CLLocationManager*      locationManager;
	NSMutableString*        lastAccuracy;
	IBOutlet UITableView*   propsView;
	IBOutlet UITableView*   coordinatesView;
	IBOutlet UIButton*      locationBtn;
	IBOutlet UIButton*      mapBtn;
	IBOutlet UIActivityIndicatorView* activityIndicatorView;
	
	CGFloat                 animatedDistance;
	CGSize                  keyboardSize;
}

@property (nonatomic, retain) NSMutableString* lastAccuracy;
@property (nonatomic, retain) Geozone* geozone;
@property (nonatomic, retain) Geozone* tempGeozone;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, retain) NSMutableArray* geoPointsData;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray* fieldLabels;
@property (nonatomic, retain) UITextField* textFieldBeingEdited;
@property (nonatomic) CGFloat animatedDistance;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic, retain) UITableView* propsView;
@property (nonatomic, retain) UITableView* coordinatesView;
@property (nonatomic, retain) UIButton* locationBtn;
@property (nonatomic, retain) UIButton* mapBtn;

- (IBAction)cancel:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (IBAction)addCoordinate:(id)sender;
- (IBAction)addMapCoordinate:(id)sender;

@end
