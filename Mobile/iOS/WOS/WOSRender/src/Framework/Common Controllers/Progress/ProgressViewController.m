//
//  RewardViewController.m
//  REPs
//
//  Created by Larry Suarez on 9/28/12.
//
//
#import "ProgressViewController.h"


@interface ProgressViewController ()

@end

@implementation ProgressViewController

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
    self = [super initWithNibName:@"ProgressViewController" bundle:[self frameworkBundle]];
	
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

- (IBAction)nextLevel:(id)sender {
	if (parentController_ != nil)
		[parentController_ completed];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	currentPointsLabel_.text  = [[NSString alloc] initWithFormat:@"$ %@", [OpenPATHContext sharedOpenPATHContext].activePatient.rewardPoints];
	//levelCompletedLabel_.text = [WSStackContext sharedStackContext].activePatient.rewardBadge;
	
	[nextLevelBtn_ setTitle: @"" forState:UIControlStateNormal];
	
	//OralScreenerAppDelegate.tabBarController.tabBar.hidden = YES;
	
	nextLevelLabel_.text = self.note1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
