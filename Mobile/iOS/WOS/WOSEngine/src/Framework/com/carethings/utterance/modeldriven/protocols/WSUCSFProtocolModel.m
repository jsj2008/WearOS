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


@implementation WSUCSFProtocolModel

@synthesize rootProtocolElement = rootProtocolElement_;
@synthesize interventionsEnum = interventionsEnum_;
@synthesize responsesEnum = responsesEnum_;
@synthesize interactionsEnum = interactionsEnum_;
@synthesize goalsEnum = goalsEnum_;
@synthesize protocolXml = protocolXml_;
@synthesize protocolFileName = protocolFileName_;
@synthesize interventions = interventions_;
@synthesize goals = goals_;
@synthesize tasks = tasks_;
@synthesize rewards = rewards_;
@synthesize study = study_;
@synthesize historyManager = historyManager_;

NSString* const RESPONSE_TYPE_FREE					= @"FREE";
NSString* const RESPONSE_TYPE_FREE_FIXED			= @"FREEFIXED";
NSString* const RESPONSE_TYPE_DIRECTIVE				= @"DIRECTIVE";
NSString* const RESPONSE_TYPE_FIXED					= @"FIXED";
NSString* const RESPONSE_TYPE_FIXED_NEXT			= @"FIXEDNEXT";
NSString* const RESPONSE_TYPE_FIXED_ASK             = @"FIXEDASK";
NSString* const RESPONSE_TYPE_GOAL					= @"GOAL";
NSString* const RESPONSE_TYPE_TASK			        = @"TASK";
NSString* const RESPONSE_TYPE_REWARD			    = @"REWARD";
NSString* const RESPONSE_TYPE_VAS					= @"VAS";
NSString* const RESPONSE_TYPE_DVAS					= @"DVAS";
NSString* const RESPONSE_TYPE_CAMERA				= @"CAMERA";
NSString* const RESPONSE_TYPE_VIDEO					= @"VIDEO";
NSString* const RESPONSE_TYPE_SENSOR				= @"SENSOR";
NSString* const RESPONSE_TYPE_VISUAL				= @"VISUAL";
NSString* const RESPONSE_TYPE_WEBVIEW               = @"WEBVIEW";
NSString* const RESPONSE_TYPE_OCR					= @"OCR";
NSString* const RESPONSE_TYPE_SCAN					= @"SCAN";
NSString* const RESPONSE_TYPE_COLLECTION            = @"COLLECTION";

NSString* const NAV_EXIT_ONLY						= @"NAVEXITONLY";
NSString* const NAV_HOME_ONLY						= @"NAVHOMEONLY";
NSString* const NAV_NEXT_ONLY						= @"NAVNEXTONLY";
NSString* const NAV_PREV_ONLY						= @"NAVPREVONLY";
NSString* const NAV_HOME_NEXT						= @"NAVHOMENEXT";
NSString* const NAV_NONE							= @"NAVNONE";
NSString* const NAV_SEND							= @"NAVSEND";
NSString* const NAV_SCROLL_DOWN						= @"NAVSCROLLDOWN";
NSString* const NAV_NEW_ONLY                        = @"NAVNEWONLY";

NSString* const INTERACTION_TYPE_RESPONSE			 = @"RESPONSE";
NSString* const INTERACTION_TYPE_PATTERN_OF_BEHAVIOR = @"PATTERNOFBEHAVIOR";
NSString* const INTERACTION_TYPE_MULTISELECT		 = @"INTERROGATIVEMULTIPLESELECT";
NSString* const INTERACTION_TYPE_SINGLESELECT		 = @"INTERROGATIVESINGLESELECT";
NSString* const INTERACTION_TYPE_UNSTRUCTURED 		 = @"INTERROGATIVEUNSTRUCTURED";
NSString* const INTERACTION_TYPE_IMPERATIVE			 = @"IMPERATIVE";
NSString* const INTERACTION_TYPE_GOAL				 = @"GOAL";
NSString* const INTERACTION_TYPE_TASK				 = @"TASK";
NSString* const INTERACTION_TYPE_REWARD				 = @"REWARD";
NSString* const INTERACTION_TYPE_DECLARATIVE		 = @"DECLARATIVE";
NSString* const INTERACTION_TYPE_COLLECTION		     = @"COLLECTION";

NSString* const INTERACTION_EXEC_MODE_SEQUENTIAL    = @"MODESEQUENTIAL";
NSString* const INTERACTION_EXEC_MODE_PARALLEL      = @"MODEPARALLEL";
NSString* const INTERACTION_EXEC_MODE_DATAFLOW      = @"MODEDATAFLOW";
NSString* const INTERACTION_EXEC_MODE_USER          = @"MODEUSER";

NSString* const RESPONSE_FORMAT_NUMERIC				= @"NUMERIC";
NSString* const RESPONSE_FORMAT_ALPHA				= @"ALPHA";
NSString* const RESPONSE_FORMAT_DATE				= @"DATE";
NSString* const RESPONSE_FORMAT_DATETIME			= @"DATETIME";
NSString* const RESPONSE_FORMAT_VALUE_LIST			= @"VALUELIST";
NSString* const RESPONSE_FORMAT_DATA_LIST			= @"DATALIST";
NSString* const RESPONSE_FORMAT_MONETARY			= @"MONETARY";
NSString* const RESPONSE_FORMAT_PHONE				= @"PHONE";

NSString* const DECISIONPOINT_TYPE_AND_SPLIT		= @"ANDSPLIT";
NSString* const DECISIONPOINT_TYPE_OR_SPLIT			= @"ORSPLIT";
NSString* const DECISIONPOINT_TYPE_AND_MERGE		= @"ANDMERGE";
NSString* const DECISIONPOINT_TYPE_OR_MERGE			= @"ORMERGE";
NSString* const DECISIONPOINT_TYPE_XOR_MERGE		= @"XORMERGE";


- (id) initWithProtocol: (NSString*) careXML andHistoryManager: (id <WSProtocolHistoryManager>) histManager {
	self = [super init];

	if (self) {
		protocolFileName_ = careXML;

		if (histManager == nil) {
			historyManager_ = [WSGeneralProtocolHistoryManager new];
		} else   {
			historyManager_ = histManager;
		}
	}

	return self;
}

-(void)setProtocolFileName:(NSString*)fileName {
    protocolFileName_ = [[NSString alloc] initWithString:fileName];
}

- (void) setupHistoryByContent: (WSInterventionHIL*) intervention {
	if (historyManager_ != nil) {
		[historyManager_ setupWithIntervention: intervention];
	}
}

