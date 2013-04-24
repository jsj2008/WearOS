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
#import "WSRedCapProtocolModel.h"
#import "WSWorldModel.h"
#import "WSBlackboardWorldModel.h"
#import "WSModelTriple.h"
#import "WSModelTripleCollection.h"


@interface WSClinicalEngine ()

@property (nonatomic) WSInteractionHIL* currentInteraction_;
@property (nonatomic) WSInterventionHIL* currentIntervention_;
@property (nonatomic) WSResponse* currentResponse_;
@property (nonatomic) id <WSProtocolModel> protocolDelegate_;
@property (nonatomic) id <WSWorldModel> worldModelDelegate_;
@property (nonatomic) WSDBPersistenceModel * persistenceDelegate_;
@property (nonatomic) id userDelegate_;
@property (nonatomic) id userSecondaryDelegate_;

@end


@implementation WSClinicalEngine;

@synthesize currentInteraction_;
@synthesize currentIntervention_;
@synthesize currentResponse_;
@synthesize protocolDelegate_;
@synthesize worldModelDelegate_;
@synthesize persistenceDelegate_;
@synthesize userDelegate_;
@synthesize userSecondaryDelegate_;


-(void)setProtocolFileName:(NSString*)fileName {
    if (self.protocolDelegate_ != nil) {
        [protocolDelegate_ setProtocolFileName:fileName];
    }
}

-(void)setUserDelegate:(id)userDelegate {
    userDelegate_ = userDelegate;
}

-(void)setUserSecondaryDelegate:(id)userDelegate {
    userSecondaryDelegate_ = userDelegate;
}

- (WSInteraction*) queryIfWithContent: (WSInteraction*) interaction {
	return nil;
}

- (void) informWithContent: (WSUtteranceRoot*) root {
	if (persistenceDelegate_ != nil) {
		[persistenceDelegate_ informWithContent: root];
	}
}

- (void) disinformAllResponsesWithContent: (WSUtteranceRoot*) interaction {
	if (persistenceDelegate_ != nil) {
		[persistenceDelegate_ disinformAllResponsesWithContent: interaction];
	}
}

-(void)disinformWithContent : (WSUtteranceRoot*)interaction andResponse : (WSResponse*)response {
	if (persistenceDelegate_ != nil) {
		[persistenceDelegate_ disinformWithContent: interaction andResponse:response];
	}
}

- (void) disinformAll {
	if (persistenceDelegate_ != nil) {
		[persistenceDelegate_ disinformAll];
	}

	if (worldModelDelegate_ != nil) {
		[worldModelDelegate_ initializeWorldModel];
	}
}

- (void) clearPersistentData {
	if (persistenceDelegate_ != nil) {
		[persistenceDelegate_ disinformAll];
	}

	if (protocolDelegate_ != nil) {
		[protocolDelegate_ clearHistory];
	}
}

- (void) clearPersistentDataWithContent: (WSInteraction*) interaction {
}

-(id)initWithProtocol :(NSString*)protocol andPersistenceModel : (id <WSPersistenceModel>)persistenceModel withOptions:(WSEngineOptions)options {
	return [self initWithWorldModel:[[WSBlackboardWorldModel alloc] init] andProtocol:[[WSUCSFProtocolModel alloc] initWithProtocol:protocol andHistoryManager:[WSGeneralProtocolHistoryManager new]] andPersistenceModel:persistenceModel withOptions:options];
}

-(id)initWithRedCapProtocol :(NSString*)protocol andPersistenceModel : (id <WSPersistenceModel>)persistenceModel withOptions:(WSEngineOptions)options {
	return [self initWithWorldModel:[[WSBlackboardWorldModel alloc] init] andProtocol:[[WSRedCapProtocolModel alloc] initWithProtocol:protocol andHistoryManager:[WSGeneralProtocolHistoryManager new]] andPersistenceModel:persistenceModel withOptions:options];
}

