//
//  InteractionTestCase.m
//  mHealthOpenFramework
//
//  Created by Larry Suarez on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InteractionTestCase.h"


@implementation InteractionTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
	id yourApplicationDelegate = [UIApplication sharedApplication] delegate];
	STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testMath {
	STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");

	//STAssertEqualsl();
}


#endif


@end