- (NSString*) readProtocolXML {
	NSError*        err = nil;
	NSString*       xmlPath = [[NSBundle mainBundle] pathForResource: protocolFileName_ ofType: @"xml"];
	
	if ([WSStringUtils isEmpty:xmlPath]) {
		return nil;
	}
	
	NSURL* xmlURL = [[NSURL alloc] initFileURLWithPath: xmlPath];

	NSString* pathway = [[NSString alloc] initWithContentsOfURL: xmlURL encoding: NSUTF8StringEncoding error: &err];

	if ([WSStringUtils isEmpty:pathway]) {
		pathway = @"<ClinicalPathway><PathwayXMLAuthor>Larry Suarez</PathwayXMLAuthor><PathwayXMLOntology>OntologyName</PathwayXMLOntology><Study><PrimaryResearcher><NameAddress><FirstName>Larry</FirstName><LastName>Suarez</LastName></NameAddress><URL>http://www.carethings.com</URL></PrimaryResearcher></Study><Interventions><Intervention><SystemID>http://www.carethings.com/sysId#cc5d86f2-0013-489e-b7d7-3573eaf91135</SystemID><Ontology>http://www.carethings.com/ontology/mainInteraction</Ontology><Interactions><Interaction><ID>http://www.carethings.com/userId#Q1</ID><Text>Main</Text><Ontology>http://www.carethings.com/ontology/interaction#Internal</Ontology><TextResource>http://www.carethings.com/resource/utterance#Desktop.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#35a5dd4b-0cf1-4ac5-aee5-1abb1772b35a</SystemID><Navigation>NAVEXITONLY</Navigation><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Q2</ID><Text>Select The Scenario</Text><Ontology>http://www.carethings.com/ontology/interaction#Internal</Ontology><TextResource>http://www.carethings.com/resource/utterance#SelectScenario.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#0c97ab73-9405-497c-8c4e-193345420a28</SystemID><Navigation>NAVNEXTONLY</Navigation><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>121</TouchX><TouchY>335</TouchY><TouchWidth>65</TouchWidth><TouchHeight>65</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#a6d885c8-0201-496f-8e5e-73d94feeb9c8</SystemID><Type>FixedNext</Type><Label>Lung Disease</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Q3</ID><Text>Select Your Coach</Text><Ontology>http://www.carethings.com/ontology/interaction#Internal</Ontology><TextResource>http://www.carethings.com/resource/utterance#SelectCoach.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#a8e40d81-2420-4a8e-bb04-938f8a4d7124</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>357</TouchX><TouchY>275</TouchY><TouchWidth>116</TouchWidth><TouchHeight>116</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#11739ed2-51f3-463a-b33d-9c49e471baad</SystemID><Type>FixedNext</Type><Label>Female A</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><PostBehaviors><Behavior>http://www.carethings.com/postbehavior/userBehavior#selectFemaleCoachA</Behavior></PostBehaviors></Response><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>497</TouchX><TouchY>275</TouchY><TouchWidth>116</TouchWidth><TouchHeight>116</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#794724cb-bc43-4563-9238-395b12a0236d</SystemID><Type>FixedNext</Type><Label>Female B</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><PostBehaviors><Behavior>http://www.carethings.com/postbehavior/userBehavior#selectFemaleCoachB</Behavior></PostBehaviors></Response><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>357</TouchX><TouchY>409</TouchY><TouchWidth>116</TouchWidth><TouchHeight>116</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#09319c6b-354c-46ad-aeba-b0f5bb1b5d5d</SystemID><Type>FixedNext</Type><Label>Male A</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><PostBehaviors><Behavior>http://www.carethings.com/postbehavior/userBehavior#selectMaleCoachA</Behavior></PostBehaviors></Response><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>497</TouchX><TouchY>409</TouchY><TouchWidth>116</TouchWidth><TouchHeight>116</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#b3064ae6-cddd-4823-8f79-aa0ae12fe728</SystemID><Type>FixedNext</Type><Label>Male B</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><PostBehaviors><Behavior>http://www.carethings.com/postbehavior/userBehavior#selectMaleCoachB</Behavior></PostBehaviors></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Q4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#TellUs.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#44c85b46-9b7e-476c-a0fb-ea4e0cddbf75</SystemID><Type>InterrogativeUnstructured</Type><Responses><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>398</TouchX><TouchY>289</TouchY><TouchWidth>384</TouchWidth><TouchHeight>62</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#5ab1913f-d2b0-432b-9658-e4525ada1191</SystemID><Type>FreeFixed</Type><Label>ID</Label><LabelResource/></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Q5</ID><Text>Type of Encounter</Text><Ontology>http://www.carethings.com/ontology/interaction#Internal</Ontology><TextResource>http://www.carethings.com/resource/utterance#EncounterType.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8ab83c92-01b0-47e2-ab3e-e3207cac3cba</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>339</TouchX><TouchY>254</TouchY><TouchWidth>65</TouchWidth><TouchHeight>65</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#90cad5c4-894a-4ffc-9c29-cca1512ee82b</SystemID><WorldModel><Fact>(avatar encountertype levelone)</Fact></WorldModel><Type>FixedNext</Type><Label>Level One</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>339</TouchX><TouchY>354</TouchY><TouchWidth>65</TouchWidth><TouchHeight>65</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#19556804-d1dd-4d2e-9ccc-f9eff24e1512</SystemID><WorldModel><Fact>(avatar encountertype leveltwo)</Fact></WorldModel><Type>FixedNext</Type><Label>Level Two</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><RenderingHint><TouchArea><TouchX>339</TouchX><TouchY>450</TouchY><TouchWidth>65</TouchWidth><TouchHeight>65</TouchHeight></TouchArea></RenderingHint><SystemID>http://www.carethings.com/sysId#f1820ce8-a806-4db8-a4e5-20a31d642dc1</SystemID><WorldModel><Fact>(avatar encountertype levelthree)</Fact></WorldModel><Type>FixedNext</Type><Label>Level Three</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro1</ID><Text>Hi! It is so nice to see you again! We are so glad that you joined us today.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#fba9ef59-f9e0-4da7-b621-576d1844acb3</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro2</ID><Text>I'm going to be your coach today.  That means I am here to help guide you</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#37e41c57-ccc5-466f-985d-0a7edf8e373d</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro3_D</ID><Text>I'm going to take you over to the receptionist who you will begin your visit with today</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#b7a73e90-a953-4cf4-b59e-8c8873efe89b</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#805d2df5-2846-4dc5-a43d-5841ddd4ca79</SystemID><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#84cb71ff-caa3-45e3-91d8-9216119f3073</SystemID><Type>FixedNext</Type><Label>Ok</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro4_D</ID><Text>How are you today? Do you have an appointment?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#receptionist_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#02ddfd41-805e-4764-8600-0348bf36d414</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#receptionist_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#c4ee26aa-cf8a-474a-8967-017d53dd110b</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#37e9605d-9977-45e7-a341-bc6c77fbace6</SystemID><Type>FixedNext</Type><Label>Yes, I have an appointment</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#d1afbaa9-61d7-4fcf-91cc-e55c8d2ef27f</SystemID><Type>FixedNext</Type><Label>Yes, I think I have an appointment</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro5</ID><Text>Ok. You can have a seat and we will be with you soon</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#receptionist_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#bebaefa1-1a3e-4849-94d1-560e964a31d8</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro6</ID><Text>Sitting waiting for the assistant</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#patient_location_waitingroom.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#53e3ce11-29a9-4727-9eee-e8cf733de7dd</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#Intro7</ID><Text>Hello, please follow me to the exam room</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#patient_encounter_assistant.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#dbfb0065-260b-43f4-a7a2-e73a8802a9bb</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A1</ID><Text>I am your doctor's medical assistant today</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#1804c167-a43b-426e-99bc-6ebecdcb6ff3</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A2_D</ID><Text>I will take your vital signs, ask you a few questions and then the Doctor will see you.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#5b4e18c9-acea-417c-909e-291d14cae78b</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A2</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#0102cf3a-bbc7-46db-99a9-ed27b2579449</SystemID><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#01210ffe-d872-4781-8d2a-0ddfd3263e80</SystemID><Type>FixedNext</Type><Label>Ok</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#A3_D</ID><Text>I see you have a diagnosis of lung cancer. Did you smoke?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#dbcf4101-46c5-490c-bfa4-38c33b8c64d5</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#47f463c3-c00b-4c70-b71f-f6db7edce87f</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#cc4630d3-08f6-451f-8d39-36f7567fd92c</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A4_D</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#d6535a1b-38de-4c2f-bc20-c00b285a6793</SystemID><Type>FixedNext</Type><Label>No and I am sick of being asked that and I hate that it is always the first question</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A5_D</SkipTo></Response><Response><ID/><Code>2</Code><SystemID>http://www.carethings.com/sysId#e7ce8f64-7d7f-46d2-ad82-67b841ce3e4c</SystemID><Type>FixedNext</Type><Label>No I was never a smoker</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A7</SkipTo></Response><Response><ID/><Code>3</Code><SystemID>http://www.carethings.com/sysId#73e5dae2-25bf-455a-973f-24b82f6c6192</SystemID><Type>FixedNext</Type><Label>Yes but I quit years ago</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A6_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#A4_D</ID><Text>Are you sure?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#a5138006-69ed-46ba-a3dd-76a0ac52b203</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#677edf05-2f79-4a09-9623-463f5fbfeb06</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#5617b97d-d5ee-457c-9c84-081b9dd68467</SystemID><Type>FixedNext</Type><Label>Yes, I'm sure</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A7</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#A5_D</ID><Text>I'm sorry, I just assumed that if you have lung cancer you must have smoked.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#53d354fe-759f-4ab5-a4b3-2f4890b9fa0d</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A5</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#2cb7fc48-174d-49b5-ab3a-37e50c9e7a72</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#e1595b2f-cd24-4556-aeff-43d88a6d821b</SystemID><Type>FixedNext</Type><Label>That's a common assumption but it is not true. There are many causes of lung cancer and anyone can get lung cancer.</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#A7</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#A6_D</ID><Text>Oh really? Exactly how long ago? Usually if you quit you don't get lung cancer</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8b894a16-bef3-49c1-9d1c-536db5280a0f</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A6</ID><Text>There are a lot of myths about lung cancer and that is one of them. You can still get lung cancer after quitting. You reduce your risks, but you can still get it.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#546c6624-d3ba-4ff0-bf0d-2e192968d7d3</SystemID><Type>Declarative</Type></Interaction><Interaction><ID>http://www.carethings.com/userId#A7</ID><Text>Jump to Assistant Poor</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource/><Directive/><SystemID>http://www.carethings.com/sysId#0fceb274-325b-47de-8221-4c52eb5e81ce</SystemID><SkipTo>http://www.carethings.com/userId#AP1_D</SkipTo><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>Imperative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A8</ID><Text>Jump to Assistant OK</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource/><Directive/><SystemID>http://www.carethings.com/sysId#54b9a4dd-b9f2-4acf-a728-71b0941eb954</SystemID><SkipTo>http://www.carethings.com/userId#AOK1_D</SkipTo><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>Imperative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#A9</ID><Text>Jump to Assistant Good</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource/><Directive/><SystemID>http://www.carethings.com/sysId#fd4fc8f5-708b-4b89-9b92-4d7104659342</SystemID><SkipTo>http://www.carethings.com/userId#AG1_D</SkipTo><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>Imperative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AP1_D</ID><Text>Do you smoke Now?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#2018b6b5-cb33-480e-b5b8-5b3f27fd9bc0</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AP1</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#4872ff49-77d2-46e3-a30c-82abb9b4577f</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#ee618929-2c78-4978-a282-8032c45c2439</SystemID><Type>FixedNext</Type><Label>Yes</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AP2_D</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#8007162a-bdd1-4715-a0e1-0b29ea75a211</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AP3_D</SkipTo></Response><Response><ID/><Code>2</Code><SystemID>http://www.carethings.com/sysId#afa433d2-6b76-4081-b7b5-a249973eb29a</SystemID><Type>FixedNext</Type><Label>Why do you ask?</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AP4_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AP2_D</ID><Text>How Could you?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#edbfd774-cbcd-4d85-8b11-70b8b73053fa</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AP2</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#c1f9a965-a7e8-46d1-a965-514169a28e59</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#31a74c69-e8e2-4afc-bb3c-9bacd060c741</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#deb1b714-69d4-4fc7-a0d9-2759c30d7760</SystemID><Type>FixedNext</Type><Label>Oh, I have tried so many times</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#92283149-209d-4caf-ac2d-99f78476b253</SystemID><Type>FixedNext</Type><Label>I know it must not make sense to you, but that really hurts my feelings</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AP3_D</ID><Text>Looks like you should have quit sooner</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#9fd408a9-0897-4b3d-bad4-3be8255bfcb7</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AP3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#c8145699-8875-4888-9bfc-00c7ed0e16e4</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#66f5c5a6-8f3b-4023-9f12-bfda1e9ef817</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#96e29dfe-ed42-4ee0-b581-bebba36d52e7</SystemID><Type>FixedNext</Type><Label>Yes I quit</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#30995dd0-d380-4a68-ad06-2a7860affdde</SystemID><Type>FixedNext</Type><Label>That hurts my feelings. People who never smoked and people who quit 30 years ago can get lung cancer</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AP4_D</ID><Text>Because smoking causes lung cancer</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#3aa7b7de-062b-46d9-9ec8-1e164b9e1f8f</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AP4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#df732862-05a7-4517-bffa-391e8546cfbc</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#7b433c2e-f24d-46e7-9188-a47a9a5d626e</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#b53f7239-73c8-4a0b-b1ff-db32f9962a5a</SystemID><Type>FixedNext</Type><Label>Yes, I still smoke</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#8ef6d601-71d3-4ad9-8e7f-82d31142520f</SystemID><Type>FixedNext</Type><Label>It's none of your business, I'll talk to the doctor</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#fb398f77-0e48-48c7-815f-a0961ec7d9ba</SystemID><Type>FixedNext</Type><Label>It is not my fault. Lots of things cause lung cancer. No one deserves lung cancer.</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#94ca5233-adef-4f84-828c-e8c6ef9a572f</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#fb34e026-7e72-4248-959e-b365f77a07fe</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_C</ID><Text>Oh I'm sorry I didn't mean to hurt your feelings</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#4b333510-3662-4daa-8ad9-5486305e5490</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_D</ID><Text>I will tell the Doctor and we will come up with a plan that works for you</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#b7613b0d-ab59-4aae-ab5e-4538dc36d909</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#eb332234-ac4c-4122-b291-2e4da12ec6bc</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#0a8a3fc6-22dd-4a84-a35d-196d1b62f875</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_C</ID><Text>I'm sorry, you're right anyone can get lung cancer for lots of different reasons.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f7ca0656-a42b-4e6f-ab61-709340954235</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_D</ID><Text>Can you tell me more about that, is there anything you need to help you stay successful?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#5a4be249-229c-4c33-863f-4c099e3d2cc7</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_E</ID><Text>Sure, cessation is a huge accomplishment</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#b25ff792-266c-4eea-a39d-b7fc27751737</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_A</ID><Text>Yes</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#640c9eee-a775-4255-a81e-cc39f19c7bff</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_B</ID><Text>Well you need to quit</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#384265b5-d8ec-4568-a7fa-c91ccc1f117b</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_C</ID><Text>Fine</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#c44dad72-863b-45f7-b755-65aea78f5ada</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_D</ID><Text>You're right - Are you interested in quitting? We can help. Nicotine is a powerful addiction and quitting is hard but don't give up. Lots of people try 2 or 3 times before they quit for good. The more times you try to quit the more likely you will be to succeed.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#dffa0fac-2134-46bd-8d5d-ef866ed69ba9</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_E</ID><Text>Silence</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#e7b9334c-e5ac-43be-92be-22096d1f0749</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK1_D</ID><Text>Do you smoke Now?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#3a9737cc-81ee-494f-bcae-3f26f80cb4a3</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK1</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#08827f87-65bb-4e51-b719-743627d38855</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#a3c6e6e2-5744-4975-bf41-cf6e9179ffeb</SystemID><Type>FixedNext</Type><Label>Yes</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AOK2_D</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#2a5575f6-f3f0-4a6c-aa43-da448944b004</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AOK3_D</SkipTo></Response><Response><ID/><Code>2</Code><SystemID>http://www.carethings.com/sysId#43c2ef8b-039b-449d-8517-29f30342ac07</SystemID><Type>FixedNext</Type><Label>Why do you ask?</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AOK4_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK2_D</ID><Text>Seriously ok</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#bd48f090-8155-4566-b91a-116298da2c49</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK2</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#481013ce-642b-472b-9633-2eab44459430</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#88bc055f-d0ec-4496-b537-eaf167e9c257</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_A</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#d6ef200d-2329-4c66-ae08-b02e20f08d2d</SystemID><Type>FixedNext</Type><Label>Oh, I've tried so many times</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_B</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#dafe4e03-6411-447a-8fd8-23873f43eed6</SystemID><Type>FixedNext</Type><Label>I know it must not make sense to you, but that really hurts my feelings</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_C</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK3_D</ID><Text>Well, at least you quit</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#386aa97d-2093-448e-b2bf-2437752a6827</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#a843154c-590c-4e86-9523-50d9743631c2</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#b80b79cb-1569-4500-966f-00ee7ea65cb2</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_A</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#e594e682-095e-4e3c-8113-39c5676810a8</SystemID><Type>FixedNext</Type><Label>Yes I quit</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_B</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#76a6657f-b02b-4de0-b15f-75cf48f2454d</SystemID><Type>FixedNext</Type><Label>Yes, it's tough</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK4_D</ID><Text>It's on my form</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#77b2714c-78e3-48b5-8424-7fdeffd9e318</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AOK4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#4ad2141e-310d-40ec-a45c-9457ae2f9ed4</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#88fe1d02-1f00-49aa-bc99-90bb72f6f5c7</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_A</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#f981fa5f-e02b-49fe-8fb1-9736777cc115</SystemID><Type>FixedNext</Type><Label>Yes, I still smoke</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_B</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#5a1c793a-d71c-4187-8da7-308428982a60</SystemID><Type>FixedNext</Type><Label>It's none of your business, I'll talk to the doctor</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_C</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#903d9209-46b0-4cf2-829d-c3131c209d60</SystemID><Type>FixedNext</Type><Label>It is not my fault. Lots of things cause lung cancer.</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#24a4080c-af3c-451b-aef1-ab4075c3903e</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#e66dc05c-b55b-4c92-9559-c1d4974eafad</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_C</ID><Text>Oh I'm sorry I didn't mean to hurt your feelings</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#17175372-7ec5-41e3-8215-aa424c2ba0da</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_D</ID><Text>I will tell the Doctor and we will come up with a plan that works for you</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f74bceef-9cae-4a2d-82a9-8937075f4d71</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#9fa4d5e3-9f54-402c-a5d0-4276ac3f8057</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#07ca97f1-edd1-4b93-8a5c-b9fa7a7ce03b</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_C</ID><Text>I'm sorry, you're right anyone can get lung cancer for lots of different reasons.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#c2c66aa6-e985-437f-ad46-9022d7f1c6ae</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_D</ID><Text>Can you tell me more about that, is there anything you need to help you stay successful?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#6a38dfa2-f3ec-44a5-a810-956a2d70f85c</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_E</ID><Text>Sure, cessation is a huge accomplishment</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#0419a620-fbe8-4bad-8464-3023dcad4657</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_A</ID><Text>Yes</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#9ea3427a-7510-4283-b012-ec237d5e33ee</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_B</ID><Text>Well you need to quit</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#d32e8e04-5bc2-41e0-99bc-f70fb3d1bd3d</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_C</ID><Text>Fine</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#03ce91fc-b0e8-48ad-ad6e-308f50a47618</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_D</ID><Text>You're right - Are you interested in quitting? We can help. Nicotine is a powerful addition and quitting is hard but don't give up. Lots of people try 2 or 3 times before they quit for good. The more times you try to quit the more likely you will be to succeed.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#e775f9b9-d5d5-440a-ab50-69ad4606f60c</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_E</ID><Text>Silence</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f95e482c-f41b-4afe-8946-ba53122511d7</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AG1_D</ID><Text>Do you smoke Now?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#ba309e87-ec03-4746-adaa-ec3792a3d67d</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AG1</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#ce82772e-0844-438a-ab9f-f73a752f03b4</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#c55d2b58-48f8-443b-b2cc-007ce5f02ffa</SystemID><Type>FixedNext</Type><Label>Yes</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AG2_D</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#87665e52-9240-46c6-a087-7e32b3709c1c</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AG3_D</SkipTo></Response><Response><ID/><Code>2</Code><SystemID>http://www.carethings.com/sysId#a65caa0b-a07a-4e5b-ae23-99efd77b88f6</SystemID><Type>FixedNext</Type><Label>Why do you ask?</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AG4_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AG2_D</ID><Text>Smoking is a rough addition to quit. But we will do everything we can to help you</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#a42fff66-8890-4e0d-9c74-fae1d46cfdab</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AG2</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#ab968bbc-2c68-46b3-91b7-50708e579d64</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#f1c58300-814b-47ab-8cc3-a655ab4760e3</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_A</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#36b4ab4c-8e1f-4ef5-b668-ba232bc7b030</SystemID><Type>FixedNext</Type><Label>Oh, I've tried so many times</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_B</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#d9794142-851a-4dbf-8593-9f9296addcc6</SystemID><Type>FixedNext</Type><Label>Oh Good</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Yes_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AG3_D</ID><Text>Great. It's not easy to quit smoking</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#1a076a30-81ea-491d-9d91-68d64007523b</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AG3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#27aed5a9-6797-447f-b978-edc09ddd7a72</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#79000904-2f23-4d5c-9bc0-ed0c44278594</SystemID><Type>FixedNext</Type><Label>Yes, it's tough</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#50de752f-8d2e-4198-9bdc-7744c7cdf720</SystemID><Type>FixedNext</Type><Label>I'm sick of being asked!</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_E</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#0e0f836f-25af-4bea-8727-d27c6a3343f0</SystemID><Type>FixedNext</Type><Label>I appreciate your saying that</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_No_F</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AG4_D</ID><Text>I'm sorry, I bet you get tired of being asked that question</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#7e604d42-08d6-4997-9c20-5c8ac5187dd6</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AG4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>When you encounter what feels like a negative attitude or stigma, whether the person intended it to be negative or not, try and remember this person lacks knowledge. Stay calm and try and inform when you can. Try not to respond with silence. Remember ask for what you need. Know the facts.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#CoachDidYouSmoke.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#9bee145a-09b0-4b45-836a-17a88397a423</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#6ebf3e3c-5a32-4361-b030-b1fb45440375</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_A</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#fc490c37-9f28-467c-b878-7641dde23aae</SystemID><Type>FixedNext</Type><Label>Yes, I still smoke</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_B</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#ccc14ed3-070a-4be9-8cca-9888b7db689d</SystemID><Type>FixedNext</Type><Label>It is not my fault. Lots of things cause lung cancer. No one deserves cancer</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#67966d8d-085a-4714-bf21-c80c4ca34f24</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#ARP_Why_E</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#262e000f-d9e7-4214-9622-a7458a5894b0</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#17cfa57d-c3b1-4baa-ad76-650510d47745</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_C</ID><Text>Oh I'm sorry I didn't mean to hurt your feelings</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#13057f55-2154-465c-b7c8-f88604db3eb7</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Yes_D</ID><Text>I will tell the Doctor and we will come up with a plan that works for you</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#153b8dbc-14a8-46e9-b0ba-c42f2601c77a</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_A</ID><Text>Oh well, the damage is done</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#fbe30b4c-834c-4d83-bb02-74753c81791b</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_B</ID><Text>Hmmmm</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#1ab48422-55fe-4837-a050-ed96f2996c83</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_C</ID><Text>I'm sorry, you're right anyone can get lung cancer for lots of different reasons.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#9c6fe8aa-cfb1-4f93-bdc2-a00d6aea865d</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_D</ID><Text>Can you tell me more about that, is there anything you need to help you stay successful?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#7e7b7f20-a385-44e1-b7aa-2965623478b8</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_No_E</ID><Text>Sure, cessation is a huge accomplishment</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#6cb70b53-fe36-4989-be5d-3df250a3ff3b</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_A</ID><Text>Yes</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#14fca68b-71a9-4cbe-98a9-aa832406476a</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_B</ID><Text>Well you need to quit</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#85f4d0d3-296e-4d4b-9f43-7fc124f545c5</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_C</ID><Text>Fine</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#6ac77261-e7c6-4b6e-a8a4-9a935dc47ddf</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_D</ID><Text>You're right - Are you interested in quitting? We can help. Nicotine is a powerful addition and quitting is hard but don't give up. Lots of people try 2 or 3 times before they quit for good. The more times you try to quit the more likely you will be to succeed.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#02cd7a9e-1533-4754-ad05-b70df82018d4</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#ARP_Why_E</ID><Text>Silence</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#d15ec2f4-bee1-4945-902b-22f1717d45fe</SystemID><SkipTo>http://www.carethings.com/userId#AC1_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC1_D</ID><Text>Do you know what type of lung cancer you have?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#ffac215e-0f69-4c8e-99c0-ff99ac43ca23</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC1</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#fc26b04d-3e0e-4c48-b605-0380b4d03ca9</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#9445d8ca-3709-4f9f-878e-aba951c27c1a</SystemID><Type>FixedNext</Type><Label>Non-small cell lung cancer</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#96b01bc3-d1cd-4535-b574-e2df2bfd2888</SystemID><Type>FixedNext</Type><Label>Large cell carcinoma</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#d79f5ccf-26f9-4a99-a003-37dc3eab668b</SystemID><Type>FixedNext</Type><Label>Other</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#5ff8296d-979d-4e46-a782-36ff223f45ea</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC3_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC2_D</ID><Text>Do you know the sub type?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#00277101-918a-4f3b-9930-21fc2cb23e0f</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC2</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#de26b21d-2f6c-429d-87b5-c68e14bd3265</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#2e78d222-57ae-4abd-ac12-6bf47b977773</SystemID><Type>FixedNext</Type><Label>Adenocarcinoma</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#cb8e3d1f-22fb-4b5d-88c3-5339a4ea2dc7</SystemID><Type>FixedNext</Type><Label>Squamous cell</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#92ed3f7a-2062-4419-8e24-85d9590a5d0c</SystemID><Type>FixedNext</Type><Label>Large cell</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#9f2afaef-4c2c-4bd1-8eb6-16533daf17b5</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC3_D</ID><Text>Do you know the stage of your lung cancer?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#a20c5ac7-0fe8-41d0-b1bd-bc5cc56a73d7</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC3</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#c7991574-9700-43d1-ad04-976b9f1d758e</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#ee6f806b-a2da-4d09-a393-285bbbf8c8b8</SystemID><Type>FixedNext</Type><Label>Stage I</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#9916c0f9-845c-41e2-82cc-537a7effd14b</SystemID><Type>FixedNext</Type><Label>Stage II</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#849667f8-126e-4565-b0af-87e093a0007c</SystemID><Type>FixedNext</Type><Label>Stage III</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#bd67ff51-7e87-428d-99bd-9ef52612fc11</SystemID><Type>FixedNext</Type><Label>Stage IV</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#0e9bbf89-0dbf-4613-ab5a-08f3ce140e89</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC4_D</ID><Text>What steps have you taken to give you more information to consider your treatment options?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#78088a13-799a-4de9-bd66-0ba092c758f4</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC4</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive><Instruction>In order to receive the best treatment possible you need to be informed. Know all you can about your diagnosis, your options, and your treatment.</Instruction><InstructionResource>http://www.carethings.com/resource/utterance#KnowYourOptions.png</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#14c2a9f1-833c-40b4-a17f-e2f7b7b0629f</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#d8381273-75d4-4a5e-80da-d03c077f3479</SystemID><Type>FixedNext</Type><Label>CT</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#9874d7cf-6304-412e-8b38-5c5272177b6c</SystemID><Type>FixedNext</Type><Label>PET</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#d5f54407-5911-4c88-9e17-ee5bc7874c5b</SystemID><Type>FixedNext</Type><Label>Bronchoscopy</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#2c10afda-a0e7-49ba-ac3d-f595c7d2963f</SystemID><Type>FixedNext</Type><Label>Endobronchial Ultra Sound (EBUS)</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#8a5b3c4e-6649-494b-bc13-bf6e7a14cb75</SystemID><Type>FixedNext</Type><Label>Bone Scan</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#294ed584-e5e8-4325-9bea-0aee203bc317</SystemID><Type>FixedNext</Type><Label>MRI</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#29384c06-3007-4c02-a510-b21aa2897a94</SystemID><Type>FixedNext</Type><Label>None</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#593026cb-8f92-445b-9a0c-738ff5ba48d0</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC5_D</ID><Text>Have you chosen your treatment plan?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#4c1e6d20-1790-408f-86dc-8a17c7359ea4</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC5</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#fed030a7-0732-4220-bd3d-4d80b884d09e</SystemID><Type>InterrogativeMultipleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#9134db6e-5663-4a9d-a040-f35e78730ccd</SystemID><Type>FixedNext</Type><Label>Chemotherapy</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#443bf46f-0156-401f-8134-baf677a4981c</SystemID><Type>FixedNext</Type><Label>Radiation</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#82a24a05-0ff0-476c-8d84-c2b03b2e150b</SystemID><Type>FixedNext</Type><Label>Surgery</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#65b3315d-de36-46ea-9a79-c3c1ca1d272b</SystemID><Type>FixedNext</Type><Label>Clinical Trial</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#3d82be7d-3c6e-4569-a168-7969b956f78c</SystemID><Type>FixedNext</Type><Label>Combination</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC6_D</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#0e392b9a-3061-44ce-9be7-2f1573956f05</SystemID><Type>FixedNext</Type><Label>None</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#bfab6484-6ebb-4de4-923f-8367525fc49a</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#AC7</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC6_D</ID><Text>Which combination of treatment?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#65ad92ab-2c51-48d8-9e67-b2a5f4500433</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#AC6</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#24d6b066-4c5a-4b64-8885-cd1922de3d21</SystemID><Type>InterrogativeSingleSelect</Type><ResponseRequired>YES</ResponseRequired><Responses><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#882c6bbc-f789-4711-a14a-3ce9b6fe2de1</SystemID><Type>FixedNext</Type><Label>Surgery and chemotherapy</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#b76a4ae6-4514-4ff7-b71a-18c940581176</SystemID><Type>FixedNext</Type><Label>Surgery and radiation</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#fdee6200-368b-472e-bdff-3c8421f8a4ca</SystemID><Type>FixedNext</Type><Label>Chemotherapy and radiation</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response><Response><ID/><Code/><SystemID>http://www.carethings.com/sysId#8dbe446f-52d4-42e6-9508-e2961289e203</SystemID><Type>FixedNext</Type><Label>I don't know</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#AC7</ID><Text>OK. The doctor will be in to see you shortly</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#assistant_pose_1.jpg</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#97cd50c9-65ae-42f0-b7ec-2b75b9c7bb4d</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE1_Coach</ID><Text>Cancer and its treatment can cause a variety of side effects but in  recent years, major strides have been made  in reducing pain, nausea and vomiting, and other physical side effects of cancer treatments.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#e7c5ff28-bb80-4727-bae2-d7776d5aa6bc</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE2_Coach</ID><Text>Many treatments used today are less intensive but as effective as treatments used in the past. Doctors also have many ways to provide relief to patients when such side effects occur. Fear of side effects is common after a diagnosis of cancer, but it may be helpful to know that preventing and controlling side effects is an important goal.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f78e551c-8362-4510-8ee6-8846f7b3a6e3</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE3_Coach</ID><Text>Before treatment begins, talk with your doctor about possible side effects of the specific treatments you will be receiving.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#265acef8-51d9-4662-82dd-efca51041be2</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE4_Coach</ID><Text>The specific side effects that can occur depend on the type of cancer, its location, the individual treatment plan (including the length and dosage of treatment), and your overall health.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#84d3173d-5913-4fb5-aa16-71b8f073aa63</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE5_Coach</ID><Text>Be sure to tell your doctor about side effects you experience during and after treatment. Care of a patient's symptoms and side effects is an important part of a person's overall treatment plan.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#dea25c40-a447-4138-b162-44edf6d81008</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE6_Coach</ID><Text>Be sure to talk with your doctor about the level of caregiving you may need during treatment and recovery, as family members and friends often play an important role in the care of a person with lung cancer.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#be513cf3-6c44-4913-8f37-e317a2bbf821</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE7_Coach</ID><Text>In addition to physical side effects, there may be psychosocial (emotional and social) effects as well. For many patients, a diagnosis of lung cancer is stressful and can bring difficult emotions.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#4959bebc-7236-4101-a3f6-c94002c88c3b</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE8_Coach</ID><Text>Patients and their families are encouraged to share their feelings with a member of their health care team, who can help with coping strategies.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#002fff06-5620-4bd7-a4da-b92ec4478e9f</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE9_D</ID><Text>Hi, How are you?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#aa2da8b2-3e1d-4b03-a95e-3eb553ca6a21</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE9</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#d87c5a77-7a8c-4a18-bd85-1f7dc5895fb3</SystemID><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#69ba5173-8360-4b27-850b-1d448c2c4c74</SystemID><Type>FixedNext</Type><Label>I'm fine</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE10</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#cc8737c9-d319-4d3e-a87f-cef9c903d28f</SystemID><Type>FixedNext</Type><Label>I've been having some trouble</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE11</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE10</ID><Text>Great</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#4a7008dc-f96c-45af-8f75-1a467a9bafe7</SystemID><SkipTo>http://www.carethings.com/userId#PE15_D</SkipTo><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE11</ID><Text>Can you tell me more?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8e0d8dac-4ade-423d-ab7f-7a4af6186c56</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE12</ID><Text>Now is the time to tell your doctor if you are experiencing any symptoms such as : * shortness of breath * pain * fatigue * insomnia * appetite loss * sore mouth * tingling or pain in your hands and feet * anxiety  * depression</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#d45e538e-b38e-4475-9dee-772b22e7fcd2</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE13</ID><Text>Describe the symptom : * How often does it occur  - Seldom orOften? * On a scale of 1-5 (5 is most severe) how severe is your symptom? * On a scale of 1-5 (5 is most distressing) how distressing to you is this symptom?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#37d19222-cf59-44d6-be69-f956af975406</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE14</ID><Text>Ask questions:  * How can I get relief? * What can I do? * Are there treatments or medications? * Will this go away when the treatment is over? * What should I expect?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f980c2e9-573e-4c37-a87f-3c9db6cb2cdd</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE15_D</ID><Text>Is there anything else you would like to discuss?</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#891e1b5b-ba18-456b-bf93-447f9e858617</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE15</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8bc15a23-8e29-4a22-8187-94ff7ccc620c</SystemID><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#855db90d-8cfa-4640-8d88-605416e45c67</SystemID><Type>FixedNext</Type><Label>Yes</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE16_Coach</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#6706e902-d94a-4df1-a27b-03201764d1ce</SystemID><Type>FixedNext</Type><Label>No</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>2</Code><SystemID>http://www.carethings.com/sysId#4932b844-4d89-44aa-b30c-e53ea7787d71</SystemID><Type>FixedNext</Type><Label>Doctor, I don't know how I am going to pay for all this</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE22_D</SkipTo></Response><Response><ID/><Code>3</Code><SystemID>http://www.carethings.com/sysId#e3b1b958-4476-4ca3-aabc-fb8d0142a53b</SystemID><Type>FixedNext</Type><Label>Doctor, how do I know when to stop treatment</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE29_D</SkipTo></Response><Response><ID/><Code>4</Code><SystemID>http://www.carethings.com/sysId#ac574ff3-9c4b-481a-bd77-8fbd0bd78ad5</SystemID><Type>FixedNext</Type><Label>Can you tell me my prognosis/How long I have</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE28_D</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE16_Coach</ID><Text>Research has reported that often times lung cancer patients feel that their doctors avoid discussing several topics: financial worries, prognosis, and end of life care.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#f44c310d-cafe-4cef-af73-a6d368c0b029</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE17_Coach</ID><Text>If you have questions that fall under any of these categories, you may want to take a moment and think of the questions that are important to you.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8c2bde2d-7d78-4cef-991e-b7c390e04056</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE18_Coach</ID><Text>The cost of treatment depends on several things: what kind of insurance you have; what type of treatment you have;  and where you get your treatment.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#16fe8b84-adc3-443b-a3d4-fc2de59a75b1</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE19_Coach</ID><Text>Medicare, Medicaid, and most insurance cover most of the cost of most kinds of chemotherapy. Your cancer center or hospital probably has a patient assistance department that can help you find out if insurance will cover what you need or whether you qualify for assistance.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#655e0577-2185-47b6-a5e6-af29f3d2e0c2</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE20_Coach</ID><Text>Or go to www.NationalLungCancerPartnership.org see their Living with a Diagnosis of Lung Cancer Financial Assistance. So take a moment and write down that website.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#8f19b16c-0dcc-4861-b7de-08a576b2d32b</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE21_Coach</ID><Text>Just like you have a right to ask and talk about the start of treatment. You have a right to express your concerns about stopping treatment. You and your Doctor can decide together when you have enough information to have that discussion.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#coach_pose_2.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#0dcf6023-6057-4d57-a240-c79408c8d908</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE22_D</ID><Text>Don't worry about that now</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#403302b2-d634-4b8d-baf7-ee930db4c627</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE22</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#1d2854b1-d9f0-4bd4-a33c-852a3000e150</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#6749fff3-5a04-423b-9554-90e776b1792a</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#847d5e75-84af-4cd8-b882-cb0b56389f88</SystemID><Type>FixedNext</Type><Label>But Doctor, -- I AM worried about it</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE23_D</ID><Text>I'm afraid we don't have time for that now</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#c70e2df9-c158-428c-8079-cb5801b3ac9e</SystemID><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE23</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#23fe7655-d0fb-40dc-bcc4-f20c999e8168</SystemID><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#284c200a-9f72-453c-b4ca-bd8597a9eeb7</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#b5e7211f-7f72-4279-a3a8-8766f7107ec8</SystemID><Type>FixedNext</Type><Label>I understand you are busy, but who do you suggest I talk to?</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE24_D</ID><Text>Money and insurance can be a real worry. I will set up an appointment for you right now with our social worker</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#b3389f5a-e50f-4c4b-b296-461908b60eee</SystemID><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE24</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#5cd7de42-e391-4d82-bc71-b7439f079358</SystemID><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#7f7d1ef4-cc6d-4177-81bb-ed35e081a78f</SystemID><Type>FixedNext</Type><Label>Thank-you that would be great</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE25_D</ID><Text>Don't worry about that now</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#18130c6f-1a78-4467-be6e-5d45cc548bf6</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE25</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#39318c22-71bf-4418-b356-6d4ab9495aa3</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#e5bf81e4-5980-47ba-9fb4-b0a00067c0e1</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#84d6a58b-d75c-43e8-81cd-8c0d318f72eb</SystemID><Type>FixedNext</Type><Label>I am worried about it and I would like to talk about the possibilities</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE26</ID><Text>We have too many things to try before we talk about that</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#0690c645-0d37-4134-b044-8b7d7e8e2840</SystemID><SkipTo>http://www.carethings.com/userId#PE32</SkipTo><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE27_D</ID><Text>We will monitor your progress closely, with each new piece of information we have about your health, comfort, and response to treatment, we will make plans for the next step together.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#69a2c939-55ad-405d-9d32-0097537109c0</SystemID><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE27</ID><Text>We will monitor your progress closely, with each new piece of information we have about your health, comfort, and response to treatment, we will make plans for the next step together.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#7926a615-7d8d-4b13-95a1-1ef49fccc2db</SystemID><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#c59531bc-5375-41d7-92c2-92f0e1926249</SystemID><Type>FixedNext</Type><Label>Ok, I will keep asking questions. Thanks.</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE28_D</ID><Text>Long enough</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#33185ad2-b003-4260-9e47-819637984784</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE28</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#10d874c4-f326-40cb-853d-e17c9b9d2c0f</SystemID><Active><Rule>(avatar encountertype levelone)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#1c1e61ae-96cb-4f60-82ab-b6007f77f0b5</SystemID><Type>FixedNext</Type><Label>What does that mean?</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#86f0cfce-190d-458b-aaa5-9429cd599d30</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE29_D</ID><Text>Don't worry about that now. Just do your treatment</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#f8ff1654-6931-4de0-abcf-746d981f874d</SystemID><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE29</ID><Text/><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive><InstructionResource>http://www.carethings.com/resource/utterance#CoachStatistics.jpg</InstructionResource></Directive><SystemID>http://www.carethings.com/sysId#4c271e9a-0326-4506-8e10-279fe67983a7</SystemID><Active><Rule>(avatar encountertype leveltwo)</Rule></Active><Type>InterrogativeSingleSelect</Type><Responses><Response><ID/><Code>0</Code><SystemID>http://www.carethings.com/sysId#1de76a79-9bc9-4e0f-8948-111d0714b2c3</SystemID><Type>FixedNext</Type><Label>But I am worried</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response><Response><ID/><Code>1</Code><SystemID>http://www.carethings.com/sysId#9539464f-25b6-4900-a4e9-c749038d3e2a</SystemID><Type>FixedNext</Type><Label>Silence</Label><LabelResource/><RenderingHint><ControlType>Button</ControlType></RenderingHint><SkipTo>http://www.carethings.com/userId#PE32</SkipTo></Response></Responses></Interaction><Interaction><ID>http://www.carethings.com/userId#PE30</ID><Text>Chances of being cured of lung cancer really depend on the stage of lung cancer you have. Early cancer is the easiest to treat.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#892ec43c-78c4-4ec7-981b-4b08c7510d12</SystemID><Active><Rule>(avatar encountertype levelthree)</Rule></Active><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE31</ID><Text>In later stages, if the cancer has spread, the goal of treatment will be to keep it under control for as long as possible with the best quality of life possible. We can often do this with chemotherapy and/or radiation therapy.</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource>http://www.carethings.com/resource/utterance#careprovider_pose_1.png</TextResource><Directive/><SystemID>http://www.carethings.com/sysId#ae9fbdd9-d216-4ffb-b94b-3a2ac4c5429a</SystemID><Type>Declarative</Type><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#PE32</ID><Text>FinalIteraction</Text><Ontology>http://www.carethings.com/ontology/interaction#ClinicalData</Ontology><TextResource/><Directive/><SystemID>http://www.carethings.com/sysId#9060fa4b-60f1-418e-9632-457cacdd0d33</SystemID><Type>Imperative</Type><Behaviors><Behavior>http://www.carethings.com/behavior/pre/userBehavior#finalInteraction</Behavior></Behaviors><Responses/></Interaction><Interaction><ID>http://www.carethings.com/userId#iFinalInteraction</ID><SubQuestion>Yes</SubQuestion><Text/><Type>Imperative</Type><Behaviors><Behavior>http://www.carethings.com/userPlugin/userBehavior#finalInteraction</Behavior></Behaviors></Interaction></Interactions></Intervention></Interventions></ClinicalPathway>";	
	}
	return pathway;
}

