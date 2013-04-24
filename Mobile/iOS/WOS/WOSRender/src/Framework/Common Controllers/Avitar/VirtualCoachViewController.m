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

#import "VirtualCoachViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WOSEngine/OpenPATHEngine.h"
#import "Theme.h"
#import "AlertUtilities.h"
#import "CTView.h"
#import "QuestionTextView.h"
#import "ResponseTextView.h"
#import "MarkupParser.h"
#import "WSRenderingEngine.h"
#import "WSStyle.h"
#import "TalkToUsViewController.h"
#import "NSAttributedString+height.h"

@implementation VirtualCoachViewController

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

@synthesize surveyNavTabs = surveyNavTabs_;
@synthesize questionTableView = questionTableView_;
@synthesize kioskBanner = kioskBanner_;
@synthesize sideBanner = sideBanner_;
@synthesize progressSlider = progressSlider_;
@synthesize videoPlayer = videoPlayer_;
@synthesize engine = engine_;
@synthesize datePickerView = datePickerView_;
@synthesize webView = webView_;
@synthesize protocol = protocol_;

#pragma mark -
#pragma mark Initialization

static float screen_height = 400;
static float screen_border = 10.0;
static float screen_width  = 320.0;

- (id)init {
    self = [super initWithNibName:@"VirtualCoachViewController" bundle:[self frameworkBundle]];
	
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

- (void)showError:(NSString*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
													message:error
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK",nil];
	
	[alert show];
}

- (void)formNavigation {
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
			topBanner_.image = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerNone.png"];
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
			
		default:
			nextBtn_.hidden     = false;
			homeBtn_.hidden     = false;
			previousBtn_.hidden = false;
			topBanner_.image     = [UIImage imageNamed:@"WOSRender.bundle/TopTabBannerHomeNext.png"];
	}
	
	if ([WSStringUtils isNotEmpty:[[[engine_ getCurrentInteraction] audioResource] fragment]]) {
		audioBtn_.hidden = false;
	} else {
		audioBtn_.hidden = true;
	}
}

- (IBAction)audioAction:(id)sender {
	if (!audioFeature_)
		return;
	
	WSInteractionHIL* interaction = [engine_ getCurrentInteraction];
	
	if (interaction == nil) {
		return;
	}
	
	NSString* whatToSay = interaction.text;
}

- (IBAction)homeAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:NO];
}

- (void)showTalkToUs:(id)sender {
    TalkToUsViewController *childController = [[TalkToUsViewController alloc] init];
	
    childController.title                   = NSLocalizedString(@"TalkToUs", nil);
    childController.albumName               = [OpenPATHContext sharedOpenPATHContext].activeStudy.organizationID;
    childController.patientNum              = [OpenPATHContext sharedOpenPATHContext].activePatient.patientNum;
	childController.dataDistributionManager = [OpenPATHContext sharedOpenPATHContext].dataDistributionManager;
	
    [[self navigationController] pushViewController:childController animated:YES];
}

- (void) loadInteractionResource {
}

- (void)resetResponseValueForAll:(WSInteractionHIL*)interaction exceptResponse:(NSURL*)sysID {
	if (interaction == nil)
		return;
	
	for (WSResponse* response in [interaction responses]) {
		if (response.systemID == nil)
			continue;
		
		if ([response.systemID isEqual:sysID])
			continue;
		
		response.responseValue = [NSMutableString stringWithString:@""];
	}
}

- (void)responseButtonClicked:(id)sender {
	WSInteractionHIL*	rowInteraction = [engine_ getCurrentInteraction];
	int					responseIndex  = ((UIButton*)sender).tag - 100;
	WSResponse*			rowResponse    = [rowInteraction getFilteredResponseAtIndex:responseIndex];
	
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
	
	if ([rowResponse isFixedNextResponse] || [rowResponse isGoal]) {
		[self nextAction:nil];
	} else {
		[self performSelectorInBackground:@selector(layoutResponseControls) withObject:nil];
	}
}

