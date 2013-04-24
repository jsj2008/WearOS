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

#import "WSSalesforceChannel.h"
#import "CoreSBJson.h"
#import "StringUtils.h"
#import "Patient.h"
#import "Goal.h"
#import "GoalDAO.h"
#import "Task.h"
#import "TaskDAO.h"


@implementation WSSalesforceChannel

@synthesize accessToken = accessToken_;
@synthesize instanceUrl = instanceUrl_;


-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

-(NSMutableURLRequest*)generatePostRequest:(NSString*)urlPath withParameter:(NSString*)parameter {
	NSString*				urlString 	= [[NSString alloc] initWithFormat:@"%@%@", instanceUrl_, urlPath];
	NSURL* 					url 		= [NSURL URLWithString:urlString];
	NSMutableURLRequest*	theRequest 	= [NSMutableURLRequest requestWithURL:url];
	NSString*				msgLength 	= [NSString stringWithFormat:@"%llu", [parameter length]];
	NSString*				authHeader 	= [NSString stringWithFormat:@"OAuth %@", accessToken_];
	
	[theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
	
	if ([StringUtils isNotEmpty:accessToken_]) {
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		[theRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	}
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [parameter dataUsingEncoding:NSUTF8StringEncoding]];
	
	return theRequest;
}

-(NSMutableURLRequest*)generatePatchRequest:(NSString*)urlPath withParameter:(NSString*)parameter {
	NSMutableURLRequest* theRequest = [self generatePostRequest:urlPath withParameter:parameter];
	
	[theRequest setHTTPMethod:@"PATCH"];
	
	return theRequest;
}

-(NSMutableURLRequest*)generateGetRequest:(NSString*)urlPath {
	NSString*				urlString = [[NSString alloc] initWithFormat:@"%@%@", instanceUrl_, urlPath]; // urlstring is released below
	NSURL* 					url = [NSURL URLWithString:urlString];
	NSMutableURLRequest*	theRequest = [NSMutableURLRequest requestWithURL:url];
	NSString*				authHeader = [NSString stringWithFormat:@"OAuth %@", accessToken_];
    
	[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
	
	return theRequest;
}

- (NSData*)sendChatterData:(NSString*)data withOptions: (WSChannelOptions) options didFailWithError:(NSError**)error {
    NSMutableURLRequest*	theRequest = [self generatePostRequest:@"/services/data/v24.0/chatter/feeds/record/0F9d0000000H3Yp/feed-items" withParameter:data];
    NSURLResponse* 			response;

    NSData* result=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];

    if (result == nil) {
        NSLog(@"Result back after posting mobile data is nil") ;
    }

    //id stringReply = (NSString *)[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];

    return result;
}

-(void)loginWithUsername:(NSString*)username password:(NSString*)password token:(NSString*)token clientIdentifier:(NSString*)clientIdentifier clientSecret:(NSString*)clientSecret {
	instanceUrl_ = @"";
	accessToken_ = @"";
	
	NSString*               passwordToken   = [NSString stringWithFormat:@"%@%@", password, token];
   	NSString*               parameter       = [[NSString alloc] initWithFormat:@"grant_type=password&client_id=%@&client_secret=%@&username=%@&password=%@", clientIdentifier, clientSecret, username, passwordToken];
	NSMutableURLRequest*	theRequest      = [self generatePostRequest:@"https://login.salesforce.com/services/oauth2/token" withParameter:parameter];
	NSURLResponse*			response;
	NSError*				error;
	
	NSData*        urlData      = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	SBJsonParser*  parser       = [[SBJsonParser alloc] init];
	NSDictionary*  responseDict = [parser objectWithData:urlData];
		
	if ((responseDict != nil) && ([responseDict objectForKey:@"error"] == nil)) {
		self.instanceUrl = [responseDict objectForKey:@"instance_url"];
		self.accessToken = [responseDict objectForKey:@"access_token"];
	} else {
		self.instanceUrl = nil;
		self.accessToken = nil;
	}
	
    return;
}

-(bool)isLoggedIn {
    if ([StringUtils isNotEmpty:accessToken_]) {
        return true;
    } else{
        return false;
    }
}

- (NSData*)sendData:(NSString*)data withOptions: (WSChannelOptions) options didFailWithError:(NSError * *)error {
	NSMutableURLRequest*	theRequest = [self generatePostRequest:@"/services/data/v20.0/sobjects/Mobile_Phone_Data__c/" withParameter:data];
	NSURLResponse* 			response;
	
    NSData* result=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    
    if (result == nil) {
        NSLog(@"Result back after posting mobile data is nil") ;
    }
	
    return(result);
}

- (NSData*)sendGroupedMobilePhoneData:(NSString*)data withOptions: (WSChannelOptions) options didFailWithError:(NSError * *)error {
	NSMutableURLRequest*	theRequest = [self generatePostRequest:@"/services/data/v20.0/sobjects/Mobile_Grouped_Phone_Data__c/" withParameter:data];
	NSURLResponse* 			response;
	
    NSData* result=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    
    if (result == nil) {
        NSLog(@"Result back after posting mobile data is nil") ;
    }
    
    //id stringReply = (NSString *)[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	
    return(result);
}

- (NSData*)sendText:(NSString*)msg toGroup:(NSString*)group withOptions:(WSChannelOptions)options didFailWithError:(NSError**)error {
    NSString*               urlString  = [[NSString alloc] initWithFormat:@"/services/data/v24.0/chatter/feeds/record/%@/feed-items/", group];
	NSMutableURLRequest*	theRequest = [self generatePostRequest:urlString withParameter:msg];
	NSURLResponse* 			response;
	
    NSData* result=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    
    if (result == nil) {
        NSLog(@"Result back after posting mobile data is nil") ;
    }
    
    //id stringReply = (NSString *)[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	
    return(result);
}

- (NSArray*)retrieveFeedForGroup:(NSString *)groupName withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v24.0/chatter/feeds/record/%@/feed-items/", groupName];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
	NSURLResponse* 	      response;

    NSData*       result          = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser          = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
    NSString *    resultStr       = [[NSString alloc] initWithBytes:[result bytes] length:[result length]  encoding:NSASCIIStringEncoding];

    return [participantDict objectForKey:@"items"];
}