- (void) parseProtocol {
	NSError* err;

    doc_ = [[GDataXMLDocument alloc] initWithXMLString: protocolXml_ options: 0 error: &err];

	if (doc_ == nil) {
		return;
	}

	NSArray* rootEnum = [[doc_ rootElement] children];

	study_ = [OpenPATHContext sharedOpenPATHContext].activeStudy;

	for (GDataXMLElement* rootElement in rootEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"PathwayXMLAuthor"] == NSOrderedSame) {
			[study_ setClinicalPathwayAuthor:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"PathwayXMLVersion"] == NSOrderedSame) {
			[study_ setClinicalPathwayVersion:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyPrimaryResearcher"] == NSOrderedSame) {
			[study_ setStudyPrimaryResearcher:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudySecondaryResearcher"] == NSOrderedSame) {
			[study_ setStudySecondaryResearcher:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyName"] == NSOrderedSame) {
			[study_ setStudyName:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyDuration"] == NSOrderedSame) {
			[study_ setStudyDuration:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailFrom"] == NSOrderedSame) {
			[study_ setStudyEmailFrom:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailTo"] == NSOrderedSame) {
			[study_ setStudyEmailTo:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailSubject"] == NSOrderedSame) {
			[study_ setStudyEmailSubject:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailLogin"] == NSOrderedSame) {
			[study_ setStudyEmailLogin:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailPass"] == NSOrderedSame) {
			[study_ setStudyEmailPass:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailSMTP"] == NSOrderedSame) {
			[study_ setStudyEmailSMTP:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyEmailPort"] == NSOrderedSame) {
			[study_ setStudyEmailPort:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"StudyPrimaryLanguage"] == NSOrderedSame) {
			[study_ setStudyPrimaryLanguage:[rootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"WorldModel"] == NSOrderedSame) {
			NSArray* modelEnum = [rootElement children];

			if ([modelEnum count] == 0) {
				continue;
			}

			study_.studyWorldModel = [NSMutableArray arrayWithCapacity: 1];

			for (GDataXMLElement* factElement in modelEnum) {
				NSString* fact = [factElement stringValue];

				if ([WSStringUtils isNotEmpty: fact]) {
					[study_.studyWorldModel addObject: fact];
				}
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"Interventions"] == NSOrderedSame) {
			interventions_          = [rootElement children];
			interventionsEnum_      = [[BiArrayEnumerator alloc]  initWithArray: interventions_];
        } else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"Goals"] == NSOrderedSame) {
    		goals_          = [rootElement children];
    		goalsEnum_      = [[BiArrayEnumerator alloc]  initWithArray: goals_];
    	} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"Tasks"] == NSOrderedSame) {
    	    tasks_          = [rootElement children];
    	    tasksEnum_      = [[BiArrayEnumerator alloc]  initWithArray: tasks_];
    	} else if ([WSStringUtils caseInsensitiveCompare:[rootElement name] toString:@"Rewards"] == NSOrderedSame) {
    	    rewards_        = [rootElement children];
    	    rewardsEnum_    = [[BiArrayEnumerator alloc]  initWithArray: rewards_];
    	}
	}

	if (interventionsEnum_ == nil) {
		// log error.  Should not happen
	}

	rootProtocolElement_   = nil;
}

- (void) initializeModel {
	protocolXml_ = [self readProtocolXML];

	[self parseProtocol];
}

- (WSSchedule*) decodeScheduleWithXML: (GDataXMLElement*) xml {
	WSSchedule*     schedule = [WSSchedule new];
	NSArray*		scheduleEnum = [xml children];

	for (GDataXMLElement* scheduleElement in scheduleEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[scheduleElement name] toString:@"Week"] == NSOrderedSame) {
			schedule.week = [scheduleElement stringValue];
		} else if ([WSStringUtils caseInsensitiveCompare:[scheduleElement name] toString:@"Day"] == NSOrderedSame) {
			schedule.day = [scheduleElement stringValue];
		} else if ([WSStringUtils caseInsensitiveCompare:[scheduleElement name] toString:@"AtMost"] == NSOrderedSame) {
			schedule.atMost = [scheduleElement stringValue];
		} else if ([WSStringUtils caseInsensitiveCompare:[scheduleElement name] toString:@"TimeRange"] == NSOrderedSame) {
			NSArray* timeEnum = [scheduleElement children];

			for (GDataXMLElement* timeElement in timeEnum) {
				if ([WSStringUtils caseInsensitiveCompare:[timeElement name] toString:@"DateTimeFrom"] == NSOrderedSame) {
					schedule.timeFrom = [timeElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[timeElement name] toString:@"DateTimeTo"] == NSOrderedSame) {
					schedule.timeTo = [timeElement stringValue];
				}
			}
		}
	}

	return schedule;
}

- (WSScheduleEvent*) decodeScheduleEventWithXML: (GDataXMLElement*) xml {
	WSScheduleEvent*	scheduleEvent		= [WSScheduleEvent new];
	NSArray*			scheduleEventEnum	= [xml children];
	
	for (GDataXMLElement* scheduleEventElement in scheduleEventEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[scheduleEventElement name] toString:@"EventId"] == NSOrderedSame) {
			scheduleEvent.eventId = [NSURL URLWithString:[scheduleEventElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[scheduleEventElement name] toString:@"Event"] == NSOrderedSame) {
			scheduleEvent.event = [scheduleEventElement stringValue];
		}
	}
	
	return scheduleEvent;
}

- (void) decodeRoot: (WSUtteranceRoot*) root WithXML: (GDataXMLElement*) xml {
	NSArray* utteranceRootEnum = [xml children];

	for (GDataXMLElement* utteranceRootElement in utteranceRootEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"ID"] == NSOrderedSame) {
			[root setUserID:[NSURL URLWithString:[utteranceRootElement stringValue]]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Schedule"] == NSOrderedSame) {
			[root setSchedule:[self decodeScheduleWithXML: utteranceRootElement]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"ScheduleEvent"] == NSOrderedSame) {
			[root setScheduleEvent:[self decodeScheduleEventWithXML: utteranceRootElement]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"RealTimeConstraints"] == NSOrderedSame) {
			NSArray* constraintsEnum = [utteranceRootElement children];
		
			for (GDataXMLElement* constraintElement in constraintsEnum) {	
				if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Dwell"] == NSOrderedSame) {
					root.rtcDwell = [constraintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Delay"] == NSOrderedSame) {
					root.rtcDelay = [constraintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Speed"] == NSOrderedSame) {
					root.rtcSpeed = [constraintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Schedule"] == NSOrderedSame) {
					[root setSchedule:[self decodeScheduleWithXML: constraintElement]];
				} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"RTC1"] == NSOrderedSame) {
					root.rtc1 = [constraintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"RTC2"] == NSOrderedSame) {
					root.rtc2 = [constraintElement stringValue];
				}
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"SkipTo"] == NSOrderedSame) {
			[root setSkipTo:[NSURL URLWithString:[utteranceRootElement stringValue]]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"SkipToIntervention"] == NSOrderedSame) {
            [root setSkipToIntervention:[NSURL URLWithString:[utteranceRootElement stringValue]]];
        } else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Attractor"] == NSOrderedSame) {
			[root setAttractor:[utteranceRootElement stringValue]];
        } else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"SystemID"] == NSOrderedSame) {
			[root setSystemID:[NSURL URLWithString:[utteranceRootElement stringValue]]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Description"] == NSOrderedSame) {
			[root setDescription:[utteranceRootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"UserValue1"] == NSOrderedSame) {
			[root setUserValue1:[utteranceRootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"UserValue2"] == NSOrderedSame) {
			[root setUserValue2:[utteranceRootElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"UserValue3"] == NSOrderedSame) {
			[root setUserValue3:[utteranceRootElement stringValue]];
	    } else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"PreBehaviors"] == NSOrderedSame) {
		    NSArray* preEnum = [utteranceRootElement children];

			if ([preEnum count] == 0) {
			    continue;
			}

			for (GDataXMLElement* preElement in preEnum) {
				[root addPreBehavior:[preElement stringValue]];
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Behaviors"] == NSOrderedSame) {
		    NSArray* behaviorEnum = [utteranceRootElement children];

		    if ([behaviorEnum count] == 0) {
		      	continue;
		    }

		    for (GDataXMLElement* behaviorElement in behaviorEnum) {
                if ([WSStringUtils caseInsensitiveCompare:[behaviorElement name] toString:@"BehaviorComponent"] == NSOrderedSame) {
                    root.behaviorUserComponent = [behaviorElement stringValue];
                } else {
		            [root addBehavior:[behaviorElement stringValue]];
                }
		    }
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"PostBehaviors"] == NSOrderedSame) {
		    NSArray* postEnum = [utteranceRootElement children];

			if ([postEnum count] == 0) {
				continue;
			}

			for (GDataXMLElement* postElement in postEnum) {
				[root addPostBehavior: [postElement stringValue]];
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Ontology"] == NSOrderedSame) {
			[root setOntology:[NSURL URLWithString:[utteranceRootElement stringValue]]];
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"WorldModel"] == NSOrderedSame) {
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
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Active"] == NSOrderedSame) {
			NSArray* activeEnum = [utteranceRootElement children];

			if ([activeEnum count] == 0) {
				continue;
			}

			//root.activeCondition = [NSMutableArray arrayWithCapacity:1];
			root.activeCondition = [NSMutableArray arrayWithCapacity: 1];

			for (GDataXMLElement* activeElement in activeEnum) {
                if ([WSStringUtils caseInsensitiveCompare:[activeElement name] toString:@"Fact"] == NSOrderedSame) {
				    NSString* fact = [activeElement stringValue];

				    if ([WSStringUtils isNotEmpty: fact]) {
					    [root.activeCondition addObject: fact];
				    }

                    root.activeConditionLangType = LanguageTypeClips;
                } else if ([WSStringUtils caseInsensitiveCompare:[activeElement name] toString:@"Expression"] == NSOrderedSame) {
                	NSString* expression = [activeElement stringValue];

                	if ([WSStringUtils isNotEmpty: expression]) {
                	     [root.activeCondition addObject: expression];
                	}

                    root.activeConditionLangType = LanguageTypeExpression;
                }
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"SkipCondition"] == NSOrderedSame) {
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
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"RenderingHint"] == NSOrderedSame) {
			NSArray* hintEnum = [utteranceRootElement children];

			for (GDataXMLElement* hintElement in hintEnum) {
				if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlType"] == NSOrderedSame) {
					root.controlType = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlImage"] == NSOrderedSame) {
					root.controlImage = [NSURL URLWithString:[hintElement stringValue]];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlHeight"] == NSOrderedSame) {
					root.controlHeight = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlWidth"] == NSOrderedSame) {
					root.controlWidth = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlItem"] == NSOrderedSame) {
					root.controlItem = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlFontSize"] == NSOrderedSame) {
					root.controlFontSize = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlFontColor"] == NSOrderedSame) {
					root.controlFontColor = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"ControlFontName"] == NSOrderedSame) {
					root.controlFontName = [hintElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[hintElement name] toString:@"TouchArea"] == NSOrderedSame) {
					NSArray* touchAreaEnum = [hintElement children];
					
					for (GDataXMLElement* touchAreaElement in touchAreaEnum) {
						if ([WSStringUtils caseInsensitiveCompare:[touchAreaElement name] toString:@"TouchX"] == NSOrderedSame) {
							root.controlTouchX = [touchAreaElement stringValue];
						} else if ([WSStringUtils caseInsensitiveCompare:[touchAreaElement name] toString:@"TouchY"] == NSOrderedSame) {
							root.controlTouchY = [touchAreaElement stringValue];
						} else if ([WSStringUtils caseInsensitiveCompare:[touchAreaElement name] toString:@"TouchWidth"] == NSOrderedSame) {
							root.controlTouchWidth = [touchAreaElement stringValue];
						} else if ([WSStringUtils caseInsensitiveCompare:[touchAreaElement name] toString:@"TouchHeight"] == NSOrderedSame) {
							root.controlTouchHeight = [touchAreaElement stringValue];
						}
					}
				}
			}
		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceRootElement name] toString:@"Directive"] == NSOrderedSame) {
			NSArray* directiveEnum = [utteranceRootElement children];

			for (GDataXMLElement* directiveElement in directiveEnum) {
				if ([WSStringUtils caseInsensitiveCompare:[directiveElement name] toString:@"Instruction"] == NSOrderedSame) {
					root.directiveInstruction = [directiveElement stringValue];
				} else if ([WSStringUtils caseInsensitiveCompare:[directiveElement name] toString:@"InstructionResource"] == NSOrderedSame) {
                    [root setDirectiveInstructionResource:[NSURL URLWithString:[directiveElement stringValue]]];
                } else if ([WSStringUtils caseInsensitiveCompare:[directiveElement name] toString:@"Image"] == NSOrderedSame) {
					root.directiveImage = [NSURL URLWithString:[directiveElement stringValue]];
				} else if ([WSStringUtils caseInsensitiveCompare:[directiveElement name] toString:@"URL"] == NSOrderedSame) {
					root.directive = [NSURL URLWithString:[directiveElement stringValue]];
				}
			}
		}
	}
}

