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

#import "SettingsTimerViewController.h"
#import "SettingsTimerDetailViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "AlertUtilities.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"

@implementation SettingsTimerViewController
@synthesize timerData;
@synthesize timer;

-(int)childrenCount:(int)row {
	int           count = 0;
	ResdbResult*  result = nil;
	TimerDAO*     dao = [TimerDAO new];
	
	result = [dao retrieveAll];
	
	if (result.resdbCode == RESDB_SQL_ROWS)
		count = [(NSString*)result.resdbObject integerValue];
	
	return count;	
}

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

- (id)init {
    self = [super initWithNibName:@"SettingsTimerViewController" bundle:[self frameworkBundle]];
	
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

- (void)callTimerDetail:(Timer*)evTimer {
	SettingsTimerDetailViewController* childController = [[SettingsTimerDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
	Timer*                     finalTimer;
	
	if (evTimer == nil) {
		finalTimer          = [Timer new];
		finalTimer.category = timer.category;
	} else 
		finalTimer = evTimer;
	
	childController.title = NSLocalizedString(@"Timer",nil);
	childController.timer = finalTimer;
	childController.hidesBottomBarWhenPushed = YES;
	
	[[self navController] pushViewController:childController animated:YES];	
}

- (IBAction)addTimer:(id)sender {	
	[self callTimerDetail:nil];
}

- (void)reloadFromDB {
	TimerDAO*      dao = [TimerDAO new];
	ResdbResult*  result = nil;
	
	[self.timerData removeAllObjects];
	
	result = [dao retrieveAll];
	
	if (result.resdbCode == RESDB_SQL_ROWS) 
		[self.timerData addObjectsFromArray:result.resdbCollection];
}

-(void)viewWillAppear:(BOOL)animated {
	[self.navController setNavigationBarHidden:false animated:NO];
	[self reloadFromDB];
	[self.tableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.timer = [Timer new];
	self.timerData = [NSMutableArray new];
		
	[super viewDidLoad];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
	
	UIView*   backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[Base64 decode:style_.background]]];
	
	self.tableView.backgroundView  = backgroundView;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.navigationItem.title = NSLocalizedString(@"Timers",nil);
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addTimer:)];
	
    self.navigationItem.rightBarButtonItem = addButton;
	[self.navController setNavigationBarHidden:false animated:NO];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	[self reloadFromDB];
	
	self.navController = [self navigationController];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
	static NSString* SimpleCellIdentifier = @"SimpleCellIdentifier";

	UITableViewCell* cell       = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	UITableViewCell* simpleCell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
	if (simpleCell == nil) {
		simpleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleCellIdentifier];
		
		simpleCell.textLabel.textColor  = [UIColor colorWithRed:(153.0/255.0 )green:(51.0/255.0)blue:0.0 alpha:1.0]; // LLS [UIColor whiteColor];
		[simpleCell imageView].image = nil;
		
		simpleCell.backgroundColor = [UIColor whiteColor]; //LLS [ UIColor lightGrayColor ];
		
		UITextView*   respTextView = [[UITextView alloc] initWithFrame: CGRectMake(50, 15, 220, 35)];
		
		respTextView.textColor			= [UIColor colorWithRed:(153.0/255.0 )green:(51.0/255.0)blue:0.0 alpha:1.0];  // LLS [UIColor whiteColor];
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
	
    NSUInteger	 row = [indexPath row];
	NSUInteger   section = [indexPath section];
	UITextView*  responseView = (UITextView*)[simpleCell viewWithTag:(NSInteger)100];
	
	Timer* myTimer =  [timerData objectAtIndex:row];
		
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	NSString* alarmName = ([StringUtils isNotEmpty:myTimer.startTime]) ? [[NSString alloc] initWithFormat:@"%@ (%@)", myTimer.name, myTimer.startTime] : myTimer.name;
	
	responseView.text = alarmName;
	simpleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[simpleCell imageView].image = [UIImage imageNamed:@"WOSRender.bundle/alarmSetting.png"];
	
	return simpleCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.timerData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger  section = [indexPath section];
	
	[self callTimerDetail:[timerData objectAtIndex:indexPath.row]];
}

@end
