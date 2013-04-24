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

#import "MediaAssetsDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "AlertUtilities.h"
#import "TextFieldCustomCell.h"
#import "DeleteCustomCell.h"
#import "LabelCustomCell.h"
#import "MediaAssetsTypeViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"
#import "MediaViewController.h"
#import "AudioTalkToUsViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation MediaAssetsDetailViewController

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

@synthesize asset;
@synthesize fieldLabels;
@synthesize tempAsset;
@synthesize textFieldBeingEdited;
@synthesize switchFieldBeingEdited;
@synthesize animatedDistance;
@synthesize keyboardSize;
@synthesize dataManager;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat TAB_BAR_HEIGHT = 49;

- (void)deleteAction {
    if (asset.objectID != nil) {
        AssetDAO *dao = [AssetDAO new];
        [dao delete:[asset objectID]];
    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)saveAction {
    if (textFieldBeingEdited != nil) {
        [self setAssetPropertyFromTextField:textFieldBeingEdited];
    }

    if (tempAsset.fileUrl != nil)
        asset.fileUrl = tempAsset.fileUrl;
    if (tempAsset.timeLength != nil)
        asset.timeLength = tempAsset.timeLength;
    if (tempAsset.fileSize != nil)
        asset.fileSize = tempAsset.fileSize;
    if (tempAsset.relatedID != nil)
        asset.relatedID = tempAsset.relatedID;
    if (tempAsset.originator != nil)
        asset.originator = tempAsset.originator;
    if (tempAsset.location != nil)
        asset.location = tempAsset.location;
    if (tempAsset.locationCode != nil)
        asset.locationCode = tempAsset.locationCode;

    if (tempAsset.assetType != asset.assetType)
        asset.assetType = tempAsset.assetType;

    if (tempAsset.patientID != nil)
        asset.patientID = tempAsset.patientID;
    if (tempAsset.container != nil)
        asset.container = tempAsset.container;

    AssetDAO *dao = [AssetDAO new];

    if (asset.objectID == nil) {
        //  This is a new object.
        [asset allocateObjectId];
        [dao insert:asset];
    } else {
        [dao update:asset];
    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sendAction {
	[NSThread detachNewThreadSelector:@selector(sendData:) toTarget:dataManager withObject:asset];
}

- (IBAction)cancel:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;

    NSString *action = [optionActions objectAtIndex:buttonIndex];

    SEL selector = NSSelectorFromString(action);
    [self performSelector:selector];
}

- (void)options:(id)sender {
    UIActionSheet *popupOptions = [[UIActionSheet alloc]
            initWithTitle:nil delegate:self
        cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];


    int buttonIndex = 0;

    [popupOptions addButtonWithTitle:@"Save Asset"];
    [optionActions insertObject:@"saveAction" atIndex:buttonIndex];
    buttonIndex++;

    if (asset.objectID != nil) {
        [popupOptions addButtonWithTitle:@"Delete Asset"];
        [optionActions insertObject:@"deleteAction" atIndex:buttonIndex];
        buttonIndex++;
    }

    if (!asset.assetArchived) {
        [popupOptions addButtonWithTitle:@"Upload Asset"];
        [optionActions insertObject:@"sendAction" atIndex:buttonIndex];
        buttonIndex++;
    }

    [popupOptions addButtonWithTitle:@"Cancel"];

    [popupOptions setCancelButtonIndex:buttonIndex];

    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;

    [popupOptions showInView:self.tabBarController.view];
}

- (int)assetTypeFromString:(NSString *)assetTypeString {
    if (assetTypeString == nil) {
        return AssetTypeUnknown;
    }

    NSString *assetTypeDataPath = [[self frameworkBundle] pathForResource:@"AssetTypeTranslation" ofType:@"plist"];
    NSDictionary *stringToNumber = [[[NSDictionary alloc] initWithContentsOfFile:assetTypeDataPath] objectForKey:@"StringToNumber"];


    NSNumber *assetType = [stringToNumber valueForKey:assetTypeString];

    if (assetType != nil) {
        return [assetType intValue];
    }

    return AssetTypeUnknown;
}

- (int)archivedFromString:(NSString *)archivedString {
    if (archivedString == nil) {
        return 0;
    }

    return ([archivedString caseInsensitiveCompare:@"YES"] == NSOrderedSame);
}

- (int)assetArchivedFromString:(NSString *)assetArchivedString {
    if (assetArchivedString == nil) {
        return 0;
    }

    return ([assetArchivedString caseInsensitiveCompare:@"YES"] == NSOrderedSame);
}

- (NSString *)assetTypeFromInt:(int)assetType {
    NSString *assetTypeDataPath = [[self frameworkBundle] pathForResource:@"AssetTypeTranslation" ofType:@"plist"];
    NSDictionary *numberToString = [[[NSDictionary alloc] initWithContentsOfFile:assetTypeDataPath] objectForKey:@"NumberToString"];


    NSString *assetTypeStr = [numberToString valueForKey:[[NSString alloc] initWithFormat:@"%d", assetType]];

    if (assetTypeStr != nil) {
        return assetTypeStr;
    }

    return @"Unknown";
}

- (NSString *)archivedFromInt:(int)archived {
    if (asset.archived) {
        return @"YES";
    } else {
        return @"NO";
    }
}

- (NSString *)assetArchivedFromInt:(int)assetArchived {
    if (asset.assetArchived) {
        return @"YES";
    } else {
        return @"NO";
    }
}

- (void)setAssetPropertyFromTextField:(UITextField *)textField {
    switch (textField.tag) {
        case kAssetFileUrlIndex:
            tempAsset.fileUrl = textField.text;
            break;
        case kAssetTimeLengthIndex:
            tempAsset.timeLength = textField.text;
            break;
        case kAssetFileSizeIndex:
            tempAsset.fileSize = textField.text;
            break;
        case kAssetRelatedIDIndex:
            tempAsset.relatedID = textField.text;
            break;
        case kAssetOriginatorIndex:
            tempAsset.originator = textField.text;
            break;
        case kAssetLocationIndex:
            tempAsset.location = textField.text;
            break;
        case kAssetLocationCodeIndex:
            tempAsset.locationCode = textField.text;
            break;
        case kAssetPatientIDIndex:
            tempAsset.patientID = textField.text;
            break;
        case kAssetAssetTypeIndex:
            tempAsset.assetType = [self assetTypeFromString:textField.text];
            break;
        case kAssetArchivedIndex:
            tempAsset.archived = [self archivedFromString:textField.text];
            break;
        case kAssetAssetArchivedIndex:
            tempAsset.assetArchived = [self assetArchivedFromString:textField.text];
            break;
        case kAssetContainerIndex:
            tempAsset.container = textField.text;
            break;
        default:
            break;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    fieldLabels = [NSMutableArray new];

    if (asset == nil) {
        asset = [Asset new];
    }

    keyboardSize = CGSizeMake(0, PORTRAIT_KEYBOARD_HEIGHT);

    tempAsset = [Asset new];
    tempAsset.assetType = asset.assetType;
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];

    optionActions = [[NSMutableArray alloc] initWithCapacity:4];

    NSArray *assetArray = [[NSArray alloc] initWithObjects:
			NSLocalizedString(@"View", nil),
            NSLocalizedString(@"File URL", nil),
            NSLocalizedString(@"Time Length", nil),
            NSLocalizedString(@"File Size", nil),
            NSLocalizedString(@"Related ID", nil),
            NSLocalizedString(@"Originator", nil),
            NSLocalizedString(@"Location", nil),
            NSLocalizedString(@"Location Code", nil),
            NSLocalizedString(@"Patient ID", nil),
            NSLocalizedString(@"Asset Type", nil),
            NSLocalizedString(@"Archived", nil),
            NSLocalizedString(@"Asset Archived", nil),
            NSLocalizedString(@"Container", nil),
            nil];

    NSDictionary *assetLabelsDict = [NSDictionary dictionaryWithObject:assetArray forKey:@"Labels"];

    [self.fieldLabels addObject:assetLabelsDict];

    loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 190, 20, 20)];
    [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadingIndicator setHidesWhenStopped:YES];

    [self.view addSubview:loadingIndicator];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                 target:self
                                 action:@selector(saveAction:)];

    self.navigationItem.rightBarButtonItem = saveButton;

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                 target:self
                                 action:@selector(options:)];

    self.navigationItem.rightBarButtonItem = actionButton;

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
    if (textFieldBeingEdited != nil) {
        [textFieldBeingEdited resignFirstResponder];
    }

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)callMemoDetail:(Asset*)asset {
	AudioTalkToUsViewController* childController = [[AudioTalkToUsViewController alloc] init];
	
    childController.title = NSLocalizedString(@"Audio Note",nil);
	childController.asset = asset;
	
	[[self navigationController] pushViewController:childController animated:YES];
}

