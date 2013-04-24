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

#import "GeozoneDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "GeozoneViewController.h"
#import "AlertUtilities.h"
#import "GeozoneViewController.h"
#import "DescriptionViewController.h"
#import "GeozoneDetailAlertDistanceViewController.h"
#import "TextFieldCustomCell.h"
#import "SwitchFieldCustomCell.h"
#import "CoordinateCustomCell.h"
#import "LabelCustomCell.h"
#import "GeozoneMapViewController.h"


@implementation GeozoneDetailViewController

- (NSBundle *)frameworkBundle {
	static NSBundle* frameworkBundle = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
		NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"WOSRender.bundle"];
		frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
	});
	return frameworkBundle;
}

static const int kLabelTag       = 4096;
static const int kTextFieldTag   = 4097;

@synthesize geoPointsData;
@synthesize locationManager;
@synthesize geozone;
@synthesize tempGeozone;
@synthesize fieldLabels;
@synthesize textFieldBeingEdited;
@synthesize animatedDistance;
@synthesize keyboardSize;
@synthesize propsView;
@synthesize coordinatesView;
@synthesize locationBtn;
@synthesize lastAccuracy;
@synthesize activityIndicatorView;
@synthesize mapBtn;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;

- (id)init {
    self = [super initWithNibName:@"GeozoneDetailView" bundle:[self frameworkBundle]];
	
    return self;
}

- (id)initWithNibName:(NSString *)n bundle:(NSBundle *)b {
    return [self init];
}

- (id)initWithCoder:(NSCoder *)inCoder {
	if (self = [super initWithCoder:inCoder]) {
		self = [self init];
	}
	
	return self;
}

- (void)deleteAction:(id)sender {
	if (geozone.objectID != nil) {
		GeozoneDAO*     dao = [GeozoneDAO new];
		[dao delete:[geozone objectID]];
	}
	
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)cancel:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {	
	GeozoneDAO* geoDAO = [GeozoneDAO new];
	
	if (textFieldBeingEdited != nil) {
		switch (textFieldBeingEdited.tag) {
			case kGeozoneNameRowIndex:
				tempGeozone.name = textFieldBeingEdited.text;
				break;
			default:
				break;
		}
	}
	
	if (tempGeozone.name != nil)
		geozone.name = tempGeozone.name;
	if (tempGeozone.description != nil)
		geozone.description = tempGeozone.description;
	if (tempGeozone.alertDistance != nil)
		geozone.alertDistance = tempGeozone.alertDistance;
	if (tempGeozone.active >= 0)
		geozone.active = tempGeozone.active;
		
	if (geozone.objectID == nil) {
		//  This is a new object.
		[geozone allocateObjectId];
		[geoDAO insert:geozone];
	} else {
		[geoDAO update:geozone];
	}
	
	GeoPointDAO* dao = [GeoPointDAO new];
	
	for (GeoPoint* point in self.geoPointsData) {
		point.relatedID = geozone.objectID;
	}
	
	[dao deleteByRelatedId:geozone.objectID];
	[dao insertByArray:self.geoPointsData];	
	
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)loadFromDB {
	GeozoneDAO* dao = [GeozoneDAO new];
	ResdbResult* result;
	
	result = [dao retrievePoints:self.geozone.objectID];
		
	if (result.resdbCode == RESDB_SQL_ROWS) {
		[self.geoPointsData removeAllObjects];
		[self.geoPointsData addObjectsFromArray:result.resdbCollection];
	} else
		[self.geoPointsData removeAllObjects];
}

-(void)viewWillAppear:(BOOL)animated {
	[self.propsView reloadData];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self deleteAction:nil];
	} else if (buttonIndex == 1) {
		[self saveAction:nil];
	}
}