- (id)initWithWorldModel:(id <WSWorldModel>)worldModel andProtocol:(id <WSProtocolModel>)protocol andPersistenceModel:persistenceModel withOptions:(__unused WSEngineOptions)options {
    self = [super init];

    if (self) {
        self.protocolDelegate_ = protocol;
        worldModelDelegate_ = worldModel;
        persistenceDelegate_ = persistenceModel;

        [protocolDelegate_ initializeModel];

        //  Persist any goals described in the protocol file.
        NSMutableArray* goals = [[NSMutableArray alloc] initWithArray:[protocolDelegate_ queryGoals]];
        GoalDAO*        dao   = [GoalDAO new];
		ResdbResult*    result;

        if ((goals != nil) && ([goals count] > 0)) {
			
            for (WSGoal *domGoal in goals) {
				result = [dao retrieve:domGoal.goal.objectID];
				
				if (result.resdbCode != RESDB_SQL_ROWS) {
                	[dao insert:domGoal.goal];
				}
            }
        }

        //  Persist any tasks described in the protocol file.
        NSMutableArray* tasks   = [[NSMutableArray alloc] initWithArray:[protocolDelegate_ queryTasks]];
        TaskDAO*        taskDao = [TaskDAO new];

        if ((tasks != nil) && ([tasks count] > 0)) {
            for (WSTask *domTask in tasks) {
				result = [taskDao retrieve:domTask.task.objectID];
				
				if (result.resdbCode != RESDB_SQL_ROWS) {
					[taskDao insert:domTask.task];
				}
            }
        }

        //  Persist any rewards described in the protocol file.
        NSMutableArray*  rewards = [[NSMutableArray alloc] initWithArray:[protocolDelegate_ queryRewards]];
        RewardDAO*       rewardDao = [RewardDAO new];

        if ((rewards != nil) && ([rewards count] > 0)) {
            for (WSReward *domReward in rewards) {
				result = [rewardDao retrieve:domReward.reward.objectID];
				
				if (result.resdbCode != RESDB_SQL_ROWS) {
                	[rewardDao insert:domReward.reward];
				}
            }
        }
    }

    return self;
}

-(void)initializeWorldModel {
}

- (void) reset {
	if (currentInteraction_  != nil) {
		[protocolDelegate_ clearHistoryByContent:currentIntervention_];
		currentInteraction_ = nil;
	}

	if (currentIntervention_ != nil) {
		currentIntervention_ = nil;
	}

	currentResponse_ = nil;

	[protocolDelegate_ initializeModel];
}

- (int) currentInteractionIndex {
	return (worldModelDelegate_ != nil) ? [protocolDelegate_ currentInteractionIndex] : 0;
}

- (void) confirmUsingContent: (WSInteraction*) interaction {
	if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ confirmUsingContent: interaction];
    }
}

- (void) disconfirmUsingContent: (WSInteraction*) interaction {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ disconfirmUsingContent: interaction];
    };
}

- (void) confirmUsingTriple: (WSModelTriple*) triple {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ confirmUsingTriple: triple];
    };
}

- (void) confirmUsingTripleCollection: (WSModelTripleCollection*) tripleColl {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ confirmUsingTripleCollection: tripleColl];
    };
}

- (void) disconfirmUsingTripleCollection: (WSModelTripleCollection*) tripleColl {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ disconfirmUsingTripleCollection: tripleColl];
    };
}

- (void) disconfirmUsingTriple: (WSModelTriple*) triple {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ disconfirmUsingTriple: triple];
    };
}

- (void) analyseUsingTripleCollection: (WSModelTripleCollection*) rules {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ analyseUsingTripleCollection: rules];
    };
}

- (void) analyseUsingTriple: (WSModelTriple*) rule {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ analyseUsingTriple: rule];
    };
}

- (int) analyse {
	return (worldModelDelegate_ != nil) ? [worldModelDelegate_ analyse] : 0;
}

/*!
   This method will remove all facts from the world model for the specified interaction.  This is typically done in
   conjunction with removing responses from the persistence store
   @param interaction: the interaction in question.
   @returns void
 */
- (void) disconfirmWorldModelWithContent: (WSInteractionHIL*) interaction {
	if ((interaction.worldModel != nil) && ([interaction.worldModel count] > 0)) {
		WSModelTripleCollection* collection = [WSModelTripleCollection new];

		[collection addClauseCollection: interaction.worldModel];

		[self disconfirmUsingTripleCollection: collection];
	}

	WSResponse* response;

	[protocolDelegate_ responseIteratorBeginFromInteraction: interaction];

	while ((response = [protocolDelegate_ nextResponseFromInteraction: interaction])) {
		if ((response.worldModel != nil) && ([response.worldModel count] > 0)) {
			WSModelTripleCollection* collection = [WSModelTripleCollection new];

			[collection addClauseCollection: response.worldModel];

			[self disconfirmUsingTripleCollection: collection];
		}
	}
}

/*!
   This method will confirm all selected response facts to the world model This is typically done in
   when applying an interaction.
   @param interaction: the interaction in question.
   @returns void
 */
- (void) confirmResponseWorldModelWithContent: (WSInteractionHIL*) interaction {
	// First disconfirm all facts.  Some responses may overlap (share facts) and we don't want to cause some sort of race condition.
	for (WSResponse* response in[interaction responses]) {
		//if ([WSStringUtils isEmpty:[response responseValue]] && (response.responseData == nil) && ([response systemID] != nil)) {
		WSModelTripleCollection* collection = [WSModelTripleCollection new];

		[collection addClauseCollection: response.worldModel withValue: @"?"];

		[self disconfirmUsingTripleCollection: collection];
		//}
	}

	// Now it is safe to confirm the facts for chosen responses.
	for (WSResponse* response in[interaction responses]) {
		if (([WSStringUtils isNotEmpty:[response responseValue]] || (response.responseData != nil)) && ([response systemID] != nil)) {
			WSModelTripleCollection* collection = [WSModelTripleCollection new];

			[collection addClauseCollection: response.worldModel withValue:[response responseValue]];

			[self confirmUsingTripleCollection: collection];
		}
	}
}

