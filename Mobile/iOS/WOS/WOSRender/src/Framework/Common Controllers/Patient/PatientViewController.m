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

#import <PatientViewController.h>
#import <WOSCore/OpenPATHCore.h>
#import "PatientDetailViewController.h"
#import "WSRenderingEngine.h"
#import "carePathwayViewController.h"
#import "WSStyle.h"
#import "SimpleCustomCell2.h"
#import "ImageUtilities.h"

@implementation PatientViewController

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

@synthesize patientData;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize patientProtocol;


- (int)childrenCount:(int)row {
    int count = 0;
    ResdbResult *result = nil;
    PatientDAO *dao = [PatientDAO new];

    result = [dao retrieveCount];

    if (result.resdbCode == RESDB_SQL_ROWS)
        count = [(NSString *) result.resdbObject integerValue];

    return count;
}

- (void)callPatientDetail:(Patient *)patient {
    PatientDetailViewController *childController = [[PatientDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];

    childController.title = NSLocalizedString(@"Participant", nil);
    childController.patient = patient;
    childController.navController = [self navController];

    [[self navigationController] pushViewController:childController animated:YES];
}

- (IBAction)addPatient:(id)sender {
    [self callPatientDetail:nil];
}

- (void)reloadFromDB {
    PatientDAO *dao = [PatientDAO new];
    ResdbResult *result = nil;

    [self.patientData removeAllObjects];

    result = [dao retrieveByPrimaryClinic:[OpenPATHContext sharedOpenPATHContext].activeStudy.studySite];

    if (result.resdbCode == RESDB_SQL_ROWS) {
		for (Patient* patient in result.resdbCollection) {
			if (![patient.objectID isEqualToString:WS_ROOT_OBJECT_IDENTIFIER])
				[self.patientData addObject:patient];
		}
	}
}

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

- (UIToolbar*)constructToolbar {
	UIToolbar*  toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 45, 320, 30)];
	
	toolbar.barStyle = UIBarStyleBlack;
	
	NSString*         siteName = [StringUtils displayString:[self locateSiteName]];
	NSString*         barTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"Site: %@", nil), siteName];
	UIBarButtonItem*  item = [[UIBarButtonItem alloc] initWithTitle:barTitle
															 style:UIBarButtonItemStylePlain
															target:nil
															action:nil];
	
	[item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[style_ fontFromStyle], UITextAttributeFont,nil] forState:UIControlStateNormal];
	
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil
																			action:nil];
	
	NSArray *items = [[NSArray alloc] initWithObjects:spacer, item, spacer, nil];
	
	[toolbar setItems:items];
	toolbar.userInteractionEnabled = NO;
	
	return toolbar;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.patientData = [NSMutableArray new];

    [super viewDidLoad];
    [self reloadFromDB];
		
	self.title = NSLocalizedString(@"Participants", nil);
	
	style_  = [[WSRenderingEngine sharedRenderingEngine] styleOfType:@"http://www.carethings.com/styletypes/interaction"];
	
	self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 75)];
	
	[self.tableView.tableHeaderView addSubview:[self constructToolbar]];
	
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    self.searchBar.barStyle = UIBarStyleBlackTranslucent;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
	
	searchDisplayController                         = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate                = self;
    searchDisplayController.searchResultsDataSource = self;
	
    [self.tableView.tableHeaderView addSubview:self.searchBar];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
	[self navigationController].navigationBar.barStyle = UIBarStyleBlack;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor clearColor];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[ImageUtilities resizedImage:[UIImage imageWithData:[Base64 decode:style_.background]] rectSize:CGRectMake(0, 0, 320, 480)]];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addPatient:)];

    self.navigationItem.rightBarButtonItem = addButton;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.patientData count];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"lastName like %@", @"Frank"] ; //]self.searchBar.text];
    
    searchPatientData = [patientData filteredArrayUsingPredicate:resultPredicate];
	
	int i = 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    carePathwayViewController *childController = [[carePathwayViewController alloc] init];
	
	/*
	 if (tableView == self.searchDisplayController.searchResultsTableView) {
	 [self performSegueWithIdentifier: @"showRecipeDetail" sender: self];
	 }
	 */
	
	childController.activeProtocol = patientProtocol;
	
	NSUInteger row     = [indexPath row];
    Patient*   patient = [patientData objectAtIndex:row];
	
	[OpenPATHContext sharedOpenPATHContext].activePatient = patient;
	
    [[self navigationController] pushViewController:childController animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	PatientDetailViewController*  childController = [[PatientDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
	NSUInteger row     = [indexPath row];
    Patient*   patient = [patientData objectAtIndex:row];
	
	[OpenPATHContext sharedOpenPATHContext].activePatient = patient;
	
	childController.patient = [OpenPATHContext sharedOpenPATHContext].activePatient;
	
	[[self navigationController] pushViewController:childController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";

    SimpleCustomCell2 *cell = (SimpleCustomCell2 *) [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];

    if (cell == nil) {
        NSArray *nib = [[self frameworkBundle] loadNibNamed:@"SimpleCustomCell2" owner:self options:nil];

        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SimpleCustomCell2 class]])
                cell = (SimpleCustomCell2 *) oneObject;

        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.nameLabel.font  = [UIFont fontWithName:@"Bryant-Bold" size:18.0];
    }
	
	/*
	 if (tableView == self.searchDisplayController.searchResultsTableView) {
	 cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
	 } else {
	 cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
	 }
	 */

    NSUInteger row = [indexPath row];
    Patient *patient = [patientData objectAtIndex:row];

    // Construct the patient name
    NSMutableString *fullName = [NSMutableString new];

    if ((patient.firstName != nil) && ([patient.firstName length] > 0)) {
        [fullName appendString:patient.firstName];
        [fullName appendString:@" "];
    }

    if ((patient.lastName != nil) && ([patient.lastName length] > 0))
        [fullName appendString:patient.lastName];

    cell.nameLabel.text = fullName;
    //cell.rightLabel.text = [DateFormatter localizedStringFromUSDateString:patient.creationTime];

    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
    [self reloadFromDB];
    [self.tableView reloadData];
}

@end