- (WSInterventionHIL*) decodeInterventionwithXML: (GDataXMLElement*) xml {
	WSInterventionHIL* intervention = [WSInterventionHIL new];

	[self decodeRoot: intervention WithXML: xml];

    NSArray* interventionEnum = [xml children];

    for (GDataXMLElement* interventionElement in interventionEnum) {
        if ([WSStringUtils caseInsensitiveCompare:[interventionElement name] toString:@"InterventionName"] == NSOrderedSame) {
            [intervention setInterventionName:[interventionElement stringValue]];
        }
    }

    return intervention;
}

- (ResponseType) responseTypeFromValue: (NSString*) value {
	NSMutableDictionary* responseType = [NSMutableDictionary dictionary];

	[responseType setValue:[NSNumber numberWithInt: ResponseTypeFree]				forKey: RESPONSE_TYPE_FREE];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeFreeFixed]          forKey: RESPONSE_TYPE_FREE_FIXED];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeDirective]          forKey: RESPONSE_TYPE_DIRECTIVE];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeFixed]				forKey: RESPONSE_TYPE_FIXED];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeFixedNext]          forKey: RESPONSE_TYPE_FIXED_NEXT];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeFixedAsk]           forKey: RESPONSE_TYPE_FIXED_ASK];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeGoal]				forKey: RESPONSE_TYPE_GOAL];
    [responseType setValue:[NSNumber numberWithInt: ResponseTypeTask]				forKey: RESPONSE_TYPE_TASK];
    [responseType setValue:[NSNumber numberWithInt: ResponseTypeReward]				forKey: RESPONSE_TYPE_REWARD];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeVAS]				forKey: RESPONSE_TYPE_VAS];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeDVAS]				forKey: RESPONSE_TYPE_DVAS];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeCamera]             forKey: RESPONSE_TYPE_CAMERA];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeVideo]				forKey: RESPONSE_TYPE_VIDEO];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeSensor]             forKey: RESPONSE_TYPE_SENSOR];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeVisual]				forKey: RESPONSE_TYPE_VISUAL];
    [responseType setValue:[NSNumber numberWithInt: ResponseTypeWebView]			forKey: RESPONSE_TYPE_WEBVIEW];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeOCR]				forKey: RESPONSE_TYPE_OCR];
	[responseType setValue:[NSNumber numberWithInt: ResponseTypeScan]				forKey: RESPONSE_TYPE_SCAN];
    [responseType setValue:[NSNumber numberWithInt: ResponseTypeCollection]		    forKey: RESPONSE_TYPE_COLLECTION];
	
	return (ResponseType)[[responseType valueForKey:[value uppercaseString]] intValue];
}

