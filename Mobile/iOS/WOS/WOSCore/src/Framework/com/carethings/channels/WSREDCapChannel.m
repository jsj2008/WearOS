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
#import "OpenPATHCore.h"

@implementation WSREDCapChannel

@synthesize accessToken = accessToken_;
@synthesize instanceUrl = instanceUrl_;
@synthesize activeBehavior = activeBehavior_;
@synthesize studyId = studyId_;


-(NSData*)retrieveDataWithOptions : (NSData*)data withOptions : (WSChannelOptions) options didFailWithError : (NSError**)error {
    return nil;
}

-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

-(void)sendData :(NSData*)data withOptions : (WSChannelOptions) options didFailWithError : (NSError**)error {
}

-(NSMutableURLRequest*)generatePostRequest:(NSString*)urlPath withParameter:(NSString*)parameter {
    NSString*				urlString 	= [[NSString alloc] initWithString: urlPath];
    NSURL* 					url 		= [NSURL URLWithString:urlString];
    NSMutableURLRequest*	theRequest 	= [NSMutableURLRequest requestWithURL:url];
    NSString*				msgLength 	= [NSString stringWithFormat:@"%llu", [parameter length]];

    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];

    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [parameter dataUsingEncoding:NSUTF8StringEncoding]];

    return theRequest;
}

