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

#import "SettingsViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "TextFieldCustomCell.h"
#import "SettingsResearcherViewController.h"
#import "SettingsSurveyLanguageViewController.h"
#import "SettingsResearcherLanguageViewController.h"
#import "LabelCustomCell.h"
#import "SettingsCoachViewController.h"
#import "SettingsAlarmStartTimeViewController.h"
#import "SettingsParticipantIDViewController.h"
#import "SettingsPasscodeViewController.h"
#import "SettingsUserNameViewController.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "GeozoneViewController.h"
#import "AlertViewController.h"
#import "SettingsStudySiteViewController.h"
#import "SettingsPhaseViewController.h"
#import "AlertUtilities.h"
#import "SettingsTimerViewController.h"

@implementation SettingsViewController

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

static const int kLabelTag = 4096;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;

- (id)init {
    self = [super initWithNibName:@"SettingsViewController" bundle:[self frameworkBundle]];
	
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

- (void)setNoParent:(BOOL)value {
	noParent = value;
}

- (IBAction)backAction:(id)sender {
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingSite && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studySite]) {
		[AlertUtilities showOkAlert:@"You must specify a study site"];
		return;
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingAlarm && ![OpenPATHContext sharedOpenPATHContext].activeTimer.active) {
		[AlertUtilities showOkAlert:@"You must specify an alarm"];
		return;
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingAuthentication && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activeSecurity.password]) {
		[AlertUtilities showOkAlert:@"You must specify a login password"];
		return;
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingResearcher && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher]) {
		[AlertUtilities showOkAlert:@"You must specify a researcher name"];
		return;
	}
	//if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingGeozone && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studySite]) {
	//	[AlertUtilities showOkAlert:@"You must specify a geozone"];
	//	return;
	//}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingParticipantId && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum]) {
		[AlertUtilities showOkAlert:@"You must specify a participant identifier"];
		return;
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettingUserName && [WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.firstName]) {
		[AlertUtilities showOkAlert:@"You must specify a user name"];
		return;
	}
	
	// No need to save the researcher name nor the site name.  Those values were saved in the Researcher Name controller and the Site Name controller.
	
	[[OpenPATHContext sharedOpenPATHContext] saveActivePatient];
	[[OpenPATHContext sharedOpenPATHContext] saveActiveStudy];
	
	if ([self.parentViewController.presentingViewController.presentedViewController isEqual:self.parentViewController]) {
		[self dismissViewControllerAnimated:YES completion:nil];	
	} else {
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

/*
 - (void)scheduleNotification {
 UILocalNotification *notification = [[UILocalNotification alloc] init];
 
 [[UIApplication sharedApplication] cancelAllLocalNotifications];
 
 NSDateFormatter *usDateFormatter = [NSDateFormatter new];
 
 [usDateFormatter setDateFormat:@"HH:mm"];
 [usDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
 
 NSDate *alarmDate = [usDateFormatter dateFromString:alarmTime];
 
 notification.fireDate = alarmDate;
 notification.timeZone = [NSTimeZone localTimeZone];
 notification.repeatInterval = NSDayCalendarUnit;
 
 notification.alertBody = @"Please fill in your diary";
 
 notification.soundName = UILocalNotificationDefaultSoundName;
 
 [[UIApplication sharedApplication] scheduleLocalNotification:notification];
 }
 */

- (NSString*)locateSiteName {
	if ([StringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studySite]) {
		SiteDAO*      dao = [SiteDAO new];
		ResdbResult*  result;
		
		result = [dao retrieve:[OpenPATHContext sharedOpenPATHContext].activeStudy.studySite];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			return ((Site*)result.resdbObject).name;
		}
	}
	
	return @"";
}