- (CGFloat)heightOfRowWithText:(NSAttributedString*)string andWidth:(float)width {
	CTFramesetterRef    framesetter = CTFramesetterCreateWithAttributedString ( (__bridge CFMutableAttributedStringRef) string);
    CFRange             labelFitRange;
    CGSize              labelSize = CTFramesetterSuggestFrameSizeWithConstraints( framesetter, CFRangeMake( 0, [string length] ),
																				 NULL, CGSizeMake( width, CGFLOAT_MAX ), &labelFitRange );
	
    return (labelSize.height);
	
    //return [attrString boundingHeightForWidth:width];
}

- (BOOL)isInternalInteraction:(WSInteraction*)interaction {
	if (interaction.ontology == nil)
		return YES;
	
	NSString* ontology = [[interaction ontology] fragment];
	
	if ([WSStringUtils caseInsensitiveCompare:@"INTERNAL" toString:ontology] == NSOrderedSame) {
		return YES;
	}
	
	return NO;
}

- (void)layoutResponseControls {
	// Lay out any touch areas if indicated
	WSInteractionHIL*   interaction = [engine_ getCurrentInteraction];
	int 				rowIndex = 0;
	
	// Clear all response buttons
	NSArray *responseButtons = [self.view subviews];
	
	for (id oneObject in responseButtons) {
		if (([oneObject isKindOfClass:[UIView class]] && ((UIView*)oneObject).tag > 0)) {
			[oneObject removeFromSuperview];
		}
	}
    
    MarkupParser*  parser = [[MarkupParser alloc] init];
	
	if ((interaction != nil) && [WSStringUtils isNotEmpty:interaction.text] && ![self isInternalInteraction:interaction]) {
        //NSMutableAttributedString* questionString = [[NSMutableAttributedString alloc] initWithString:interaction.text];
		
       	//CTFontRef helvetica     = CTFontCreateWithName(CFSTR("Helvetica"), 18.0, NULL);
       	//CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 18.0, NULL);
		
		CTFontRef helvetica     = CTFontCreateWithName((__bridge CFStringRef)style_.fontFamily, 24, NULL);
		CTFontRef helveticaBold = CTFontCreateWithName((__bridge CFStringRef)style_.fontFamily, 24, NULL);
		
        /*
		 [questionString addAttribute:(__bridge id)kCTFontAttributeName
		 value:(__bridge id)helvetica
		 range:NSMakeRange(0, [questionString length])];
		 
		 // add some color
		 [questionString addAttribute:(__bridge id)kCTForegroundColorAttributeName
		 value:(__bridge id)[UIColor whiteColor].CGColor
		 range:NSMakeRange(0, [questionString length])];
		 */
		
        NSMutableString* questionText = [[NSMutableString alloc] initWithFormat:@"<font color=\"white\">%@",interaction.text];
		
        MarkupParser* parser = [[MarkupParser alloc] init];
        NSMutableAttributedString* questionString = [parser attrStringFromMarkup:questionText];
		
        CTTextAlignment theAlignment = kCTCenterTextAlignment;
		
        CFIndex theNumberOfSettings = 1;
        CTParagraphStyleSetting theSettings[1] = {
			{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment }
		};
		
        CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
		
		[questionString addAttribute:(__bridge id)kCTFontAttributeName
							   value:(__bridge id)helveticaBold
							   range:NSMakeRange(0, [questionString length])];

        [questionString addAttribute:(__bridge id)kCTParagraphStyleAttributeName
							   value:(__bridge id)theParagraphRef
							   range:NSMakeRange(0, [questionString length])];
		
 		float width  = screen_width;
		float height = [self heightOfRowWithText:questionString andWidth:screen_width];
		float x      = 0;
		float y      = screen_height - height - screen_border;
		
		UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, (height+20))];
		backView.backgroundColor = [UIColor blackColor];
		backView.alpha = 0.5;
		backView.tag = TAG_TEXT_QUESTION_VIEW;
		
		QuestionTextView* questionView = [[QuestionTextView alloc] initWithString:questionString andFrame:CGRectMake(x, y, width, height)];
		
		questionView.tag = TAG_TEXT_QUESTION_VIEW;
		
		[self.view addSubview:backView];
		[self.view addSubview:questionView];
		
		[self.view bringSubviewToFront:questionView];
	}
	
	if ((interaction != nil) && ([interaction filteredResponseCount] > 0)) {
		float xOffset		= 0.0;
        float yOffset       = 0.0;
		float widthLastRow  = 0.0;
        float heightLastRow = 10.0;
		
		for (WSResponse* response in [interaction filteredResponses]) {
			if ([response isFreeFixedResponse]) {
				float x =		[response.controlTouchX floatValue];
				float y =		[response.controlTouchY floatValue];
				float width =	[response.controlTouchWidth floatValue];
				float height = 	[response.controlTouchHeight floatValue];
				
				UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
				
				textView.tag = rowIndex + 100;
				
				textView.textColor				= [UIColor colorWithRed:(153.0/255.0 )green:(51.0/255.0)blue:0.0 alpha:1.0];
				textView.font					= [style_ fontFromStyle];   //[UIFont systemFontOfSize:20];
				
				textView.scrollEnabled			= YES;
				[textView setDelegate:self];
				textView.backgroundColor		= [UIColor clearColor];
				
				[self.view addSubview:textView];
				
				// Add a picker if requested.
				if ([response isResponseFormatValueList] || [response isResponseFormatDataList]) {
					UIPickerView* picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
					
					picker.autoresizingMask			= UIViewAutoresizingFlexibleWidth;
					picker.dataSource				= self;
					picker.delegate					= self;
					picker.showsSelectionIndicator	= YES;
					picker.tag = rowIndex + 100;
					
					textView.textAlignment = UITextAlignmentCenter;
					
					if ([response isResponseFormatValueList]) {
						//int x = (orientationOffset_ - [rowResponse.constraintControlWidth intValue]) / 2;
						picker.frame = CGRectMake(530, 460, 200, 175);
						[self.view addSubview:picker];
						[picker reloadAllComponents];
					}
				}
			} else if ([response isFixedResponse] || [response isFixedNextResponse] ||[response isDirectiveResponse]) {
				if (![self isInternalInteraction:interaction]) {
                    NSMutableAttributedString *responseString = [[NSMutableAttributedString alloc] initWithString:[WSStringUtils decodeFormattedString:response.label]];
					
                   	//CTFontRef helvetica     = CTFontCreateWithName(CFSTR("TrebuchetMS"), 28.0, NULL);
                   	//CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 28.0, NULL);
										
                   	CTFontRef helvetica     = CTFontCreateWithName((__bridge CFStringRef)style_.fontFamily, style_.fontSize, NULL);
                   	CTFontRef helveticaBold = CTFontCreateWithName((__bridge CFStringRef)style_.fontFamily, style_.fontSize, NULL);
					
                   	[responseString addAttribute:(__bridge id)kCTFontAttributeName
										   value:(__bridge id)helvetica
										   range:NSMakeRange(0, [responseString length])];
					
                   	// add some color
                   	[responseString addAttribute:(__bridge id)kCTForegroundColorAttributeName
										   value:(__bridge id)[UIColor whiteColor].CGColor
										   range:NSMakeRange(0, [responseString length])];
					
					yOffset = yOffset + heightLastRow + 40;
					xOffset = 0;
					
					heightLastRow 	= [self heightOfRowWithText:responseString andWidth:(screen_width - 40)];
					widthLastRow	= screen_width;
					
					UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, widthLastRow, (heightLastRow+20))];
					backView.backgroundColor = [UIColor blackColor];
					backView.alpha = 0.5;
					backView.tag = TAG_TEXT_RESPONSE_VIEW;
					
					ResponseTextView* responseView = [[ResponseTextView alloc] initWithString:responseString andFrame:CGRectMake((xOffset+20), (yOffset+10), (widthLastRow-40), heightLastRow)];
					
                    responseView.tag = TAG_TEXT_RESPONSE_VIEW;
					
					[self.view addSubview:backView];
					[self.view addSubview:responseView];
					
					[self.view bringSubviewToFront:responseView];
				} else if (response.controlTouchY != 0){
					xOffset			= [response.controlTouchX floatValue];
					yOffset 		= 20; //[response.controlTouchY floatValue];
					heightLastRow 	= [response.controlTouchHeight floatValue];
					widthLastRow	= [response.controlTouchWidth floatValue];
				}
				
			    UIButton* responseButton = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, yOffset, widthLastRow, (heightLastRow+20))];
				
				responseButton.tag = rowIndex + 100;
				[self.view addSubview:responseButton];
				
				responseButton.showsTouchWhenHighlighted = true;
				
				[responseButton addTarget:self action: @selector(responseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
				
				bool showCheckMark = false;
				
				if ([interaction isInterrogativeMulti]) {
					if ([StringUtils isNotEmpty:response.responseValue] && (![response.responseValue isEqualToString:@"0"])) {
						[engine_ setCurrentResponse:response];
						showCheckMark = true;
					}
				} else if ([interaction isInterrogativeSingle]) {
					if  ([WSStringUtils isNotEmpty:response.responseValue]) {
						[engine_ setCurrentResponse:response];
						showCheckMark = true;
					}
				}
				
				if (showCheckMark) {
					NSString*  backgroundImagePath = [[self frameworkBundle] pathForResource:@"checkMark" ofType:@"png"];
					UIImage*   backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
					UIView*    backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
					
					float checkMarkOffset = (((heightLastRow+20) - 30) / 2);
					backgroundView.frame = CGRectMake((screen_width - 40), ((yOffset - 5) + checkMarkOffset), 30, 30);
					backgroundView.tag	 = 200;
					
					[self.view addSubview:backgroundView];
					[self.view bringSubviewToFront:backgroundView];
				}
			} else if ([response hasVideoControl]) {
				if (videoPlayer_ == nil) {
					NSString*    urlStr  = [[self frameworkBundle] pathForResource:[[response controlImage] fragment] ofType:nil];
					NSURL*       url     = [NSURL fileURLWithPath:urlStr];
					
					videoPlayer_                = [[MPMoviePlayerController alloc] initWithContentURL:url];
					videoPlayer_.controlStyle   = MPMovieControlStyleEmbedded;
					videoPlayer_.view.frame     = CGRectMake(162, 220, 700, 450);
				} else {
					NSString*    urlStr  = [[self frameworkBundle] pathForResource:[[response controlImage] fragment] ofType:nil];
					NSURL*       url     = [NSURL fileURLWithPath:urlStr];
					
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
	if (audioPlayer_ != nil) {
		audioPlayer_ = nil;
	}
	
	[videoPlayer_.view removeFromSuperview];
	
	if (videoPlayer_ != nil) {
		[videoPlayer_ stop];
	}
	
	[engine_ askPreviousWithContent:[engine_ getCurrentIntervention]];
	
	if ([engine_ getCurrentInteraction] == nil) {
		return;
	}
	
	[self loadInteractionResource];
	
	[self layoutResponseControls];
	
	[self formNavigation];
	
	[self audioAction:nil];
}

- (IBAction)nextAction:(id)sender {
	if (audioPlayer_ != nil) {
		audioPlayer_ = nil;
	}
	
	[videoPlayer_.view removeFromSuperview];
	
	if (videoPlayer_ != nil) {
		[videoPlayer_ stop];
	}
	
	if ([[engine_ getCurrentInteraction] hasNoSelectedResponses] && [[engine_ getCurrentInteraction] isResponseRequired]) {
		[AlertUtilities showOkAlert:@"You must provide a response to the question." withTitle:@"Response Required"];
		return;
	}
	
	[engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	
	if ([engine_ getCurrentInteraction] == nil) {
		return;
	}
	
	[self loadInteractionResource];
	
	[self layoutResponseControls];
	
	[self formNavigation];
	
	[self audioAction:nil];
}

#pragma mark -
#pragma mark View lifecycle

- (void)setupSurvey {
	if (audioPlayer_ != nil) {
		audioPlayer_ = nil;
	}
	
	[videoPlayer_.view removeFromSuperview];
	
	if (videoPlayer_ != nil) {
		[videoPlayer_ stop];
	}
	
	progressSlider_.minimumValue		= 0.0;
	progressSlider_.maximumValue		= [[engine_ getCurrentIntervention] numberOfInteractions] - 1;
	progressSlider_.value					= 0; //[[engine_ getCurrentIntervention] getCurrentInteractionNumber];
	[progressSlider_ setThumbImage:[UIImage imageNamed:@"WOSRender.bundle/thumb.png"] forState:UIControlStateNormal];
	
	progressSlider_.value = 0.0;
	
	[engine_ reset];
	
	// Setup our first interaction
	[engine_ askNextWithContent:[engine_ getCurrentIntervention]];
	[self formNavigation];
	
	[self layoutResponseControls];
	
	[self loadInteractionResource];
	
	[self audioAction:nil];
	
	coachBtn_.hidden = YES;
}

- (void) finalInteraction:(id)sender {
	[[self navigationController] popViewControllerAnimated:NO];	
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	activeCoach_ = COACH_NO_COACH;
				
	NSUserDefaults*	prefs = [NSUserDefaults standardUserDefaults];
	audioFeature_ = [prefs boolForKey:@"Audio"];
	
	if ([WSStringUtils isNotEmpty:[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath]) {
		if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachPhoto1"] && ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1 != nil)) {
			backgroundImageView_.image = [[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto1] scaleProportionalToSize:CGSizeMake(320,440)];
		} else if ([[OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath isEqualToString:@"CoachPhoto2"] && ([OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2 != nil)) {
			backgroundImageView_.image = [[[UIImage alloc] initWithData:[OpenPATHContext sharedOpenPATHContext].activePatient.coachPhoto2] scaleProportionalToSize:CGSizeMake(320,440)];
		} else {
			backgroundImageView_.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"WOSRender.bundle/%@", [OpenPATHContext sharedOpenPATHContext].activePatient.coachFilePath]];
		}
	} else {
		backgroundImageView_.image = [UIImage imageNamed:@"WOSRender.bundle/CoachFemale01.jpg"];
	}
	
	[self.view sendSubviewToBack:backgroundImageView_];
	
	if ([WSStringUtils isEmpty:protocol_]) {
		protocol_ = @"WOSRender.bundle/SampleCoach";
	}
		
	histManager_ 		= [WSGeneralProtocolHistoryManager new];
	persistModel_ 		= nil; //[AvatarPersistanceModel new];
		
	engine_ = [[WSClinicalEngine alloc] initWithProtocol:protocol_ andPersistenceModel:persistModel_ withOptions:WSOptionEngineNone];
	
	[engine_ setUserDelegate:self];
	
	videoPlayer_ = nil;
	
	coachBtn_.hidden = YES;
		
	touchView_.backgroundColor = [UIColor clearColor];
	
	self.view.backgroundColor                        = [Theme backgroundColor];
	[questionTableView_ setBackgroundView:nil];
	questionTableView_.backgroundColor = [Theme backgroundColor];
	questionTableView_.separatorColor = [UIColor clearColor];
	
	responseTextView_					= [[UITextView alloc] initWithFrame: CGRectMake(5, 5, 650, 130)];
	responseTextView_.textColor			= [UIColor colorWithRed:(153.0/255.0 ) green:(51.0/255.0) blue:0.0 alpha:1.0];
	responseTextView_.font				= [UIFont systemFontOfSize:32];
	responseTextView_.scrollEnabled		= YES;
	[responseTextView_ setDelegate:self];
	responseTextView_.backgroundColor	= [UIColor whiteColor];
	
	responseTextField_					= [[UITextField alloc] initWithFrame: CGRectMake(5, 5, 700, 45)];
	responseTextField_.textColor			= [UIColor colorWithRed:(153.0/255.0 ) green:(51.0/255.0) blue:0.0 alpha:1.0];
	responseTextField_.font				= [UIFont systemFontOfSize:32];
	[responseTextField_ setTextAlignment:UITextAlignmentCenter];
	[responseTextField_ setDelegate:self];
	responseTextField_.returnKeyType		= UIReturnKeyDone;
	responseTextField_.backgroundColor	= [UIColor whiteColor];
	
	self.tabBarController.tabBar.hidden		= NO;
	
	surveyNavTabs_.selectedSegmentIndex  = -1;
		
	speech_ = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	
	//[speech_ setRate:(float)1.0];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	[self setupSurvey];
}

-(void)viewWillAppear:(BOOL)animated {
	self.navigationController.navigationBarHidden = true;
}

-(int)locateDataRow:(NSString*)dataValue {
	if (dataValue == nil)
		return 0;
	
	for (int i = 0; i < [[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintValueList count]; i++) {
		if ([dataValue isEqualToString:[[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintValueList objectAtIndex:i]])
			return i;
	}
	
	return 0;
}

- (IBAction)sendXML {
	[self setupSurvey];
	
	NSURL *myURL = [NSURL URLWithString:@"companion://www.ucsf.edu"];
	[[UIApplication sharedApplication] openURL:myURL];
}

- (IBAction)clearSurvey {
	progressSlider_.minimumValue	= 0.0;
	progressSlider_.maximumValue	= [[engine_ getCurrentIntervention] numberOfInteractions] - 1;
	progressSlider_.value				= 0; //[[engine_ getCurrentIntervention] getCurrentInteractionNumber];
	[progressSlider_ setThumbImage:[UIImage imageNamed:@"WOSRender.bundle/thumb.png"] forState:UIControlStateNormal];
	
	[engine_ reset];
	
	[questionTableView_ reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
}

#pragma mark -
#pragma mark Picker view delegate

- (unsigned) countOccurencesOf: (NSString *)subString inString:(NSString*)srcString {
	unsigned     count = 0;
	unsigned     myLength = [srcString length];
	NSRange    uncheckedRange = NSMakeRange(0, myLength);
    
	for(;;)  {
		NSRange foundAtRange = [srcString rangeOfString:subString options:0 range:uncheckedRange];
        
		if (foundAtRange.location == NSNotFound)
			return count;
        
		unsigned newLocation = NSMaxRange(foundAtRange);
        
		uncheckedRange = NSMakeRange(newLocation, myLength-newLocation);
        
		count++;
	}
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
	int				responseIndex	= picker.tag - 100;
	WSResponse*		rowResponse	= [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
	int valueCount = [[rowResponse constraintValueList] count];
	return valueCount;
}

- (NSString*)pickerView:(UIPickerView*)picker titleForRow:(NSInteger) row forComponent:(NSInteger)component {
	int				responseIndex	= picker.tag - 100;
	WSResponse*		rowResponse	= [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	
	return [[rowResponse constraintValueList] objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)picker viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintControlWidth intValue], 36)];
	[label setText:[[[engine_ getCurrentInteraction] getFilteredResponseAtIndex:0].constraintValueList objectAtIndex:row]];
	[label setTextAlignment:UITextAlignmentCenter];
	
	return label;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	int					responseIndex = picker.tag - 100;
	WSResponse*			rowResponse = [[engine_ getCurrentInteraction] getFilteredResponseAtIndex:responseIndex];
	NSArray*			responseControls = [self.view subviews];
	UITextField*		textField;
	
	for (id oneObject in responseControls) {
		if (([oneObject isKindOfClass:[UITextView class]] && ((UIView*)oneObject).tag == picker.tag)) {
			textField = oneObject;
			break;
		}
	}
	
	if (textField == nil)
		return;
	
	[engine_ setCurrentResponse:rowResponse];
	
	textField.text = [rowResponse.constraintValueList objectAtIndex:row];
	rowResponse.responseValue = [NSMutableString stringWithString:textField.text];
	
	if ([[engine_ getCurrentInteraction] isInterrogativeSingle]) {
		[self resetResponseValueForAll:[engine_ getCurrentInteraction] exceptResponse:rowResponse.systemID];
	}
}


@end