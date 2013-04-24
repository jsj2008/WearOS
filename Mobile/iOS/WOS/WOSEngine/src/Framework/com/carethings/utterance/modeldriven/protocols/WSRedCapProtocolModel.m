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
 *
 *  NOTES:
 *       Typically we have:
 *            Interaction systemID is set to the field name from REDCap.
 *            Response systemID is set to the field name from REDCap coupled with the response code (e.g. <field name>_<field code>.
 *            The corresponding user IDs are set to their systemID.
 */

#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"
#import "WSProtocolModel.h"
#import "WSUCSFProtocolModel.h"
#import "WSWorldModel.h"
#import "WSBlackboardWorldModel.h"
#import "WSModelTriple.h"
#import "WSModelTripleCollection.h"
#import "WSRedCapRenderingModel.h"
#import "WSRedCapProtocolModel.h"


@implementation WSRedCapProtocolModel

- (id) initWithProtocol: (NSString*) careXML andHistoryManager: (id <WSProtocolHistoryManager>) histManager {
	self = [super init];

	if (self) {
		protocolXml_ = careXML;

        if (histManager == nil) {
      		historyManager_ = [WSGeneralProtocolHistoryManager new];
      	} else {
      		historyManager_ = histManager;
      	}
	}

	return self;
}

-(void)setProtocolFileName:(NSString*)fileName {
    protocolFileName_ = [[NSString alloc] initWithString:fileName];
}

- (void) setupHistoryByContent: (WSInterventionHIL*) intervention {
    [self setupHistoryByContent:intervention];
}

- (NSString*) readRedCAPProtocolXML {
	NSError*        err = nil;
	NSString*       xmlPath = [[NSBundle mainBundle] pathForResource: protocolFileName_ ofType: @"xml"];

	if ([WSStringUtils isEmpty:xmlPath]) {
		return nil;
	}

	NSURL* xmlURL = [[NSURL alloc] initFileURLWithPath: xmlPath];

	NSString* pathway = [[NSString alloc] initWithContentsOfURL: xmlURL encoding: NSASCIIStringEncoding error: &err];

	return pathway;
}

- (GDataXMLElement*)generateFinalInteraction {
    GDataXMLElement*    finalInteraction  = [GDataXMLNode elementWithName:@"Interaction"];

    GDataXMLElement* idElement = [GDataXMLNode elementWithName:@"ID"];
    idElement.stringValue = @"http://www.carethings.com/userId#iFinalInteraction";
    [finalInteraction addChild:idElement];

    GDataXMLElement* typeElement = [GDataXMLNode elementWithName:@"Type"];
    typeElement.stringValue = @"Imperative";
    [finalInteraction addChild:typeElement];

    GDataXMLElement* behaviorsElement = [GDataXMLNode elementWithName:@"Behaviors"];

    GDataXMLElement* behaviorElement = [GDataXMLNode elementWithName:@"Behavior"];
    behaviorElement.stringValue = @"http://www.carethings.com/userBehavior/className#FinalInteraction";
    [behaviorsElement addChild:behaviorElement];

    [finalInteraction addChild:behaviorsElement];

    return finalInteraction;
}

- (void) setUpRedCapIntervention:(GDataXMLElement*)intervention withForm:(NSString*)formName {
    GDataXMLElement* sysIdElement = [GDataXMLNode elementWithName:@"SystemID"];
    sysIdElement.stringValue = [[NSString alloc] initWithFormat:@"http://www.carethings.com/sysId#%@", formName];
    [intervention addChild:sysIdElement];

    GDataXMLElement* typeElement = [GDataXMLNode elementWithName:@"Type"];
    typeElement.stringValue = @"GOAL";
    [intervention addChild:typeElement];

    GDataXMLElement* navElement = [GDataXMLNode elementWithName:@"Navigation"];
    navElement.stringValue = @"NAVEXITONLY";
    [intervention addChild:navElement];

    if ([WSStringUtils isNotEmpty:formName]) {
        NSString* formattedFormName = [[formName stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];

        GDataXMLElement* formElement = [GDataXMLNode elementWithName:@"InterventionName"];
        formElement.stringValue = [[NSString alloc] initWithString:formattedFormName];
        [intervention addChild:formElement];
    }
}

- (void) setUpJumpIntervention:(GDataXMLElement*)intervention {
    GDataXMLElement* sysIdElement = [GDataXMLNode elementWithName:@"SystemID"];
    sysIdElement.stringValue = @"http://www.carethings.com/sysId#JumpIntervention";
    [intervention addChild:sysIdElement];
	
    GDataXMLElement* typeElement = [GDataXMLNode elementWithName:@"Type"];
    typeElement.stringValue = @"InterrogativeSingleSelect";
    [intervention addChild:typeElement];
	
    GDataXMLElement* navElement = [GDataXMLNode elementWithName:@"Navigation"];
    navElement.stringValue = @"NAVEXITONLY";
    [intervention addChild:navElement];
}

- (void) addJumpResponse:(GDataXMLElement*)jumpResponses withForm:(NSString*)formName {
    GDataXMLElement*  response  = [GDataXMLNode elementWithName:@"Response"];

    GDataXMLElement* idElement = [GDataXMLNode elementWithName:@"SystemID"];
    idElement.stringValue = @"Dashboard";
    [response addChild:idElement];

    //  Massage the form name
    NSString* formattedFormName = [[formName stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];

    GDataXMLElement* labelElement = [GDataXMLNode elementWithName:@"Label"];
    labelElement.stringValue = [[NSString alloc] initWithString:formattedFormName];
    [response addChild:labelElement];

    GDataXMLElement* typeElement = [GDataXMLNode elementWithName:@"Type"];
    typeElement.stringValue = @"GOAL";
    [response addChild:typeElement];

    GDataXMLElement* skipToElement = [GDataXMLNode elementWithName:@"SkipToIntervention"];
    skipToElement.stringValue = [[NSString alloc] initWithFormat:@"http://www.carethings.com/sysId#%@", formName];
    [response addChild:skipToElement];

    [jumpResponses addChild:response];
}

- (void) parseProtocol {
	NSError* err;

    doc_ = [[GDataXMLDocument alloc] initWithXMLString: protocolXml_ options: 0 error: &err];

	if (doc_ == nil) {
		return;
	}

    // First deconstruct the REDCap XML into interventions (each form is one intervention)
    GDataXMLElement*    interventions        = [GDataXMLNode elementWithName:@"Interventions"];
    GDataXMLElement*    jumpIntervention     = [GDataXMLNode elementWithName:@"Intervention"];
	GDataXMLElement*    jumpInteractions     = [GDataXMLNode elementWithName:@"Interactions"];
    GDataXMLElement*    jumpInteraction      = [GDataXMLNode elementWithName:@"Interaction"];
	GDataXMLElement*    jumpResponses        = [GDataXMLNode elementWithName:@"Responses"];

    [self setUpJumpIntervention:jumpIntervention];

    NSArray*         	itemEnum             = [[doc_ rootElement] children];
    NSMutableString*    currentFormName      = [[NSMutableString alloc] initWithCapacity:100];

    GDataXMLElement*    redcapIntervention = nil;
    GDataXMLElement* 	redcapInteractions = nil;

    for (GDataXMLElement* rootElement in itemEnum) {
        if ([[rootElement name] isEqualToString: @"item"])   {
            NSArray*     interactionEnum = [rootElement children];
            NSString*    fieldName;
            NSString*    fieldLabel;

            for (GDataXMLElement* interactionElement in interactionEnum) {
                if ([[interactionElement name] isEqualToString: @"form_name"]) {
                    if ([WSStringUtils caseInsensitiveCompare:[interactionElement stringValue] toString:currentFormName] != NSOrderedSame)  {
                        if (redcapIntervention != nil) {
                            [redcapIntervention addChild: redcapInteractions];

                            [interventions addChild:redcapIntervention];
                        }

                        redcapIntervention  = [GDataXMLNode elementWithName:@"Intervention"];
                        redcapInteractions  = [GDataXMLNode elementWithName:@"Interactions"];

                        [currentFormName setString:[interactionElement stringValue]];

                        [self setUpRedCapIntervention:redcapIntervention withForm:currentFormName];

                        [self addJumpResponse:jumpResponses withForm:currentFormName];
                    }
                } else if ([[interactionElement name] isEqualToString: @"field_label"]) {
                    fieldLabel = [interactionElement stringValue];
                } else if ([[interactionElement name] isEqualToString: @"field_name"]) {
                    fieldName = [interactionElement stringValue];
                }
            }

            // Determine if this is a special encoded OpenPATH "item"
            if ([[fieldName uppercaseString] rangeOfString:@"OPENPATH"].location != NSNotFound) {
                GDataXMLDocument* interactionDoc             = [[GDataXMLDocument alloc] initWithXMLString: fieldLabel options: 0 error: &err];
                GDataXMLElement*  openPathInteractionElement = [interactionDoc rootElement];

                [redcapInteractions addChild:openPathInteractionElement];
            } else {
                [redcapInteractions addChild:rootElement];
            }
        }
    }

    //  Add the final jump response
    [self addJumpResponse:jumpResponses withForm:currentFormName];
	
	[jumpInteraction  addChild:jumpResponses];
	[jumpInteractions addChild:jumpInteraction];
	[jumpIntervention addChild:jumpInteractions];

    //  Add the final interactions from the final form
    [redcapIntervention addChild: redcapInteractions];

    //  Add the final RedCAP form
    [interventions addChild:redcapIntervention];

    GDataXMLElement*    finalInterventions = [GDataXMLNode elementWithName:@"Interventions"];

    [finalInterventions addChild:jumpIntervention];
    [finalInterventions addChildren:interventions];

	interventions_          = [finalInterventions children];
	interventionsEnum_      = [[BiArrayEnumerator alloc]  initWithArray: interventions_];
}

- (void) initializeModel {
	[self parseProtocol];
}

- (void) decodeRoot: (WSUtteranceRoot*) root WithXML: (GDataXMLElement*) xml {
    NSArray* utteranceRootEnum = [xml children];

   	for (GDataXMLElement* utteranceRootElement in utteranceRootEnum) {
   		if ([[utteranceRootElement name] isEqualToString: @"ID"]) {
   			[root setUserID:[NSURL URLWithString:[utteranceRootElement stringValue]]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"SkipTo"])   {
   			[root setSkipTo:[NSURL URLWithString:[utteranceRootElement stringValue]]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"Attractor"])   {
   			[root setAttractor:[utteranceRootElement stringValue]];
           } else if ([[utteranceRootElement name] isEqualToString: @"SystemID"])   {
   			[root setSystemID:[NSURL URLWithString:[utteranceRootElement stringValue]]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"Description"])   {
   			[root setDescription:[utteranceRootElement stringValue]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"UserValue1"])   {
   			[root setUserValue1:[utteranceRootElement stringValue]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"UserValue2"])   {
   			[root setUserValue2:[utteranceRootElement stringValue]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"UserValue3"])   {
   			[root setUserValue3:[utteranceRootElement stringValue]];
   	    } else if ([[utteranceRootElement name] isEqualToString: @"PreBehaviors"])   {
   		    NSArray* preEnum = [utteranceRootElement children];

   			if ([preEnum count] == 0) {
   			    continue;
   			}

   			for (GDataXMLElement* preElement in preEnum) {
   				[root addPreBehavior:[preElement stringValue]];
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"Behaviors"])   {
   		    NSArray* behaviorEnum = [utteranceRootElement children];

   		    if ([behaviorEnum count] == 0) {
   		      	continue;
   		    }

   		    for (GDataXMLElement* behaviorElement in behaviorEnum) {
                   if ([[behaviorElement name] isEqualToString:@"BehaviorComponent"]) {
                       root.behaviorUserComponent = [behaviorElement stringValue];
                   } else {
   		            [root addBehavior:[behaviorElement stringValue]];
                   }
   		    }
   		} else if ([[utteranceRootElement name] isEqualToString: @"PostBehaviors"])   {
   		    NSArray* postEnum = [utteranceRootElement children];

   			if ([postEnum count] == 0) {
   				continue;
   			}

   			for (GDataXMLElement* postElement in postEnum) {
   				[root addPostBehavior: [postElement stringValue]];
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"Ontology"])   {
   			[root setOntology:[NSURL URLWithString:[utteranceRootElement stringValue]]];
   		} else if ([[utteranceRootElement name] isEqualToString: @"WorldModel"])   {
   			NSArray* modelEnum = [utteranceRootElement children];

   			if ([modelEnum count] == 0) {
   				continue;
   			}

   			root.worldModel = [NSMutableArray arrayWithCapacity: 1];

   			for (GDataXMLElement* factElement in modelEnum) {
   				NSString* fact = [factElement stringValue];

   				if ([WSStringUtils isNotEmpty: fact]) {
   					[root.worldModel addObject: fact];
   				}
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"Active"])   {
   			NSArray* activeEnum = [utteranceRootElement children];

   			if ([activeEnum count] == 0) {
   				continue;
   			}

   			//root.activeCondition = [[NSMutableArray arrayWithCapacity:1];
   			root.activeCondition = [NSMutableArray arrayWithCapacity: 1];

   			for (GDataXMLElement* activeElement in activeEnum) {
                   if ([[activeElement name] isEqualToString:@"Fact"]) {
   				    NSString* fact = [activeElement stringValue];

   				    if ([WSStringUtils isNotEmpty: fact]) {
   					    [root.activeCondition addObject: fact];
   				    }

                       root.activeConditionLangType = LanguageTypeClips;
                   } else if ([[activeElement name] isEqualToString:@"Expression"]) {
                   	NSString* expression = [activeElement stringValue];

                   	if ([WSStringUtils isNotEmpty: expression]) {
                   	     [root.activeCondition addObject: expression];
                   	}

                       root.activeConditionLangType = LanguageTypeExpression;
                   }
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"SkipCondition"])   {
   			NSArray* skipEnum = [utteranceRootElement children];

   			if ([skipEnum count] == 0) {
   				continue;
   			}

   			root.skipCondition = [NSMutableArray arrayWithCapacity: 1];

   			for (GDataXMLElement* factElement in skipEnum) {
   				NSString* fact = [factElement stringValue];

   				if ([WSStringUtils isNotEmpty: fact]) {
   					[root.skipCondition addObject: fact];
   				}
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"RenderingHint"])   {
   			NSArray* hintEnum = [utteranceRootElement children];

   			for (GDataXMLElement* hintElement in hintEnum) {
   				if ([[hintElement name] isEqualToString: @"ControlType"]) {
   					root.controlType = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlImage"])   {
   					root.controlImage = [NSURL URLWithString:[hintElement stringValue]];
   				} else if ([[hintElement name] isEqualToString: @"ControlHeight"])   {
   					root.controlHeight = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlWidth"])   {
   					root.controlWidth = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlItem"])   {
   					root.controlItem = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlFontSize"])   {
   					root.controlFontSize = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlFontColor"])   {
   					root.controlFontColor = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"ControlFontName"])   {
   					root.controlFontName = [hintElement stringValue];
   				} else if ([[hintElement name] isEqualToString: @"TouchArea"])   {
   					NSArray* touchAreaEnum = [hintElement children];

   					for (GDataXMLElement* touchAreaElement in touchAreaEnum) {
   						if ([[touchAreaElement name] isEqualToString: @"TouchX"]) {
   							root.controlTouchX = [touchAreaElement stringValue];
   						} else if ([[touchAreaElement name] isEqualToString: @"TouchY"])   {
   							root.controlTouchY = [touchAreaElement stringValue];
   						} else if ([[touchAreaElement name] isEqualToString: @"TouchWidth"])   {
   							root.controlTouchWidth = [touchAreaElement stringValue];
   						} else if ([[touchAreaElement name] isEqualToString: @"TouchHeight"])   {
   							root.controlTouchHeight = [touchAreaElement stringValue];
   						}
   					}
   				}
   			}
   		} else if ([[utteranceRootElement name] isEqualToString: @"Directive"])   {
   			NSArray* directiveEnum = [utteranceRootElement children];

   			for (GDataXMLElement* directiveElement in directiveEnum) {
   				if ([[directiveElement name] isEqualToString: @"Instruction"]) {
   					root.directiveInstruction = [directiveElement stringValue];
   				} else if ([[directiveElement name] isEqualToString: @"InstructionResource"]) {
                       [root setDirectiveInstructionResource:[NSURL URLWithString:[directiveElement stringValue]]];
                   } else if ([[directiveElement name] isEqualToString: @"Image"])   {
   					root.directiveImage = [NSURL URLWithString:[directiveElement stringValue]];
   				} else if ([[directiveElement name] isEqualToString: @"URL"])   {
   					root.directive = [NSURL URLWithString:[directiveElement stringValue]];
   				}
   			}
   		}
   	}
}

- (WSInterventionHIL*) decodeInterventionwithXML: (GDataXMLElement*) xml {
    WSUCSFProtocolModel* model        = [[WSUCSFProtocolModel alloc] initWithProtocol:nil andHistoryManager:nil];
    WSInterventionHIL*   intervention = [model decodeInterventionwithXML:xml];

    [self decodeRoot: intervention WithXML: xml];

    return intervention;
}

- (void) transferConstraintsFromInteraction:(WSInteraction*)interaction toResponse:(WSResponse*)response {
    if ((interaction == nil) || (response == nil)) {
        return;
    }

    if (interaction.type != InteractionHILTypeInterrogativeUnstructured) {
        return;
    }

    response.constraintMaxValue     = ([WSStringUtils isNotEmpty:interaction.constraintMaxValue]) ? [[NSString alloc] initWithString:interaction.constraintMaxValue] : nil;
   	response.constraintMaxValueText = ([WSStringUtils isNotEmpty:interaction.constraintMaxValueText]) ? [[NSString alloc] initWithString:interaction.constraintMaxValueText] : nil;
   	response.constraintMinValue     = ([WSStringUtils isNotEmpty:interaction.constraintMinValue]) ? [[NSString alloc] initWithString:interaction.constraintMinValue]: nil;
    response.constraintMinValueText = ([WSStringUtils isNotEmpty:interaction.constraintMinValueText]) ? [[NSString alloc] initWithString:interaction.constraintMinValueText] : nil;
    response.constraintControlWidth = ([WSStringUtils isNotEmpty:interaction.constraintControlWidth]) ? [[NSString alloc] initWithString:interaction.constraintControlWidth]: nil;
    response.constraintValueList    = ((interaction.constraintValueList != nil) && ([interaction.constraintValueList count] > 0)) ? [[NSMutableArray alloc] initWithArray:interaction.constraintValueList] : nil;
    response.constraintDataListName = ([WSStringUtils isNotEmpty:interaction.constraintDataListName]) ? [[NSString alloc] initWithString:interaction.constraintDataListName] : nil;
    response.constraintBehavior     = (interaction.constraintBehavior != nil) ? [[NSURL alloc] initWithString:[interaction.constraintBehavior absoluteString]] : nil;
    response.constraintDataType     = interaction.constraintDataType;
}

- (void) decodeTypeOfInteraction:(WSInteractionHIL*)interaction withXML:(GDataXMLElement*) xml {
     // TEXT	- single-line text box (for text and numbers)
     // NOTES	- large text box for lots of text
     // DROPDOWN	- dropdown menu with options
     // RADIO	- radio buttons with options
     // CHECKBOX	- checkboxes to allow selection of more than one option
     // FILE	- upload a document
     // CALC	- perform real-time calculations
     // SQL	- select query statement to populate dropdown choices
     // DESCRIPTIVE	- text displayed with no data entry and optional image/file attachment
     // SLIDER	- visual analogue scale; coded as 0-100
     // YESNO	- radio buttons with yes and no options; coded as 1, Yes | 0, No
     // TRUEFALSE	- radio buttons with true and false options; coded as 1, True | 0, False

     if ([[xml stringValue] caseInsensitiveCompare:@"TEXT"] == NSOrderedSame) {
         [interaction setType:InteractionHILTypeInterrogativeUnstructured];

         WSResponse* response = [WSResponse new];

         response.description = @"Auto-generated response";
         [response setResponseType:ResponseTypeFreeFixed];
         [response setSystemID:interaction.systemID];
         [response setUserID:interaction.systemID];

         [self transferConstraintsFromInteraction:interaction toResponse:response];

         [interaction addResponse:response];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"NOTES"] == NSOrderedSame) {
         [interaction setType:InteractionHILTypeInterrogativeUnstructured];

         WSResponse* response = [WSResponse new];

         response.description = @"Auto-generated response";
         [response setResponseType:ResponseTypeFree];
         [response setSystemID:interaction.systemID];
         [response setUserID:interaction.systemID];

         [self transferConstraintsFromInteraction:interaction toResponse:response];

         [interaction addResponse:response];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"DROPDOWN"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeInterrogativeSingleSelect];

        [interaction setFormat:ResponseDataTypeValueList];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"RADIO"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeInterrogativeSingleSelect];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"CHECKBOX"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeInterrogativeMultiSelect];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"DESCRIPTIVE"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeDeclarative];

         // See if there is a file attachment
         WSREDCapChannel* channel = [WSREDCapChannel new];
         NSError*         error;
         NSData*          result  = [channel retrieveFileAttachment:[interaction.userID fragment] withOptions:WSChannelOptionNone didFailWithError:&error];

         WSResponse* response = [WSResponse new];

         response.description = @"Auto-generated response";
         [response setResponseType:ResponseTypeDirective];
         [response setSystemID:interaction.systemID];
         [response setUserID:interaction.systemID];

         [interaction addResponse:response];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"SLIDER"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeInterrogativeSingleSelect];

         WSResponse* response = [WSResponse new];

         // First generate the response representing the labels of the slider
         response.description = @"Auto-generated response";
         [response setResponseType:ResponseTypeDirective];
         [response setSystemID:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@#%@", @"http://www.carethings.com/sysId", [ResourceIdentityGenerator allocateObjectId]]]];
         [response setUserID:response.systemID];

        [interaction addResponse:response];

         // Now generate the response representing the slider itself
         response = [WSResponse new];

         response.description = @"Auto-generated response";
         [response setResponseType:ResponseTypeVAS];
         [response setSystemID:interaction.systemID];
         [response setUserID:interaction.systemID];

        [interaction addResponse:response];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"YESNO"] == NSOrderedSame) {
        [interaction setType:InteractionHILTypeInterrogativeSingleSelect];

        WSResponse* yesResponse = [WSResponse new];
        WSResponse* noResponse  = [WSResponse new];

        yesResponse.description = @"Auto-generated response";
        [yesResponse setResponseType:ResponseTypeFixedNext];
        [yesResponse setLabel:@"Yes"];
        [yesResponse setCode:[[NSURL alloc] initWithString:@"http://www.carethings.com/code#1"]];
        [yesResponse setSystemID:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@_1", [interaction.systemID absoluteString]]]];
        [yesResponse setUserID:interaction.systemID];

        noResponse.description = @"Auto-generated response";
        [noResponse  setResponseType:ResponseTypeFixedNext];
        [noResponse  setLabel:@"No"];
        [noResponse  setCode:[[NSURL alloc] initWithString:@"http://www.carethings.com/code#0"]];
        [noResponse setSystemID:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@_0", [interaction.systemID absoluteString]]]];
        [noResponse setUserID:interaction.systemID];

        [interaction addResponse:yesResponse];
        [interaction addResponse:noResponse];
     } else if ([[xml stringValue] caseInsensitiveCompare:@"TRUEFALSE"] == NSOrderedSame) {
         [interaction setType:InteractionHILTypeInterrogativeSingleSelect];

         WSResponse* trueResponse   = [WSResponse new];
         WSResponse* falseResponse  = [WSResponse new];

         trueResponse.description = @"Auto-generated response";
         [trueResponse setResponseType:ResponseTypeFixedNext];
         [trueResponse setLabel:@"True"];
         [trueResponse setCode:[[NSURL alloc] initWithString:@"http://www.carethings.com/code#1"]];
         [trueResponse setSystemID:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@_1", [interaction.systemID absoluteString]]]];
         [trueResponse setUserID:interaction.systemID];

         falseResponse.description = @"Auto-generated response";
         [falseResponse setResponseType:ResponseTypeFixedNext];
         [falseResponse setLabel:@"False"];
         [falseResponse setCode:[[NSURL alloc] initWithString:@"http://www.carethings.com/code#0"]];
         [falseResponse setSystemID:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@_0", [interaction.systemID absoluteString]]]];
         [falseResponse setUserID:interaction.systemID];

         [interaction addResponse:trueResponse];
         [interaction addResponse:falseResponse];
     }
}

- (ConstraintDataType) decodeConstraintDataType:(NSString*)constraintDataType {
    if ([WSStringUtils isEmpty:constraintDataType]) {
        return ConstraintDataTypeUnknown;
    }

    NSDictionary*  redCapToOpDataType = [NSDictionary dictionaryWithObjectsAndKeys:
            [[NSNumber alloc] initWithInt:ConstraintDataTypeNumeric], @"number",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeNumeric], @"number_1dp",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeNumeric], @"number_2dp",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeNumeric], @"number_3dp",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeNumeric], @"number_4dp",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_mdy",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_dmy",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_ymd",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_seconds_mdy",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_seconds_dmy",
            [[NSNumber alloc] initWithInt:ConstraintDateTypeDateTime], @"datetime_seconds_ymd",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeSSN], @"ssn",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeAlpha], @"alpha_only",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeDate], @"date_ymd",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeDate], @"date_dmy",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeDate], @"date_mdy",
            [[NSNumber alloc] initWithInt:ConstraintDataTypePhone], @"phone",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeTime], @"time",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeTime], @"time_mm_ss",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeEmail], @"email",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeZipcode], @"zipcode",
            [[NSNumber alloc] initWithInt:ConstraintDataTypeInteger], @"integer",
            nil];

    ConstraintDataType dataType = (ConstraintDataType) [[redCapToOpDataType objectForKey:constraintDataType] intValue];
	
	return dataType;
}