- (WSInteraction*) historyWithContent: (WSIntervention*) intervention {
	return [self askPreviousWithContent: intervention];
}

- (int) executeConditionWithCollection: (WSModelTripleCollection*) collection {
	[self analyseUsingTripleCollection: collection];

	int ruleCnt = [self analyse];

	return ruleCnt;
}

- (int) evaluateConditionWithSet: (NSArray*) conditionSet {
	WSModelTripleCollection* ruleCollection = [WSModelTripleCollection new];

	[ruleCollection addClauseCollection: conditionSet];

    return [self executeConditionWithCollection:ruleCollection ];
}

- (NSString*)normalizeExpression:(NSString*)expressionText {
    NSError*              error;
    NSRegularExpression*  regex = [NSRegularExpression regularExpressionWithPattern:@"\\$[a-zA-Z_0-9]*" options:(NSRegularExpressionOptions) 0 error:&error];
    NSArray*              matches;
    NSMutableDictionary*  variableValues = [[NSMutableDictionary alloc] initWithCapacity:10];

    matches = [regex matchesInString:expressionText options:(NSMatchingOptions) 0 range:NSMakeRange(0, [expressionText length])];

    if ((matches != nil) && ([matches count] > 0)) {
        for (NSTextCheckingResult* match in matches) {
            NSRange    matchRange = [match range];
            NSString*  variable   = [expressionText substringWithRange:matchRange];
            NSString*  var;

            var = [variable substringWithRange:NSMakeRange(1, ([variable length] - 1))];

            ActivityDAO*  dao = [ActivityDAO new];
            ResdbResult*  result;

            result = [dao retrieveByUserId:var andRelatedId:[OpenPATHContext sharedOpenPATHContext].activePatient.patientNum];

            if (RESDB_SQL_ROWS == result.resdbCode) {
                Activity* activity = [result.resdbCollection objectAtIndex:0];

                if ((activity != nil) && [WSStringUtils isNotEmpty:activity.value ]) {
                    [variableValues setObject:activity.value forKey:var];
                } else {
                    [variableValues setObject:@"false" forKey:var];
                }
            }  else {
                [variableValues setObject:@"false" forKey:var];
            }
        }
    }
}

- (bool) evaluateExpressionWithSet: (NSArray*) expressionSet {
    if ((expressionSet ==  nil) || [expressionSet count] == 0) {
        return true;
    }

    NSError*  error = nil;
    NSString* expressionText = [expressionSet objectAtIndex:0];

    if ([WSStringUtils isEmpty:expressionText]) {
        return true;
    }

    expressionText = [self normalizeExpression:expressionText];

    [DDParser setDefaultPowerAssociativity:DDOperatorAssociativityRight];

    DDMathEvaluator*evaluator = [[DDMathEvaluator alloc] init];

    [evaluator setFunctionResolver:^DDMathFunction (NSString *name) {
        return [^DDExpression* (NSArray *args, NSDictionary *substitutions, DDMathEvaluator *eval, NSError **error) {
            return [DDExpression numberExpressionWithNumber:[NSNumber numberWithInt:42]];
        } copy];
    }];

    DDMathStringTokenizer* tokenizer = [[DDMathStringTokenizer alloc] initWithString:expressionText error:&error];
    DDParser*              parser = [DDParser parserWithTokenizer:tokenizer error:&error];

    DDExpression*  expression = [parser parsedExpressionWithError:&error];
    DDExpression*  rewritten  = [evaluator expressionByRewritingExpression:expression];
    NSNumber*      value = [rewritten evaluateWithSubstitutions:nil evaluator:evaluator error:&error];

    if (value != nil) {
        return [value boolValue];
    } else {
        return false;
    }
}

- (bool) isActiveDomain: (WSUtteranceRoot*) domain {
	//  Apply any active conditions
    if ((domain.activeCondition == nil) || ([domain.activeCondition count] == 0)) {
        return true;
    }

    if ((domain.activeConditionLangType == LanguageTypeUnknown) || (domain.activeConditionLangType == LanguageTypeClips)) {
		return ([self evaluateConditionWithSet: domain.activeCondition] >= [domain.activeCondition count]);
    } else if (domain.activeConditionLangType == LanguageTypeExpression) {
        return [self evaluateExpressionWithSet: domain.activeCondition];
    }

    return true;
}

- (bool) isActiveGoal:(WSGoal*)goal {
    //  Must convert the goal activation string into a collection of triples
    WSModelTripleCollection* factCollection = [WSModelTripleCollection new];

    if ([WSStringUtils isEmpty:[goal getActivation]]) {
        return true;
    }

    [factCollection addClauseCollectionWithString:[goal getActivation]];

    return [self executeConditionWithCollection:factCollection]  >= [factCollection collectionCount] ? true : false;
}

