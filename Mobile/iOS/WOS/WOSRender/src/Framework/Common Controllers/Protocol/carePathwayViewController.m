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

#import "carePathwayViewController.h"
#import "Theme.h"
#import "AlertUtilities.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AudioTalkToUsViewController.h"
#import "MediaAssetsViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "LabelWithCountCustomCell.h"
#import "GoalDetailViewController.h"
#import "WSInteractionViewController.h"
#import "WSRenderingEngine.h"
#import "WOSCore/OpenPATHCore.h"
#import "SettingsViewController.h"
#import "VirtualCoachViewController.h"
#import "GoalMainViewController.h"
#import "talkToUsViewController.h"
#import "MediaViewController.h"
#import "MediaSendDataManager.h"
#import "KVPasscodeViewController.h"
#import "RewardViewController.h"
#import "PatientViewController.h"
#import "ProgressViewController.h"

@implementation carePathwayViewController

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

// Transform values for full screen support:
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.12412    //use this is for iOS 3.x

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;


@synthesize questionTableView = questionTableView_;
@synthesize pickerView = pickerView_;
@synthesize datePickerView = datePickerView_;
@synthesize engine = engine_;
@synthesize clearBtn = clearBtn_;
@synthesize sendBtn = sendBtn_;
@synthesize previousBtn = previousBtn_;
@synthesize homeBtn = homeBtn_;
@synthesize nextBtn = nextBtn_;
@synthesize userView = userView_;
@synthesize patientBtn = patientBtn_;
@synthesize riskFactor = riskFactor_;
@synthesize packYearsPacksPerDay = packYearsPacksPerDay_;
@synthesize packYearsYearsSmoking = packYearsYearsSmoking_;
@synthesize activeProtocol = activeProtocol_;
@synthesize persistanceModel = persistanceModel_;
@synthesize dataManager = dataManager_;
@synthesize homePopsController = homePopsController_;
@synthesize engineDelegate = engineDelegate_;

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super initWithNibName:@"carePathwayViewController" bundle:[self frameworkBundle]];
	
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

- (void)showImageViewer:(UIImage *)imageToUse {
}

- (void)setEngineWithProtocol:(NSString*)protocol {
	if (engine_ != nil) {
		[engine_ setProtocolFileName:protocol];
	}
}

-(IBAction)finalIntervention {
	[[self navigationController] popViewControllerAnimated:true];
}

- (void)loadInteractionResource {
    UIImage *backgroundImage = [UIImage imageNamed:[[[engine_ getCurrentInteraction] textResource] fragment]];
	
    backgroundImageView_.image = backgroundImage;
}