- (NSString*) decodeConstraintFormat:(NSString*)constraintDataType {
    if ([WSStringUtils isEmpty:constraintDataType]) {
        return nil;
    }

    NSString* format = nil;

    if ([constraintDataType isEqualToString:@"number"]) {
        format = @"[[0-9]*";
    }

    if ([constraintDataType isEqualToString:@"number_1dp"]) {
        format = @"[[0-9]*.[[0-9]";
    }

    if ([constraintDataType isEqualToString:@"number_2dp"]) {
        format = @"[[0-9]*.[[0-9][[0-9]";
    }

    if ([constraintDataType isEqualToString:@"number_3dp"]) {
        format = @"[[0-9]*.[[0-9][[0-9][[0-9]";
    }

    if ([constraintDataType isEqualToString:@"datetime_mdy"]) {
        format = @"^(0[[1-9]|1[[012])[[- /.](0[[1-9]|[[12][[0-9]|3[[01])[[- /.](19|20)\\d\\d$";
    }

    if ([constraintDataType isEqualToString:@"datetime_dmy"]) {
        format = @"^(0[[1-9]|[[12][[0-9]|3[[01])[[- /.](0[[1-9]|1[[012])[[- /.](19|20)\\d\\d$";
    }

    if ([constraintDataType isEqualToString:@"datetime_ymd"]) {
        format = @"^(19|20)\\d\\d[[- /.](0[[1-9]|1[[012])[[- /.](0[[1-9]|[[12][[0-9]|3[[01])$";
    }

    if ([constraintDataType isEqualToString:@"datetime_seconds_mdy"]) {

    }

    if ([constraintDataType isEqualToString:@"datetime_seconds_dmy"]) {

    }

    if ([constraintDataType isEqualToString:@"datetime_seconds_ymd"]) {

    }

    if ([constraintDataType isEqualToString:@"ssn"]) {
        format = @"^\\d{3}-\\d{2}-\\d{4}$";
    }

    if ([constraintDataType isEqualToString:@"alpha_only"]) {
        format = @"[[a-zA-Z]*";
    }

    if ([constraintDataType isEqualToString:@"date_ymd"]) {

    }

    if ([constraintDataType isEqualToString:@"date_dmy"]) {

    }

    if ([constraintDataType isEqualToString:@"date_mdy"]) {

    }

    if ([constraintDataType isEqualToString:@"phone"]) {
        format = @"^\\s*([[\\(]?)\\[[?\\s*\\d{3}\\s*\\]?[[\\)]?\\s*[[\\-]?[[\\.]?\\s*\\d{3}\\s*[[\\-]?[[\\.]?\\s*\\d{4}$";
    }

    if ([constraintDataType isEqualToString:@"time"]) {

    }

    if ([constraintDataType isEqualToString:@"time_mm_ss"]) {

    }

    if ([constraintDataType isEqualToString:@"email"]) {
        format = @"^\\w+@[[a-zA-Z_]+?\\.[[a-zA-Z]{2,3}$";
    }

    if ([constraintDataType isEqualToString:@"zipcode"]) {
        format = @"(^(?!0{5})(\\d{5})(?!-?0{4})(|-\\d{4})?$)";
    }

    if ([constraintDataType isEqualToString:@"integer"]) {
        format = @"[[0-9]*";
    }

    return format;
}