- (void)constructGoalsForInteraction:(WSInteractionHIL*)interaction {
    //  Make sure there are goals defined for the protocol
    GoalDAO*      dao = [GoalDAO new];
    ResdbResult*  result;

    result = [dao retrieveByOntology:[interaction.ontology fragment]];

    if (result.resdbCode == RESDB_SQL_NO_ROWS) {
        return;
    }

    for (Goal* goal in result.resdbCollection) {
		WSResponse* response = [WSResponse new];

		NSString* goalId             = [[NSString alloc] initWithFormat:@"http://www.carethings.com/goal#%@", goal.name];
        NSString* behaviorUrl        = @"http://www.carethings.com/userBehavior#goalDetails";
        NSString* activeBehaviorUrl  = @"http://www.carethings.com/className#SetActiveGoal";

        response.systemID     = [[NSURL alloc] initWithString:goal.objectID];
		response.ontology     = [[NSURL alloc] initWithString:goal.ontology];
		response.responseType = ResponseTypeGoal;
		response.label        = goal.name;
		response.goalName     = [[NSURL alloc] initWithString:goalId];
        [response addPostBehavior:activeBehaviorUrl];
        [response addPostBehavior:behaviorUrl];

		[interaction addResponse:response];
    }
}

- (bool) isActiveTask:(WSTask*)task {
    //  Must convert the task activation string into a collection of triples
    WSModelTripleCollection* factCollection = [WSModelTripleCollection new];

    if ([WSStringUtils isEmpty:[task getActivation]]) {
        return true;
    }

    [factCollection addClauseCollectionWithString:[task getActivation]];

    return [self executeConditionWithCollection:factCollection]  >= [factCollection collectionCount] ? true : false;
}

- (void)constructTasksForInteraction:(WSInteractionHIL*)interaction {
    //  Make sure there are tasks defined for the protocol
    TaskDAO*      dao = [TaskDAO new];
    ResdbResult*  result;

    result = [dao retrieveAll];

    if (result.resdbCode == RESDB_SQL_NO_ROWS) {
        return;
    }

    for (Task* task in result.resdbCollection) {
        WSResponse* response     = [WSResponse new];
        NSString*   behaviorUrl  = @"http://www.carethings.com/className#SetActiveTask";

        response.systemID     = [[NSURL alloc] initWithString:task.objectID];
        response.responseType = ResponseTypeTask;
        response.label        = task.name;
        response.ontology     = [[NSURL alloc] initWithString:task.ontology];
        [response addPostBehavior:behaviorUrl];
        [response addPostBehaviorWithURL:task.actionPlan];
		
		[interaction addResponse:response];
    }
}

- (bool) isActiveReward:(WSReward*)reward {
    //  Must convert the goal activation string into a collection of triples
    WSModelTripleCollection* factCollection = [WSModelTripleCollection new];

    if ([WSStringUtils isEmpty:[reward getActivation]]) {
        return true;
    }

    [factCollection addClauseCollectionWithString:[reward getActivation]];

    return [self executeConditionWithCollection:factCollection]  >= [factCollection collectionCount] ? true : false;
}

- (void)constructRewardsForInteraction:(WSInteractionHIL*)interaction {
    //  Make sure there are rewards defined for the protocol
    RewardDAO*    dao = [RewardDAO new];
    ResdbResult*  result;

    result = [dao retrieveAll];

    if (result.resdbCode == RESDB_SQL_NO_ROWS) {
        return;
    }

    for (Reward* reward in result.resdbCollection) {
        WSResponse* response = [WSResponse new];

        response.systemID         = [[NSURL alloc] initWithString:reward.objectID];
        response.responseType     = ResponseTypeReward;
        response.label            = reward.name;
        response.ontology         = [[NSURL alloc] initWithString:reward.ontology];
        [response addPostBehaviorWithURL:reward.actionPlan];

        [interaction addResponse:response];
    }
}

- (void)constructSetMembersForInteraction:(__unused WSInteractionHIL*)interaction {
    /*
    ActivityDAO*  dao = [ActivityDAO new];
    ResdbResult*  result;

    result = [dao retrieveByInstanceId:(NSString*)interaction.instanceID andType:@"COLLECTION"];

    if (result.resdbCode == RESDB_SQL_NO_ROWS) {
        return;
    }

    WSActivity*  wsactivity = [WSActivity new];

    for (Activity* activity in result.resdbCollection) {
        [wsactivity initWithActivity:activity];

        WSResponse* response = [WSResponse new];

        NSString* sysId    = [NSString alloc] initWithFormat:@"http://www.carethings.com/sysId#%@", reward.objectID];
        NSString* rewardId = [NSString alloc] initWithFormat:@"http://www.carethings.com/goal#%@", reward.name];

        response.systemID     = [NSURL alloc] initWithString:sysId];
        response.responseType = ResponseTypeReward;
        response.label        = reward.name;
        //response.rewardName     = [NSURL alloc] initWithString:rewardId];
        [response addPostBehaviorWithURL:reward.actionPlan];

        [interaction addResponse:response];
    }
    */
}