- (NSDictionary *)retrieveGoalWithOptions:(NSString *)goalId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Name,description__c,instructions__c,activation__c,motivation__c,expectation__c,reward__c,actionplan__c,category__c,code__c+from+Goal__c+where+Id='%@'", goalId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
	NSURLResponse* 	      response;

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
	
	if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
		NSArray*      list = [participantDict objectForKey:@"records"];
		
		if ((list != nil) && ([list count] > 0)) {
			NSDictionary* attrs = [list objectAtIndex:0];
			return attrs;
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}


- (void)retrieveGoalsForParticipant:(NSString*)participantId withOptions:(WSChannelOptions)options  didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Goal__c+from+Participantgoals__c+where+Participant__c+='%@'", participantId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
	NSURLResponse* 	      response;
	GoalDAO*              dao = [GoalDAO new];

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
	NSString*     resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	
	[dao deleteAll];
	
	if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
		NSArray*      list = [participantDict objectForKey:@"records"];
		
		if (list != nil) {
			for (NSDictionary* rowDict in list) {
				NSString* goalId = [rowDict objectForKey:@"Goal__c"];
				
				if ([StringUtils isNotEmpty:goalId]) {
					
					NSDictionary* goalResult = [self retrieveGoalWithOptions:goalId withOptions:WSChannelOptionNone didFailWithError:nil];
					
					if (goalResult != nil) {
						Goal* goal = [Goal new];
						
						if (([goalResult objectForKey:@"Name"] != nil) && (![[goalResult objectForKey:@"Name"] isKindOfClass:[NSNull class]]))
							goal.name = [goalResult objectForKey:@"Name"];
						
						if (([goalResult objectForKey:@"code__c"] != nil) && (![[goalResult objectForKey:@"code__c"] isKindOfClass:[NSNull class]]))
							goal.code = [goalResult objectForKey:@"code__c"];
						
						if (([goalResult objectForKey:@"description__c"] != nil) && (![[goalResult objectForKey:@"description__c"] isKindOfClass:[NSNull class]]))
							goal.description = [goalResult objectForKey:@"description__c"];
						
						if (([goalResult objectForKey:@"instructions__c"] != nil) && (![[goalResult objectForKey:@"instructions__c"] isKindOfClass:[NSNull class]]))
							goal.instructions = [goalResult objectForKey:@"instructions__c"];
						
						if (([goalResult objectForKey:@"activation__c"] != nil) && (![[goalResult objectForKey:@"activation__c"] isKindOfClass:[NSNull class]]))
							goal.activation = [goalResult objectForKey:@"activation__c"];
						
						if (([goalResult objectForKey:@"motivation__c"] != nil) && (![[goalResult objectForKey:@"motivation__c"] isKindOfClass:[NSNull class]]))
							goal.personalValue = [goalResult objectForKey:@"motivation__c"];
						
						if (([goalResult objectForKey:@"expectation__c"] != nil) && (![[goalResult objectForKey:@"expectation__c"] isKindOfClass:[NSNull class]]))
							goal.expectationOfSuccess = [goalResult objectForKey:@"expectation__c"];
						
						if (([goalResult objectForKey:@"reward__c"] != nil) && (![[goalResult objectForKey:@"reward__c"] isKindOfClass:[NSNull class]]))
							goal.reward = [goalResult objectForKey:@"reward__c"];
						
						if (([goalResult objectForKey:@"category__c"] != nil) && (![[goalResult objectForKey:@"category__c"] isKindOfClass:[NSNull class]]))
							goal.ontology = [[NSString alloc] initWithFormat:@"%@", [goalResult objectForKey:@"category__c"]];
												
						if (([goalResult objectForKey:@"actionplan__c"] != nil) && (![[goalResult objectForKey:@"actionplan__c"] isKindOfClass:[NSNull class]]))
							goal.actionPlan = [goalResult objectForKey:@"actionplan__c"];
						
						[goal allocateObjectId];
						
						[dao insert:goal];
					}	
				}
			}
		} else {
			return;
		}
	} else {
		return;
	}
}