- (void)decodeREDCapParams:(NSString*)paramList forDomain:(WSInteraction*)interaction {
    if ([WSStringUtils isEmpty:paramList])
        return;

    if (interaction == nil)
        return;

    NSArray*    params = [paramList componentsSeparatedByString:@";"];

    if ((params == nil) || ([params count] == 0))
        return;

    for (NSString* param in params) {
        NSArray* nvp = [param componentsSeparatedByString:@"="];

        if ([nvp count] != 2)
            continue;

        NSString* paramName  = [nvp objectAtIndex:0];
        NSString* paramValue = [nvp objectAtIndex:1];

        if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"SCHEDULE.WEEK"] == NSOrderedSame) {
            if (interaction.schedule == nil) {
                interaction.schedule = [WSSchedule new];
            }

            interaction.schedule.week = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"SCHEDULE.DAY"] == NSOrderedSame) {
            if (interaction.schedule == nil) {
                interaction.schedule = [WSSchedule new];
            }

            interaction.schedule.day = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"SCHEDULE.ATMOST"] == NSOrderedSame) {
            if (interaction.schedule == nil) {
                interaction.schedule = [WSSchedule new];
            }

            interaction.schedule.atMost = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"SCHEDULE.TIMERANGE.DATETIMEFROM"] == NSOrderedSame) {
            if (interaction.schedule == nil) {
                interaction.schedule = [WSSchedule new];
            }

            interaction.schedule.timeFrom = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"SCHEDULE.TIMERANGE.DATETIMETO"] == NSOrderedSame) {
            if (interaction.schedule == nil) {
                interaction.schedule = [WSSchedule new];
            }

            interaction.schedule.timeTo = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"ONTOLOGY"] == NSOrderedSame) {
            interaction.ontology = [[NSURL alloc] initWithString:paramValue];
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"COLOR"] == NSOrderedSame) {
            interaction.constraintColor = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"VAS.MINTEXT"] == NSOrderedSame) {
            interaction.constraintMinValueText = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"VAS.MAXTEXT"] == NSOrderedSame) {
            interaction.constraintMaxValueText = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"VAS.MIDTEXT"] == NSOrderedSame) {
            interaction.constraintMidValueText = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"VAS.MINMIDTEXT"] == NSOrderedSame) {
            interaction.constraintMinMidValueText = paramValue;
        } else if ([WSStringUtils caseInsensitiveCompare:paramName toString:@"VAS.MIDMAXTEXT"] == NSOrderedSame) {
            interaction.constraintMidMaxValueText = paramValue;
        }
    }
}