- (ResponseDataType) responseFormatFromValue: (NSString*) value {
	NSMutableDictionary* responseFormat = [NSMutableDictionary dictionary];

	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeNumeric]      forKey: RESPONSE_FORMAT_NUMERIC];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeAlpha]		forKey: RESPONSE_FORMAT_ALPHA];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeDate]         forKey: RESPONSE_FORMAT_DATE];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDateTypeDateTime]     forKey: RESPONSE_FORMAT_DATETIME];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeValueList]    forKey: RESPONSE_FORMAT_VALUE_LIST];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeDataList]     forKey: RESPONSE_FORMAT_DATA_LIST];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypePhone]		forKey: RESPONSE_FORMAT_PHONE];
	[responseFormat setValue:[NSNumber numberWithInt: ResponseDataTypeMonetary]     forKey: RESPONSE_FORMAT_MONETARY];

	return (ResponseDataType)[[responseFormat valueForKey:[value uppercaseString]] intValue];
}

- (WSResponse*) decodeResponseWithXML: (GDataXMLElement*) xml {
    WSResponse* response = [WSResponse new];

    return [self decodeResponseWithXML:xml andResponse:response];
}

- (WSResponse*) decodeResponseWithXML: (GDataXMLElement*) xml andResponse:(WSResponse*)response {
    if ((response == nil) || (xml == nil))
        return nil;

	[self decodeRoot: response WithXML: xml];

	NSArray* responseEnum = [xml children];

	if ([responseEnum count] == 0)
		return nil;

	for (GDataXMLElement* responseElement in responseEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"Type"] == NSOrderedSame) {
			response.responseType = [self responseTypeFromValue:[responseElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"Label"] == NSOrderedSame) {
			response.label = [responseElement stringValue];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"LabelResource"] == NSOrderedSame) {
			response.labelResource = [NSURL URLWithString:[responseElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"GoalName"] == NSOrderedSame) {
			response.goalName = [NSURL URLWithString:[responseElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"Code"] == NSOrderedSame) {
			response.code = [NSURL URLWithString:[responseElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"Format"] == NSOrderedSame) {
			response.format = [self responseFormatFromValue:[responseElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[responseElement name] toString:@"Constraints"] == NSOrderedSame) {
			NSArray* constraintsEnum = [responseElement children];

			for (GDataXMLElement* constraintRoot in constraintsEnum) {
				NSArray* constraintEnum = [constraintRoot children];

				for (GDataXMLElement* constraintElement in constraintEnum) {
					if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MinValue"] == NSOrderedSame) {
						response.constraintMinValue = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MinValueText"] == NSOrderedSame) {
						response.constraintMinValueText = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MaxValue"] == NSOrderedSame) {
						response.constraintMaxValue = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MaxValueText"] == NSOrderedSame) {
						response.constraintMaxValueText = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MidValue"] == NSOrderedSame) {
                        response.constraintMidValue = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MidValueText"] == NSOrderedSame) {
                        response.constraintMidValueText = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MinMidValue"] == NSOrderedSame) {
                        response.constraintMinMidValue = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MinMidValueText"] == NSOrderedSame) {
                        response.constraintMinMidValueText = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MidMaxValue"] == NSOrderedSame) {
                        response.constraintMidMaxValue = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"MidMaxValueText"] == NSOrderedSame) {
                        response.constraintMidMaxValueText = [constraintElement stringValue];
                    } else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Behavior"] == NSOrderedSame) {
						response.constraintBehavior = [NSURL URLWithString:[constraintElement stringValue]];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Width"] == NSOrderedSame) {
						response.constraintControlWidth = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"DataListName"] == NSOrderedSame) {
						response.constraintDataListName = [constraintElement stringValue];
					} else if ([WSStringUtils caseInsensitiveCompare:[constraintElement name] toString:@"Values"] == NSOrderedSame) {
						NSArray* constraintValuesEnum = [constraintElement children];

						for (GDataXMLElement* constraintValueElement in constraintValuesEnum) {
							if ([WSStringUtils caseInsensitiveCompare:[constraintValueElement name] toString:@"Value"] == NSOrderedSame) {
								NSString* constraintValue = [[NSString alloc] initWithString:[constraintValueElement stringValue]];
								[response addConstraintValue:constraintValue];
							}
						}
					}
				}
			}
		}
	}

	response.responseValue = nil;

	return response;
}