- (NSDictionary *)retrieveTaskWithOptions:(NSString *)activityId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Name,description__c,instructions__c,activation__c,priority__c,repeat__c,status__c,actionplan__c,ontology__c,code__c+from+Activity__c+where+Id='%@'", activityId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
 	NSURLResponse* 	      response;

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
	
	if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
		NSArray*      list = [participantDict objectForKey:@"records"];
		
		if ((list != nil) && ([list count] > 0)) {
			NSDictionary* attrs = [list objectAtIndex:0];
			return attrs;
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

- (void)retrieveTasksForParticipant:(NSString *)participantId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Activity__c+from+participantactivities__c+where+Participant__c+='%@'", participantId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
	NSURLResponse* 	      response;
	TaskDAO*              dao = [TaskDAO new];

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
	NSString*     resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	
	[dao deleteAll];
	
	if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
		NSArray*      list = [participantDict objectForKey:@"records"];
		
		if (list != nil) {
			for (NSDictionary* rowDict in list) {
				NSString* taskId = [rowDict objectForKey:@"Activity__c"];
				
				if ([StringUtils isNotEmpty:taskId]) {
					
					NSDictionary* taskResult = [self retrieveTaskWithOptions:taskId withOptions:WSChannelOptionNone didFailWithError:nil];
					
					if (taskResult != nil) {
						Task* task = [Task new];
						
						if (([taskResult objectForKey:@"Name"] != nil) && (![[taskResult objectForKey:@"Name"] isKindOfClass:[NSNull class]]))
							task.name = [taskResult objectForKey:@"Name"];
						
						if (([taskResult objectForKey:@"code__c"] != nil) && (![[taskResult objectForKey:@"code__c"] isKindOfClass:[NSNull class]]))
							task.code = [taskResult objectForKey:@"code__c"];
						
						if (([taskResult objectForKey:@"description__c"] != nil) && (![[taskResult objectForKey:@"description__c"] isKindOfClass:[NSNull class]]))
							task.description = [taskResult objectForKey:@"description__c"];
						
						if (([taskResult objectForKey:@"instructions__c"] != nil) && (![[taskResult objectForKey:@"instructions__c"] isKindOfClass:[NSNull class]]))
							task.instructions = [taskResult objectForKey:@"instructions__c"];
						
						if (([taskResult objectForKey:@"activation__c"] != nil) && (![[taskResult objectForKey:@"activation__c"] isKindOfClass:[NSNull class]]))
							task.activation = [taskResult objectForKey:@"activation__c"];
						
						if (([taskResult objectForKey:@"priority__c"] != nil) && (![[taskResult objectForKey:@"priority__c"] isKindOfClass:[NSNull class]]))
							task.priority = [taskResult objectForKey:@"priority__c"];
						
						if (([taskResult objectForKey:@"repeat__c"] != nil) && (![[taskResult objectForKey:@"repeat__c"] isKindOfClass:[NSNull class]]))
							task.repeat = [[taskResult objectForKey:@"repeat__c"] intValue];
						
						if (([taskResult objectForKey:@"status__c"] != nil) && (![[taskResult objectForKey:@"status__c"] isKindOfClass:[NSNull class]]))
							task.status = [taskResult objectForKey:@"status__c"];
						
						if (([taskResult objectForKey:@"ontology__c"] != nil) && (![[taskResult objectForKey:@"ontology__c"] isKindOfClass:[NSNull class]]))
							task.ontology = [[NSString alloc] initWithFormat:@"http://www.carethings.com/ontology/classification#%@", [taskResult objectForKey:@"ontology__c"]];
						
						//if (([taskResult objectForKey:@"actionplan__c"] != nil) && (![[taskResult objectForKey:@"actionplan__c"] isKindOfClass:[NSNull class]]))
						task.actionPlan = [[NSURL alloc] initWithString:@"http://www.carethings.com/postbehavior/protocol#PrimeTaskExperience"]; //[taskResult objectForKey:@"actionplan__c"];
						
						[task allocateObjectId];
						
						[dao insert:task];
					}
				}
			}
		} else {
			return;
		}
	} else {
		return;
	}
}