- (void)decodeResponseParams:(NSString*)params forResponse:(WSResponse*)response {
    if ([WSStringUtils isEmpty:params])
        return;

    if (response == nil)
        return;

    [self decodeREDCapParams:params forDomain:response];
}

- (void)decodeResponsesOfInteraction:(WSInteractionHIL*)interaction WithXML:(GDataXMLElement*)xml {
    if ([WSStringUtils isEmpty:[xml stringValue]]) {
        return;
    }

    NSMutableString*  responseString   = [[NSMutableString alloc] initWithString:[xml stringValue]];
    NSArray*          responseList     = [responseString componentsSeparatedByString:@"\\n"];

    if ((responseList != nil) && ([responseList count] > 0)) {
        for (NSString * responseStr in responseList) {
            NSArray*    responseParts = [responseStr componentsSeparatedByString:@","];

            if ((responseParts != nil) && ([responseParts count] > 0)) {
                WSResponse* response = [WSResponse new];

                if ([responseParts count] == 1)  {
                    [response setLabel:[responseParts objectAtIndex:0]];

                    NSString* responseUrlStr = [[NSString alloc] initWithFormat:@"%@_0", [interaction.systemID absoluteString]];
                    NSURL*    responseURL    = [[NSURL alloc] initWithString:responseUrlStr];

                    [response setSystemID:responseURL];
                } else {
                    NSString* codeValue   = [[responseParts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSString* rawResponse = [[responseParts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                    [response setLabel:rawResponse];
                    [response setCode:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.carethings.com/code#%@", codeValue]]];

                    NSString* systemIdStr = [[NSString alloc] initWithFormat:@"%@_%@", [interaction.systemID absoluteString], codeValue];
                    NSURL*    systemIdURL = [[NSURL alloc] initWithString:systemIdStr];

                    [response setSystemID:systemIdURL];
                }

                // Explanation.  For response identifiers in REDCap, if it is a choice field then the identifier
                // will include the code. For example, in branch expressions the choice is <field name>(<code value>).  If the
                // field is not a choice then the response in branch expressions is merely <field name>.
                if ([interaction isInterrogativeMulti]) {
                    [response setUserID:response.systemID];
                    [response setResponseType:ResponseTypeFixed];
                } else {
                    [response setUserID:interaction.systemID];
                    [response setResponseType:ResponseTypeFixedNext];
                }

                [interaction addResponse:response];
            }
        }
    }
}

- (NSString*)normalizeREDCapExpression:(NSString*)expression {
    if ([WSStringUtils isEmpty:expression]) {
        return nil;
    }

    NSString* tempExpression = expression;

    tempExpression = [tempExpression stringByReplacingOccurrencesOfString:@" and " withString:@" && "];
    tempExpression = [tempExpression stringByReplacingOccurrencesOfString:@" or " withString:@" || "];
    tempExpression = [tempExpression stringByReplacingOccurrencesOfString:@"<>" withString:@"!="];
    tempExpression = [tempExpression stringByReplacingOccurrencesOfString:@"]" withString:@" "];
    tempExpression = [tempExpression stringByReplacingOccurrencesOfString:@"[[" withString:@"$"];

    NSError* error = nil;

    // Finally, convert parameters with choice fields (e.g. parameter(3) into parameter_3)
    NSRegularExpression*  regex = [NSRegularExpression regularExpressionWithPattern:@"(\\$[[a-zA-Z_]*)\\(([[0-9]*)\\)" options:(NSRegularExpressionOptions) 0 error:&error];
    NSString*             finalExpression;

    if (error == nil) {
        finalExpression = [regex stringByReplacingMatchesInString:tempExpression
                                                          options:(NSMatchingOptions) 0
                                                            range:NSMakeRange(0, [tempExpression length])
                                                     withTemplate:@"$1_$2"];
    } else {
        finalExpression = tempExpression;
    }

    return finalExpression;
}

- (void)decodeCalculation:(NSString*)expression forInteraction:(WSInteractionHIL*)interaction {
    NSString* tempExpression = [self normalizeREDCapExpression:expression];





}

- (void)decodeVASBasedResponseOfInteraction:(WSInteractionHIL*)interaction WithXML:(GDataXMLElement*)xml {
    if ([WSStringUtils isEmpty:[xml stringValue]]) {
        return;
    }

    NSMutableString*  responseString   = [[NSMutableString alloc] initWithString:[xml stringValue]];
    WSResponse*       vasResponse      = [interaction.responses objectAtIndex:1];

    if (vasResponse == nil) {
        return;
    }
	
	NSArray* responseList     = [responseString componentsSeparatedByString:@"\\n"];

    vasResponse.userID = interaction.systemID;

    if ((responseList != nil) && ([responseList count] > 0)) {
        for (NSString * responseStr in responseList) {
            NSArray*    responseParts = [responseStr componentsSeparatedByString:@"|"];

            if ((responseParts != nil) && ([responseParts count] > 0)) {
                if ([responseParts count] == 1)  {
                    [vasResponse setConstraintMinValue:[responseParts objectAtIndex:0]];
                } else if ([responseParts count] == 2) {
                    [vasResponse setConstraintMinValueText:[responseParts objectAtIndex:0]];
                    [vasResponse setConstraintMaxValueText:[responseParts objectAtIndex:1]];
                } else if ([responseParts count] == 3) {
                    [vasResponse setConstraintMinValueText:[responseParts objectAtIndex:0]];
					[vasResponse setConstraintMidValueText:[responseParts objectAtIndex:1]];
                    [vasResponse setConstraintMaxValueText:[responseParts objectAtIndex:2]];
                }
            }
        }
    }

    //  Now generate the label
    WSResponse*  labelResponse = [interaction.responses objectAtIndex:0];

    labelResponse.label              = [[NSString alloc] initWithFormat:@"%@ %@", vasResponse.constraintMinValueText, vasResponse.constraintMaxValueText];
    labelResponse.constraintMinValue = vasResponse.constraintMinValueText;
    labelResponse.constraintMaxValue = vasResponse.constraintMaxValueText;
}

// Must translate a REDCap branch expression into something we can process.  Luckily, the branch
// expressions are very close to expressions supported by OpenPATH.
- (void) decodeBranchingLogic:(NSString*)expression forInteraction:(WSInteraction*)interaction {
    if ([WSStringUtils isEmpty:expression] || (interaction == nil)) {
        return;
    }

    NSString* finalExpression = [self normalizeREDCapExpression:expression];
		
	interaction.activeCondition = [NSMutableArray arrayWithCapacity: 1];
	[interaction.activeCondition addObject: finalExpression];
	interaction.activeConditionLangType = LanguageTypeExpression;
}

- (void)decodeFieldNote:(NSString*)note forInteration:(WSInteractionHIL*)interaction {
    if ([WSStringUtils isEmpty:note])
        return;

    if (interaction == nil)
        return;

    [self decodeREDCapParams:note forDomain:interaction];
}

- (WSInteractionHIL*) decodeInteractionHILwithXML: (GDataXMLElement*) xml {
	WSInteractionHIL* interaction = [WSInteractionHIL new];

    NSArray *interactionEnum = [xml children];

    if ([WSStringUtils caseInsensitiveCompare:[xml name] toString:@"Interaction"] == NSOrderedSame) {
        WSUCSFProtocolModel* model = [[WSUCSFProtocolModel alloc] initWithProtocol:nil andHistoryManager:nil];

        interaction = [model decodeInteractionHILwithXML:xml];
    } else {
        for (GDataXMLElement *interactionElement in interactionEnum) {
            if ([[interactionElement name] isEqualToString:@"field_name"]) {
				if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setUserID:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.carethings.com/userID#%@", [interactionElement stringValue]]]];

                    if (interaction.systemID == nil) {
                        [interaction setSystemID:interaction.userID];
                    }
                }
            } else if ([[interactionElement name] isEqualToString:@"form_name"]) {
                ;
            } else if ([[interactionElement name] isEqualToString:@"section_header"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setDescription:[interactionElement stringValue]];

                    [interaction addPreBehavior: @"http://www.carethings.com/userBehavior#addSectionHeader"];
                }
            } else if ([[interactionElement name] isEqualToString:@"system_id"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setSystemID:[[NSURL alloc] initWithString:[interactionElement stringValue]]];
                }
            } else if ([[interactionElement name] isEqualToString:@"navigation"]) {
                WSUCSFProtocolModel* model = [[WSUCSFProtocolModel alloc] initWithProtocol:nil andHistoryManager:nil];

                [interaction setNavigation:[model interactionNavigationFromValue:[interactionElement stringValue]]];
            } else if ([[interactionElement name] isEqualToString:@"field_type"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [self decodeTypeOfInteraction:interaction withXML:interactionElement];
                }
            } else if ([[interactionElement name] isEqualToString:@"field_label"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setText:[interactionElement stringValue]];
                }
            } else if ([[interactionElement name] isEqualToString:@"select_choices_or_calculations"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    if ([interaction isInterrogativeUnstructured]) {
                        [self decodeCalculation:[interactionElement stringValue] forInteraction:interaction];
                    } else if ([interaction hasVasResponse]) {
                        [self decodeVASBasedResponseOfInteraction:interaction WithXML:interactionElement];
                    } else {
                        // If processing a matrix question, we only process the responses once for the first interaction
                        [self decodeResponsesOfInteraction:interaction WithXML:interactionElement];
                    }
                }
            } else if ([[interactionElement name] isEqualToString:@"field_note"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [self decodeFieldNote:[interactionElement stringValue] forInteration:interaction];
                }
            } else if ([[interactionElement name] isEqualToString:@"matrix_group_name"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setGroupName:[interactionElement stringValue]];
                }
            } else if ([[interactionElement name] isEqualToString:@"text_validation_type_or_show_slider_number"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    interaction.constraintDataType = [self decodeConstraintDataType:[interactionElement stringValue]];
                    interaction.constraintFormat   = [self decodeConstraintFormat:[interactionElement stringValue]];
                }
            } else if ([[interactionElement name] isEqualToString:@"text_validation_min"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setConstraintMinValue:[interactionElement stringValue]];
                }
            } else if ([[interactionElement name] isEqualToString:@"text_validation_max"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setConstraintMaxValue:[interactionElement stringValue]];
                }
            } else if ([[interactionElement name] isEqualToString:@"identifier"]) {
                ;
            } else if ([[interactionElement name] isEqualToString:@"branching_logic"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [self decodeBranchingLogic:[interactionElement stringValue] forInteraction:interaction];
                }
            } else if ([[interactionElement name] isEqualToString:@"required_field"]) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]]) {
                    [interaction setResponseRequired:(([[interactionElement stringValue] caseInsensitiveCompare:@"Y"] == NSOrderedSame) ? true : false)];
                }
            } else if ([[interactionElement name] isEqualToString:@"custom_alignment"]) {
                ;
            } else if ([[interactionElement name] isEqualToString:@"question_number"]) {
                ;
            }
        }

        interaction.ontology = [[NSURL alloc] initWithString:@"http://www.carethings.com/ontology#survey"];
    }

	return interaction;
}