- (bool) skipDomain: (WSUtteranceRoot*) domain {
    if ((domain.skipCondition == nil) || ([domain.skipCondition count] == 0)) {
        return false;
    }

    if ((domain.activeConditionLangType == LanguageTypeUnknown) || (domain.activeConditionLangType == LanguageTypeClips)) {
		return ([self evaluateConditionWithSet: domain.skipCondition] >= [domain.skipCondition count]);
    } else if (domain.activeConditionLangType == LanguageTypeExpression) {
        return [self evaluateExpressionWithSet: domain.skipCondition];
    }

    return false;
}

- (void) applyDomainWorldModel: (WSUtteranceRoot*) domain {
	if ((domain.worldModel != nil) && ([domain.worldModel count] > 0)) {
		WSModelTripleCollection* collection = [WSModelTripleCollection new];

		[collection addClauseCollection: domain.worldModel];

		[self confirmUsingTripleCollection: collection];
	}
}

- (void) applyScheduleEvent: (WSUtteranceRoot*) domain {
	if (domain.scheduleEvent != nil) {
		[domain.scheduleEvent causeEvent];
	}
}

- (bool)hasBehavior:(NSURL*)app {
	if (app == nil)
		return false;
	
	NSString* appName = [app fragment];
	
	if ([WSStringUtils isEmpty:appName])
		return false;
	
	WSUserApp* userApp = [NSClassFromString(appName) new];
	
	if (userApp == nil) {
		return false;
    }

	return true;
}

- (void)applyBehavior:(NSMutableArray*)behaviorCollection {
	if ((behaviorCollection == nil) || ([behaviorCollection count] == 0)) {
		return;
    }

    //  A behavior may malign the behavior collection passed in so make a copy
    NSArray* localBehaviorCollection = [[NSArray alloc] initWithArray:behaviorCollection];

    for (NSURL* behaviorURL in localBehaviorCollection) {
        NSString* behaviorType = [behaviorURL lastPathComponent];
	    NSString* behavior      = [behaviorURL fragment];

        if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"className"] == NSOrderedSame) {
            WSUserApp* userApp = [NSClassFromString(behavior) new];

      		if (userApp != nil) {
      		    [userApp runAppWithIntervention: currentIntervention_ andInteraction: currentInteraction_ andResponse: currentResponse_];
      	    }
        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"fact"] == NSOrderedSame) {
            WSModelTriple* triple = [[WSModelTriple alloc] initWithClause:behavior];
            [self confirmUsingTriple:triple];
        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"protocol"] == NSOrderedSame) {
            // We are being asked to switch protocols.
            [self setProtocolFileName:behavior];
            [self reset];
        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"formula"] == NSOrderedSame) {


            [currentResponse_.responseValue setString: @" "];
        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"userBehavior"] == NSOrderedSame) {
            NSString* iosBehavior = [[NSString alloc] initWithFormat:@"%@:", behavior];

            if ((userDelegate_ != nil) && [userDelegate_ respondsToSelector:NSSelectorFromString(iosBehavior)]) {
                [userDelegate_ performSelector:NSSelectorFromString(iosBehavior) withObject:[NSArray arrayWithObjects:currentIntervention_, currentInteraction_, currentResponse_, nil]];
            } else if ((userDelegate_ != nil) && [userDelegate_ respondsToSelector:NSSelectorFromString(behavior)]) {
                [userDelegate_ performSelector:NSSelectorFromString(behavior) withObject:nil];
            } else if ((userSecondaryDelegate_ != nil) && [userSecondaryDelegate_ respondsToSelector:NSSelectorFromString(iosBehavior)]) {
                [userSecondaryDelegate_ performSelector:NSSelectorFromString(iosBehavior) withObject:[NSArray arrayWithObjects:currentIntervention_, currentInteraction_, currentResponse_, nil]];
            } else if ((userSecondaryDelegate_ != nil) && [userSecondaryDelegate_ respondsToSelector:NSSelectorFromString(behavior)]) {
                [userSecondaryDelegate_ performSelector:NSSelectorFromString(behavior) withObject:nil];
            }
        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"userComponent"] == NSOrderedSame) {

        } else if ([WSStringUtils caseInsensitiveCompare:behaviorType toString:@"userForm"] == NSOrderedSame) {

        }
    }
}