-(void)options:(id)sender {
	UIActionSheet*  popupOptions;
	
	popupOptions = [[UIActionSheet alloc]
					initWithTitle:nil
					delegate:self
					cancelButtonTitle:@"Cancel"
					destructiveButtonTitle:nil
					otherButtonTitles:@"Delete Geozone",@"Save Geozone",nil];
	
	popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
	[popupOptions showInView:self.tabBarController.view];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	geoPointsData         = [NSMutableArray new];
	
	[self loadFromDB];
	
	fieldLabels = [NSMutableArray new];
	
	if (geozone == nil) {
		geozone = [Geozone new];
		geozone.relatedID = WS_ROOT_OBJECT_IDENTIFIER;
		geozone.alertDistance = @"500 meters";
	}
	
	tempGeozone = [Geozone new];
	tempGeozone.active = -1;  // So we can tell if the user change it.
	
    NSArray*      mainArray      = [[NSArray alloc] initWithObjects:@"Name", @"Description", @"Distance", @"Active", nil];
    NSDictionary* mainLabelsDict = [NSDictionary dictionaryWithObject:mainArray forKey:@"Labels"];
	
    [self.fieldLabels addObject:mainLabelsDict];
	
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	self.propsView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	self.coordinatesView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
	
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									  initWithTitle:NSLocalizedString(@"Cancel",nil)
									  style:UIBarButtonItemStylePlain
									  target:self
									  action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self setRightNavigationButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
			
    [super viewDidLoad];	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == propsView) 
		return 4;
	else
		return [self.geoPointsData count];
}

- (IBAction)addCoordinate:(id)sender {
    self.locationManager = [CLLocationManager new];
    locationManager.delegate = self;

	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
	[geoPointsData removeAllObjects];
	[self.coordinatesView reloadData];
	
	[activityIndicatorView startAnimating];
	
    [locationManager startUpdatingLocation];
}

- (IBAction)addMapCoordinate:(id)sender {
	GeozoneMapViewController* childController = [[GeozoneMapViewController alloc] init];
	
	[childController setTitle: NSLocalizedString(@"Map",nil)];
	
	[[self navigationController] pushViewController:childController animated:YES];	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	CLLocationCoordinate2D cord = newLocation.coordinate;
	
	double accuracy = [newLocation horizontalAccuracy];
	
	//if ((accuracy < 0) || (accuracy > 20))
	//	return;
	
	GeoPoint* point = [GeoPoint new];
	
	point.latitude  = cord.latitude;
	point.longitude = cord.longitude;
	point.accuracy  = accuracy;
	[point allocateObjectId];
	
	lastAccuracy = [NSString stringWithFormat:@"%i",(int)accuracy];
	
	//  For now we are going to clear the geoPoints array.  In the future, we will allow the care provider to 
	//  define a multi-point area (a geozone).
	[geoPointsData removeAllObjects];
    [geoPointsData addObject:point];
	
	[self.coordinatesView reloadData];
	
	[activityIndicatorView stopAnimating];
	
	[locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error description]);
}

-(IBAction)textFieldDone:(id)textField {
	[textField resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == coordinatesView)
		return NSLocalizedString(@"Coordinates",nil);
	else
		return nil;
}

