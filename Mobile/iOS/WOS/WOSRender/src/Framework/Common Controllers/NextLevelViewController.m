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

#import "NextLevelViewController.h"
#import "SimpleCustomCell.h"
#import "CustomViewCell.h"

@implementation NextLevelViewController

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

@synthesize rowImage;
@synthesize	navController;
@synthesize tableDataSource;
@synthesize currentTitle;
@synthesize currentLevel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
	//self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"WOSRender.bundle/BasicTableBackgroundView.png"]];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tableDataSource count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString* CellIdentifier = @"Cell"; 
	
	SimpleCustomCell* cell = (SimpleCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell class]])
                cell = (SimpleCustomCell *)oneObject;
    }
	
	int count = [self childrenCount:indexPath.row];
	
	if (count == 0) {
		cell.countButton.hidden  = YES;
		cell.countLabel.hidden   = YES;
	} else {
		cell.countButton.hidden  = NO;
		cell.countLabel.hidden   = NO;
		cell.countLabel.text = [NSString stringWithFormat:@"%d",count];
	}
		
	NSDictionary* dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	cell.nameLabel.text = [dictionary objectForKey:@"Title"];
		
	if ([dictionary objectForKey:@"Children"] != nil)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	CustomViewCell* customCell = (SimpleCustomCell*)cell;
	
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
		NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"LightBackgroundLLS" ofType:@"png"];
		UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
		UIView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		backgroundView.frame = customCell.cellParentView.bounds;
		
		[customCell.cellParentView addSubview:backgroundView];
		[customCell.cellParentView sendSubviewToBack:backgroundView];
		[customCell.accessoryView addSubview:backgroundView];
    } else {
		NSString *backgroundImagePath = [[self frameworkBundle] pathForResource:@"DarkBackgroundLLS" ofType:@"png"];
		UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:2.0];
		UIView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		backgroundView.frame = customCell.cellParentView.bounds;
		
		[customCell.cellParentView addSubview:backgroundView];
		[customCell.cellParentView sendSubviewToBack:backgroundView];
		[customCell.accessoryView addSubview:backgroundView];
	}
}

-(int)childrenCount:(int)row {	
	NSDictionary*             dictionary = [self.tableDataSource objectAtIndex:row];
	NSString*                 viewName = [dictionary objectForKey:@"View"];
	int                       count = 0;
	
	if (viewName != nil)
		count = [[NSClassFromString(viewName) new] childrenCount:row];
	
	return count;
}

-(void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NextLevelViewController*  rvController = nil;
	NSDictionary*             dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	NSArray*                  children = [dictionary objectForKey:@"Children"];
	NSString*                 viewName = [dictionary objectForKey:@"View"];
	NSString*				  viewNameNoXib = [dictionary objectForKey:@"ViewNoXib"];
	NSString*                 titleName = [dictionary objectForKey:@"Title"];
	BOOL					  groupedTable = [[dictionary objectForKey:@"GroupedTable"] boolValue];
	
	if ([children count] != 0) {
		//  Sometimes the table list is managed by a specific controller and not our generic NextLevelViewController. Use it if specified
		if (viewName != nil) {
			if (groupedTable)
				rvController = [[NSClassFromString(viewName) alloc] initWithStyle:UITableViewStyleGrouped];
			else
				rvController = [[NSClassFromString(viewName) alloc] initWithStyle:UITableViewStylePlain];
		} else {
			rvController = [[NextLevelViewController alloc] initWithStyle:UITableViewStylePlain];
		}
		
		if (rvController != nil) {
			rvController.navController = self.navController;
			rvController.currentLevel += 1;
			[rvController setTitle: [dictionary objectForKey:@"Title"]];
			rvController.tableDataSource = children;
			
			[navController pushViewController:rvController animated:YES];
		}
	} else {
		if (viewName != nil) {
			UIViewController* childController = [[NSClassFromString(viewName)  alloc] init];
			childController.title = titleName;
			[[self navController] pushViewController:childController animated:YES];	
		} else if (viewNameNoXib != nil) {
			UIViewController* childController = [[NSClassFromString(viewNameNoXib) alloc] init];
			childController.title = titleName;
			[[self navController] pushViewController:childController animated:YES];	
		}
	}
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