- (GDataXMLElement*) locateInteractions: (GDataXMLElement*) xml {
	NSArray* interventionEnum =  [xml children];

	for (GDataXMLElement* interventionElement in interventionEnum) {
		if ([[interventionElement name] isEqualToString: @"Interactions"]) {
			//[[interventionEnum;
			return interventionElement;
		}
	}

	//[[interventionEnum;

	return nil;
}

- (void) interventionIteratorBegin {
	interventionsEnum_  = [[BiArrayEnumerator alloc]  initWithArray: interventions_];
}

- (WSIntervention*) nextIntervention {
	if (interventionsEnum_ == nil)
		return nil;

	GDataXMLElement* interventionElement = [interventionsEnum_ nextObject];

	if (interventionElement == nil)
		return nil;

	WSInterventionHIL* intervention = [self decodeInterventionwithXML: interventionElement];

	if (intervention == nil)
		return nil;

	intervention.tag = [interventionsEnum_ currentPos];

	GDataXMLElement* interactionsElement = [self locateInteractions: interventionElement];

	intervention.interactions = [interactionsElement children];

	[self interactionIteratorBeginFromIntervention: intervention];

	[intervention setupProtocolHistory: historyManager_];

	return intervention;
}

- (void) interactionIteratorBeginFromIntervention: (WSInterventionHIL*) intervention {
	interactionsEnum_  = [[BiArrayEnumerator alloc]  initWithArray: intervention.interactions];
}