- (NSString*)locateResearcherName {
	if ([StringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher]) {
		UserDAO*      dao = [UserDAO new];
		ResdbResult*  result;
		
		result = [dao retrieve:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryResearcher];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			return ((User*)result.resdbObject).lastName;
		}
	}
	
	return @"";
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
    fieldLabels = [NSMutableArray new];
	
	self.title = @"Settings";
	
	features_ = [[NSMutableArray alloc] initWithCapacity:10];
	
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasPhases) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingsPhaseRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasReminders) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingsAlarmTimeRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasAuthentication) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingsPasscodeRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasParticipantIDSettings) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingsParticipantIDRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasUserNameSettings) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingsUserNameRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasResearcherSettings) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingResearcherRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasSiteSettings) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingSiteRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasVirtualCoach) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingVirtualCoachRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasLanguages) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingLanguageRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasDesktopPhoto) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingDesktopPhotoRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasGeozones) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingGeozoneRowIndex]];
	}
	if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasResearcherLanguage) {
		[features_ addObject:[[NSNumber alloc] initWithInt:kSettingResearcherLanguageRowIndex]];
	}
	
	imagePickerController                    = [[UIImagePickerController alloc] init];
	imagePickerController.allowsImageEditing = YES;
	imagePickerController.delegate           = self;
	imagePickerController.sourceType         = UIImagePickerControllerSourceTypePhotoLibrary;
	
    study = [OpenPATHContext sharedOpenPATHContext].activeStudy;
    tempStudy = [Study new];
	
    NSArray *patientArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Researcher", nil), NSLocalizedString(@"Clinic", nil), NSLocalizedString(@"Language", nil), NSLocalizedString(@"Language", nil), nil];
    NSDictionary *patientLabelsDict = [NSDictionary dictionaryWithObject:patientArray forKey:@"Labels"];
	
    [fieldLabels addObject:patientLabelsDict];
		
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	
	tableView_.backgroundView  = nil;
	tableView_.backgroundColor = [UIColor clearColor];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	backgroundView_.image = [UIImage imageWithData:[Base64 decode:style_.background]];
	
	self.view.backgroundColor = [UIColor clearColor];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
	[OpenPATHContext sharedOpenPATHContext].activeFeatures.hasVisitedSettings = true;
	[[OpenPATHContext sharedOpenPATHContext] saveActiveFeatures];
	
	if (noParent) {
		topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerNone.png"];
	}
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
        return [features_ count];
    } else
        return 0;
}