-(NSMutableURLRequest*)generateGetRequest:(NSString*)urlPath {
    NSString*				urlString  = [[NSString alloc] initWithFormat:@"%@%@", instanceUrl_, urlPath]; // urlstring is released below
    NSURL* 					url        = [NSURL URLWithString:urlString];
    NSMutableURLRequest*	theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString*				authHeader = [NSString stringWithFormat:@"OAuth %@", accessToken_];

    [theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];

    return theRequest;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    BehaviorDAO* 		dao      = [BehaviorDAO new];
    Behavior*    		behavior = [Behavior new];
    ResdbResult* 		result   = nil;
    NSString*           statusMessage = @"UPLOAD COMPLETE";

    //  If we have seen this study before then use it.
    result = [dao retrieveByRelatedId:studyId_];

    if (result.resdbCode != RESDB_SQL_ROWS) {
        //  Create a temporary one using our demo breast cancer survey
        behavior.behaviorType     = BEHAVIOR_TYPE_PROCEDURE;
        behavior.behaviorState    = BEHAVIOR_STATE_ACTIVE;
        behavior.protocolLanguage = BEHAVIOR_LANG_TYPE_REDCAP_XML;

        [behavior setRelatedID:studyId_];
        [behavior setDecoratedName:@"REDCap Survey"];
        [behavior allocateObjectId];

        NSString* protocolString = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><records><item><field_name><![CDATA[gender]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[What is your gender?]]></field_label><select_choices_or_calculations><![CDATA[0, Male \\n 1, Female]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[hadmammogram]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you ever had a mammogram?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[clinicalbreastexam]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you had a clinical breast exam within the last 3 months (done by a clinician)?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[changesrightbreast]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you noticed any of the following changes in your RIGHT breast in the LAST 3 MONTHS?]]></field_label><select_choices_or_calculations><![CDATA[0, Lump (new or unusual) \\n 1, Nipple discharge \\n 2, Pain \\n 3, Other \\n 4, None of the above]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[changesleftbreast]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you noticed any of the following changes in your LEFT breast in the LAST 3 MONTHS?]]></field_label><select_choices_or_calculations><![CDATA[0, Lump (new or unusual) \\n 1, Nipple discharge \\n 2, Pain \\n 3, Other \\n 4, None of the above]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[changesrightbreasttoday]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you noticed any of the following changes in your RIGHT breast that are PRESENT TODAY?]]></field_label><select_choices_or_calculations><![CDATA[0, Lump (new or unusual) \\n 1, Nipple discharge \\n 2, Pain \\n 3, Other \\n 4, None of the above]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[changesleftbreasttoday]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you noticed any of the following changes in your LEFT breast that are PRESENT TODAY?]]></field_label><select_choices_or_calculations><![CDATA[0, Lump (new or unusual) \\n 1, Nipple discharge \\n 2, Pain \\n 3, Other \\n 4, None of the above]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[toldbreastcancer]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has a doctor ever told you that you have breast cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - invasive breast cancer \\n 1, Yes - ductal carcinoma in situ (DCIS) \\n 2, Yes - but I don't know what kind of breast cancer \\n 3, No \\n 4, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[diagnosedcancer]]></field_name><form_name><![CDATA[my_breast_health]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Have you ever been diagnosed with any of the following cancers?]]></field_label><select_choices_or_calculations><![CDATA[0, Adrenal Cancer \\n 1, Bladder Cancer \\n 2, Bone Cancer \\n 3, Brain Cancer \\n 4, Breast Cancer \\n 5, Cervical Cancer \\n 6, Colon, Rectal, Large Intestine Cancer \\n 7, Gall Bladder Cancer \\n 8, Gastric/Stomach Cancer \\n 9, Kidney or Renal Cancer \\n 10, Leukemia \\n 11, Lung Cancer \\n 12, Lymphoma - Hodgkins \\n 13, Lymphoma - non-Hodgkins \\n 14, Ovary, Peritoneal, Fallopian Tube Cancer \\n 15, Pancreatic Cancer \\n 16, Prostate Cancer \\n 17, Renal Pelvis / Ureter Cancer \\n 18, Sarcoma \\n 19, Skin - Basal / Squamous Cell Cancer \\n 20, Skin - Melanoma Cancer \\n 21, Small Intestine Cancer \\n 22, Testicular Cancer \\n 23, Thyroid Cancer \\n 24, Uterine (non-Cervical) / Endometrial Cancer \\n 25, Other cancer non in this list \\n 26, Unknown type of cancer \\n 27, No history of cancer \\n 28, Don't know whether I've had cancer]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[adopted]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Are you adopted?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[numberofsisters]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[dropdown]]></field_type><field_label><![CDATA[Please answer the following questions for your blood relatives, including half-relatives and relatives who have died, but not step-relatives. How many sisters do you have?]]></field_label><select_choices_or_calculations><![CDATA[0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5 \\n 6, 6 \\n 7, 7 \\n 8, 8 \\n 9, 9 \\n 10, 10 \\n 11, 11 \\n 12, 12 \\n 13, 13 \\n 14, 14 \\n 15, 15]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[numberofdaughters]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[dropdown]]></field_type><field_label><![CDATA[How many daughters do you have?]]></field_label><select_choices_or_calculations><![CDATA[0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5 \\n 6, 6 \\n 7, 7 \\n 8, 8 \\n 9, 9 \\n 10, 10 \\n 11, 11 \\n 12, 12 \\n 13, 13 \\n 14, 14 \\n 15, 15]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[numbermaternalaunts]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header><![CDATA[Demographics Information]]></section_header><field_type><![CDATA[dropdown]]></field_type><field_label><![CDATA[How many maternal aunts (mom's sisters) do you have?]]></field_label><select_choices_or_calculations><![CDATA[0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5 \\n 6, 6 \\n 7, 7 \\n 8, 8 \\n 9, 9 \\n 10, 10 \\n 11, 11 \\n 12, 12 \\n 13, 13 \\n 14, 14 \\n 15, 15]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[numberofpaternalaunts]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[dropdown]]></field_type><field_label><![CDATA[How many paternal aunts (father's sisters) do you have?]]></field_label><select_choices_or_calculations><![CDATA[0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5 \\n 6, 6 \\n 7, 7 \\n 8, 8 \\n 9, 9 \\n 10, 10 \\n 11, 11 \\n 12, 12 \\n 13, 13 \\n 14, 14 \\n 15, 15]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[familydiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has anyone in your family ever been diagnosed with breast cancer or DCIS (ductal carcinoma in situ)?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[motherdiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has your mother ever been diagnosed with breast cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - invasive breast cancer \\n 1, Yes - ductal carcinoma in situ (DCIS) \\n 2, Yes - but I don't know what kind of breast cancer \\n 3, No \\n 4, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[relativesdiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any of your relatives ever been diagnosed with bilateral breast cancer of DCIS (ductal carcinoma in situ)? note: bilateral means in both breasts]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[grandmotherdiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has your maternal grandmother (your mother's mother) ever been diagnosed with breast cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - invasive breast cancer \\n 1, Yes - ductal carcinoma in situ (DCIS) \\n 2, Yes - but I don't know what kind of breast cancer \\n 3, No \\n 4, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[paternalgrandmotherdiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has your paternal grandmother (your father's mother) ever been diagnosed with breast cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - invasive breast cancer \\n 1, Yes - ductal carcinoma in situ (DCIS) \\n 2, Yes - but I don't know what kind of breast cancer \\n 3, No \\n 4, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[paternalauntsdiagnosedcancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any of your paternal aunts (father's sisters) ever been diagnosed with breast cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - invasive breast cancer \\n 1, Yes - ductal carcinoma in situ (DCIS) \\n 2, Yes - but I don't know what kind of breast cancer \\n 3, No \\n 4, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[malerelativecancer]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any male relatives in your family ever been diagnosed with breast cancer (including chest wall cancer)?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't Know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[mothersisterdaughtergrandauntdiagnosed]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has your mother, sister(s) daughter(s), grandmother(s), or aunt(s) ever been diagnosed with ovarian cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[relativesdiagnosedbreastovarian]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Has your mother, sister(s) daughter(s), grandmother(s), or aunt(s) ever been diagnosed with both breast and ovarian cancer?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[diagnosedbeforefiftyfive]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any other women in your family (not already mentioned, including cousins and nieces) been diagnosed with breast cancer or DCIS (ductal carcinoma in situ) before the age of 55 years?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[relativesdiagnosedbeforefiftyfive]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have two or more of your relatives on the same side of the family been diagnosed with uterus (endometrial) and/or colon cancer diagnosed before age 55?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[relativesdiagnosedbefore20]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any of your relatives been diagnosed with any type of cancer before age 20?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[relativesdiagnosedbeforefortyfive]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have any of your relatives ever been diagnosed with leukemia, brain cancer, or a sarcoma before age 45?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[genetictesting]]></field_name><form_name><![CDATA[my_familys_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Have you ever had genetic testing for family cancer risk?]]></field_label><select_choices_or_calculations><![CDATA[0, Yes \\n 1, No \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[howlonghormonetherapy]]></field_name><form_name><![CDATA[my_health]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[For how many total years have you been on hormone replacement therapy?]]></field_label><select_choices_or_calculations><![CDATA[0, Less than five years \\n 1, For five years or more \\n 2, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[medications]]></field_name><form_name><![CDATA[my_health]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Are you CURRENTLY taking any of the following medications?]]></field_label><select_choices_or_calculations><![CDATA[0, Tamoxifen (Nolvadex) \\n 1, Raloxifene (Evista) \\n 2, Anastrozole (Arimidex) \\n 3, Letrozole (Femara) \\n 4, Hormones for birth control \\n 5, None]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[proceduresrightbreast]]></field_name><form_name><![CDATA[my_health]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Have you had any of the following breast procedures on your RIGHT breast?]]></field_label><select_choices_or_calculations><![CDATA[0, Fine Needle Aspiration (FNA) \\n 1, Core biopsy \\n 2, Surgical biopsy \\n 3, Lumpectomy for cancer \\n 4, Mastectomy \\n 5, Radiation Therapy \\n 6, Breast reconstruction \\n 7, Breast reduction \\n 8, Implants \\n 9, None of the above \\n 10, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[proceduresleftbreast]]></field_name><form_name><![CDATA[my_health]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Have you had any of the following breast procedures on your LEFT breast?]]></field_label><select_choices_or_calculations><![CDATA[0, Fine Needle Aspiration (FNA) \\n 1, Core biopsy \\n 2, Surgical biopsy \\n 3, Lumpectomy for cancer \\n 4, Mastectomy \\n 5, Radiation Therapy \\n 6, Breast reconstruction \\n 7, Breast reduction \\n 8, Implants \\n 9, None of the above \\n 10, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[height]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[slider]]></field_type><field_label><![CDATA[What is your height in feet (inches will be asked in the next question)?]]></field_label><select_choices_or_calculations><![CDATA[ | 12]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number><![CDATA[number]]></text_validation_type_or_show_slider_number><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[heightinches]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[slider]]></field_type><field_label><![CDATA[What is your current height in inches?]]></field_label><select_choices_or_calculations><![CDATA[0 | 6 | 12]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[weightpounds]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[text]]></field_type><field_label><![CDATA[What is your current weight in pounds?]]></field_label><select_choices_or_calculations/><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[alcoholicdrinksperday]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[On average, how many alcoholic drinks do you have per day?]]></field_label><select_choices_or_calculations><![CDATA[0, None \\n 1, Less than one or one a day \\n 2, About two a day \\n 3, Three or more a day]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[health]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Considering your health over the last month, how would you characterize your health?]]></field_label><select_choices_or_calculations><![CDATA[1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[limitationsactivities]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Do you currently have any limitations in your regular activities?]]></field_label><select_choices_or_calculations><![CDATA[1, 1 \\n 2, 2 \\n 3, 3]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[diagnosedhealthissues]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Have you ever been diagnosed or treated for any of the following health issues?]]></field_label><select_choices_or_calculations><![CDATA[0, Heart Disease \\n 1, Diabetes (problem with your blood sugar levels) \\n 2, High Blood Pressure \\n 3, Heart Attack \\n 4, Ulcer or Stomach Disease \\n 5, Lung Disease \\n 6, Congestive Heart Failure \\n 7, Kidney Disease \\n 8, Depression \\n 9, Osteoarthritis, degenerative arthritis Back pain \\n 10, Rheumatoid arthritis \\n 11, Liver Disease \\n 12, Anemia or other blood disease \\n 13, Chronic Obstructive Pulmonary Disease \\n 14, Alzheimer's disease, dementia \\n 15, Stroke \\n 16, Cancer (other than Breast Cancer or Skin Cancer) \\n 17, Other conditions (not listed) \\n 18, No - I have never been diagnosed or treated for health issues \\n 19, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[conditionslimitations]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Do these conditions cause limitations in your regular activities?]]></field_label><select_choices_or_calculations><![CDATA[1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[jewishancestry]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[checkbox]]></field_type><field_label><![CDATA[Do you have any Jewish ancestry in your family]]></field_label><select_choices_or_calculations><![CDATA[0, Yes - only on my father's side \\n 1, Yes - only on my mother's side \\n 2, Yes - on both sides \\n 3, Yes - not sure which side of my family \\n 4, No \\n 5, Don't know]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[racialbackground]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[What is your racial background?]]></field_label><select_choices_or_calculations><![CDATA[0, Black or African American \\n 1, White \\n 2, Asian \\n 3, American Indian or Alaska Native \\n 4, Native Hawaiian or Other Pacific Islander \\n 5, Some other race \\n 6, Don't know \\n 7, Refused]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[hispanicancestry]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[Are you of Hispanic, Latino or Spanish origin or ancestry?]]></field_label><select_choices_or_calculations><![CDATA[0, No, not of Hispanic, Latino or Spanish origin \\n 1, Yes - Puerto Rican \\n 2, Yes - other Hispanic, Latino, or Spanish origin \\n 3, Yes - Mexican, Mexican American, or Chicano \\n 4, Yes - Cuban]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[yearsschooling]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[How many years of schooling have you had?]]></field_label><select_choices_or_calculations><![CDATA[0, Some high school or less \\n 1, High school graduate \\n 2, Some college or technical school \\n 3, College graduate or more]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item><item><field_name><![CDATA[maritalstatus]]></field_name><form_name><![CDATA[about_me]]></form_name><section_header/><field_type><![CDATA[radio]]></field_type><field_label><![CDATA[What best describes your current marital status?]]></field_label><select_choices_or_calculations><![CDATA[0, Married \\n 1, Widowed \\n 2, Living with a partner in a marriage-like relationship \\n 3, Never married \\n 4, Divorced \\n 5, Separated]]></select_choices_or_calculations><field_note/><text_validation_type_or_show_slider_number/><text_validation_min/><text_validation_max/><identifier/><branching_logic/><required_field/><custom_alignment/><question_number/></item></records>";
        behavior.protocol = (NSMutableData*)[protocolString dataUsingEncoding:NSUTF8StringEncoding];

        statusMessage = @"DEMO SURVEY";
    } else {
        behavior = [result.resdbCollection objectAtIndex:0];
    }

    activeBehavior_ = behavior;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"carePATHUploadStatus" object:statusMessage];
}

-(void)loginWithUsername:(NSString*)username password:(NSString*)password token:(NSString*)token target:(id)target selector:(SEL)selector {
}

- (NSData*)retrieveDataDictionary:(NSString*)data withOptions:(WSChannelOptions)options didFailWithError:(NSError * *)error {
    NSString*               token        = [OpenPATHContext sharedOpenPATHContext].activeSecurity.securityToken;
    NSString*               endPoint     = [OpenPATHContext sharedOpenPATHContext].activeSecurity.endPointURL;
    NSString*               redcapParam  = [[NSString alloc] initWithFormat:@"content=metadata&format=xml&token=%@", token];
    NSMutableURLRequest*	theRequest   = [self generatePostRequest:endPoint withParameter:redcapParam];
	
	activeBehavior_ = nil;

    [NSURLConnection connectionWithRequest:theRequest delegate:self];

    return nil;
}

- (NSData*)retrieveFileAttachment:(NSString*)data withOptions:(WSChannelOptions)options didFailWithError:(NSError * *)error {
    NSString*               token        = [OpenPATHContext sharedOpenPATHContext].activeSecurity.securityToken;
    NSString*               endPoint     = [OpenPATHContext sharedOpenPATHContext].activeSecurity.endPointURL;
    NSString*               redcapParam  = [[NSString alloc] initWithFormat:@"content=file&action=export&format=xml&field=%@&token=%@", data, token];
    NSMutableURLRequest*	theRequest   = [self generatePostRequest:endPoint withParameter:redcapParam];
    NSURLResponse* 			response;

    NSData* result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];

    if (result == nil) {
        NSLog(@"Result back after file attachment data is nil") ;
    }

    NSString* resultStr = [[NSString alloc] initWithBytes:[result bytes] length:[result length] encoding:NSUTF8StringEncoding];

    return(result);
}

- (NSData*)retrieveExportData:(NSString*)data withOptions:(WSChannelOptions)options didFailWithError:(NSError**)error {
    NSString*               token        = [OpenPATHContext sharedOpenPATHContext].activeSecurity.securityToken;
    NSString*               endPoint     = [OpenPATHContext sharedOpenPATHContext].activeSecurity.endPointURL;
    NSString*               redcapParam  = [[NSString alloc] initWithFormat:@"content=record&format=xml&token=%@", token];
    NSMutableURLRequest*	theRequest   = [self generatePostRequest:endPoint withParameter:redcapParam];
	
	activeBehavior_ = nil;
	
    [NSURLConnection connectionWithRequest:theRequest delegate:self];
	
    return nil;
}

- (NSData*)sendMobilePhoneData:(NSString*)data withOptions: (WSChannelOptions) options didFailWithError:(NSError * *)error {
    NSString*               token        = [OpenPATHContext sharedOpenPATHContext].activeSecurity.securityToken;
    NSString*               endPoint     = [OpenPATHContext sharedOpenPATHContext].activeSecurity.endPointURL;
    NSString*               redcapParam  = [[NSString alloc] initWithFormat:@"content=record&overwriteBehavior=normal&type=flat&format=xml&token=%@&data=%@", token, data];
    NSMutableURLRequest*	theRequest   = [self generatePostRequest:endPoint withParameter:redcapParam];
	NSURLResponse* 			response;
	
	activeBehavior_ = nil;
	
	[NSURLConnection connectionWithRequest:theRequest delegate:self];
	
	return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Here in connection did finish loading");
	
	BehaviorDAO* 		dao = [BehaviorDAO new];
    ResdbResult* 		result = nil;
	
	[activeBehavior_ setRelatedID:studyId_];
	[activeBehavior_ setDecoratedName:@"REDCap Survey"];
	
	[activeBehavior_ allocateObjectId];
	
	//  If we have seen this study before then don't update.
	result = [dao retrieveByRelatedId:studyId_];
	
	if (result.resdbCode != RESDB_SQL_ROWS) {
		[dao insert:activeBehavior_];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"carePATHUploadStatus" object:@"UPLOAD COMPLETE"];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        return YES;
    } else if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        return YES;
    }

    return NO;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // cast the response to NSHTTPURLResponse so we can look for 404 etc
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if ([httpResponse statusCode] >= 400) {
        // do error handling here
        NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    } else {
        // start recieving data
    }
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } else  {
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } else  {
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
            NSURLCredential *creden = [[NSURLCredential alloc] initWithUser:@"USERNAME" password:@"ucsf.edu" persistence:NSURLCredentialPersistenceForSession];

            [[challenge sender] useCredential:creden forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender]cancelAuthenticationChallenge:challenge];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData  {
	if (activeBehavior_ == nil) {
		activeBehavior_ = [Behavior new];
		
		activeBehavior_.behaviorType     = BEHAVIOR_TYPE_PROCEDURE;
		activeBehavior_.behaviorState    = BEHAVIOR_STATE_ACTIVE;
		activeBehavior_.protocolLanguage = BEHAVIOR_LANG_TYPE_REDCAP_XML;
		
		activeBehavior_.protocol = [[NSMutableData alloc] initWithCapacity:100];
	}

    if (theData != nil) {
        NSString* dataStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];			 
		NSError*            err;
		GDataXMLDocument*   doc = [[GDataXMLDocument alloc] initWithXMLString:dataStr options: 0 error: &err];		
		NSArray*            errorNodes = [doc nodesForXPath:@"//error" error:nil];

        if (errorNodes == nil) {
			NSArray* countNodes = [doc nodesForXPath:@"//count" error:nil];
			
			if ((countNodes != nil) && ([countNodes count] > 0)) {
				GDataXMLElement* countNode = [countNodes objectAtIndex:0];
								
				[[NSNotificationCenter defaultCenter] postNotificationName:@"carePATHImportStatus" object:[countNode stringValue] ];
				return;
			}
			
            [activeBehavior_.protocol appendBytes:[theData bytes] length:[theData length]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"carePATHUploadStatus" object:@"ERROR"];
            return;
		}
    }
}

@end