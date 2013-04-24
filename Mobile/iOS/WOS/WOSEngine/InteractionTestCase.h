//
//  InteractionTestCase.h
//  mHealthOpenFramework
//
//  Created by Larry Suarez on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 0

#import <SenTestingKit/SenTestingKit.h>
//#import "application_headers" as required


@interface InteractionTestCase : SenTestCase {
}

-(void)testMath;                // simple standalone test

@end