- (IBAction)textFieldDone:(id)textField {
    [textField resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
    [tableView_ reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSNumber* feature = [features_ objectAtIndex:[indexPath row]];
	int       featureVal = [feature intValue];
	
	if (([indexPath section] == 0) && (featureVal == kSettingsPhaseRowIndex)) {
        SettingsPhaseViewController *childController = [[SettingsPhaseViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingsAlarmTimeRowIndex)) {
		SettingsTimerViewController *childController = [[SettingsTimerViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingsPasscodeRowIndex)) {
        SettingsPasscodeViewController *childController = [[SettingsPasscodeViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingsParticipantIDRowIndex)) {
        SettingsParticipantIDViewController *childController = [[SettingsParticipantIDViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingsUserNameRowIndex)) {
        SettingsUserNameViewController *childController = [[SettingsUserNameViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingResearcherRowIndex)) {
        SettingsResearcherViewController *childController = [[SettingsResearcherViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingSiteRowIndex)) {
        SettingsStudySiteViewController *childController = [[SettingsStudySiteViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingVirtualCoachRowIndex)) {
        SettingsCoachViewController* childController = [[SettingsCoachViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingLanguageRowIndex)) {
        SettingsCoachViewController* childController = [[SettingsCoachViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingDesktopPhotoRowIndex)) {
        [self presentModalViewController:imagePickerController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingResearcherLanguageRowIndex)) {
        SettingsResearcherLanguageViewController *childController = [[SettingsResearcherLanguageViewController alloc] init];
		
        [[self navigationController] pushViewController:childController animated:YES];
    } else if (([indexPath section] == 0) && (featureVal == kSettingGeozoneRowIndex)) {
        GeozoneViewController *childController = [[GeozoneViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
        [[self navigationController] pushViewController:childController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return @"Languages";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString*      PatientTextCellIdentifier = @"PatientTextCellIdentifier";
    static NSString*      SimpleCellIdentifier = @"SimpleCellIdentifier";
    TextFieldCustomCell*  textCell;
    UITableViewCell*      simpleCell;
    NSUInteger            row = [indexPath row];
    NSUInteger            section = [indexPath section];
	
    textCell = [tableView dequeueReusableCellWithIdentifier:PatientTextCellIdentifier];
	
    if (textCell == nil) {
        textCell = [[TextFieldCustomCell alloc] initWithIdentifier:PatientTextCellIdentifier delegate:self];
        textCell.accessoryType = UITableViewCellAccessoryNone;
        textCell.backgroundColor = [UIColor whiteColor];
    }
	
    simpleCell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];
	
	if (simpleCell == nil) {
		simpleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleCellIdentifier];
		
		simpleCell.textLabel.textColor  = style_.textColor;  // [UIColor colorWithRed:(153.0/255.0 )green:(51.0/255.0)blue:0.0 alpha:1.0]; // LLS [UIColor whiteColor];
		[simpleCell imageView].image = nil;
		
		simpleCell.backgroundColor = [UIColor whiteColor]; //LLS [ UIColor lightGrayColor ];
		
		UITextView*   respTextView = [[UITextView alloc] initWithFrame: CGRectMake(50, 15, 220, 40)];
		
		respTextView.textColor			= style_.textColor;
		respTextView.font				= [style_ fontFromStyle];
		respTextView.textAlignment		= UITextAlignmentLeft;
		respTextView.scrollEnabled		= NO;
		respTextView.userInteractionEnabled = false;
		[respTextView setDelegate:self];
		respTextView.backgroundColor	= [UIColor whiteColor]; // LLS [UIColor lightGrayColor];
		respTextView.tag				= 100;
		
		simpleCell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        simpleCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(224.0 / 255.0) green:(231.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];\
		
		//respTextView.frame = CGRectMake(5, 5, 275, [rowResponse.controlHeight intValue]);
		[simpleCell.contentView addSubview:respTextView];
		simpleCell.accessoryView = nil;
	}
	
    if (section == 0) {
        textCell.textField.tag = row;
        textCell.accessoryType = UITableViewCellAccessoryNone;
		
		UITextView*  responseView = (UITextView*)[simpleCell viewWithTag:(NSInteger)100];
		NSNumber*    feature      = [features_ objectAtIndex:row];
		
        switch ([feature intValue]) {
			case kSettingsPhaseRowIndex:
			{
				NSString* phase     = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyDuration]) ? NSLocalizedString([OpenPATHContext sharedOpenPATHContext].activeStudy.studyDuration, nil) : @" ";
				NSString* phaseText = [[NSString alloc] initWithFormat:@"Phase: %@", phase];
				
				responseView.text = phaseText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/alarmSetting.png"];
				
				return simpleCell;
			}
				break;
				
			case kSettingsAlarmTimeRowIndex:
			{
				NSString* alarmTime     = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeTimer.startTime]) ? [OpenPATHContext sharedOpenPATHContext].activeTimer.startTime : @" ";
				NSString* alarmTimeText = [[NSString alloc] initWithFormat:@"Alarm Time"];
				
				responseView.text = alarmTimeText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/alarmSetting.png"];
				
				return simpleCell;
			}
				break;
				
			case kSettingsPasscodeRowIndex:
			{
				NSString* passcode     = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeSecurity.password]) ? @"****" : @" ";
				NSString* passcodeText = [[NSString alloc] initWithFormat:@"Passcode: %@", passcode];
				
				responseView.text = passcodeText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/passwordSetting.png"];
				
				return simpleCell;
			}
				break;
				
			case kSettingsParticipantIDRowIndex:
			{
				NSString* patientId     = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum]) ? [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum : @" ";
				NSString* patientIdText = [[NSString alloc] initWithFormat:@"Participant ID: %@", patientId];
				
				responseView.text = patientIdText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/patientIdSetting.png"];
				
				return simpleCell;
			}
				break;
				
			case kSettingsUserNameRowIndex:
			{
				NSString* userName = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.firstName]) ? [OpenPATHContext sharedOpenPATHContext].activePatient.firstName : @" ";
				NSString* userNameText = [[NSString alloc] initWithFormat:@"User Name: %@", userName];
				
				responseView.text = userNameText;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/userNameSetting.png"];
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
				return simpleCell;
			}
				break;
				
            case kSettingResearcherRowIndex:
			{
				NSString* researcherNameText = [[NSString alloc] initWithFormat:@"Researcher: %@", [self locateResearcherName]];
                responseView.text = researcherNameText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/careProviderSetting.png"];
				
                return simpleCell;
            }
                break;
            case kSettingSiteRowIndex:
			{
				NSString* siteNameText   = [[NSString alloc] initWithFormat:@"Site: %@", [self locateSiteName]];
                responseView.text        = siteNameText;
				simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/siteSetting.png"];
				
                return simpleCell;
            }
                break;
            case kSettingVirtualCoachRowIndex:
                responseView.text = @"Virtual Coach";
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/coachSetting.png"];
				
                return simpleCell;
				
		        break;
            case kSettingLanguageRowIndex:
            {
				NSString* language     = ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryLanguage]) ? [OpenPATHContext sharedOpenPATHContext].activeStudy.studyPrimaryLanguage : @" ";
				NSString* languageText = [[NSString alloc] initWithFormat:@"Language: %@", language];
				
                responseView.text = languageText;
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/languageSetting.png"];
				
                return simpleCell;
            }
			case kSettingDesktopPhotoRowIndex:
            {
				responseView.text = @"Desktop Photo";
                //simpleCell.label.text = languageStr;
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/desktopSetting.png"];
				
                return simpleCell;
            }
                break;
				
			case kSettingGeozoneRowIndex:
				responseView.text = @"Geozones";
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/coachSetting.png"];
				
                return simpleCell;
				
		        break;
				
            default:
                break;
        }
		
        return textCell;
    } else {
        textCell.textField.tag = row;
        textCell.accessoryType = UITableViewCellAccessoryNone;
		
		UITextView*  responseView = (UITextView*)[simpleCell viewWithTag:(NSInteger)100];
		
        switch (row) {
            case kSettingLanguageRowIndex:
            {
                NSString *languageStr;
				
                if (tempStudy.studyPrimaryLanguage != nil) {
                    languageStr = tempStudy.studyPrimaryLanguage;
                } else if (study.studyPrimaryLanguage != nil) {
                    languageStr = study.studyPrimaryLanguage;
                } else {
                    languageStr = @" ";
                }
				
                responseView.text = @"Participant";
                //simpleCell.label.text = languageStr;
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
                return simpleCell;
            }
                break;
            case kSettingResearcherLanguageRowIndex:
            {
                NSString *languageStr;
				
                if (tempStudy.var1 != nil) {
                    languageStr = tempStudy.var1;
                } else if (study.var1 != nil) {
                    languageStr = study.var1;
                } else {
                    languageStr = @" ";
                }
				
                simpleCell.text = @"Researcher";
                //simpleCell.label.text = languageStr;
                simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
                return simpleCell;
            }
                break;
            default:
                break;
        }
		
        return textCell;
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
    CGFloat tempDistance = keyboardSize.height + 12;
	
    // Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
    switch (textField.tag) {
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
	
    textFieldBeingEdited = textField;
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

- (void)setPatientPropertyFromTextField:(UITextField *)textField {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	[OpenPATHContext sharedOpenPATHContext].activePatient.photo2 = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
	
	PatientDAO* dao = [PatientDAO new];
	
	[dao update:[OpenPATHContext sharedOpenPATHContext].activePatient];
	
	[picker dismissModalViewControllerAnimated:YES];
}

@end