- (WSInteractionHIL*) nextInteractionFromIntervention: (WSInterventionHIL*) intervention {
	if (intervention == nil)
		return nil;

	WSInteractionHIL*               interaction = nil;
	GDataXMLElement*                interactionElement = nil;
    WSInteractionHIL*               parentInteraction = nil;

	while ((interactionElement = [interactionsEnum_ nextObject]) != nil) {
		if ([interactionElement kind] == GDataXMLCommentKind)
			continue;

		interaction = [self decodeInteractionHILwithXML: interactionElement];

        if ([WSStringUtils isNotEmpty:interaction.groupName]) {
            if ([WSStringUtils isNotEmpty:activeMatrixGroup_]) {
                [interaction.filteredResponses initWithArray:interaction.responses];
                [parentInteraction addMember:interaction];
            } else {
                parentInteraction = [interaction copy];
                parentInteraction.text          = interaction.description;  // Question text is stored as a section header in REDCap
                parentInteraction.type          = InteractionHILTypeCollection;
                parentInteraction.executionMode = InteractionExecutionModeUser;

                [parentInteraction addMember:interaction];
                activeMatrixGroup_ = interaction.groupName;
            }

            continue;
        }

		interaction.tag = [interactionsEnum_ pos];

		break;
	}
	
	if (parentInteraction != nil) {
		interaction = parentInteraction;
        activeMatrixGroup_ = nil;
	}

	return interaction;
}

