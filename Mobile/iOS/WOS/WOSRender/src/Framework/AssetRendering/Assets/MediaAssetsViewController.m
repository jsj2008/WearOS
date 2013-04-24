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

#import "MediaAssetsViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import <ImageIO/CGImageProperties.h>
#import "WOSCore/OpenPATHCore.h"
#import "SimpleCustomCell3.h"
#import "AudioTalkToUsViewController.h"
#import "MediaAssetsDetailViewController.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@implementation MediaAssetsViewController

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

@synthesize assets;
@synthesize patientNum;
@synthesize dataManager;

- (id)init {
    self = [super initWithNibName:@"MediaAssetsViewController" bundle:[self frameworkBundle]];
	
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

-(void)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadFromDB {
    AssetDAO*       dao = [AssetDAO new];
    ResdbResult*    result;

    [assets removeAllObjects];

	if ([StringUtils isEmpty:self.patientNum]) {
    	result = [dao retrieveAll];
	} else {
    	result = [dao retrieveByPatientId:self.patientNum];		
	}

    if (result.resdbCode == RESDB_SQL_ROWS) {
        [assets addObjectsFromArray:result.resdbCollection];
    }
}

- (void) viewWillAppear:(BOOL)animated {
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	
    [tableView_ deselectRowAtIndexPath:[tableView_ indexPathForSelectedRow] animated:animated];

    [self reloadFromDB];
   	[tableView_ reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view from its nib.
	
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
    library_ = [[ALAssetsLibrary alloc] init];
	
	self.title = @"Media Assets";

    assets = [[NSMutableArray alloc] initWithCapacity:20];

    [self reloadFromDB];
	
	// Really strange situation where the tableview is set at 0,0 event though the
	// navigation bar appears.  Only happens when moving from another controller.
	CGRect rect = tableView_.frame;
	
	//if (rect.origin.y == 0)
	//	tableView_.frame = CGRectMake(0, 40, 320, 450);
	
	//[library release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [assets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return 55.0;
}

- (void)callMemoDetail:(Asset*)asset {
	AudioTalkToUsViewController* childController = [[AudioTalkToUsViewController alloc] init];
	
    childController.title = NSLocalizedString(@"Audio Note",nil);
	childController.asset = asset;
	
	[[self navigationController] pushViewController:childController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    Asset* asset = [assets objectAtIndex:indexPath.row];
    
    if (asset == nil)
        return;
	
	MediaAssetsDetailViewController* childController = [[MediaAssetsDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];

	childController.asset 		= asset;
	childController.dataManager = dataManager;
    childController.title 		= NSLocalizedString(@"Asset", nil);
	
    [[self navigationController] pushViewController:childController animated:YES];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	SimpleCustomCell3* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell3" owner:self options:nil];
		
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell3 class]])
                cell = (SimpleCustomCell3 *)oneObject;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.nameLabel.textColor = [style_ textColor];
		cell.nameLabel.font      = [style_ fontFromStyle];
		cell.lowerLeftLabel.textColor = [style_ textColor];
		cell.lowerLeftLabel.font      = [style_ fontFromStyle];
    }
	
	Asset* asset = (Asset *)[assets objectAtIndex:indexPath.row];
	
	NSString* assetDescribe = asset.assetID;
	
	if ([StringUtils isEmpty:assetDescribe]) {
		[cell.nameLabel setText:@"Unknown Asset"];
	} else {
		[cell.nameLabel setText:assetDescribe];
	}
	
	NSString* assetDateTime = asset.creationTime;
	
	if ([StringUtils isEmpty:assetDateTime]) {
		[cell.lowerLeftLabel setText:@"Unknown Date"];
	} else {
		[cell.lowerLeftLabel setText:assetDateTime];
	}
	
	if (asset.assetType == AssetTypePhoto) {
		[cell.imageButton setImage:[UIImage imageNamed:@"WOSRender.bundle/photo32.png"] forState:UIControlStateNormal];
	} else if (asset.assetType == AssetTypeVideo) {
		[cell.imageButton setImage:[UIImage imageNamed:@"WOSRender.bundle/video32.png"] forState:UIControlStateNormal];
	} else if (asset.assetType == AssetTypeAudio) {
		[cell.imageButton setImage:[UIImage imageNamed:@"WOSRender.bundle/audio32.png"] forState:UIControlStateNormal];
	} else if (asset.assetType == AssetTypeText) {
		[cell.imageButton setImage:[UIImage imageNamed:@"WOSRender.bundle/text32.png"] forState:UIControlStateNormal];
	}
	
	return cell;
}

@end