- (void)launchImageViewer {
	MediaViewController* 	childController = [[MediaViewController alloc] init];
	NSString*               imageUrlString = asset.fileUrl;
	
	if ([StringUtils isEmpty:imageUrlString])
		return;
	
	ALAssetsLibrary*  assetLib = [[ALAssetsLibrary alloc] init];
	NSURL*            imageUrl = [[NSURL alloc] initWithString:imageUrlString];
	
	NSLog(@"Created the URL.\n");
	
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
		NSLog(@"Successfully found the asset via the URL");
		
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		CGImageRef iref = [rep fullResolutionImage];
		
		NSLog(@"After attempting to generate the representation.\n");
		
		if (iref) {
			NSLog(@"Now have a reference.\n");
			
			UIImage *largeimage = [UIImage imageWithCGImage:iref];
			
			childController.image = largeimage;
			
			[[self navigationController] pushViewController:childController animated:YES];
		}
	};
	
	ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
		NSLog(@"Error while trying to access the asset from the lib\n");
		
		// important: notifies lock that "all tasks finished" (even though they failed)
		// notifies the lock that "all tasks are finished"
	};
	
	NSLog(@"About to call the asset library.\n");
	
	[assetLib assetForURL:imageUrl resultBlock:resultblock
			 failureBlock:(ALAssetsLibraryAccessFailureBlock) failureBlock];
	
	NSLog(@"All done with the processing of one asset.\n");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    if ([indexPath section] == 1) {
        [self deleteAction];
    }

    if ((section == 0) && (row == kAssetAssetTypeIndex)) {
        MediaAssetsTypeViewController *rvController = [[MediaAssetsTypeViewController alloc] initWithStyle:UITableViewStylePlain];

        rvController.asset = tempAsset;
        [rvController setTitle:NSLocalizedString(@"Asset Type", nil)];

        [[self navigationController] pushViewController:rvController animated:YES];
    } else if ((section == 0) && (row == kAssetFileViewIndex)) {
		if (asset.assetType == AssetTypeAudio) {
			[self callMemoDetail:asset];
		} else if (asset.assetType == AssetTypeVideo) {
			
		} else if (asset.assetType == AssetTypePhoto) {
			[self performSelectorOnMainThread:@selector(launchImageViewer) withObject:nil waitUntilDone:NO];
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *PatientTextCellIdentifier = @"PatientTextCellIdentifier";
    static NSString *SimpleCellIdentifier = @"SimpleCellIdentifier";
    static NSString *AssetLabelCellIdentifier = @"AssetLabelCellIdentifier";
    TextFieldCustomCell *textCell;
    UITableViewCell *simpleCell;
    LabelCustomCell *labelCell;
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];

    // Allocate the correct cell type
    switch (row) {
        case kAssetAssetTypeIndex:
		case kAssetFileViewIndex:
            labelCell = [tableView dequeueReusableCellWithIdentifier:AssetLabelCellIdentifier];

            if (labelCell == nil) {
                labelCell = [[LabelCustomCell alloc] initWithIdentifier:AssetLabelCellIdentifier];
				
				labelCell.nameLabel.font = [style_ fontFromStyle];
				labelCell.nameLabel.textColor = [style_ textColor];
				labelCell.label.font = [style_ fontFromStyle];
				labelCell.label.textColor = [style_ textColor];
			}
			
            labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }

    textCell = [tableView dequeueReusableCellWithIdentifier:PatientTextCellIdentifier];

    if (textCell == nil) {
        textCell = [[TextFieldCustomCell alloc] initWithIdentifier:PatientTextCellIdentifier delegate:self];
        textCell.accessoryType = UITableViewCellAccessoryNone;
        textCell.backgroundColor = [UIColor whiteColor];
		
		textCell.textField.font = [style_ fontFromStyle];
		textCell.textField.textColor = [style_ textColor];		
		textCell.nameLabel.font = [style_ fontFromStyle];
		textCell.nameLabel.textColor = [UIColor blackColor];
    }

    simpleCell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];

    if (simpleCell == nil) {
        simpleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleCellIdentifier];
        simpleCell.accessoryType = UITableViewCellAccessoryNone;
        simpleCell.backgroundColor = [UIColor whiteColor];
    }

    textCell.textField.tag = row;
    textCell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *dictionary = [fieldLabels objectAtIndex:section];
    NSArray *labelArray = [dictionary objectForKey:@"Labels"];

    textCell.nameLabel.text = [labelArray objectAtIndex:row];

    switch (row) {
		case kAssetFileViewIndex:
            labelCell.nameLabel.text = @"View";
			labelCell.tag = row;
			labelCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			return labelCell;
            break;
        case kAssetFileUrlIndex:
            textCell.textField.text = (tempAsset.fileUrl != nil) ? tempAsset.fileUrl : asset.fileUrl;
            break;
        case kAssetTimeLengthIndex:
            textCell.textField.text = (tempAsset.timeLength != nil) ? tempAsset.timeLength : asset.timeLength;
            break;
        case kAssetFileSizeIndex:
            textCell.textField.text = (tempAsset.fileSize != nil) ? tempAsset.fileSize : asset.fileSize;
            break;
        case kAssetRelatedIDIndex:
            textCell.textField.text = (tempAsset.relatedID != nil) ? tempAsset.relatedID : asset.relatedID;
            break;
        case kAssetOriginatorIndex:
            textCell.textField.text = (tempAsset.originator != nil) ? tempAsset.originator : asset.originator;
            break;
        case kAssetLocationIndex:
            textCell.textField.text = (tempAsset.location != nil) ? tempAsset.location : asset.location;
            break;
        case kAssetLocationCodeIndex:
            textCell.textField.text = (tempAsset.locationCode != nil) ? tempAsset.locationCode : asset.locationCode;
            break;
        case kAssetPatientIDIndex:
            textCell.textField.text = (tempAsset.patientID != nil) ? tempAsset.patientID : asset.patientID;
            break;
        case kAssetAssetTypeIndex:
            labelCell.nameLabel.text = @"Asset Type";
            labelCell.tag = row;

            if (tempAsset.assetType != asset.assetType) {
                labelCell.label.text = [self assetTypeFromInt:tempAsset.assetType];
            } else {
                labelCell.label.text = [self assetTypeFromInt:asset.assetType];
            }

            labelCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return labelCell;
            break;
        case kAssetArchivedIndex:
            textCell.textField.text = [self archivedFromInt:asset.archived];
            break;
        case kAssetAssetArchivedIndex:
            textCell.textField.text = [self assetArchivedFromInt:asset.assetArchived];
            break;
        case kAssetContainerIndex:
            textCell.textField.text = (tempAsset.container != nil) ? tempAsset.container : asset.container;
            break;
        default:
            break;
    }

    return textCell;
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];

    // Get the frame of the keyboard.
    NSValue *centerValue = [info objectForKey:UIKeyboardCenterEndUserInfoKey];
    NSValue *boundsValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGPoint keyboardCenter = [centerValue CGPointValue];
    CGRect keyboardBounds = [boundsValue CGRectValue];
    CGPoint keyboardOrigin = CGPointMake(keyboardCenter.x - keyboardBounds.size.width / 2.0,
            keyboardCenter.y - keyboardBounds.size.height / 2.0);

    CGRect keyboardScreenFrame = {keyboardOrigin, keyboardBounds.size};
    // some calculation...
    CGRect viewFrame = self.view.frame;
    CGRect keyboardFrame = [self.view.superview convertRect:keyboardScreenFrame fromView:nil];
    CGRect hiddenRect = CGRectIntersection(viewFrame, keyboardFrame);
    CGRect remainder, slice;

    CGRectDivide(viewFrame, &slice, &remainder, CGRectGetHeight(hiddenRect), CGRectMaxYEdge);

    keyboardSize.width = keyboardBounds.size.width;
    keyboardSize.height = keyboardBounds.size.height;
}

#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];

    // Make sure any movement will ensure that the table row will be visible below the top frame tab bar.
    switch (textField.tag) {
        case kAssetFileUrlIndex:
        case kAssetTimeLengthIndex:
        case kAssetFileSizeIndex:
        case kAssetRelatedIDIndex:
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
    [self setAssetPropertyFromTextField:textField];

    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

@end