- (void)showSettings {
    SettingsViewController *childController = [[SettingsViewController alloc] init];
	
    childController.title = NSLocalizedString(@"Settings", nil);
	
	UINavigationController* navController = [self navigationController];
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showGoals {
    GoalMainViewController *childController = [[GoalMainViewController alloc] init];
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showRewards {
	RewardViewController* childController = [[RewardViewController alloc] init];
	
	childController.title = NSLocalizedString(@"Rewards", nil);
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showProgress {
	ProgressViewController* childController = [[ProgressViewController alloc] init];
	
	childController.title = NSLocalizedString(@"Progress", nil);
	
    [[self navigationController] pushViewController:childController animated:YES];
}

/*
- (void)showParticipants {
	PatientViewController* childController = [[PatientViewController alloc] init];
	
    [[self navigationController] pushViewController:childController animated:YES];
}
 */

- (void)showVirtualCoach {
    VirtualCoachViewController *childController = [[VirtualCoachViewController alloc] init];
	
    childController.title = NSLocalizedString(@"Coach", nil);
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showTalkToUs {
    TalkToUsViewController *childController = [[TalkToUsViewController alloc] init];
 	
    childController.title = NSLocalizedString(@"TalkToUs", nil);
    childController.albumName = [OpenPATHContext sharedOpenPATHContext].activeStudy.organizationID;
    childController.patientNum = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showAssetsLibrary {
    MediaAssetsViewController *childController = [[MediaAssetsViewController alloc] init];
	
    childController.patientNum = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)showAudio:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response {
    AudioTalkToUsViewController *childController = [[AudioTalkToUsViewController alloc] init];
	
    childController.albumName = childController.albumName = [OpenPATHContext sharedOpenPATHContext].activeStudy.organizationID;
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void)determineLocation:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response {
    activeResponse_ = response;
	
    locationManager_ = [CLLocationManager new];
    locationManager_.delegate = self;
	
    locationManager_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
    [locationManager_ startUpdatingLocation];
	
    CLLocation *newLocation = locationManager_.location;
    CLLocationCoordinate2D cord = newLocation.coordinate;
	
    [locationManager_ stopUpdatingLocation];
	
    activeResponse_.label = [[NSString alloc] initWithFormat:@"%f, %f", cord.latitude, cord.longitude];
	
    [locationManager_ stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D cord = newLocation.coordinate;
	
    //def deg_to_dms(deg):
    //d = int(deg)
    //md = abs(deg - d) * 60
    //m = int(md)
    //sd = (md - m) * 60
    //return [d, m, sd]
	
    int latD = (int) cord.latitude;
    int longD = (int) cord.longitude;
	
    double latMd = fabs(cord.latitude - latD) * 60;
    double longMd = fabs(cord.longitude - longD) * 60;
	
    int latM = (int) latMd;
    int longM = (int) longMd;
	
    double latSd = (latMd - latM) * 60;
    double longSd = (longMd - longM) * 60;
	
    NSString *latString = [[NSString alloc] initWithFormat:@"%d degrees, %f minutes, %f seconds", latD, latM, latSd];
    NSString *longString = [[NSString alloc] initWithFormat:@"%d degrees, %f minutes, %f seconds", longD, longM, longSd];
    NSString *finalString = [[NSString alloc] initWithFormat:@"longitude: %@ latitude: %@", latString, longString];
	
    [locationManager_ stopUpdatingLocation];
	
    activeResponse_.label = finalString;
	
    activeResponse_ = nil;
}

- (CGSize)keyboardSize:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    NSValue *beginValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
    CGSize keyboardSize;
	
    if ([UIKeyboardDidShowNotification isEqualToString:[aNotification name]]) {
        screenOrientation_ = orientation;
		
        if (UIDeviceOrientationIsPortrait(orientation)) {
            keyboardSize = [beginValue CGRectValue].size;
        } else {
            keyboardSize.height = [beginValue CGRectValue].size.width;
            keyboardSize.width = [beginValue CGRectValue].size.height;
        }
    } else if ([UIKeyboardDidHideNotification isEqualToString:[aNotification name]]) {
        // We didn't rotate
        if (screenOrientation_ == orientation) {
            if (UIDeviceOrientationIsPortrait(orientation)) {
                keyboardSize = [beginValue CGRectValue].size;
            } else {
                keyboardSize.height = [beginValue CGRectValue].size.width;
                keyboardSize.width = [beginValue CGRectValue].size.height;
            }
            // We rotated
        } else if (UIDeviceOrientationIsPortrait(orientation)) {
            keyboardSize.height = [beginValue CGRectValue].size.width;
            keyboardSize.width = [beginValue CGRectValue].size.height;
        } else {
            keyboardSize = [beginValue CGRectValue].size;
        }
    }
	
    return keyboardSize;
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    keyboardSize_ = [self keyboardSize:aNotification];
}

- (void)showError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	
    [alert show];
}

#pragma mark Client List Methods

#pragma mark -
#pragma mark Toolbar Methods

- (void)formNavigation {
    previousBtn_.hidden = false;
    nextBtn_.hidden = false;
	
    if ([[engine_ getCurrentInteraction] navigation] > 0) {
        switch ([[engine_ getCurrentInteraction] navigation]) {
			case InteractionHILNavNewOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = false;
				previousBtn_.hidden = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHomeNew.png"];
				break;
				
            case InteractionHILNavExitOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerBack.png"];
				break;
				
			case InteractionHILNavHomeOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = false;
				previousBtn_.hidden = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHome.png"];
				break;
				
			case InteractionHILNavNextOnly:
				nextBtn_.hidden     = false;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = true;
				topBanner_.image    = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerNext.png"];
				break;
				
			case InteractionHILNavPrevOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = false;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBanner.png"];
				break;
				
			case InteractionHILNavNone:
				topBanner_.image = nil;
				break;
				
			default:
				nextBtn_.hidden     = false;
				homeBtn_.hidden     = false;
				previousBtn_.hidden = false;
			    topBanner_.image     = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHomeNext.png"];
		}
    } else {
        previousBtn_.hidden = false;
        nextBtn_.hidden = false;
        homeBtn_.hidden = false;
        patientBtn_.hidden = true;
		topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBanner.png"];
    }
}

#pragma mark -

- (IBAction)audioAction:(id)sender {
}

- (void)resetResponseValueForAll:(WSInteractionHIL *)interaction exceptResponse:(NSURL *)sysID {
    if (interaction == nil)
        return;
	
    for (WSResponse *response in [interaction responses]) {
        if (response.systemID == nil)
            continue;
		
        if ([response.systemID isEqual:sysID])
            continue;
		
        response.responseValue = [NSMutableString stringWithString:@""];
    }
}

- (void)responseButtonClicked:(id)sender {
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    int responseIndex = ((UIButton *) sender).tag - 100;
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:responseIndex];
	
    [engine_ setCurrentResponse:rowResponse];
	
    if ([rowInteraction isInterrogativeSingle]) {
        rowResponse.responseValue = [NSMutableString stringWithString:@"1"];
		
        [self resetResponseValueForAll:rowInteraction exceptResponse:rowResponse.systemID];
    } else if ([rowInteraction isInterrogativeMulti]) {
        //  Toggle the activity.
        if ([WSStringUtils isEmpty:rowResponse.responseValue]) {
            rowResponse.responseValue = [NSMutableString stringWithString:@"1"];
        } else {
            rowResponse.responseValue = [NSMutableString stringWithString:@""];
        }
    }
	
    if ([rowResponse isFixedNextResponse] || [rowResponse isGoal] || [rowResponse isTask] || [rowResponse isReward]) {
        [self nextAction:nil];
    } else if ([rowResponse isFixedAskResponse]) {
        [self askAction];
        [self performSelectorInBackground:@selector(layoutResponseControls) withObject:nil];
    } else {
        [self performSelectorInBackground:@selector(layoutResponseControls) withObject:nil];
    }
}

- (void)layoutResponseControls {
    // Lay out any touch areas if indicated
    WSInteractionHIL *interaction = [engine_ getCurrentInteraction];
    int rowIndex = 0;
	
    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];
	
    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }
	
    if ((interaction != nil) && ([interaction filteredResponseCount] > 0)) {
        for (WSResponse *response in [interaction filteredResponses]) {
            if ([WSStringUtils isNotEmpty:response.controlTouchX]) {
                float x = [response.controlTouchX floatValue];
                float y = [response.controlTouchY floatValue];
                float width = [response.controlTouchWidth floatValue];
                float height = [response.controlTouchHeight floatValue];
				
                if ([response isFreeFixedResponse]) {
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
					
                    textView.tag = rowIndex + 100;
					
                    textView.textColor = [style_ textColor];
                    textView.font = [style_ fontFromStyle];
					
                    textView.scrollEnabled = YES;
                    [textView setDelegate:self];
                    textView.backgroundColor = [UIColor clearColor];
					
                    [self.view addSubview:textView];
					
                    // Add a picker if requested.
                    if ([response isResponseFormatValueList] || [response isResponseFormatDataList]) {
                        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
						
                        picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                        picker.dataSource = self;
                        picker.delegate = self;
                        picker.showsSelectionIndicator = YES;
                        picker.tag = rowIndex + 100;
						
                        textView.textAlignment = UITextAlignmentCenter;
						
                        if ([response isResponseFormatValueList]) {
                            //int x = (orientationOffset_ - [rowResponse.constraintControlWidth intValue]) / 2;
                            picker.frame = CGRectMake(530, 460, 200, 175);
                            [self.view addSubview:picker];
                            [picker reloadAllComponents];
                        } else {
                        }
                    }
                } else if ([response isFixedResponse] || [response isFixedNextResponse] || [response isFixedAskResponse]) {
                    UIButton *responseButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
					
                    responseButton.tag = rowIndex + 100;
                    [self.view addSubview:responseButton];
					
					if ([StringUtils isNotEmpty:style_.buttonBackgroundSelectedImage]) {
						[responseButton setImage:[UIImage imageWithData:[Base64 decode:style_.buttonBackgroundSelectedImage]] forState:UIControlStateHighlighted];
						responseButton.showsTouchWhenHighlighted = false;
					} else {
						responseButton.showsTouchWhenHighlighted = true;
					}
					
                    [responseButton addTarget:self action:@selector(responseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
					
                    bool showCheckMark = false;
					
                    if ([interaction isInterrogativeMulti]) {
                        if ([WSStringUtils isNotEmpty:response.responseValue] && (![response.responseValue isEqualToString:@"0"])) {
                            [engine_ setCurrentResponse:response];
                            showCheckMark = true;
                        }
                    } else if ([interaction isInterrogativeSingle]) {
                        if ([WSStringUtils isNotEmpty:response.responseValue]) {
                            [engine_ setCurrentResponse:response];
                            showCheckMark = true;
                        }
                    }
					
                    if (showCheckMark) {
                        NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"checkMark" ofType:@"png"];
                        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
                        UIView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
						
                        backgroundView.frame = CGRectMake(x, y, 30, 30);
                        backgroundView.tag = 200;
						
                        [self.view addSubview:backgroundView];
                        [self.view bringSubviewToFront:backgroundView];
                    }
                } else if ([response isDirectiveResponse]) {
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
					
                    textView.tag = rowIndex + 100;
					
                    textView.textColor = [style_ textColor];
                    textView.font = [style_ headerFontFromStyle];
					
                    textView.scrollEnabled = YES;
                    [textView setDelegate:self];
                    textView.backgroundColor = [UIColor clearColor];
					
                    textView.text = [response label];
					
                    [self.view addSubview:textView];
                }
            } else if ([response hasVideoControl]) {
                if (videoPlayer_ == nil) {
                    NSString *urlStr = [[self frameworkBundle] pathForResource:[[response controlImage] fragment] ofType:nil];
                    NSURL *url = [NSURL fileURLWithPath:urlStr];
					
                    videoPlayer_ = [[MPMoviePlayerController alloc] initWithContentURL:url];
                    videoPlayer_.controlStyle = MPMovieControlStyleEmbedded;
                    videoPlayer_.view.frame = CGRectMake(162, 240, 700, 450);
                } else {
                    NSString *urlStr = [[self frameworkBundle] pathForResource:[[response controlImage] fragment] ofType:nil];
                    NSURL *url = [NSURL fileURLWithPath:urlStr];
					
                    [videoPlayer_ setContentURL:url];
                }
				
                [self.view addSubview:videoPlayer_.view];
				
                [videoPlayer_ play];
            }
			
            rowIndex++;
        }
    }
}

- (IBAction)previousAction:(id)sender {	
    // There might be data in the free control.
    if (textViewBeingEdited_ != nil) {
        [textViewBeingEdited_ resignFirstResponder];
        textViewBeingEdited_ = nil;
    }
	
    if (textFieldBeingEdited_ != nil) {
        [textFieldBeingEdited_ resignFirstResponder];
        textFieldBeingEdited_ = nil;
    }
			
    [pickerView_ removeFromSuperview];
    [datePickerView_ removeFromSuperview];
    [videoPlayer_.view removeFromSuperview];
    [userView_ removeFromSuperview];
    backgroundImageView_.image = nil;
	[interactionImageView_ removeFromSuperview];
	questionTableView_.separatorColor = [UIColor grayColor];
	
    if (videoPlayer_ != nil) {
        [videoPlayer_ stop];
    }
	
    [engine_ askPreviousWithContent:[engine_ getCurrentIntervention]];
	
	// We may have changed protocols which means it is up to us to try another iteration (engine won't do that for us
	if (engine_.getCurrentInteraction == nil) {
		[engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	}
	
    [self formNavigation];
	
	// See if we can render the interaction based on the ontology.  Otherwise render the interaction using our
	// standard way of rendering (via a table).
	if ([engine_ getCurrentInteraction].ontology != nil)  {
		if ([self renderInteractionByOntology]) {
			return;
		}
	}
	
    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];
	
    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }
	
	[self loadInteractionResource];
	
    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
        [self loadInteractionResource];
        [self layoutResponseControls];
		
        questionTableView_.hidden = true;
    } else {
        questionTableView_.hidden = false;
		
        if ([WSStringUtils isNotEmpty:style_.background]) {
            UIImage *backgroundImage = [UIImage imageWithData:[Base64 decode:style_.background]];
            backgroundImageView_.image = backgroundImage;
        }
		
        [questionTableView_ reloadData];
		
        if (([questionTableView_ numberOfSections] > 0) && ([questionTableView_ numberOfRowsInSection:0] > 0))
            [questionTableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }	
}

- (IBAction)newAction:(id)sender {
	if ([engine_ getCurrentInteraction] == nil) {
		return;
	}
	
	if ([[engine_ getCurrentInteraction] isGoal]) {
		GoalDetailViewController* childController = [[GoalDetailViewController alloc] init];
		
		childController.title = NSLocalizedString(@"New Goal", nil);
		
		[[self navigationController] pushViewController:childController animated:YES];
	} else if ([[engine_ getCurrentInteraction] isReward]) {
		
	} else if ([[engine_ getCurrentInteraction] isTask]) {
		
	}
}

- (bool)renderInteractionByOntology {
	activeInteractionController_ = [renderingEngine_ predictInteractionUsingOntology:[engine_ getCurrentInteraction].ontology andEngine:engine_];
	
	if (activeInteractionController_ == nil) {
		return false;
	}
	
    activeInteractionController_.interaction  = [engine_ getCurrentInteraction];
	activeInteractionController_.intervention = [engine_ getCurrentIntervention];
	
	activeInteractionController_.view.frame = CGRectMake(0, 41, 320, 423);
	
	activeInteractionController_.parentController = self;
	
	[self.view addSubview:activeInteractionController_.view];
	
    //[[self navigationController] pushViewController:viewController animated:YES];
	
	return true;
}

- (IBAction)nextAction:(id)sender {
    // There might be data in the free control.
    if (textViewBeingEdited_ != nil) {
        [textViewBeingEdited_ resignFirstResponder];
        textViewBeingEdited_ = nil;
    }
	
    if (textFieldBeingEdited_ != nil) {
        [textFieldBeingEdited_ resignFirstResponder];
        textFieldBeingEdited_ = nil;
    }
	
    if ([[engine_ getCurrentInteraction] hasNoSelectedResponses] && [[engine_ getCurrentInteraction] isResponseRequired]) {
        [AlertUtilities showOkAlert:@"You must provide a response to the question." withTitle:@"Response Required"];
        return;
    }
	
    if ([[engine_ getCurrentInteraction] hasSelectedResponses]) {
        NSString *constraintError = [[engine_ getCurrentResponse] checkConstraints];
		
        if ([WSStringUtils isNotEmpty:constraintError]) {
            [self showError:constraintError];
            return;
        }
    }
	
    [pickerView_ removeFromSuperview];
    [datePickerView_ removeFromSuperview];
    [videoPlayer_.view removeFromSuperview];
    [userView_ removeFromSuperview];
    backgroundImageView_.image = nil;
	[interactionImageView_ removeFromSuperview];
	questionTableView_.separatorColor = [UIColor grayColor];
	
    if (videoPlayer_ != nil) {
        [videoPlayer_ stop];
    }
	
    [engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	
	// We may have changed protocols which means it is up to us to try another iteration (engine won't do that for us
	if (engine_.getCurrentInteraction == nil) {
		[engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	}
	
    [self formNavigation];
	
	// See if we can render the interaction based on the ontology.  Otherwise render the interaction using our
	// standard way of rendering (via a table).
	if ([engine_ getCurrentInteraction].ontology != nil)  {
		if ([self renderInteractionByOntology]) {
			return;
		}
	}
	
    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];
	
    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }
	
	[self loadInteractionResource];
	
    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
        [self loadInteractionResource];
        [self layoutResponseControls];
		
        questionTableView_.hidden = true;
    } else {
        questionTableView_.hidden = false;
		
        if ([WSStringUtils isNotEmpty:style_.background]) {
            UIImage *backgroundImage = [UIImage imageWithData:[Base64 decode:style_.background]];
            backgroundImageView_.image = backgroundImage;
        }
		
        [questionTableView_ reloadData];
		
        if (([questionTableView_ numberOfSections] > 0) && ([questionTableView_ numberOfRowsInSection:0] > 0))
            [questionTableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (IBAction)askAction {
    if ([[engine_ getCurrentInteraction] hasNoSelectedResponses] && [[engine_ getCurrentInteraction] isResponseRequired]) {
        [AlertUtilities showOkAlert:@"You must provide a response to the question." withTitle:@"Response Required"];
        return;
    }
	
    if ([[engine_ getCurrentInteraction] hasSelectedResponses]) {
        NSString *constraintError = [[engine_ getCurrentResponse] checkConstraints];
		
        if ([WSStringUtils isNotEmpty:constraintError]) {
            [self showError:constraintError];
            return;
        }
    }
	
    [engine_ askWithContent:[engine_ getCurrentIntervention]];
}

#pragma mark -
#pragma mark View lifecycle

- (void)finalInteraction:(id)sender {
	[engine_ reset];
}

- (void)setupSurvey {
    [engine_ reset];
	
    //[engine_ clearPersistantData];
	
    // Setup our first interaction
    [engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	
    [self formNavigation];
	
    [pickerView_ removeFromSuperview];
    [datePickerView_ removeFromSuperview];
    [videoPlayer_.view removeFromSuperview];
    [userView_ removeFromSuperview];
    backgroundImageView_.image = nil;
	[interactionImageView_ removeFromSuperview];
	[activeInteractionController_.view removeFromSuperview];
	
    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];
	
    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }
	
	[self loadInteractionResource];
	
    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
        [self loadInteractionResource];
        [self layoutResponseControls];
		
        questionTableView_.hidden = true;
    } else {
        questionTableView_.hidden = false;
		
        if ([WSStringUtils isNotEmpty:style_.background]) {
            backgroundImageView_.image = [UIImage imageWithData:[Base64 decode:style_.background]];
        }
		
        [questionTableView_ reloadData];
		
        if (([questionTableView_ numberOfSections] > 0) && ([questionTableView_ numberOfRowsInSection:0] > 0))
            [questionTableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (IBAction)homeAction:(id)sender {
	if (homePopsController_) {
		[[self navigationController] popViewControllerAnimated:true];	
	}
	
    [pickerView_ removeFromSuperview];
    [datePickerView_ removeFromSuperview];
    [videoPlayer_.view removeFromSuperview];
    [userView_ removeFromSuperview];
    backgroundImageView_.image = nil;
	[interactionImageView_ removeFromSuperview];
	
    if (videoPlayer_ != nil) {
        [videoPlayer_ stop];
    }
	
	//[self setEngineWithProtocol:@"OralScreenerDashboard"];
    [self setupSurvey];
	
    [questionTableView_ reloadData];
}

- (void)passcodeController:(KVPasscodeViewController *)controller passcodeEntered:(NSString *)passCode {
    if ([passCode isEqualToString:[OpenPATHContext sharedOpenPATHContext].activeSecurity.password]) {
        [controller dismissModalViewControllerAnimated:YES];
    } else {
        controller.instructionLabel.text = @"Invalid passcode.  Please try again";
        [controller resetWithAnimation:KVPasscodeAnimationStyleInvalid];
    }
}

- (void)showLog {
	if (![OpenPATHContext sharedOpenPATHContext].activeFeatures.hasVisitedSettings && [OpenPATHContext sharedOpenPATHContext].activeFeatures.requireSettings) {
		SettingsViewController *  childController              = [[SettingsViewController alloc] init];
		UINavigationController*   settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:childController];
		
		childController.title = NSLocalizedString(@"Settings", @"Application settings (e.g. passcode, researcher name, user name)");
		
		[self.navigationController presentModalViewController:settingsNavigationController animated:YES];
	} else if ([OpenPATHContext sharedOpenPATHContext].activeFeatures.hasAuthentication && [WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activeSecurity.password] && ![OpenPATHContext sharedOpenPATHContext].authenticated) {
		KVPasscodeViewController*  passcodeController = [[KVPasscodeViewController alloc] init];
		UINavigationController*    passcodeNavigationController = [[UINavigationController alloc] initWithRootViewController:passcodeController];
		
	    passcodeController.delegate = self;
		
		[self.navigationController presentModalViewController:passcodeNavigationController animated:YES];
	} else if ([OpenPATHContext sharedOpenPATHContext].activePatient.welcomeCoach) {
		VirtualCoachViewController*  controller = [[VirtualCoachViewController alloc] initWithNibName:@"VirtualCoachViewController" bundle:nil];
		
		[[self navigationController] pushViewController:controller animated:false];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
	
	//[self setupSurvey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	renderingEngine_ = [WSRenderingEngine new];
		
	NSDecimalNumber* points;
	
	if ([WSStringUtils isEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.rewardPoints]) {
		points = [NSDecimalNumber decimalNumberWithString:@"60"];
	} else {
		points = [NSDecimalNumber decimalNumberWithString:[OpenPATHContext sharedOpenPATHContext].activePatient.rewardPoints];
	}
	
	points = [points decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:@".50"]];
	
	[OpenPATHContext sharedOpenPATHContext].activePatient.rewardPoints = [points stringValue];
	
	//[OpenPATHContext sharedOpenPATHContext].activePatient.rewardBadge  = @"Level 5";;
	
    [self.navigationController setNavigationBarHidden:YES animated:NO];
		
    videoPlayer_ = nil;
	
	engine_ = [[WSClinicalEngine alloc] initWithProtocol:activeProtocol_ andPersistenceModel:[OpenPATHContext sharedOpenPATHContext].persistenceManager withOptions:WSOptionEngineNone];
	style_  = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	[engine_ setUserDelegate:self];
	[engine_ setUserSecondaryDelegate:engineDelegate_];
	
	if ([WSStringUtils isNotEmpty:style_.background]) {
		UIImage *backgroundImage = [UIImage imageWithData:[Base64 decode:style_.background]];
		backgroundImageView_.image = backgroundImage;
	}
	
    self.view.backgroundColor = [UIColor clearColor];
			
	questionTableView_.backgroundView = nil;
	questionTableView_.backgroundColor = [UIColor clearColor];
    questionTableView_.separatorColor = [UIColor grayColor]; // LLS [UIColor whiteColor];
	
    pickerView_ = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pickerView_.dataSource = self;
    pickerView_.delegate = self;
    pickerView_.showsSelectionIndicator = YES;
	
    datePickerView_ = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePickerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    datePickerView_.datePickerMode = UIDatePickerModeDate;
	
    [datePickerView_ addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
	
    self.tabBarController.tabBar.hidden = NO;
	
    [self setupSurvey];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
    keyboardSize_ = CGSizeMake(320, 216);
	
    imagePicker_ = [[UIImagePickerController alloc] init];
    //imagePicker_.sourceType					= UIImagePickerControllerSourceTypeCamera;
    //imagePicker_.showsCameraControls		= YES;
    //imagePicker_.navigationBarHidden			= YES;
    imagePicker_.delegate = self;
    videoPlayer_.view.frame = CGRectMake(0, 100, 320, 300);
	
    // Make camera view full screen:
    imagePicker_.wantsFullScreenLayout = YES;
    //imagePicker_.cameraViewTransform = CGAffineTransformScale(imagePicker_.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
	
	[self showLog];
}

- (void)showWaitingView {
    CGRect frame = CGRectMake(90, 190, 32, 32);
    UIActivityIndicatorView *progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	
    frame = CGRectMake(130, 193, 140, 30);
    UILabel *waitingLable = [[UILabel alloc] initWithFrame:frame];
    waitingLable.text = @"Sending data...";
    waitingLable.textColor = [UIColor whiteColor];
    waitingLable.font = [style_ fontFromStyle];
    waitingLable.backgroundColor = [UIColor clearColor];
    frame = [[UIScreen mainScreen] applicationFrame];
	
    UIView *theView = [[UIView alloc] initWithFrame:frame];
    theView.backgroundColor = [UIColor blackColor];
    theView.alpha = 0.7;
    theView.tag = 999;
    [theView addSubview:progressInd];
    [theView addSubview:waitingLable];
		
    [self.view addSubview:theView];
    [self.view bringSubviewToFront:theView];
}

- (void)takePatientPicture:(id)params {
	NSArray*         paramList = (NSArray*)params;
	WSIntervention*  intervention = nil;
	WSInteraction*   interaction = nil;
	WSResponse*      response = nil;
	
	if (paramList != nil) {
		if ([paramList count] > 2) {
			intervention = [paramList objectAtIndex:0];
			interaction  = [paramList objectAtIndex:1];
			response     = [paramList objectAtIndex:2];
		} else if ([paramList count] > 1) {
			intervention = [paramList objectAtIndex:0];
			interaction  = [paramList objectAtIndex:1];
		} else if ([paramList count] == 1) {
			intervention = [paramList objectAtIndex:0];		
		}
	}
		
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
		
        imagePicker_.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        imagePicker_.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
		
        imagePicker_.showsCameraControls = YES;
        imagePicker_.navigationBarHidden = YES;
		
        // Make camera view full screen:
        imagePicker_.wantsFullScreenLayout = YES;
        imagePicker_.cameraViewTransform = CGAffineTransformScale(imagePicker_.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
		
        imagePickerInteraction_ = interaction;
        imagePickerResponse_    = response;
		
        [self presentModalViewController:imagePicker_ animated:YES];
    } else
        [AlertUtilities showOkAlert:@"The camera is not available."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIView *v = [self.view viewWithTag:999];
	
    if (v)
        [v removeFromSuperview];
}

- (void)talkText :(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response {
    NSString *subjectLine = [[NSString alloc] initWithFormat:@"Text message from participant %@", [[OpenPATHContext sharedOpenPATHContext].activeStudy.studyID absoluteString]];
}

/*
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
 imagePickerResponse_.responseData  = [[NSMutableData alloc] initWithData:UIImagePNGRepresentation(image)];
 
 [[engine_ persistanceDelegate] informWithContent:imagePickerInteraction_];
 
 [imagePickerResponse_ release];
 [imagePickerInteraction_ release];
 
 imagePickerInteraction_	= nil;
 imagePickerResponse_	= nil;
 
 [picker dismissModalViewControllerAnimated:YES];
 }
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithInfoFromImagePicker:[info objectForKey:UIImagePickerControllerMediaMetadata]];
    UIImage *image = nil;
	
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
    if ([mediaType isEqualToString:@"public.image"]) {
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		
        [metadata setDescription:[engine_ getCurrentInteraction].text];
        [metadata setDateOriginal:[NSDate date]];
        [metadata setImageOrientarion:image.imageOrientation];
		
        Study *   study    = [OpenPATHContext sharedOpenPATHContext].activeStudy;
		NSString* siteName = [StringUtils isEmpty:[study studySiteName]] ? @"Unknown" : [study studySiteName];
		
        [metadata setUserComment:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum];
        [metadata setSubjectLocation:siteName];
        [metadata setArtist:study.studyPrimaryResearcher];
		
        AssetDAO * dao   = [AssetDAO new];
        Asset *    asset = [Asset new];
		
        [library saveImage:image toAlbum:siteName metadata:metadata withCompletionBlock:^(NSURL *assetUrl, NSError *error) {
            if (error != nil) {
                NSLog(@"Big error: %@", [error description]);
            } else {
                asset.fileUrl = [assetUrl absoluteString];
				
                [asset allocateObjectId];
                asset.assetID    = [engine_ getCurrentResponse].label;
                asset.relatedID  = [OpenPATHContext sharedOpenPATHContext].activeStudy.organizationID;
                asset.originator = study.studyPrimaryResearcher;
                asset.location   = siteName;
                asset.assetType  = AssetTypePhoto;
                asset.patientID  = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
				
                [dao insert:asset];
            }
        }];
    } else if ([mediaType isEqualToString:@"public.movie"]) {
        //NSURL* videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		
        //[NSData dataWithContentsOfURL:videoURL]
    }
		
    [picker dismissModalViewControllerAnimated:NO];
		
    imagePickerInteraction_ = nil;
    imagePickerResponse_ = nil;
	
    if (image != nil) {
        MediaViewController *childController = [[MediaViewController alloc] init];
		
        childController.image = image;
		
        [[self navigationController] pushViewController:childController animated:YES];
    }
}

- (void)takeVideoWithIntervention:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
		
        imagePicker_.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeMovie];
        imagePicker_.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        imagePicker_.videoQuality = UIImagePickerControllerQualityTypeHigh;
		
        imagePicker_.showsCameraControls = YES;
        imagePicker_.navigationBarHidden = YES;
		
        // Make camera view full screen:
        imagePicker_.wantsFullScreenLayout = YES;
        imagePicker_.cameraViewTransform = CGAffineTransformScale(imagePicker_.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
		
        imagePickerInteraction_ = interaction;
        imagePickerResponse_    = response;
		
        [self presentModalViewController:imagePicker_ animated:YES];
    } else
        [AlertUtilities showOkAlert:@"The video camera is not available."];
}

- (int)locateDataRow:(NSString *)dataValue {
    if (dataValue == nil)
        return 0;
	
    for (int i = 0; i < [[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintValueList count]; i++) {
        if ([dataValue isEqualToString:[[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintValueList objectAtIndex:i]])
            return i;
    }
	
    return 0;
}

- (IBAction)clearSurvey {
    [engine_ reset];
    [questionTableView_ reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [engine_ getCurrentInteraction].text;
 }
 */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *text = [engine_ getCurrentInteraction].text;
	
    if ([WSStringUtils isNotEmpty:text]) {
        CGSize size = [text sizeWithFont:[style_ headerFontFromStyle] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
		
        return size.height + 30.0f;
    } else {
        return 0;
    }
}

- (CGFloat)heightOfRowWithText:(NSString *)text {
	UIFont* font = [style_ fontFromStyle];
	
    CGSize size = [text sizeWithFont:[style_ fontFromStyle] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
    return size.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
	
    if (height != 0) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 290, height)];
        NSString *textStr = [engine_ getCurrentInteraction].text;
		
        textView.textColor = style_.headerTextColor;
		
        textView.font = [style_ headerFontFromStyle];
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
		
        textView.text = textStr;
		
        [headerView addSubview:textView];
		
		self.title = textStr;
    }
	
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[engine_ getCurrentInteraction] filteredResponseCount];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier             = @"Cell";
    static NSString *CellButtonIdentifier       = @"CellButton";
    static NSString *CellTextFieldIdentifier    = @"CellTextField";
    static NSString *CellTextBoxIdentifier      = @"CellTextBox";
    static NSString *CellSeparatorIdentifier    = @"CellSeparator";
	static NSString *CellWithCountIdentifier    = @"CellWithCount";
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:indexPath.row];
	
    UITableViewCell*           cell          = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell*           cellButton    = [tableView dequeueReusableCellWithIdentifier:CellButtonIdentifier];
    UITableViewCell*           cellTextField = [tableView dequeueReusableCellWithIdentifier:CellTextFieldIdentifier];
    UITableViewCell*           cellSeparator = [tableView dequeueReusableCellWithIdentifier:CellSeparatorIdentifier];
    UITableViewCell*           cellTextBox   = [tableView dequeueReusableCellWithIdentifier:CellTextBoxIdentifier];
	LabelWithCountCustomCell*  cellWithCount = [tableView dequeueReusableCellWithIdentifier:CellWithCountIdentifier];;
	
    // Construct the correct control for the type of response
	if ((cellWithCount == nil) && ([rowResponse isTask])) {
		cellWithCount = [[LabelWithCountCustomCell alloc] initWithIdentifier:CellWithCountIdentifier];
		
		cellWithCount.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        cellWithCount.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(224.0 / 255.0) green:(231.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];
		
		cellWithCount.nameLabel.textColor = style_.textColor;
        cellWithCount.nameLabel.font      = style_.fontFromStyle;
	}
	
    if ((cell == nil) && (rowResponse.type == ResponseTypeUnknown)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        cell.textLabel.textColor = style_.textColor;
        cell.textLabel.font      = style_.fontFromStyle;
		
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(224.0 / 255.0) green:(231.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
        [cell imageView].image = nil;
		
		cell.backgroundColor = [UIColor whiteColor];
		
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = rowResponse.label;
    }
	
    if ((cellTextBox == nil) && [rowResponse isFreeResponse]) {
        cellTextBox = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTextBoxIdentifier];
		
        // Response represents a text view
        UITextView *respTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 280, [rowResponse.controlHeight intValue])];
		
        respTextView.textColor = style_.textColor;
        respTextView.font = style_.fontFromStyle;
        respTextView.scrollEnabled = YES;
        [respTextView setDelegate:self];
        respTextView.backgroundColor = [UIColor whiteColor];
        respTextView.tag = TAG_TEXT_VIEW;
        respTextView.returnKeyType = UIReturnKeyDone;
        respTextView.frame = CGRectMake(5, 5, 280, [rowResponse.controlHeight intValue]);
		
        [cellTextBox.contentView addSubview:respTextView];
        cellTextBox.accessoryType = UITableViewCellAccessoryNone;
        cellTextBox.backgroundColor = [UIColor whiteColor];
    }
	
    if ((cellTextField == nil) && [rowResponse isFreeFixedResponse]) {
        // Represents a cell with a text field for data entry. The background is transparent.  Looks like a typical data entry box.
        cellTextField = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTextFieldIdentifier];
        cellTextField.selectionStyle = UITableViewCellSelectionStyleNone;
		
        UITextField *txtField;
		
        txtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 285, 45)];
        txtField.textColor = style_.textColor;
        txtField.font = style_.fontFromStyle;
        [txtField setTextAlignment:UITextAlignmentCenter];
        [txtField setDelegate:self];
        txtField.returnKeyType = UIReturnKeyDone;
        txtField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"WOSRender.bundle/TextBox.png"]];;
        txtField.borderStyle = UITextBorderStyleNone;
        txtField.tag = TAG_TEXT_FIELD;
        txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
        cellTextField.backgroundView = nil;
        cellTextField.selectedBackgroundView = nil;
        cellTextField.backgroundColor = [UIColor clearColor];
		
        [cellTextField.contentView addSubview:txtField];
    }
	
    if ((cellSeparator == nil) && [rowResponse isDirectiveResponse]) {
        cellSeparator = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellSeparatorIdentifier];
        cellSeparator.selectionStyle = UITableViewCellSelectionStyleNone;
		
        UITextView *respTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 270, 50)];
		
        respTextView.textColor = [UIColor blackColor];  //[UIColor colorWithRed:(153.0/255.0 )green:(51.0/255.0)blue:0.0 alpha:1.0];
        respTextView.font = style_.fontFromStyle;
        respTextView.textAlignment = UITextAlignmentLeft;
        respTextView.scrollEnabled = NO;
        //respTextView.editable			= NO;
        respTextView.returnKeyType = UIReturnKeyDone;
        [respTextView setDelegate:self];
        respTextView.backgroundColor = [UIColor clearColor];
        respTextView.tag = TAG_DIRECTIVE_VIEW;
		
        //respTextView.frame = CGRectMake(5, 5, 275, [rowResponse.controlHeight intValue]);
        [cellSeparator.contentView addSubview:respTextView];
        cellSeparator.backgroundColor = [UIColor clearColor];
    }
	
    // CellButton represents a cell that acts like a standard button. Allows navigating to the next interaction without pressing the NEXT button.
	if ((cellButton == nil) && ([rowResponse isFixedResponse] || [rowResponse isGoal] || [rowResponse isReward] || [rowResponse isTask] || [rowResponse isFixedNextResponse])) {
        cellButton = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellButtonIdentifier];
		
        cellButton.textLabel.textColor = style_.textColor;
        [cellButton imageView].image = nil;
				
		cellButton.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        cellButton.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(224.0 / 255.0) green:(231.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];\
						
		cellButton.backgroundView= nil;
		
        UITextView *respTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 270, 50)];
		
        respTextView.textColor = style_.labelTextColor;
        respTextView.font = style_.fontFromStyle;
        respTextView.textAlignment = UITextAlignmentCenter;
        respTextView.scrollEnabled = NO;
        [respTextView setDelegate:self];
		respTextView.backgroundColor	= [UIColor clearColor];
		respTextView.userInteractionEnabled = false;
		respTextView.tag = TAG_BUTTON_VIEW;
		
		if ([WSStringUtils isNotEmpty:style_.tableCellBackgroundImage]) {
			UIImageView* backgroundView		= [[ UIImageView alloc ] initWithFrame:CGRectZero ];
			backgroundView.backgroundColor  = [ UIColor clearColor ];
        	backgroundView.image			= [UIImage imageWithData:[Base64 decode:style_.tableCellBackgroundImage]];
        	cellButton.backgroundView		= backgroundView;
		}
		
		if ([WSStringUtils isNotEmpty:style_.tableCellBackgroundSelectedImage]) {
			UIImageView* backgroundView		  = [[ UIImageView alloc ] initWithFrame:CGRectZero ];
			backgroundView.backgroundColor    = [ UIColor clearColor ];
        	backgroundView.image			  = [UIImage imageWithData:[Base64 decode:style_.tableCellBackgroundSelectedImage]];
        	cellButton.selectedBackgroundView = backgroundView;
		}
		
		if (style_.tableCellBackgroundColor != nil) {
			cellButton.backgroundColor = style_.tableCellBackgroundColor;
		} else {
			cellButton.backgroundColor = [UIColor whiteColor];	
		}
		
        [cellButton.contentView addSubview:respTextView];
        cellButton.accessoryView = nil;
    }
	
    // Now generate the correct table row based on the information in the interaction/reponse
	if ([rowResponse isTask]) {
		cellWithCount.nameLabel.text = rowResponse.label;
		
		TaskDAO*      dao = [TaskDAO new];
		ResdbResult*  result = nil;
		
		result = [dao retrieve:[rowResponse.systemID absoluteString]];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			Task* task = (Task*)result.resdbObject;
			
			cellWithCount.countLabel.text = [[NSString alloc] initWithFormat:@"%d", task.completionCount];
		} else {
			cellWithCount.countLabel.text = @"0";
		}
		
		NSString* selectedBackgroundImagePath = [[self frameworkBundle] pathForResource:@"WOSRender.bundle/paintCellYellowBackgroundSelected" ofType:@"png"];
		UIImage*  selectedBackgroundImage     = [[UIImage imageWithContentsOfFile:selectedBackgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
		UIView*   selectedBackgroundView      = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
		
        cellWithCount.selectedBackgroundView = nil; //selectedBackgroundView;
        cellWithCount.selectedBackgroundView.backgroundColor = [UIColor clearColor];
		
        cellWithCount.backgroundColor = [UIColor whiteColor];
		
		NSString* backgroundImagePath = [[self frameworkBundle] pathForResource:@"WOSRender.bundle/paintCellBackground" ofType:@"png"];
		UIImage*  backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
		UIView*   backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
		
		cellWithCount.backgroundView= nil; //backgroundView;
		
		cellWithCount.countLabel.hidden = NO;
		cellWithCount.countButton.hidden = NO;
		
		return cellWithCount;
	}
	
    if ((![WSStringUtils isEmpty:[rowResponse controlType]] && [[rowResponse controlType] isEqualToString:@"Video"])) {
		
        // Cell is a standard unmaligned table cell.
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textColor = [Theme buttonTextColor];
            [cell imageView].image = nil;
        }
		
        // Response needs to show a video.
        if (videoPlayer_ == nil) {
            NSString *urlStr = [[self frameworkBundle] pathForResource:[[rowResponse controlImage] fragment] ofType:nil];
            NSURL *url = [NSURL fileURLWithPath:urlStr];
			
            videoPlayer_ = [[MPMoviePlayerController alloc] initWithContentURL:url];
            videoPlayer_.controlStyle = MPMovieControlStyleNone; //MPMovieControlStyleEmbedded;
            videoPlayer_.view.frame = CGRectMake(0, 0, 320, 420);
			[videoPlayer_ setFullscreen:true animated:true];
        } else {
            NSString *urlStr = [[self frameworkBundle] pathForResource:[[rowResponse controlImage] fragment] ofType:nil];
            NSURL *url = [NSURL fileURLWithPath:urlStr];
			
            [videoPlayer_ setContentURL:url];
        }
		
        cell.accessoryType = UITableViewCellAccessoryNone;
		
        cell.textLabel.text = rowResponse.label;
		
        [self.view addSubview:videoPlayer_.view];
		
        [videoPlayer_ play];
		
        return cell;
    } else if ([rowResponse isFixedResponse] || [rowResponse isGoal] || [rowResponse isTask] || [rowResponse isReward] || [rowResponse isFixedNextResponse]) {
        UITextView *responseView = (UITextView *) [cellButton viewWithTag:(NSInteger) TAG_BUTTON_VIEW];
		
        responseView.frame = CGRectMake(5, 5, 270, ([self heightOfRowWithText:rowResponse.label] + 15));
        responseView.backgroundColor = [UIColor clearColor];
        responseView.text = rowResponse.label;
        cellButton.contentView.tag = indexPath.row;   //  Allows us to know the response index when given the view
		
		cellButton.backgroundColor = [UIColor whiteColor];
		
        cellButton.accessoryView = nil;
		
        if ([rowResponse controlImage] != nil) {
            [cellButton imageView].image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"WOSRender.bundle/%@", [[rowResponse controlImage] fragment]]];
			interactionImageView_.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"WOSRender.bundle/%@", [[rowResponse controlImage] fragment]]];
			[self.view addSubview:interactionImageView_];
			[self.view bringSubviewToFront:interactionImageView_];
        } else {
            [cellButton imageView].image = nil;
        }
		
        //  For multi-selects using buttons, we may not have made the selections persistant yet.  So the response value field knows.
        bool showCheckMark = false;
		
        if ([rowInteraction isInterrogativeMulti]) {
            if ([WSStringUtils isNotEmpty:rowResponse.responseValue] && (![rowResponse.responseValue isEqualToString:@"0"])) {
                [engine_ setCurrentResponse:rowResponse];
                showCheckMark = true;
            }
        } else if ([rowInteraction isInterrogativeSingle]) {
            if ([WSStringUtils isNotEmpty:rowResponse.responseValue]) {
                [engine_ setCurrentResponse:rowResponse];
                showCheckMark = true;
            }
        }
		
		if ([rowResponse isGoal]) {
			GoalDAO*      dao    = [GoalDAO new];
			ResdbResult*  result = nil;
			
			result = [dao retrieve:[rowResponse.systemID absoluteString]];
			
			if (result.resdbCode == RESDB_SQL_ROWS) {
				Goal* goal = (Goal*)result.resdbObject;
				
				if ([WSStringUtils isNotEmpty:goal.completionTime]) {
					NSString*  backgroundImagePath = [[self frameworkBundle] pathForResource:@"reward" ofType:@"png"];
					UIImage*   backgroundImage     = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
					UIView*    backgroundView      = [[UIImageView alloc] initWithImage:backgroundImage];
					
					cellButton.accessoryView = backgroundView;
					cellButton.accessoryType = UITableViewCellAccessoryCheckmark;
				}
			}
			
			return cellButton;
		}
		
        if (showCheckMark) {
            NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"checkMark" ofType:@"png"];
            UIImage *backgroundImage      = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
            UIView *backgroundView        = [[UIImageView alloc] initWithImage:backgroundImage];
			
            cellButton.accessoryView = backgroundView;
            cellButton.accessoryType = UITableViewCellAccessoryCheckmark;
        } else
            cellButton.accessoryType = UITableViewCellAccessoryNone;
		
        return cellButton;
    } else if (![WSStringUtils isEmpty:[rowResponse controlType]] && [[rowResponse controlType] isEqualToString:@"Image"]) {
        // Response represents an image.
        UILabel *label = [cell textLabel];
        label.textAlignment = UITextAlignmentLeft;
		
        if ([WSStringUtils isNotEmpty:[[rowResponse controlImage] fragment]]) {
            [cell imageView].image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"WOSRender.bundle/%@", [[rowResponse controlImage] fragment]]];
        } else {
            [cell imageView].image = nil;
        }
		
        cell.textLabel.text = rowResponse.label;
		
        return cell;
    } else if ([rowResponse isFreeResponse]) {
        UITextView *respTextView = (UITextView *) [cellTextBox viewWithTag:(NSInteger) TAG_TEXT_VIEW];
		
        if (respTextView == nil) {
            //  We got problems
            return nil;
        }
		
        if ([WSStringUtils isNotEmpty:[rowResponse controlHeight]]) {
            respTextView.frame = CGRectMake(5, 5, 280, [rowResponse.controlHeight intValue]);
        }
		
        if (rowResponse.responseValue != nil) {
            respTextView.text = rowResponse.responseValue;
        } else {
            respTextView.text = nil;
        }
		
        cellTextBox.contentView.tag = indexPath.row;   //  Allows us to know the response index when given the view
		
        [respTextView setDelegate:self];
        respTextView.returnKeyType = UIReturnKeyDone;
		
        if ([rowResponse isResponseFormatNumeric])
            [respTextView setKeyboardType:UIKeyboardTypeNumberPad];
        else
            [respTextView setKeyboardType:UIKeyboardTypeDefault];
		
        return cellTextBox;
    } else if ([rowResponse isDirectiveResponse]) {
		UITextView *respTextView = (UITextView *) [cellSeparator viewWithTag:(NSInteger) TAG_DIRECTIVE_VIEW];
		
        if ([WSStringUtils isNotEmpty:[[rowResponse directiveImage] fragment]]) {
            userView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[rowResponse directiveImage] fragment]]];
			
			float imageHeight = 165.0;
			float imageWidth  = 220.0;
			
			if ([WSStringUtils isNotEmpty:[rowResponse controlHeight]]) {
				imageHeight = [rowResponse.controlHeight intValue];
			}
			
			if ([WSStringUtils isNotEmpty:[rowResponse controlWidth]]) {
				imageWidth = [rowResponse.controlWidth intValue];
			}
			
            CGRect imageRect = CGRectMake(((322 - imageWidth) / 2), 0, imageWidth, imageHeight);
			
            [userView_ setFrame:imageRect];
			
            //[cellSeparator addSubview:userView_];
			
			interactionImageView_.image = [UIImage imageNamed:[[rowResponse directiveImage] fragment]];
			backgroundImageView_.image  = nil;
			[self.view addSubview:interactionImageView_];
			[self.view bringSubviewToFront:interactionImageView_];
			
			cellSeparator.backgroundColor = [UIColor clearColor];
			respTextView.backgroundColor  = [UIColor clearColor];
			questionTableView_.separatorColor = [UIColor clearColor];
			
        } else if ([WSStringUtils isNotEmpty:[rowResponse behaviorUserComponent]]) {
            WSUserComponent *userComp = [NSClassFromString([rowResponse behaviorUserComponent]) new];
			
            if (userComp != nil) {
                userView_ = [userComp runAppWithIntervention:[engine_ getCurrentIntervention] andInteraction:[engine_ getCurrentInteraction] andResponse:rowResponse];
				
                [cellSeparator addSubview:userView_];
            }
        } else {
			respTextView.frame = CGRectMake(5, 5, 270, ([self heightOfRowWithText:rowResponse.label] + 100));
			cellSeparator.backgroundColor     = [UIColor clearColor];
			respTextView.backgroundColor      = [UIColor clearColor];
			questionTableView_.separatorColor = [UIColor clearColor];
		}
		
        respTextView.text = rowResponse.label;
		
        return cellSeparator;
    } else if ([rowResponse isFreeFixedResponse]) {
        UITextField *respTextField = (UITextField *) [cellTextField viewWithTag:(NSInteger) TAG_TEXT_FIELD];
		
        if (respTextField == nil) {
            // We got problems
            return nil;
        }
		
		questionTableView_.separatorColor = [UIColor clearColor];
		
        cellTextField.contentView.tag = indexPath.row;   //  Allows us to know the response index when given the text field
		
        if (rowResponse.responseValue != nil) {
            respTextField.text = rowResponse.responseValue;
        } else {
            respTextField.text = nil;
        }
		
        if ([rowResponse isResponseFormatNumeric]) {
            [respTextField setKeyboardType:UIKeyboardTypeNumberPad];
        } else if ([rowResponse isResponseFormatPhone]) {
            [respTextField setKeyboardType:UIKeyboardTypePhonePad];
        } else
            [respTextField setKeyboardType:UIKeyboardTypeDefault];
		
        [respTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		
        // Add a picker if requested.
        if ([rowResponse isResponseFormatValueList] || [rowResponse isResponseFormatDataList]) {
            pickerView_.tag = indexPath.row;    // Link the picker to the field
			
            if ([rowResponse isResponseFormatDataList]) {
                ActivityDAO *dao = [ActivityDAO new];
                ResdbResult *result;
				
                result = [dao retrieveByReason:@"Partner"];
				
                if (result.resdbCode == RESDB_SQL_ROWS) {
                    rowResponse.constraintValueList = [[NSMutableArray alloc] initWithCapacity:1];
					
                    [rowResponse.constraintValueList addObject:@" "];
					
                    int x = (320 - 200) / 2;
                    pickerView_.frame = CGRectMake(x, 247, 200, 30);
					
                    [self.view addSubview:pickerView_];
					
                    for (Activity *activity in result.resdbCollection) {
                        [rowResponse.constraintValueList addObject:activity.relatedID];
                    }
					
                    [pickerView_ reloadAllComponents];
                    [pickerView_ selectRow:[self locateDataRow:rowResponse.responseValue] inComponent:0 animated:NO];
                }
            } else {
                int x = (320 - 200) / 2;
                pickerView_.frame = CGRectMake(x, 247, 200, 30);
				
                [self.view addSubview:pickerView_];
                [pickerView_ reloadAllComponents];
                [pickerView_ selectRow:[self locateDataRow:rowResponse.responseValue] inComponent:0 animated:NO];
            }
        } else if ([rowResponse isResponseFormatDate]) {
            int x = (320 - 100) / 2;
            datePickerView_.frame = CGRectMake(x, 247, 120, 60);
            datePickerView_.datePickerMode = UIDatePickerModeDate;
            [self.view addSubview:datePickerView_];
			
            datePickerView_.tag = indexPath.row;  // Link the picker to the view.
        } else if ([rowResponse isResponseFormatDateTime]) {
            int x = (320 - 240) / 2;
            datePickerView_.datePickerMode = UIDatePickerModeDateAndTime;
            datePickerView_.frame = CGRectMake(x, 247, 240, 60);
            [self.view addSubview:datePickerView_];
			
            datePickerView_.tag = indexPath.row;  // Link the picker to the view.
        }
		
        [respTextField setReturnKeyType:UIReturnKeyDone];
		
        return cellTextField;
    }
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:indexPath.row];
	
    if ([WSStringUtils isNotEmpty:[rowInteraction getFilteredResponseAtIndex:indexPath.row].controlHeight])
        return ([[rowInteraction getFilteredResponseAtIndex:indexPath.row].controlHeight intValue] + 10);
	
    if ([rowResponse isFreeResponse]) {
        height = [rowResponse.controlHeight intValue] + 10;
    } else
        height = [self heightOfRowWithText:rowResponse.label] + 30;
	
    return height;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:indexPath.row];
	
    [engine_ setCurrentResponse:rowResponse];
	
    if ([WSStringUtils isNotEmpty:rowResponse.label]) {
        rowResponse.responseValue = [NSMutableString stringWithString:rowResponse.label];
    }
	
    if ([rowInteraction isInterrogativeSingle]) {
        [self resetResponseValueForAll:rowInteraction exceptResponse:rowResponse.systemID];
    }
	
    if (([rowResponse isFixedNextResponse] && [rowInteraction isInterrogativeSingle]) || [rowResponse isTask] || [rowResponse isGoal]) {
        [self nextAction:nil];
    } else if ([rowResponse isFixedResponse]) {
        // Reload the table so as to show the checkmark next to the response.
        [tableView reloadData];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    int responseIndex = [textField superview].tag;
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:responseIndex];
	
    [engine_ setCurrentResponse:rowResponse];
	
    textFieldBeingEdited_ = textField;
	
    return true;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    int responseIndex = [textView superview].tag;
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:responseIndex];
	
    [engine_ setCurrentResponse:rowResponse];
	
    if (textView.tag == TAG_BUTTON_VIEW) {
        if ([rowInteraction isInterrogativeSingle]) {
            rowResponse.responseValue = [NSMutableString stringWithString:rowResponse.label];
			
            [self resetResponseValueForAll:rowInteraction exceptResponse:rowResponse.systemID];
        } else if ([rowInteraction isInterrogativeMulti]) {
            //  Toggle the activity.
            if ([WSStringUtils isEmpty:rowResponse.responseValue]) {
                rowResponse.responseValue = [NSMutableString stringWithString:rowResponse.label];
            } else {
                rowResponse.responseValue = [NSMutableString stringWithString:@""];
            }
        }
		
        if ([rowResponse isFixedNextResponse] || [rowResponse isGoal] || [rowResponse isTask] || [rowResponse isReward]) {
            [self nextAction:nil];
        } else {
            [questionTableView_ reloadData];
        }
		
        return false;
    } else {
        textViewBeingEdited_ = textView;
        return true;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewFrame = self.view.frame;
	
    animatedDistance_ = textFieldRect.origin.y - TAB_BAR_HEIGHT - 20; // Push the text view to the top of the screen.  The "20" value was derived by trial-and-error.
    viewFrame.origin.y -= animatedDistance_;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
    [self.view setFrame:viewFrame];
	
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    int responseIndex = [textView superview].tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
    [engine_ setCurrentResponse:rowResponse];
	
    rowResponse.responseValue = [NSMutableString stringWithString:textView.text];
	
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance_;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
    [self.view setFrame:viewFrame];
	
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //CGRect   textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    //CGFloat  keyboardDistance = keyboardSize_.height + 12;
	
    // Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
    /*
     if (textFieldRect.origin.y > keyboardDistance) {
	 CGRect viewFrame = self.view.frame;
	 
	 animatedDistance_ = textFieldRect.origin.y - TAB_BAR_HEIGHT - 20; // Push the text view to the top of the screen.  The "20" value was derived by trial-and-error.
	 viewFrame.origin.y -= animatedDistance_;
	 
	 [UIView beginAnimations:nil context:NULL];
	 [UIView setAnimationBeginsFromCurrentState:YES];
	 [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	 
	 [self.view setFrame:viewFrame];
	 
	 [UIView commitAnimations];
     } else {
	 */
    animatedDistance_ = 0;
    //}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int responseIndex = [textField superview].tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
    [engine_ setCurrentResponse:rowResponse];
	
    rowResponse.responseValue = [NSMutableString stringWithString:textField.text];
	
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance_;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
    [self.view setFrame:viewFrame];
	
    [UIView commitAnimations];
}