-(void)onSwitchChanged:(UISwitch*)activeSwitch {
	if (activeSwitch.tag == kGeozoneActiveRowIndex) {
		tempGeozone.active = [activeSwitch isOn] ? 1 : 0;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger				row = indexPath.row;
	static NSString*		GeozoneTextCellIdentifier = @"GeozoneTextCellIdentifier";
	static NSString*		GeozoneSwitchCellIdentifier = @"GeozoneSwitchCellIdentifier";
	static NSString*		GeozoneLabelCellIdentifier = @"GeozoneLabelCellIdentifier";
	TextFieldCustomCell*    textCell;
	SwitchFieldCustomCell*  switchCell;
	LabelCustomCell*        labelCell;
	CoordinateCustomCell*   coordCell;
	
    if (tableView == coordinatesView) {
		NSUInteger	pointCount = [geoPointsData count];
		
        if (indexPath.row < pointCount) {
			static NSString *PointCellIdentifier = @"GeoPointCell";
			
			coordCell = [tableView dequeueReusableCellWithIdentifier:GeozoneLabelCellIdentifier];
			
			if (coordCell == nil) {
				coordCell = [[CoordinateCustomCell alloc] initWithIdentifier:GeozoneLabelCellIdentifier];
				coordCell.accessoryType = UITableViewCellAccessoryNone;
			}
			
            GeoPoint* point = [geoPointsData objectAtIndex:row];
			coordCell.nameLabel.text = [[NSString alloc] initWithFormat:@"%f / %f",point.latitude, point.longitude];
			coordCell.label.text = [[NSString alloc] initWithFormat:@"%i",(int)point.accuracy];
			coordCell.label.textAlignment = UITextAlignmentRight;
			[coordCell.label setBackgroundColor:[UIColor clearColor]];
			return coordCell;
        } 
    } else {        
		switch ([indexPath row]) {
			case kGeozoneNameRowIndex:
				textCell = [tableView dequeueReusableCellWithIdentifier:GeozoneTextCellIdentifier];
				
				if (textCell == nil) 
					textCell = [[TextFieldCustomCell alloc] initWithIdentifier:GeozoneTextCellIdentifier delegate:self];
				break;
			case kGeozoneDescriptionRowIndex:
			case kGeozoneAlertDistanceRowIndex:
				labelCell = [tableView dequeueReusableCellWithIdentifier:GeozoneLabelCellIdentifier];
				
				if (labelCell == nil)
					labelCell = [[LabelCustomCell alloc] initWithIdentifier:GeozoneLabelCellIdentifier];
				
				labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case kGeozoneActiveRowIndex:
				switchCell = [tableView dequeueReusableCellWithIdentifier:GeozoneSwitchCellIdentifier];
				
				if (switchCell == nil) 
					switchCell = [[SwitchFieldCustomCell alloc] initWithIdentifier:GeozoneSwitchCellIdentifier delegate:self];
				
				switchCell.switchField.tag = kGeozoneActiveRowIndex;
				break;
			default:
				break;
		}
        
        switch (row) {
            case kGeozoneNameRowIndex:
                textCell.nameLabel.text = @"Name";
				textCell.textField.text = (tempGeozone.name != nil) ? tempGeozone.name : geozone.name;
				textCell.textField.tag = row;
				return textCell;
                break;
            case kGeozoneDescriptionRowIndex:
				labelCell.nameLabel.text = @"Description";
				labelCell.label.text = (tempGeozone.description != nil) ? tempGeozone.description : geozone.description;
				labelCell.tag = row;
				labelCell.selectionStyle = UITableViewCellSelectionStyleBlue;
				return labelCell;
                break;
			case kGeozoneAlertDistanceRowIndex:
				labelCell.nameLabel.text = @"Distance";
				labelCell.label.text = (tempGeozone.alertDistance != nil) ? tempGeozone.alertDistance : geozone.alertDistance;
				labelCell.tag = row;
				labelCell.selectionStyle = UITableViewCellSelectionStyleBlue;
				return labelCell;
                break;	
			case kGeozoneActiveRowIndex:
				switchCell.nameLabel.text = @"Active";
				
				if ((tempGeozone.active == 0) || (geozone.active == 0)) 
					[switchCell.switchField setOn:NO];
				else
					[switchCell.switchField setOn:YES];
				return switchCell;
				break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger			section = [indexPath section];
	NSUInteger			row = [indexPath row];
	
	if (tableView == propsView) {
		if ([indexPath row] == kGeozoneDescriptionRowIndex) {
			DescriptionViewController* childController = [[DescriptionViewController alloc] initWithStyle:UITableViewStyleGrouped];
			
			childController.dto = geozone;
			[childController setTitle: NSLocalizedString(@"Description",nil)];
			
			[[self navigationController] pushViewController:childController animated:YES];
		} else if ([indexPath row] == kGeozoneAlertDistanceRowIndex) {
			GeozoneDetailAlertDistanceViewController* childController = [[GeozoneDetailAlertDistanceViewController alloc] initWithStyle:UITableViewStylePlain];
			
			childController.geozone = geozone;
			[childController setTitle: NSLocalizedString(@"Distance",nil)];
			
			[[self navigationController] pushViewController:childController animated:YES];
		}
	}
}

#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	CGRect   textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
	CGFloat  tempDistance = keyboardSize.height + 12;
	
	// Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
	if (textFieldRect.origin.y > tempDistance) {
		CGRect viewFrame = self.view.frame;
		
		animatedDistance = (textFieldRect.origin.y - (keyboardSize.height - TAB_BAR_HEIGHT));
		viewFrame.origin.y -= animatedDistance;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		
		[self.view setFrame:viewFrame];
		
		[UIView commitAnimations];
	} else {
		animatedDistance = 0;
	}	
	
	self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	switch (textField.tag) {
		case kGeozoneNameRowIndex:
			tempGeozone.name = textField.text;
			break;
		default:
			break;
	}
	
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
	[self.view setFrame:viewFrame];
	
	self.textFieldBeingEdited = nil;
    
	[UIView commitAnimations];			
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{	
	NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	
    keyboardSize = [aValue CGRectValue].size;
}

- (void)setRightNavigationButton {
	if (geozone.objectID == nil) {
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemSave
										target:self
										action:@selector(saveAction:)];
		
		self.navigationItem.rightBarButtonItem = saveButton;	
	} else {
		UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
										  target:self
										  action:@selector(options:)];
		
		self.navigationItem.rightBarButtonItem = actionButton;
	}	
}

@end
