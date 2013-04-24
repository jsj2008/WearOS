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

#import "NewsFeedViewController.h"
#import "WOSCore/OpenPATHCore.h"
#import "WOSEngine/OpenPATHEngine.h"
#import "SimpleCustomCell2.h"
#import "NewsFeedCell.h"
#import "TextMsgViewController.h"
#import "WSStyle.h"
#import "WSRenderingEngine.h"


@implementation NewsFeedViewController

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

@synthesize dataDistributionManager = dataDistributionManager_;
@synthesize groupName = groupName_;
@synthesize groupDescription = groupDescription_;

- (id)init {
    self = [super initWithNibName:@"NewsFeedViewController" bundle:[self frameworkBundle]];
	
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

- (void)reloadFeedData {
	if ((dataDistributionManager_ != nil) && [dataDistributionManager_ isLoggedIn]) {
		NSError*  error;
		
		NSArray *records = [dataDistributionManager_ retrieveFeedForGroup:groupName_ withOptions:WSChannelOptionNone didFailWithError:&error];
		
		data_ = records;
		
		[feedListView_ reloadData];
	}
}

-(void)refreshAction:(id)sender {
	[self reloadFeedData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	style_ = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
    // Do any additional setup after loading the view from its nib.
	
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];	
}

-(IBAction)txtMsgAction:(id)sender {
	TextMsgViewController *childController = [[TextMsgViewController alloc] init];
	
	childController.dataDistributionManager = dataDistributionManager_;
	childController.groupDescription        = groupDescription_;
	childController.groupName               = groupName_;
		
    [[self navigationController] pushViewController:childController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data_ count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)heightOfRowWithText:(NSString *)text {
    UIFont*  font = [UIFont fontWithName:@"Verdana" size:12.0];
	
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(224.0f, 600.0f) lineBreakMode:UILineBreakModeWordWrap];
	
    return size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger    row  = [indexPath row];
	NSDictionary* obj  = [data_ objectAtIndex:row];
	NSDictionary* body = [obj objectForKey:@"body"];
		
	CGFloat height = ([self heightOfRowWithText:[body objectForKey:@"text"]] + 70);
	
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* SimpleTableIdentifier = @"CellNewsIdentifier";
	NewsFeedCell*    cellNews      = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
		
    if (cellNews == nil) {
		NSArray *nib = [[self frameworkBundle] loadNibNamed:@"NewsFeedCell" owner:self options:nil];
		
		for (id oneObject in nib) {
			if ([oneObject isKindOfClass:[NewsFeedCell class]])
				cellNews = (NewsFeedCell*)oneObject;
			
			//cellNews.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
		
		cellNews.textView.font     = [style_ subFontFromStyle];
		cellNews.headingLabel.font = [style_ fontFromStyle];
    }
	
    NSUInteger    row  = [indexPath row];
	NSDictionary* obj  = [data_ objectAtIndex:row];
	NSDictionary* body = [obj objectForKey:@"body"];
			
    cellNews.textView.text     = [body objectForKey:@"text"] ;
	cellNews.photoView.frame   = CGRectMake(13, 14, 50, 53);
	cellNews.textView.frame    = CGRectMake(71, 44, 224, ([self heightOfRowWithText:[body objectForKey:@"text"]] + 10));
	cellNews.headingLabel.text = groupDescription_;
		
    return cellNews;
}

- (void)viewWillAppear:(BOOL)animated {
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
		
    [self reloadFeedData];
}

@end