- (WSInteraction*) askPreviousWithContent: (WSIntervention*) intervention {
	WSInteractionHIL* oldInteraction = currentInteraction_;

	currentInteraction_ = [protocolDelegate_ previousInteractionFromIntervention: (WSInterventionHIL*)intervention];

	if (currentInteraction_ != nil) {
		// Remove all persistent data and world model facts concerning the old interaction.  This is part of the described behavior of
		// going back from an existing interaction.
		[persistenceDelegate_ disinformAllResponsesWithContent: oldInteraction];
		[self disconfirmWorldModelWithContent: oldInteraction];

		WSResponse* response;

		[protocolDelegate_ responseIteratorBeginFromInteraction: currentInteraction_];
		[currentInteraction_.filteredResponses removeAllObjects];

		while ((response = [protocolDelegate_ nextResponseFromInteraction: currentInteraction_])) {
			if (![response isActiveInStudy:[OpenPATHContext sharedOpenPATHContext].activeStudy]) {
				continue;
			}

			if (![self isActiveDomain: response]) {
				continue;
			}

			if ([self skipDomain: response]) {
				continue;
			}

			//  This will populate the response with any values that have been persisted
			if (persistenceDelegate_ != nil) {
				[persistenceDelegate_ tellWithContent: currentInteraction_ andResponse: response];
			}

			// Apply a pre-behavior which is typically used to populate the response.
			currentResponse_ = response;
			[self applyBehavior:response.preBehavior];
			currentResponse_ = nil;

			[currentInteraction_ addFilteredResponse:response];
		}
	}

	return currentInteraction_;
}

- (bool) isValidResponseValue:(__unused WSResponse*)response {
    if ((currentResponse_ != nil) && ([currentResponse_ isFreeResponse] || [currentResponse_ isFreeFixedResponse])) {

    }

    return true;
}

- (WSInteraction*) askNextWithContent: (WSIntervention*) intervention {
	//stopWatch_ = [WSStopWatch start];
    if ((currentIntervention_ == nil) || ((currentResponse_ != nil) && (currentResponse_.skipToIntervention != nil)) || ((intervention != nil) && (currentIntervention_ != intervention))) {
        if ((currentResponse_ != nil) && (currentResponse_.skipToIntervention != nil)) {
			[self setCurrentInterventionByID:currentResponse_.skipToIntervention];
		} else if (currentIntervention_ == nil) {
            currentIntervention_ = (WSInterventionHIL*)[protocolDelegate_ nextIntervention];
        } else if (intervention != nil) {
            [self setCurrentInterventionByID:intervention.systemID];
        } else {
            currentIntervention_ = (WSInterventionHIL*)[protocolDelegate_ nextIntervention];
        }

        if (currentIntervention_ == nil) {
            return nil;
        }

        if (![currentIntervention_ isActiveInStudy:[OpenPATHContext sharedOpenPATHContext].activeStudy]) {
            currentIntervention_ = nil;
            return nil;
        }

      	if (![self isActiveDomain: currentIntervention_]) {
            currentIntervention_ = nil;
      		return nil;
      	}

      	if ([self skipDomain: currentIntervention_]) {
            currentIntervention_ = nil;
      		return nil;
      	}

        [self applyDomainWorldModel: currentIntervention_];

      	if ([currentIntervention_ numberOfInteractions] == 0) {
            currentIntervention_ = nil;
      		return nil;
        }
    }

    // Validate the responses based on any constraints
    if (![self isValidResponseValue:currentResponse_]) {
        return nil;
    }

	// FixedAsk responses have already executed their behaviors
	if ((currentResponse_ != nil) && (![currentResponse_ isFixedAskResponse])) {
		[self applyBehavior:[currentResponse_ behavior]];
		[self applyBehavior:[currentResponse_ postBehavior]];
	}
		
	//NSLog(@"Elapsed time Marker 1: %f", [stopWatch_ elapsedTime]);

	//  Apply the world models of all selected responses
	[self confirmResponseWorldModelWithContent: currentInteraction_];
	
	//NSLog(@"Elapsed time before processInteractions: %f", [stopWatch_ elapsedTime]);

	//  Persist the responses from the current interactions.  We don't persist an interaction collection (we only persist the members)
	if ([currentInteraction_ isNotCollection]) {
		[self informWithContent: currentInteraction_];
	}

    //  Persist any collection members
    if ([currentInteraction_ isCollection]) {
        for (WSInteractionHIL* member in [currentInteraction_ members]) {
            [self informWithContent: member];
        }
    }

  	//NSLog(@"Elapsed time before processInteractions in nextIntervention loop: %f", [stopWatch_ elapsedTime]);


	if ([self processInteractions]) {
	    return nil;
	}

    //NSLog(@"Elapsed time after processInteractions in nextIntervention: %f", [stopWatch_ elapsedTime]);

	return currentInteraction_;
}

- (WSInteraction*) askWithContent: (WSIntervention*) intervention {
	//stopWatch_ = [WSStopWatch start];
	
	//print_free_memory();
	
	if (currentResponse_ != nil) {
		[self applyBehavior:[currentResponse_ behavior]];
		[self applyBehavior:[currentResponse_ postBehavior]];
	}
	
	//NSLog(@"Elapsed time Marker 1: %f", [stopWatch_ elapsedTime]);
	
	//  Apply the world models of all selected responses
	[self confirmResponseWorldModelWithContent: currentInteraction_];
	
	//NSLog(@"Elapsed time before processInteractions: %f", [stopWatch_ elapsedTime]);
	
	//  Persist the responses from the current interaction.
	[self informWithContent: currentInteraction_];
	
	return currentInteraction_;
}