- (WSActor*) decodeActorWithXML: (GDataXMLElement*) xml {
	WSActor*  actor		= [WSActor new];
	NSArray*  actorEnum	= [xml children];
    
    actor.triggers = [[NSMutableArray alloc] initWithCapacity:1];

	for (GDataXMLElement* actorElement in actorEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[actorElement name] toString:@"Emotion"] == NSOrderedSame) {
			actor.emotion = [actorElement stringValue];
		} else if ([WSStringUtils caseInsensitiveCompare:[actorElement name] toString:@"Trigger"] == NSOrderedSame) {
			[actor.triggers addObject:[actorElement stringValue]];
		} else if ([WSStringUtils caseInsensitiveCompare:[actorElement name] toString:@"SystemID"] == NSOrderedSame) {
			[actor setSystemID:[NSURL URLWithString:[actorElement stringValue]]];
		}
	}

	return actor;
}

- (void) decodeUtteranceForInteraction:(__unused WSInteraction*)interaction withXML:(GDataXMLElement*)xml {
   	NSArray*  utteranceEnum	= [xml children];

   	for (GDataXMLElement* utteranceElement in utteranceEnum) {
   		if ([WSStringUtils caseInsensitiveCompare:[utteranceElement name] toString:@"Text"] == NSOrderedSame) {
   			//actor.emotion = [NSURL URLWithString:[actorElement stringValue]];
   		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceElement name] toString:@"Lights"] == NSOrderedSame) {
   			//[actor.triggers addObject:[actorElement stringValue]];
   		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceElement name] toString:@"Audio"] == NSOrderedSame) {
   			//[actor setSystemID:[NSURL URLWithString:[actorElement stringValue]]];
   		} else if ([WSStringUtils caseInsensitiveCompare:[utteranceElement name] toString:@"Visual"] == NSOrderedSame) {
   		   	//[actor setSystemID:[NSURL URLWithString:[actorElement stringValue]]];
   		}  else if ([WSStringUtils caseInsensitiveCompare:[utteranceElement name] toString:@"Actor"] == NSOrderedSame) {
   		    //[actor setSystemID:[NSURL URLWithString:[actorElement stringValue]]];
   		}
   	}
}

