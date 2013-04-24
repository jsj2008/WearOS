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

#import "PatientDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "TextFieldCustomCell.h"
#import "DeleteCustomCell.h"
#import "SimpleCustomCell2Group.h"
#import "WSStyle.h"
#import "PatientGenderViewController.h"
#import "WSRenderingEngine.h"
#import "AlertUtilities.h"
#import "ImageUtilities.h"
#import "BarcodeScannerViewController.h"

@implementation PatientDetailViewController

static const int kLabelTag = 4096;

@synthesize patient;
@synthesize fieldLabels;
@synthesize tempPatient;
@synthesize textFieldBeingEdited;
@synthesize switchFieldBeingEdited;
@synthesize animatedDistance;
@synthesize keyboardSize;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;

- (void)deleteAction:(id)sender {
    if (patient.objectID != nil) {
        PatientDAO *dao = [PatientDAO new];
        [dao delete:[patient objectID]];
    }

    //OralScreenerAppDelegate *appDelegate = (OralScreenerAppDelegate *) [[UIApplication sharedApplication] delegate];

    //appDelegate.activePatient = nil;

    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setPatientPropertyFromTextField:(UITextField *)textField {
    switch (textField.tag) {
        case kPatientLastNameRowIndex:
            tempPatient.lastName = textField.text;
            break;
        case kPatientFirstNameRowIndex:
            tempPatient.firstName = textField.text;
            break;
        case kPatientNumRowIndex:
            tempPatient.patientNum = textField.text;
            break;
        case kPatientGenderRowIndex:
            tempPatient.gender = textField.text;
            break;
        case kPatientWeightRowIndex:
            tempPatient.weight = textField.text;
            break;
        case kPatientHeightRowIndex:
            tempPatient.height = textField.text;
            break;
        case kPatientDateOfBirthRowIndex:
            tempPatient.dateOfBirth = textField.text;
            break;
        default:
            break;
    }
}

- (IBAction)saveAction:(id)sender {
    if (textFieldBeingEdited != nil) {
        [self setPatientPropertyFromTextField:textFieldBeingEdited];
    }

    if (tempPatient.lastName != nil)
        patient.lastName = tempPatient.lastName;
    if (tempPatient.firstName != nil)
        patient.firstName = tempPatient.firstName;
    if (tempPatient.patientNum != nil)
        patient.patientNum = tempPatient.patientNum;
    if (tempPatient.gender != nil)
        patient.gender = tempPatient.gender;
    if (tempPatient.weight != nil)
        patient.weight = tempPatient.weight;
    if (tempPatient.height != nil)
        patient.height = tempPatient.height;
    if (tempPatient.dateOfBirth != nil)
        patient.dateOfBirth = tempPatient.dateOfBirth;

    if ([StringUtils isEmpty:patient.patientNum]) {
        [AlertUtilities showOkAlert:@"You must specify a participant number."];
        return;
    }

    PatientDAO *dao = [PatientDAO new];

    if (patient.objectID == nil) {
        //  This is a new object.
        [patient allocateObjectId];
		patient.primaryClinic = [OpenPATHContext sharedOpenPATHContext].activeStudy.studySite;
        [dao insert:patient];
    } else {
        [dao update:patient];
    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSString*)generatePatientNum {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	NSString*   uuidStr = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
	NSArray*    splitUUID = [uuidStr componentsSeparatedByString:@"-"];	
	UInt32      randomResult = 0;
	
	SecRandomCopyBytes(kSecRandomDefault, sizeof(int), (uint8_t*)&randomResult);
	
	NSString* finalStr = [[NSString alloc] initWithFormat:@"%@-%@-%i", [splitUUID objectAtIndex:0], [splitUUID objectAtIndex:1], randomResult];
	
	CFRelease(uuidObj);
	
	return finalStr;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    fieldLabels = [NSMutableArray new];

    if (patient == nil) {
        patient = [Patient new];
		
		patient.patientNum = [self generatePatientNum];
    }

    tempPatient = [Patient new];
	
    NSArray *patientArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Last Name", nil), NSLocalizedString(@"First Name", nil), NSLocalizedString(@"Particpant #", nil), NSLocalizedString(@"Gender", nil), NSLocalizedString(@"Weight", nil), NSLocalizedString(@"Height", nil), @"Date of Birth", nil];
    NSDictionary *patientLabelsDict = [NSDictionary dictionaryWithObject:patientArray forKey:@"Labels"];

    [self.fieldLabels addObject:patientLabelsDict];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                 target:self
                                 action:@selector(saveAction:)];
	
	self.tableView.backgroundView  = nil;
	self.tableView.tableFooterView = nil;
	self.tableView.tableHeaderView = nil;
	
	self.tableView.separatorColor  = [UIColor lightGrayColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	
	UIImageView*  imageView = [[UIImageView alloc] initWithImage:[ImageUtilities resizedImage:[UIImage imageWithData:[Base64 decode:style_.background]] rectSize:CGRectMake(0, 0, 320, 480)]];

	self.tableView.backgroundView  = imageView;
	
    self.navigationItem.rightBarButtonItem = saveButton;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
	[self navigationController].navigationBar.barStyle = UIBarStyleBlack;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
	keyboardSize = CGSizeMake(320, 216);

    [super viewDidLoad];
}

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
    if (section == 0) {
        NSDictionary *dictionary = [fieldLabels objectAtIndex:section];
        NSArray *array = [dictionary objectForKey:@"Labels"];
        return [array count];
    } else if ((section == 1) && (patient.objectID != nil))
        return 1;
    else
        return 0;
}

- (IBAction)textFieldDone:(id)textField {
    [textField resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)viewWillAppear:(BOOL)animated {
    if (textFieldBeingEdited != nil) {
        [textFieldBeingEdited resignFirstResponder];
    }

    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        [self deleteAction:nil];
    } else if ([indexPath row] == kPatientNumRowIndex) {
        BarcodeScannerViewController *childController = [[BarcodeScannerViewController alloc] init];

        childController.patient = patient;

        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && ([indexPath row] == kPatientGenderRowIndex)) {
		//self.navigationItem.rightBarButtonItem = saveButton;
		
		PatientGenderViewController *childController = [[PatientGenderViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
		tempPatient.gender = ([StringUtils isEmpty:tempPatient.gender]) ? patient.gender : tempPatient.gender;
		
		childController.patient = tempPatient;
		//childController.navController = [self navController];
		
		[[self navigationController] pushViewController:childController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *PatientTextCellIdentifier = @"PatientTextCellIdentifier";
    static NSString *SimpleCellIdentifier = @"SimpleCellIdentifier";
    static NSString *PatientDeleteCellIdentifier = @"PatientDeleteCellIdentifier";
    TextFieldCustomCell *textCell;
    SimpleCustomCell2Group *simpleCell;
    DeleteCustomCell *deleteCell;

    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];

    if (section == 0) {
        textCell = [tableView dequeueReusableCellWithIdentifier:PatientTextCellIdentifier];

		if (textCell == nil) {
			textCell = [[TextFieldCustomCell alloc] initWithIdentifier:PatientTextCellIdentifier delegate:self];
			textCell.accessoryType = UITableViewCellAccessoryNone;
			textCell.backgroundColor = [UIColor whiteColor];
			
			textCell.nameLabel.textColor = [style_ textColor];
			textCell.nameLabel.font = [style_ fontFromStyle];
			
			textCell.textField.textColor = [UIColor grayColor];
			textCell.textField.font = [style_ fontFromStyle];
		}
		
		simpleCell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];
		
		if (simpleCell == nil) {
			//NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell2Group" owner:self options:nil];
			
			//for (id oneObject in nib)
			//	if ([oneObject isKindOfClass:[SimpleCustomCell2Group class]])
			//		simpleCell = (SimpleCustomCell2Group *) oneObject;
			simpleCell = [[SimpleCustomCell2Group alloc] initWithIdentifier:SimpleCellIdentifier  delegate:self];
			
			simpleCell.accessoryType = UITableViewCellAccessoryNone;
			simpleCell.backgroundColor = [UIColor whiteColor];
			
			simpleCell.nameLabel.textColor = [style_ textColor];
			simpleCell.nameLabel.font = [style_ fontFromStyle];
			simpleCell.nameLabel.backgroundColor = [UIColor whiteColor];
			
			simpleCell.rightLabel.textColor = [UIColor grayColor];
			simpleCell.rightLabel.font = [style_ fontFromStyle];
			simpleCell.rightLabel.backgroundColor = [UIColor whiteColor];
			
			simpleCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

        textCell.textField.tag = row;
        textCell.accessoryType = UITableViewCellAccessoryNone;

        switch (row) {
            case kPatientLastNameRowIndex:
                textCell.nameLabel.text = @"Last Name";
                textCell.textField.text = (tempPatient.lastName != nil) ? tempPatient.lastName : patient.lastName;
                break;
            case kPatientFirstNameRowIndex:
                textCell.nameLabel.text = @"First Name";
                textCell.textField.text = (tempPatient.firstName != nil) ? tempPatient.firstName : patient.firstName;
                break;
            case kPatientNumRowIndex:
            {
                NSString *patientNumStr;

                if (tempPatient.patientNum != nil) {
                    patientNumStr = tempPatient.patientNum;
                } else if (patient.patientNum != nil) {
                    patientNumStr = patient.patientNum;
                } else {
                    patientNumStr = @" ";
                }

                simpleCell.textLabel.text = [NSString stringWithFormat:@"Participant #  %@", patientNumStr];
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                return simpleCell;
            }
                break;
            case kPatientGenderRowIndex:
			{
                NSString *patientGenderStr;
				
                if (tempPatient.gender != nil) {
                    patientGenderStr = tempPatient.gender;
                } else if (patient.gender != nil) {
                    patientGenderStr = patient.gender;
                } else {
                    patientGenderStr = @" ";
                }
				
				simpleCell.nameLabel.text = NSLocalizedString(@"Gender", @"Gender of the member");
				simpleCell.rightLabel.text = NSLocalizedString(patientGenderStr, nil);
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
                return simpleCell;
			}
				break;
            case kPatientWeightRowIndex:
                textCell.nameLabel.text = @"Weight";
                textCell.textField.text = (tempPatient.weight != nil) ? tempPatient.weight : patient.weight;
                break;
            case kPatientHeightRowIndex:
                textCell.nameLabel.text = @"Height";
                textCell.textField.text = (tempPatient.height != nil) ? tempPatient.height : patient.height;
                break;
            case kPatientDateOfBirthRowIndex:
                textCell.nameLabel.text = @"Date of Birth";
                textCell.textField.text = (tempPatient.dateOfBirth != nil) ? tempPatient.dateOfBirth : patient.dateOfBirth;
                break;
            default:
                break;
        }

        return textCell;

    } else if (section == 1) {
        deleteCell = [tableView dequeueReusableCellWithIdentifier:PatientDeleteCellIdentifier];

        if (deleteCell == nil)
            deleteCell = [[DeleteCustomCell alloc] initWithIdentifier:PatientDeleteCellIdentifier];

        return deleteCell;
    }
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];

    // Get the size of the keyboard.
    NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];

    keyboardSize = [aValue CGRectValue].size;
}

#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];

    // Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
    switch (textField.tag) {
        case kPatientLastNameRowIndex:
        case kPatientFirstNameRowIndex:
        case kPatientNumRowIndex:
        case kPatientGenderRowIndex:
            animatedDistance = 0;
            break;

        default:
        {
            CGRect viewFrame = self.view.frame;
			
            animatedDistance = (textFieldRect.origin.y - (keyboardSize.height - TAB_BAR_HEIGHT));
            viewFrame.origin.y -= animatedDistance;
			
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
			
            [self.view setFrame:viewFrame];
			
            [UIView commitAnimations];
        }
    }

    self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setPatientPropertyFromTextField:textField];

    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

@end