- (void) setCurrentInteractionByID: (NSURL*) interactionResource {
	if (interactionResource == nil)
		return;

	[self reset];

	do {
		[self askNextWithContent: currentIntervention_];

		if ((currentInteraction_ != nil) &&[currentInteraction_.systemID isEqual: interactionResource]) {
			break;
		}
	}
	while (currentInteraction_ != nil);
}

- (int)informCount:(WSUtteranceRoot *)root {
    return 0;
}

- (int)informComplete {
    return 0;
}

- (bool)processInteraction:(WSInteractionHIL*)interaction  {
    [self applyDomainWorldModel: interaction];
    [self applyScheduleEvent: interaction];

    //NSLog(@"Elapsed time after apply model and check schedule event: %f", [stopWatch_ elapsedTime]);

    // Launch the appropriate behaviors.  These behaviors may effect the contents of the intervention and/or responses
    [self applyBehavior:interaction.preBehavior];
    [self applyBehavior:interaction.behavior];

    // If this is an imperative (autonomous) interaction then our work is done.  Look for the next interaction.
    if ((interaction != nil) && [interaction isImperative]) {
        //  We must honor a skip for an imperative.
        //	skipTo = (currentInteraction_.systemSkipTo != nil) ? [currentInteraction_.systemSkipTo copy] : [currentInteraction_.skipTo copy];
        return false;
    }

    currentResponse_ = nil;

    //  Extract goals from the PHR which are activated by the interaction.
    if ([interaction isGoal])  {
        [self constructGoalsForInteraction:interaction];
    }

    //  Extract tasks from the PHR which are activated by the interaction.
    if ([interaction isTask])  {
        [self constructTasksForInteraction:interaction];
    }

    //  Extract rewards from the PHR which are activated by the interaction.
    if ([interaction isReward])  {
        [self constructRewardsForInteraction:interaction];
    }

    //  Extract set members from the activities if this is a collection
    if ([interaction isCollection]) {
        [self constructSetMembersForInteraction:interaction];
    }

    interaction.text = [WSStringUtils decodeFormattedString:interaction.text];

    //  Each response, if any, may have a condition.  For example, a response is only shown if the participant is female.  Construct
    //  the filtered responses.
    WSResponse* response;

    //NSLog(@"Elapsed time after processing behaviors (pre and user app): %f", [stopWatch_ elapsedTime]);

    [protocolDelegate_ responseIteratorBeginFromInteraction: interaction];
    [interaction.filteredResponses removeAllObjects];

    //NSLog(@"Elapsed time before process responses loop: %f", [stopWatch_ elapsedTime]);

    while ((response = [protocolDelegate_ nextResponseFromInteraction: interaction])) {
        //NSLog(@"Elapsed time in process responses loop: %f", [stopWatch_ elapsedTime]);

        if (![response isActiveInStudy:[OpenPATHContext sharedOpenPATHContext].activeStudy]) {
            continue;
        }

        if (![self isActiveDomain: response]) {
            continue;
        }

        if ([self skipDomain: response]) {
            continue;
        }

        //  This will populate the response with any values that have been persisted.  We don't populate the responses
        //  of a collection interaction.
        if ((persistenceDelegate_ != nil) && ([interaction isNotCollection])) {
            [persistenceDelegate_ tellWithContent: interaction andResponse: response];
        }

        // Apply a pre-behavior which is typically used to populate the response.
        currentResponse_ = response;
        [self applyBehavior:response.preBehavior];

        currentResponse_ = nil;

        response.label = [WSStringUtils decodeFormattedString:response.label];

        // Responses as part of a intervention that is a collection are not processed (e.g. persistence) so they are not filtered
        if ([interaction isNotCollection]) {
            [interaction addFilteredResponse: response];
        }
    }

    return true;
}