- (int) currentInteractionIndex {
	if (interactionsEnum_ != nil)
		return [interactionsEnum_ currentPos];
	else
		return 0;
}

-(WSInteractionHIL*)interactionWithSystemID:(NSString*)sysId {
    NSError * error;
    NSString * path = [[NSString alloc] initWithFormat:@"Interaction[[SystemID=%@]", sysId];

    NSArray* interactions = [doc_ nodesForXPath:path error:&error];

    if ((interactions == nil) || ([interactions count] != 1)) {
        return nil;
    }

    return [self decodeInteractionHILwithXML:[interactions objectAtIndex:0]];
}

- (WSInteractionHIL*) previousInteractionFromIntervention: (WSInterventionHIL*) intervention {
	if (intervention == nil)
		return nil;

	WSInteractionHIL*				interaction = nil;
	id <WSProtocolHistoryManager>	planHistory = (id <WSProtocolHistoryManager>)[intervention protocolHistory];

	if (planHistory == nil)
		return nil;

	if ([planHistory count] > 0) {
		NSInteger historyPos = [[planHistory lastInteraction] intValue];

		GDataXMLElement*  element = [interactionsEnum_ setLastObject: historyPos];

		interaction =  [self decodeInteractionHILwithXML: element];

		[planHistory popInteraction];
	}

	return interaction;
}