- (InteractionType) interactionTypeFromValue: (NSString*) value {
	NSMutableDictionary* interactionType = [NSMutableDictionary dictionary];
	
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeResponse]							forKey: INTERACTION_TYPE_RESPONSE];
    [interactionType setValue:[NSNumber numberWithInt: InteractionTypePatternOfBehavior]					forKey: INTERACTION_TYPE_PATTERN_OF_BEHAVIOR];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeInterrogativeMultiSelect]          forKey: INTERACTION_TYPE_MULTISELECT];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeInterrogativeSingleSelect]         forKey: INTERACTION_TYPE_SINGLESELECT];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeInterrogativeUnstructured]         forKey: INTERACTION_TYPE_UNSTRUCTURED];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeImperative]						forKey: INTERACTION_TYPE_IMPERATIVE];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeGoal]								forKey: INTERACTION_TYPE_GOAL];
    [interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeTask]								forKey: INTERACTION_TYPE_TASK];
    [interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeReward]						    forKey: INTERACTION_TYPE_REWARD];
	[interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeDeclarative]						forKey: INTERACTION_TYPE_DECLARATIVE];
    [interactionType setValue:[NSNumber numberWithInt: InteractionHILTypeCollection]						forKey: INTERACTION_TYPE_COLLECTION];

	return (InteractionType)[[interactionType valueForKey:[value uppercaseString]] intValue];
}

- (InteractionHILNavigation) interactionNavigationFromValue: (NSString*) value {
	NSMutableDictionary* interactionNavigation = [NSMutableDictionary dictionary];

	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavExitOnly]				forKey: NAV_EXIT_ONLY];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavHomeOnly]     		forKey: NAV_HOME_ONLY];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavNextOnly]             forKey: NAV_NEXT_ONLY];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavPrevOnly]             forKey: NAV_PREV_ONLY];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavHomeNext]             forKey: NAV_HOME_NEXT];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavNone]                 forKey: NAV_NONE];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavSend]                 forKey: NAV_SEND];
	[interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILScrollDown]              forKey: NAV_SCROLL_DOWN];
    [interactionNavigation setValue:[NSNumber numberWithInt: InteractionHILNavNewOnly]              forKey: NAV_NEW_ONLY];

	return (InteractionHILNavigation)[[interactionNavigation valueForKey:[value uppercaseString]] intValue];
}

- (InteractionExecutionMode) interactionExecutionModeFromValue: (NSString*) value {
    NSMutableDictionary* interactionExecMode = [NSMutableDictionary dictionary];

    [interactionExecMode setValue:[NSNumber numberWithInt: InteractionExecutionModeSequential]  forKey: INTERACTION_EXEC_MODE_SEQUENTIAL];
    [interactionExecMode setValue:[NSNumber numberWithInt: InteractionExecutionModeParallel]    forKey: INTERACTION_EXEC_MODE_PARALLEL];
    [interactionExecMode setValue:[NSNumber numberWithInt: InteractionExecutionModeDataFlow]	forKey: INTERACTION_EXEC_MODE_DATAFLOW];
    [interactionExecMode setValue:[NSNumber numberWithInt: InteractionExecutionModeUser]	    forKey: INTERACTION_EXEC_MODE_USER];

    return (InteractionExecutionMode)[[interactionExecMode valueForKey:[value uppercaseString]] intValue];
}

