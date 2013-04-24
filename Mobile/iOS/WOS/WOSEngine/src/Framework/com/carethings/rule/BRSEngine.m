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

#import "BRSEngine.h"
#import "WOSCore/OpenPATHCore.h"

@implementation BRSEngine

@synthesize environment;

//SYNTHESIZE_SINGLETON_FOR_CLASS(SessionManager);

static BRSEngine *sharedBRSEngine = nil;

+ (BRSEngine *)sharedBRSEngine { 
	@synchronized(self) { 
		if (sharedBRSEngine == nil) { 
			sharedBRSEngine = [self new]; 
		} 
	} 
	
	return sharedBRSEngine; 
} 

/*
+ (id)allocWithZone:(NSZone *)zone { 
	@synchronized(self) { 
		if (sharedBRSEngine == nil) { 
			sharedBRSEngine = [super allocWithZone:zone]; 
			return sharedBRSEngine; 
		} 
	} 
	
	return nil; 
} 

- (id)copyWithZone:(NSZone *)zone { 
	return self; 
} 

- (id)retain { 
	return self; 
} 

- (NSUInteger)retainCount { 
	return NSUIntegerMax; 
} 

- (void)release { 
} 

- (id)autorelease { 
	return self; 
}
 */

-(void)initializeRuleBase {
	char buffer[1000];
	memset(buffer, '\0', 1000);
		
	InitializeEnvironment();
	
	self.environment = CreateEnvironment();
	
	//sprintf(buffer, "(watch all)");
		
	//  Add the RDF triple template.
	NSString*  defaultRDFTemplate = @"(deftemplate MAIN::RDFTriple (slot subject) (slot predicate) (slot object))";
	
	[self addFact:nil factTemplate:defaultRDFTemplate];
}

-(NSString*)listRules {
	char* theStringRouter = "*** listdefrules-in-analyzedata ***";
	char  theString[9000];
	
	memset(theString, '\0', 9000);
	
	OpenStringDestination(environment, theStringRouter, theString, 9000);
	EnvListDefrules(environment, theStringRouter, NULL);
	CloseStringDestination(environment, theStringRouter);
	
	return ([[NSString alloc] initWithUTF8String:theString]);
}

-(NSString*)listFacts {
	char* theStringRouter = "*** listdeffacts-in-analyzedata ***";
	char  theString[9000];
	
	memset(theString, '\0', 9000);
	
	OpenStringDestination(environment, theStringRouter, theString, 9000);
	EnvListDeffacts(environment, theStringRouter, NULL);
	CloseStringDestination(environment, theStringRouter);
	
	return ([[NSString alloc] initWithUTF8String:theString]);
}

-(void)addFact:(NSString*)fact factTemplate:(NSString*)template  {
	char buffer[1000];
	memset(buffer, '\0', 1000);
	
	if ((fact == nil) && (template == nil)) 
		return;
	
	if (template != nil) {
		[template getCString:buffer maxLength:1000 encoding:NSASCIIStringEncoding];
		
		int status = EnvLoadFromString(environment, buffer, -1);
				
		if (status <= 0)
			return; // Do nothing for now
	}
	
	if (fact != nil) {
		memset(buffer, '\0', 1000);
		
		//  We need to decorate the fact
		NSMutableString*  finalFact = [[NSMutableString alloc] initWithString:fact];
				
		//[finalFact appendString:fact];
		//[finalFact appendString:@")"];
				
		[finalFact getCString:buffer maxLength:1000 encoding:NSASCIIStringEncoding];
		
		void* factStruct = EnvAssertString(environment, buffer);
				
		if (factStruct == nil) {
			// Got an error.  See if this is really not a fact but some other command
			//int status = EnvLoadFromString(environment, buffer, -1);
			
			buffer[[finalFact length]] = '\n';
			
			CompleteCommand( buffer);
			
			SetCommandString(environment, buffer);
			
			ExecuteIfCommandComplete(environment);
									
			return;
		}
		
		/*
		memset(buffer, '\0', 1000);
		
		[finalFact setString:@"(defrule r1 => (printout t \"Asserted fact "];
		[finalFact appendString:fact];
		[finalFact appendString:@"\" crlf))\n"];
				
		[finalFact getCString:buffer maxLength:1000 encoding:NSASCIIStringEncoding];
		
		int clipsStatus = EnvLoadFromString(environment, buffer, -1);
		
		[finalFact;
		
		if ((clipsStatus == -1) || (clipsStatus == 0)) {
			// Got an error.
			return;
		}		
		
		int i = [self run];
		 */
		
		//NSString* listFacts = [self listFacts];
		//int j = 1;
	}
}

