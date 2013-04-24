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
 * This code  is the  sole  property of CareThings, Inc. and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade secret, not to be disclosed 
 * without written authorization from CareThings.  Any  use, duplication, or  disclosure of this program  
 * by other than CareThings and its assigned licensees is strictly forbidden by law.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSProtocolModel.h"
#import "WSUCSFProtocolModel.h"
#import "WSWorldModel.h"
#import "WSBlackboardWorldModel.h"
#import "WSModelTriple.h"
#import "WSModelTripleCollection.h"
#import "WSRedCapProtocolModel.h"
#import "WSRedCapRenderingModel.h"



@implementation WSRedCapRenderingModel

- (id) initWithRendering: (NSString*) renderXML {
    self = [super init];

    if (self) {
        renderXml_ = renderXML;
    }

    return self;
}

- (void)saveGoal {
    GoalDAO*      dao = [GoalDAO new];
    ResdbResult*  result;

    if (activeGoal_ != nil) {
        result = [dao retrieveByName:activeGoal_.name];

        if (result.resdbCode == RESDB_SQL_ROWS) {
            activeGoal_.objectID = ((Goal*) [result.resdbCollection objectAtIndex:0]).objectID;

            [dao update:activeGoal_];
        } else {

        }
    }
}

- (void) parseRendering {
    NSError*         err;
    ResdbResult*     result;
    Activity *       activeActivity;
    RenderStyleDAO*  renderDao = [RenderStyleDAO new];
    FeaturesDAO*     featuresDao = [FeaturesDAO new];

    result = [renderDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        renderStyle_ = (RenderStyle*)result.resdbObject;
    } else{
        renderStyle_ = [RenderStyle new];
    }

    result = [featuresDao retrieve:WS_ROOT_OBJECT_IDENTIFIER];

    if (result.resdbCode == RESDB_SQL_ROWS) {
        features_ = (Features*)result.resdbObject;
    } else{
        features_ = [Features new];
    }

    doc_ = [[GDataXMLDocument alloc] initWithXMLString: renderXml_ options: 0 error: &err];

    if (doc_ == nil) {
        return;
    }

    NSArray*         	itemEnum             = [[doc_ rootElement] children];
    NSMutableString*    currentFormName      = [[NSMutableString alloc] initWithCapacity:100];

    for (GDataXMLElement* rootElement in itemEnum) {
        if ([[rootElement name] isEqualToString: @"item"])   {
            NSArray*     renderingEnum = [rootElement children];
            NSString*    fieldName;
            NSString*    fieldLabel;

            for (GDataXMLElement* interactionElement in renderingEnum) {
                if ([[interactionElement name] isEqualToString: @"form_name"]) {
                    features_.eula = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_label"]) {
                    features_.hasEula = true;
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    features_.splashScreen = [NSMutableData dataWithBytes:(void*)[[interactionElement stringValue] UTF8String]  length:[[interactionElement stringValue] length]];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    features_.hasAuthentication = true;
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    features_.hasReminders = true;
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.textColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.textFontSize = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.textFontFamily = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.questionColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.questionFontSize = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.questionFontFamily = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.headerColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.headerFontSize = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.headerFontFamily = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.choiceTextColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.choiceFontSize = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.choiceFontFamily = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.responseBorderColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.backgroundColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.separatorColor = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.nextButtonText = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.previousButtonText = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    renderStyle_.homeButtonText = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_name_1"]) {
                    activeGoal_ = [Goal new];
                    activeGoal_.name = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_description_1"]) {
                    activeGoal_.description = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_activation_1"]) {
                    //activeGoal_.activation = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_personal_value_1"]) {
                    activeGoal_.personalValue = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_expectation_1"]) {
                    activeGoal_.expectationOfSuccess = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_reward_1"]) {
                    activeGoal_.reward = [interactionElement stringValue];
                    [self saveGoal];
                } else if ([[interactionElement name] isEqualToString: @"app_goal_action_plan_1"]) {
                    activeGoal_.actionPlan = [[NSURL alloc] initWithString:[interactionElement stringValue]];
                    [self saveGoal];
                }
            }
        }
    }

    if ([WSStringUtils isEmpty:features_.objectID]) {
        features_.objectID = WS_ROOT_OBJECT_IDENTIFIER;
        [featuresDao insert:features_];
    } else {
        [featuresDao update:features_];
    }

    WSFeatures*  wsFeatures = [[WSFeatures alloc] initWithFeatures:features_];

    [OpenPATHContext sharedOpenPATHContext].features = wsFeatures;

    if ([WSStringUtils isEmpty:renderStyle_.objectID]) {
        renderStyle_.objectID = WS_ROOT_OBJECT_IDENTIFIER;
        [renderDao insert:renderStyle_];
    } else {
        [renderDao update:renderStyle_];
    }

    WSRenderStyle* wsRenderStyle = [[WSRenderStyle alloc] initWithRenderStyle:renderStyle_];
}

@end