- (bool) processInteractions {
	NSURL* skipTo = nil;
	
	//NSLog(@"Elapsed time start of processInteractions: %f", [stopWatch_ elapsedTime]);

	if (currentResponse_ != nil) {
		skipTo = (currentResponse_.systemSkipTo != nil) ? [currentResponse_.systemSkipTo copy] : [currentResponse_.skipTo copy];
	} else if (currentInteraction_ != nil) {
		skipTo = (currentInteraction_.systemSkipTo != nil) ? [currentInteraction_.systemSkipTo copy] : [currentInteraction_.skipTo copy];
	}

	// Interactions with a user application spec are not visible to the user and should not be part of the history.  Only interrogative
	// interactions are of interest.
	if (([currentInteraction_ behaviorUserApp] == nil) && ([currentInteraction_ isInterrogative] || [currentInteraction_ isDeclarative])) {
		[protocolDelegate_ tellHistory: currentIntervention_];
	}

	if (currentResponse_ != nil) {
		currentInteraction_ = nil;
	}
	
	//NSLog(@"Elapsed time before nextInteractionFromIntervention loop: %f", [stopWatch_ elapsedTime]);
	
	//if (skipTo != nil) {
		// Start the search from the beginning
	//	[protocolDelegate_ interactionIteratorBeginFromIntervention:currentIntervention_];		
	//}
	
	while ((currentInteraction_ = [protocolDelegate_ nextInteractionFromIntervention: currentIntervention_]) != nil) {
		//NSLog(@"Elapsed time in nextInteractionFromIntervention loop: %f", [stopWatch_ elapsedTime]);
		if (skipTo != nil) {
			if ([ResourceIdentityGenerator isSystemIdentifier: skipTo]) {
				if ((currentInteraction_.systemID == nil) || (![currentInteraction_.systemID isEqual: skipTo])) {
					currentInteraction_ = nil;
					continue;
				}
			} else if ((currentInteraction_.userID == nil) || (![currentInteraction_.userID isEqual: skipTo])) {
				currentInteraction_ = nil;
				continue;
			}
		}

		if (![currentInteraction_ isActiveInStudy:[OpenPATHContext sharedOpenPATHContext].activeStudy]) {
			currentInteraction_ = nil;
			
			// If we skipped to this interaction but it is not active, then turn off the skip
			skipTo = nil;
			
			continue;
		}

		//  Apply any active conditions
		if (![self isActiveDomain: currentInteraction_]) {
			currentInteraction_ = nil;

			// If we skipped to this interaction but it is not active, then turn off the skip.
			skipTo = nil;

			continue;
		}

		//  Apply any skip conditions
		if ([self skipDomain: currentInteraction_]) {
			currentInteraction_ = nil;

			// If we skipped to this interaction but it is not active, then turn off the skip.
			skipTo = nil;

			continue;
		}
		
		//NSLog(@"Elapsed time before apply model and check schedule event: %f", [stopWatch_ elapsedTime]);

        if (![self processInteraction:currentInteraction_]) {
            skipTo = nil;
            continue;
        }

        if ([currentInteraction_ isCollection]) {
            for (WSInteractionHIL* member in [currentInteraction_ members]) {
                [self processInteraction:member];
            }
        }

		//  We now have a clean interaction with all valid responses that has passed all constraints, active conditions, etc.
        return true;
	}

	currentInteraction_ = nil;

	return false;
}

- (void) interactionCount {
}

- (NSString*) currentInteractionText {
	return nil;
}

- (NSString*) stringToHex: (__unused NSString*) str {
	return nil;
}

- (WSIntervention*) getCurrentIntervention {
	return currentIntervention_;
}

- (WSInteractionHIL*) getCurrentInteraction {
	return currentInteraction_;
}

- (WSResponse*) getCurrentResponse {
	return currentResponse_;
}

- (void)setCurrentIntervention:(WSInterventionHIL*)intervention  {
	currentIntervention_ = intervention;
}

- (void)setCurrentInteraction:(WSInteractionHIL*)interaction {
	currentInteraction_ = interaction;
}

- (void)setCurrentResponse:(WSResponse*)response {
	currentResponse_ = response;
}

- (void) resetToInteraction: (NSString*) interactionSystemID {
}

- (void) recruitWithContent: (WSUtteranceRoot*) interaction {
}

- (void) confirmWithContent: (WSInteraction*) interaction {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ confirmUsingContent: interaction];
    };
}

- (void) disconfirmWithContent: (WSInteraction*) interaction {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ disconfirmUsingContent: interaction];
    }
}

- (void) confirmWithTriple: (WSModelTriple*) triple {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ confirmUsingTriple: triple];
    }
}

- (void) disconfirmWithTriple: (WSModelTriple*) triple {
    if (worldModelDelegate_ != nil) {
        [worldModelDelegate_ disconfirmUsingTriple: triple];
    };
}

- (void) setCurrentInterventionByID: (NSURL*) interventionID {
    while ((currentIntervention_ = (WSInterventionHIL*)[protocolDelegate_ nextIntervention]) != nil) {
        if ([[currentIntervention_.systemID fragment] isEqualToString:[interventionID fragment]])  {
            break;
        }
    }
}

- (NSArray*) queryInterventions {
    return [protocolDelegate_ queryInterventions];
}

- (NSArray*) queryInteractions {
	return nil;
}

- (NSData*) tellAllWithOptions: (WSPersistenceOptions) options {
	return [persistenceDelegate_ tellAllWithOptions: options];
}

- (NSData*) tellWithContent: (WSUtteranceRoot*) root andOptions: (WSPersistenceOptions) options {
	return [persistenceDelegate_ tellWithContent: root andOptions: options];
}

- (NSData*) tellWithContent: (WSUtteranceRoot*) root andResponse: (WSResponse*) response {
	return [persistenceDelegate_ tellWithContent:root andResponse: response];
}

@end