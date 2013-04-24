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

#import "GoalMainViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WOSEngine/OpenPATHEngine.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSMutableDictionary+ImageMetadata.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "LabelWithCountCustomCell.h"
#import "AlertUtilities.h"
#import "GoalDetailViewController.h"
#import "GoalCustomCell.h"
#import "VirtualCoachViewController.h"

@implementation GoalMainViewController

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

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super initWithNibName:@"GoalMainViewController" bundle:[self frameworkBundle]];
	
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

- (void)showError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	
    [alert show];
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
				newBtn_.hidden      = false;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHome.png"];
				break;
				
            case InteractionHILNavExitOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = true;
				newBtn_.hidden      = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerNone.png"];
				break;
				
			case InteractionHILNavHomeOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = false;
				previousBtn_.hidden = true;
				newBtn_.hidden      = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHome.png"];
				break;
				
			case InteractionHILNavNextOnly:
				nextBtn_.hidden     = false;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = true;
				newBtn_.hidden      = true;
				topBanner_.image    = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerNext.png"];
				break;
				
			case InteractionHILNavPrevOnly:
				nextBtn_.hidden     = true;
				homeBtn_.hidden     = true;
				previousBtn_.hidden = false;
				newBtn_.hidden      = true;
				topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBanner.png"];
				break;
				
			default:
				nextBtn_.hidden     = false;
				homeBtn_.hidden     = false;
				previousBtn_.hidden = false;
				newBtn_.hidden      = true;
			    topBanner_.image     = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHomeNext.png"];
		}
    } else {
        previousBtn_.hidden = false;
        nextBtn_.hidden = false;
        homeBtn_.hidden = false;
        patientBtn_.hidden = true;
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

                    responseButton.showsTouchWhenHighlighted = true;

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
                        NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"WOSRender.bundle/checkMark" ofType:@"png"];
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
    [pickerView_ removeFromSuperview];
    [datePickerView_ removeFromSuperview];
    [videoPlayer_.view removeFromSuperview];
    [userView_ removeFromSuperview];
    backgroundImageView_.image = nil;
	[interactionImageView_ removeFromSuperview];

    [engine_ askPreviousWithContent:[engine_ getCurrentIntervention]];

    [self formNavigation];

    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];

    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }

    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
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

    if (videoPlayer_ != nil) {
        [videoPlayer_ stop];
    }

    [engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	
	// We may have changed protocols which means it is up to us to try another iteration (engine won't do that for us
	if (engine_.getCurrentInteraction == nil) {
		[engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	}

    [self formNavigation];
	
    // Clear all response buttons
    NSArray *responseButtons = [self.view subviews];

    for (id oneObject in responseButtons) {
        if (([oneObject isKindOfClass:[UIView class]] && ((UIView *) oneObject).tag > 0)) {
            [oneObject removeFromSuperview];
        }
    }

    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
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

    if (([engine_ getCurrentInteraction].textResource != nil) && ([WSStringUtils isNotEmpty:[[engine_ getCurrentInteraction].textResource fragment]])) {
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

- (IBAction)homeAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setupSurvey];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)goalDetails {
	GoalDetailViewController*  controller = [[GoalDetailViewController alloc] init];
	
	[[self navigationController] pushViewController:controller animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    videoPlayer_ = nil;

	engine_ = [[WSClinicalEngine alloc] initWithProtocol:@"WOSRender.bundle/MainGoals" andPersistenceModel:nil withOptions:WSOptionEngineNone];
    style_  = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	[engine_ setUserDelegate:self];
	
	if ([WSStringUtils isNotEmpty:style_.background]) {
		UIImage* backgroundImage = [UIImage imageWithData:[Base64 decode:style_.background]];
		backgroundImageView_.image = backgroundImage;
	}

    self.view.backgroundColor = [UIColor whiteColor]; // LLS [Theme backgroundColor];

    [questionTableView_ setBackgroundView:nil];
    questionTableView_.backgroundColor = [UIColor clearColor]; // LLS [Theme backgroundColor];

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

- (void)takePictureWithIntervention:(WSIntervention *)intervention andInteraction:(WSInteraction *)interaction andResponse:(WSResponse *)response {
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
        imagePickerResponse_ = response;

        [self presentModalViewController:imagePicker_ animated:YES];
    } else
        [AlertUtilities showOkAlert:@"The camera is not available."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIView *v = [self.view viewWithTag:999];

    if (v)
        [v removeFromSuperview];
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
    }

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[engine_ getCurrentInteraction] filteredResponseCount];
}

- (void)goalCoachAction:(id)sender {
	UIButton*           coachButton    = (UIButton*)sender;
	WSInteractionHIL*   rowInteraction = [engine_ getCurrentInteraction];
    WSResponse*         rowResponse    = [rowInteraction getFilteredResponseAtIndex:coachButton.tag];
	GoalDAO*            dao            = [GoalDAO new];
	ResdbResult*        result;
	
	result = [dao retrieve:[rowResponse.systemID absoluteString]];
	
    VirtualCoachViewController *childController = [[VirtualCoachViewController alloc] init];
	
    childController.title = NSLocalizedString(@"Coach", nil);
	
	if (result.resdbCode == RESDB_SQL_ROWS) {
		Goal* goal = (Goal*)result.resdbObject;
		
		[OpenPATHContext sharedOpenPATHContext].activeGoal = goal;
		
		childController.protocol = [StringUtils isEmpty:goal.startTime] ? @"WOSRender.bundle/GoalStart" : @"WOSRender.bundle/GoalExperience";
	} else {
		childController.protocol = @"WOSRender.bundle/GoalStart";
	}
	
    [[self navigationController] pushViewController:childController animated:YES];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier             = @"Cell";
    static NSString *CellButtonIdentifier       = @"CellButton";
    static NSString *CellTextFieldIdentifier    = @"CellTextField";
    static NSString *CellTextBoxIdentifier      = @"CellTextBox";
    static NSString *CellSeparatorIdentifier    = @"CellSeparator";
	static NSString *CellWithCountIdentifier    = @"CellWithCount";
	static NSString *CellGoalIdentifier         = @"CellGoal";
    WSInteractionHIL *rowInteraction = [engine_ getCurrentInteraction];
    WSResponse *rowResponse = [rowInteraction getFilteredResponseAtIndex:indexPath.row];

    UITableViewCell*           cell          = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell*           cellButton    = [tableView dequeueReusableCellWithIdentifier:CellButtonIdentifier];
    UITableViewCell*           cellTextField = [tableView dequeueReusableCellWithIdentifier:CellTextFieldIdentifier];
    UITableViewCell*           cellSeparator = [tableView dequeueReusableCellWithIdentifier:CellSeparatorIdentifier];
    UITableViewCell*           cellTextBox   = [tableView dequeueReusableCellWithIdentifier:CellTextBoxIdentifier];
	LabelWithCountCustomCell*  cellWithCount = [tableView dequeueReusableCellWithIdentifier:CellWithCountIdentifier];
	GoalCustomCell*            cellGoal      = [tableView dequeueReusableCellWithIdentifier:CellGoalIdentifier];

    // Construct the correct control for the type of response
    if ((cell == nil) && (rowResponse.type == ResponseTypeUnknown)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.textColor = style_.textColor;
        cell.textLabel.font      = style_.fontFromStyle;
	
        [cell imageView].image = nil;

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

        txtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
        txtField.textColor = style_.textColor;
        txtField.font = style_.fontFromStyle;
        [txtField setTextAlignment:UITextAlignmentCenter];
        [txtField setDelegate:self];
        txtField.returnKeyType = UIReturnKeyDone;
        txtField.backgroundColor = [UIColor clearColor];
        txtField.borderStyle = UITextBorderStyleRoundedRect;
        txtField.tag = TAG_TEXT_FIELD;
        txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        cellTextField.backgroundView = nil;
        cellTextField.selectedBackgroundView = nil;
        cellTextField.backgroundColor = [UIColor whiteColor];

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
        respTextView.backgroundColor = [UIColor whiteColor];
        respTextView.tag = TAG_DIRECTIVE_VIEW;

        //respTextView.frame = CGRectMake(5, 5, 275, [rowResponse.controlHeight intValue]);
        [cellSeparator.contentView addSubview:respTextView];
        cellSeparator.backgroundColor = [UIColor whiteColor];
    }

    // CellButton represents a cell that acts like a standard button. Allows navigating to the next interaction without pressing the NEXT button.
	if ((cellGoal == nil) && [rowResponse isGoal]) {
		NSArray *nib = [[self frameworkBundle] loadNibNamed:@"GoalCustomCell" owner:self options:nil];
			
		for (id oneObject in nib) {
			if ([oneObject isKindOfClass:[GoalCustomCell class]])
				cellGoal = (GoalCustomCell *)oneObject;
			
			cellGoal.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
        		
        cellGoal.textLabel.textColor = style_.textColor;
        [cellGoal imageView].image = nil;
		
		if ([WSStringUtils isNotEmpty:style_.tableCellBackgroundImage]) {
			UIImageView* backgroundView		= [[ UIImageView alloc ] initWithFrame:CGRectZero ];
			backgroundView.backgroundColor  = [ UIColor clearColor ];
        	backgroundView.image			= [UIImage imageWithData:[Base64 decode:style_.tableCellBackgroundImage]];
        	cellGoal.backgroundView		    = backgroundView;
		}
		
		if ([WSStringUtils isNotEmpty:style_.tableCellBackgroundSelectedImage]) {
			UIImageView* backgroundView		  = [[ UIImageView alloc ] initWithFrame:CGRectZero ];
			backgroundView.backgroundColor    = [ UIColor clearColor ];
        	backgroundView.image			  = [UIImage imageWithData:[Base64 decode:style_.tableCellBackgroundSelectedImage]];
        	cellGoal.selectedBackgroundView   = backgroundView;
		}
		
		if (style_.tableCellBackgroundColor != nil) {
			cellGoal.backgroundColor = style_.tableCellBackgroundColor;
		}
		
        cellGoal.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
	
	if ((cellButton == nil) && ([rowResponse isFixedResponse] || [rowResponse isReward] || [rowResponse isTask] || [rowResponse isFixedNextResponse])) {
		cellButton = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellButtonIdentifier];

        cellButton.textLabel.textColor = style_.textColor;
        [cellButton imageView].image = nil;
		
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
		}

        UITextView *respTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 270, 50)];

        respTextView.textColor = style_.textColor;
        respTextView.font = style_.fontFromStyle;
        respTextView.textAlignment = UITextAlignmentCenter;
        respTextView.scrollEnabled = NO;
        [respTextView setDelegate:self];
		respTextView.backgroundColor	= [UIColor clearColor];
		respTextView.userInteractionEnabled = false;
		respTextView.tag = TAG_BUTTON_VIEW;
		
        [cellButton.contentView addSubview:respTextView];
        cellButton.accessoryView = nil;
    }

    if ((![WSStringUtils isEmpty:[rowResponse controlType]] && [[rowResponse controlType] isEqualToString:@"Video"])) {

        // Cell is a standard unmaligned table cell.
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.textColor = [UIColor blackColor];
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
    } else if ([rowResponse isGoal]) {
        cellGoal.contentView.tag = indexPath.row;   //  Allows us to know the response index when given the view
		cellGoal.nameLabel.text = rowResponse.label;
        cellGoal.accessoryView = nil;
		
		GoalDAO*     dao = [GoalDAO new];
		ResdbResult* result;
		
		result = [dao retrieve:[rowResponse.systemID absoluteString]];
		
		if (result.resdbCode == RESDB_SQL_ROWS) {
			Goal* goal = (Goal*)result.resdbObject;
			
			cellGoal.motivationLabel.text = goal.personalValue;
		}
		
		[cellGoal.coachButton addTarget:self action:@selector(goalCoachAction:) forControlEvents:UIControlEventTouchUpInside];
		cellGoal.coachButton.tag = indexPath.row;
		
		[cellGoal imageView].image = nil;
						
		cellGoal.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
        return cellGoal;
    } else if ([rowResponse isFixedResponse] || [rowResponse isTask] || [rowResponse isReward] || [rowResponse isFixedNextResponse]) {
        UITextView *responseView = (UITextView *) [cellButton viewWithTag:(NSInteger) TAG_BUTTON_VIEW];

        responseView.frame = CGRectMake(5, 5, 270, ([self heightOfRowWithText:rowResponse.label] + 15));
        responseView.backgroundColor = [UIColor clearColor];
        responseView.text = rowResponse.label;
        cellButton.contentView.tag = indexPath.row;   //  Allows us to know the response index when given the view

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
		
        if (showCheckMark) {
            NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"checkMark" ofType:@"png"];
            UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
            UIView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];

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
            userView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[NSString alloc] initWithFormat:@"WOSRender.bundle/%@", [[rowResponse directiveImage] fragment]]]];

            CGRect imageRect = CGRectMake(40, 0, 220, 165);
            [userView_ setFrame:imageRect];

            [cellSeparator addSubview:userView_];
        } else if ([WSStringUtils isNotEmpty:[rowResponse behaviorUserComponent]]) {
            WSUserComponent *userComp = [NSClassFromString([rowResponse behaviorUserComponent]) new];

            if (userComp != nil) {
                userView_ = [userComp runAppWithIntervention:[engine_ getCurrentIntervention] andInteraction:[engine_ getCurrentInteraction] andResponse:rowResponse];

                [cellSeparator addSubview:userView_];
            }
        } else {
			respTextView.frame = CGRectMake(5, 5, 270, ([self heightOfRowWithText:rowResponse.label] + 15));
		}

        respTextView.text = rowResponse.label;

        respTextView.backgroundColor = [UIColor whiteColor];

        return cellSeparator;
    } else if ([rowResponse isFreeFixedResponse]) {
        UITextField *respTextField = (UITextField *) [cellTextField viewWithTag:(NSInteger) TAG_TEXT_FIELD];

        if (respTextField == nil) {
            // We got problems
            return nil;
        }

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
                    pickerView_.frame = CGRectMake(x, 277, 200, 30);

                    [self.view addSubview:pickerView_];

                    for (Activity *activity in result.resdbCollection) {
                        [rowResponse.constraintValueList addObject:activity.relatedID];
                    }

                    [pickerView_ reloadAllComponents];
                    [pickerView_ selectRow:[self locateDataRow:rowResponse.responseValue] inComponent:0 animated:NO];
                }
            } else {
                int x = (320 - 200) / 2;
                pickerView_.frame = CGRectMake(x, 277, 200, 30);

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
        height = 50;
    } else if ([rowResponse isGoal]) {
		return 70;
	} else {
        height = [self heightOfRowWithText:rowResponse.label] + 30;
	}

    return height;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

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