- (WSInteractionHIL*) lastInteractionFromProtocolHistory: (WSInterventionHIL*) intervention {
	if (intervention == nil)
		return nil;

	WSInteractionHIL*				interaction = nil;
	id <WSProtocolHistoryManager>	planHistory = (id <WSProtocolHistoryManager>)[intervention protocolHistory];

	if (planHistory == nil)
		return nil;

	if ([planHistory count] > 0) {
		NSInteger historyPos = [[planHistory lastInteraction] intValue];

		GDataXMLElement*  element = [interactionsEnum_ setLastObject: historyPos];

		interaction =  [self decodeInteractionHILwithXML: element];
	}

	return interaction;
}

- (void) tellHistory: (WSInterventionHIL*) intervention {
	if (intervention == nil)
		return;

    if (historyManager_ != nil) {
	    [historyManager_ pushInteraction:[NSNumber numberWithInt:[interactionsEnum_ pos]]];

	[historyManager_ persist: intervention];
    }
}

-(NSArray*)queryGoals {
    return nil;
}

-(NSArray*)queryTasks {
   	return nil;
}

-(NSArray*)queryRewards {
   	return nil;
}

-(NSArray*)queryInterventions {
    BiArrayEnumerator* localInterventionsEnum  = [[BiArrayEnumerator alloc]  initWithArray: interventions_];
    NSMutableArray*    interventions           = [[NSMutableArray alloc] initWithCapacity:10];
    GDataXMLElement*   interventionElement     = nil;

    if (localInterventionsEnum == nil)
    	return nil;

    while ((interventionElement = [localInterventionsEnum nextObject]) != nil) {
        WSInterventionHIL* intervention = [self decodeInterventionwithXML: interventionElement];

        if (intervention == nil) {
    	    continue;
        }

        [interventions addObject:intervention];
    }

    return interventions;
}

- (void) clearHistory {
	if (historyManager_ != nil) {
		[historyManager_ clearHistory];
	}
}

- (void) clearHistoryByContent: (WSInterventionHIL*) intervention {
	if (historyManager_ != nil) {
		[historyManager_ clearHistoryByIntervention:intervention];
	}
}

- (void) responseIteratorBeginFromInteraction: (WSInteractionHIL*) interaction {
	responsesEnum_  = [[BiArrayEnumerator alloc]  initWithArray: interaction.responses];
}

- (WSResponse*) nextResponseFromInteraction: (WSInteractionHIL*) interaction {
	if (interaction == nil)
		return nil;

	WSResponse* response = [responsesEnum_ nextObject];

	return response;
}

@end