- (WSInteractionHIL*) decodeInteractionHILwithXML: (GDataXMLElement*) xml {
	WSInteractionHIL* interaction = [WSInteractionHIL new];

	[self decodeRoot: interaction WithXML: xml];

    if (self) {
        NSArray *interactionEnum = [xml children];

        for (GDataXMLElement *interactionElement in interactionEnum) {
            if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Type"] == NSOrderedSame) {
                [interaction setType:[self interactionTypeFromValue:[interactionElement stringValue]]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Text"] == NSOrderedSame) {
                [interaction setText:[interactionElement stringValue]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"TextResource"] == NSOrderedSame) {
                [interaction setTextResource:[NSURL URLWithString:[interactionElement stringValue]]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"AudioResource"] == NSOrderedSame) {
                [interaction setAudioResource:[NSURL URLWithString:[interactionElement stringValue]]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"TextHeight"] == NSOrderedSame) {
                [interaction setTextHeight:[interactionElement stringValue]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"GroupName"] == NSOrderedSame) {
                [interaction setGroupName:[interactionElement stringValue]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"ExecutionMode"] == NSOrderedSame) {
                interaction.executionMode = [self interactionExecutionModeFromValue:[interactionElement stringValue]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Actor"] == NSOrderedSame) {
                [interaction setActor:[self decodeActorWithXML:interactionElement]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Utterance"] == NSOrderedSame) {
                [self decodeUtteranceForInteraction:interaction withXML:interactionElement];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Navigation"] == NSOrderedSame) {
                [interaction setNavigation:[self interactionNavigationFromValue:[interactionElement stringValue]]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"ResponseRequired"] == NSOrderedSame) {
                if ([WSStringUtils isNotEmpty:[interactionElement stringValue]] && (([WSStringUtils caseInsensitiveCompare:[interactionElement stringValue] toString:@"YES"] == NSOrderedSame) || ([WSStringUtils caseInsensitiveCompare:[interactionElement stringValue] toString:@"Y"] == NSOrderedSame))) {
                    [interaction setResponseRequired:true];
                }
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Scroll"] == NSOrderedSame) {
                [interaction setScroll:[interactionElement stringValue]];
            } else if ([WSStringUtils caseInsensitiveCompare:[interactionElement name] toString:@"Responses"] == NSOrderedSame) {
                NSArray *responseEnum = [interactionElement children];

                if ([responseEnum count] == 0) {
                    continue;
                }

                for (GDataXMLElement *responseElement in responseEnum) {
                    // @LEAK   how often is this allocated?
                    WSResponse *response = [self decodeResponseWithXML:responseElement];

                    if (response != nil) {
                        [interaction addResponse:response];
                    }
                }
            }
        }
    }

	return interaction;
}

- (GDataXMLElement*) locateInteractions: (GDataXMLElement*) xml {
	NSArray* interventionEnum =  [xml children];

	for (GDataXMLElement* interventionElement in interventionEnum) {
		if ([WSStringUtils caseInsensitiveCompare:[interventionElement name] toString:@"Interactions"] == NSOrderedSame) {
			return interventionElement;
		}
	}

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
	GDataXMLElement*                interactionElement;

	while ((interactionElement = [interactionsEnum_ nextObject]) != nil) {
		if ([interactionElement kind] == GDataXMLCommentKind)
			continue;

		interaction = [self decodeInteractionHILwithXML: interactionElement];

		interaction.tag = [interactionsEnum_ pos];

		break;
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
    NSString * path = [[NSString alloc] initWithFormat:@"Interaction[SystemID=%@]", sysId];

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
	id <WSProtocolHistoryManager>	planHistory = [intervention protocolHistory];

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
	id <WSProtocolHistoryManager>	planHistory = [intervention protocolHistory];

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
    if ((goalsEnum_ == nil) || ([goalsEnum_ numberOfElements] == 0)) {
        return nil;
    }

    NSMutableArray*  goals = [[NSMutableArray alloc] initWithCapacity:10];
    GDataXMLElement* goalsElement;

    while ((goalsElement = [goalsEnum_ nextObject]) != nil) {
        NSArray* goalEnum = [goalsElement children];
        Goal*    goal     = [Goal new];

        for (GDataXMLElement* goalElement in goalEnum) {
            if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Activation"] == NSOrderedSame) {
                NSArray* factEnum = [goalElement children];

          		if ([factEnum count] == 0) {
          			continue;
          		}

          		goal.activation = [NSMutableArray arrayWithCapacity: 1];

          		for (GDataXMLElement* postElement in factEnum) {
          			NSString* fact = [[NSString alloc] initWithString:[postElement stringValue]];

          			[goal.activation addObject:fact];
          		}
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"SystemID"] == NSOrderedSame) {
                goal.objectID = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Description"] == NSOrderedSame) {
                goal.description = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Name"] == NSOrderedSame) {
                goal.name = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"ShortDescription"] == NSOrderedSame) {
                goal.shortDescription = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Ontology"] == NSOrderedSame) {
                goal.ontology = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Instructions"] == NSOrderedSame) {
                goal.instructions = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"PersonalValue"] == NSOrderedSame) {
                goal.personalValue = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"ExpectationOfSuccess"] == NSOrderedSame) {
                goal.expectationOfSuccess = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"Reward"] == NSOrderedSame) {
                goal.reward = [goalElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[goalElement name] toString:@"ActionPlan"] == NSOrderedSame) {
                goal.actionPlan = [[NSURL alloc] initWithString:[goalElement stringValue]];
            }
        }

        if ([WSStringUtils isEmpty:goal.objectID]) {
            //  We really prefer that the protocol contain the ID.
            [goal allocateObjectId];
        }

        WSGoal* wsgoal = [[WSGoal alloc] initWithGoal:goal];
        [goals addObject:wsgoal];
    }

   	return goals;
}

-(NSArray*)queryTasks {
    if ((tasksEnum_ == nil) || ([tasksEnum_ numberOfElements] == 0)) {
        return nil;
    }

    NSMutableArray*  tasks = [[NSMutableArray alloc] initWithCapacity:10];
    GDataXMLElement* tasksElement;

    while ((tasksElement = [tasksEnum_ nextObject]) != nil) {
        NSArray* taskEnum = [tasksElement children];
        Task*    task     = [Task new];

        for (GDataXMLElement* taskElement in taskEnum) {
            if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Activation"] == NSOrderedSame) {
                NSArray* factEnum = [taskElement children];

          		if ([factEnum count] == 0) {
          			continue;
          		}

          		task.activation = [NSMutableArray arrayWithCapacity: 1];

          		for (GDataXMLElement* postElement in factEnum) {
          			NSString* fact = [[NSString alloc] initWithString:[postElement stringValue]];

          			[task.activation addObject:fact];
          		}
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"SystemID"] == NSOrderedSame) {
                task.objectID = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Description"] == NSOrderedSame) {
                task.description = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Name"] == NSOrderedSame) {
                task.name = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"ShortDescription"] == NSOrderedSame) {
                task.shortDescription = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Ontology"] == NSOrderedSame) {
                task.ontology = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"CompletionCount"] == NSOrderedSame) {
                task.completionCount = [[taskElement stringValue] intValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Repeat"] == NSOrderedSame) {
                task.repeat = [[taskElement stringValue] intValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Instructions"] == NSOrderedSame) {
                task.instructions = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Priority"] == NSOrderedSame) {
                task.priority = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"Status"] == NSOrderedSame) {
                task.status = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"LastCompletionTime"] == NSOrderedSame) {
                task.lastCompletionTime = [taskElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[taskElement name] toString:@"ActionPlan"] == NSOrderedSame) {
                task.actionPlan = [[NSURL alloc] initWithString:[taskElement stringValue]];
            }
        }

        if ([WSStringUtils isEmpty:task.objectID]) {
            //  We really prefer that the protocol contain the ID.
            [task allocateObjectId];
        }

        WSTask* wstask = [[WSTask alloc] initWithTask:task];
        [tasks addObject:wstask];
    }

   	return tasks;
}

-(NSArray*)queryRewards {
    if ((rewardsEnum_ == nil) || ([rewardsEnum_ numberOfElements] == 0)) {
        return nil;
    }

    NSMutableArray*  rewards = [[NSMutableArray alloc] initWithCapacity:10];
    GDataXMLElement* rewardsElement;

    while ((rewardsElement = [rewardsEnum_ nextObject]) != nil) {
        NSArray* rewardEnum = [rewardsElement children];
        Reward*  reward     = [Reward new];

        for (GDataXMLElement* rewardElement in rewardEnum) {
            if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Activation"] == NSOrderedSame) {
                NSArray* factEnum = [rewardElement children];

          		if ([factEnum count] == 0) {
          			continue;
          		}

          		reward.activation = [NSMutableArray arrayWithCapacity: 1];

          		for (GDataXMLElement* postElement in factEnum) {
          			NSString* fact = [[NSString alloc] initWithString:[postElement stringValue]];

          			[reward.activation addObject:fact];
          		}
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"SystemID"] == NSOrderedSame) {
                reward.objectID = [rewardElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Description"] == NSOrderedSame) {
                reward.description = [rewardElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Name"] == NSOrderedSame) {
                reward.name = [rewardElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"ShortDescription"] == NSOrderedSame) {
                reward.shortDescription = [rewardElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Ontology"] == NSOrderedSame) {
                reward.ontology = [rewardElement stringValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"CompletionCount"] == NSOrderedSame) {
                reward.completionCount = [[rewardElement stringValue] intValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Repeat"] == NSOrderedSame) {
                reward.repeat = [[rewardElement stringValue] intValue];
            } else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"Instructions"] == NSOrderedSame) {
                reward.instructions = [rewardElement stringValue];
            }  else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"LastCompletionTime"] == NSOrderedSame) {
                reward.lastCompletionTime = [rewardElement stringValue];
            }  else if ([WSStringUtils caseInsensitiveCompare:[rewardElement name] toString:@"ActionPlan"] == NSOrderedSame) {
                reward.actionPlan = [[NSURL alloc] initWithString:[rewardElement stringValue]];
            }
        }

        if ([WSStringUtils isEmpty:reward.objectID]) {
            //  We really prefer that the protocol contain the ID.
            [reward allocateObjectId];
        }

        WSReward* wsreward = [[WSReward alloc] initWithReward:reward];
        [rewards addObject:wsreward];
    }

   	return rewards;
}

-(NSArray*)queryInterventions {
    return nil;
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