- (NSString*)retrieveParticipantIdForParticipant:(NSString*)partId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Id+from+Participant__c+where+participantid__c='%@'", partId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
	NSURLResponse* 	      response;

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];	
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];
	
	if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
		NSArray*      list = [participantDict objectForKey:@"records"];
		
		if ((list != nil) && ([list count] > 0)) {
			NSDictionary* attrs = [list objectAtIndex:0];
			return [attrs objectForKey:@"Id"];
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

- (NSString*)retrieveParticipantNameForParticipant:(NSString*)partId withOptions:(WSChannelOptions)options didFailWithError:(NSError **)error {
    NSString*             urlString  = [[NSString alloc] initWithFormat:@"/services/data/v20.0/query/?q=SELECT+Name+from+Participant__c+where+participantid__c='%@'", partId];
    NSMutableURLRequest*  theRequest = [self generateGetRequest:urlString];
    NSURLResponse* 	      response;

    NSData*       result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* participantDict = [parser objectWithData:result];

    if ((participantDict != nil) && ([participantDict objectForKey:@"error"] == nil)) {
        NSArray*      list = [participantDict objectForKey:@"records"];

        if ((list != nil) && ([list count] > 0)) {
            NSDictionary* attrs = [list objectAtIndex:0];
            return [attrs objectForKey:@"Name"];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Here in connection did finish loading");
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

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData  {
    //NSString *retData = [[NSString alloc] initwithData:theData encoding:NSUTF8StringEncoding];
    //NSLog(@"String sent from server %@",retData);
	// The token returned by Salesforce aka ID can be combined with the http link as below to access attachments
	// https://c.na12.content.force.com/servlet/servlet.FileDownload?file=00PU0000000VyxtMAC
    // do an upert here and remove waiting view
    // Create SBJSON object to parse JSON
    //SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    //NSDictionary *retObject = [parser objectWithData:theData];
}

@end