-(void)addFacts:(NSArray*)facts factTemplate:(NSString*)template {
	if ((facts == nil) || ([facts count] == 0))
		return;
	
	for (NSString* fact in facts) {
		[self addFact:fact factTemplate:template];
	}
}

-(int)invokeFunctionWithName:(__unused NSString*)name andArguments:(NSString*)arguments {
	/*
	DATA_OBJECT result;
	
	memset(&result, 0, sizeof(struct dataObject));

	char*       functionName  = (char*)[name UTF8String];
	char*       argumentsChar = (char*)[arguments UTF8String];
	
	int i = FunctionCall(functionName, argumentsChar, &result);
	
	return i;
	*/
	
	char buffer[1000];
	memset(buffer, '\0', 1000);
	
	[arguments getCString:buffer maxLength:1000 encoding:NSASCIIStringEncoding];
	
	char* theStringRouter = "*** factfuncs-in-analyzedata ***";
	char  theString[9000];
	
	memset(theString, '\0', 9000);
	
	OpenStringDestination(environment, theStringRouter, theString, 9000);
	EnvLoadFromString(environment, buffer, -1);
	CloseStringDestination(environment, theStringRouter);
	
	int i = 1;
	
	return i;
}

-(void)retractFact:(NSString*)fact factTemplate:(__unused NSString*)template {
	if (fact == nil)
		return;
	
	char  buffer[9000];
	
	memset(buffer, '\0', 9000);
	
	//  Construct the retraction rule
	NSMutableString*  finalRule = [[NSMutableString alloc] initWithString:@"(defrule "];
	
	NSURL*		ruleResource	= [ResourceIdentityGenerator generateWithPath:@"retractrule"] ;
	NSString*	ruleName		= [[NSString alloc] initWithFormat:@"%@_rule", [ruleResource fragment]];
	
	[finalRule appendString:ruleName];
	[finalRule appendString:@"\n?g <- "];
	[finalRule appendString:fact];
	[finalRule appendString:@"\n=>(retract ?g)"];
	//[finalRule appendString:@"(printout t \"retracted fact "];
	//[finalRule appendString:fact];
	//[finalRule appendString:@"\" crlf)\n"];
	[finalRule appendString:@")\n"];
	
	[finalRule getCString:buffer maxLength:9000 encoding:NSASCIIStringEncoding];
	
	int clipsStatus = EnvLoadFromString(environment, buffer, -1);
	
	if ((clipsStatus == -1) || (clipsStatus == 0)) {
		// Got an error
		return;
	}
	
	[self run];
	
	// Now get rid of the retraction rule
	memset(buffer, '\0', 9000);
	
	[ruleName getCString:buffer maxLength:9000 encoding:NSASCIIStringEncoding];
	
	void* ruleDef = EnvFindDefrule(environment, buffer);
	
	EnvUndefrule(environment, ruleDef);
	
	//NSString* listFacts = [self listFacts];
	
	//int j = 1;
}

-(void)addRules:(NSArray*)rules {
	if ((rules == nil) || ([rules count] == 0))
		return;
	
	for (NSString* rule in rules) {
		[self addRule:rule];
	}
}

-(void)addRule:(NSString*)rule {
	if (rule == nil)
		return;
	
	char  buffer[9000];
	
	memset(buffer, '\0', 9000);
	
	//  We need to decorate the rule
	NSMutableString*  finalRule = [[NSMutableString alloc] initWithString:@"(defrule "];
	
	NSURL*  ruleResource = [ResourceIdentityGenerator generateWithPath:@"rule"] ;
	
	[finalRule appendString:[ruleResource fragment]];
	[finalRule appendString:@"_rule \n"];
	[finalRule appendString:rule];
	[finalRule appendString:@"\n=>"];
	//[finalRule appendString:"(printout t \"fired rule on condition "];
	//[finalRule appendString:rule];
	//[finalRule appendString:@"\" crlf)\n"];
	[finalRule appendString:@")\n"];
	
	//[ruleResource;
	
	[finalRule getCString:buffer maxLength:9000 encoding:NSASCIIStringEncoding];
	
	int clipsStatus = EnvLoadFromString(environment, buffer, -1);
	
	if ((clipsStatus == -1) || (clipsStatus == 0)) {
		// Got an error.
		return;
	}
	
	//NSString* ruleList = [self listRules];
	
	//int i = 1;
}

-(int)run {
	return (int) EnvRun(environment, -1);
}

-(void)reset {
	EnvReset(environment);
}

@end