- (BOOL)textViewShouldReturn:(UITextView *)theTextView {
    [theTextView resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: myOutlet = nil;
}

#pragma mark -
#pragma mark Picker view delegate

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    int responseIndex = picker.tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
    int valueCount = [[rowResponse constraintValueList] count];
    return valueCount;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView_ {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int responseIndex = picker.tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
    return [[rowResponse constraintValueList] objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    int responseIndex = pickerView.tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
    [label setText:[rowResponse.constraintValueList objectAtIndex:row]];
    [label setTextAlignment:UITextAlignmentCenter];
	
    return label;
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int responseIndex = picker.tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
    UITableViewCell *cell = [questionTableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:responseIndex inSection:0]];
    UITextField *textField = (UITextField *) [cell viewWithTag:TAG_TEXT_FIELD];
	
    if (textField == nil)
        return;
	
    [engine_ setCurrentResponse:rowResponse];
	
    textField.text = [rowResponse.constraintValueList objectAtIndex:row];
    rowResponse.responseValue = [NSMutableString stringWithString:textField.text];
}

- (NSString *)currentDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:(NSString *) @"MMM d, yyyy"];
	
    return [dateFormatter stringFromDate:[NSDate new]];
}

- (void)changeDateInLabel:(UIPickerView *)picker {
    int responseIndex = picker.tag;
    WSResponse *rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
    UITableViewCell *cell = [questionTableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:responseIndex inSection:0]];
    UITextField *textField = (UITextField *) [cell viewWithTag:TAG_TEXT_FIELD];
	
    if (textField == nil)
        return;
	
    [engine_ setCurrentResponse:rowResponse];
	
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
	
    if ([rowResponse isResponseFormatDateTime]) {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    } else {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
	
    textField.text = [dateFormatter stringFromDate:[datePickerView_ date]];
	
    rowResponse.responseValue = [NSMutableString stringWithString:textField.text];
}

@end
