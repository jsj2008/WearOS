//
//  WSGalleryWebServiceDataChannel.m
//  mHealthOpenFramework
//
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

#import "WSGalleryWebServiceDataChannel.h"
#import "CoreUtils.h"


@implementation WSGalleryWebServiceDataChannel

- (id) initWithURL: (NSString*) url {
	self = [super init];

	if (self) {
		webService_ = [[NSURL alloc] initWithString: url];
	}

	return self;
}

-(void)loginWithUsername : (NSString*)username password:(NSString*)password token:(NSString*)token target:(id)target selector:(SEL)selector {
}

-(void)loginWithToken : (NSString*)token target:(id)target selector:(SEL)selector {
}

- (void) sendAsynchronousData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
}

- (NSData*) sendSynchronousData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	NSMutableURLRequest*   urlRequest = [NSMutableURLRequest requestWithURL: webService_];
	NSURLResponse*         response;
	NSError*               err = nil;

	[urlRequest setHTTPMethod: @"POST"];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setHTTPShouldHandleCookies:NO];
	[urlRequest setValue: @"en-CA" forHTTPHeaderField: @"Content-Language"];
    //[urlRequest setValue: @"45f6941a7ef37084e4295f0c20902f49" forHTTPHeaderField: @"X-Gallery-Request-Key"];

    if (CU_IS_FLAG_SET(options, WSChannelOptionOctetStream)) {
        [urlRequest setValue: @"application/octet-stream" forHTTPHeaderField: @"Content-Type"];
    } else {
        [urlRequest setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    }

    /*
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    // post body
    NSMutableData *body = [NSMutableData data];

    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[NSString stringWithFormat:@"--%@\r\n", @"0xKhTmLbOuNdArY"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // add image data
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);

    if (imageData) {
        [body appendData:[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:body];

    // set the content-length
    [urlRequest setValue:[NSString stringWithFormat: @"%d", [body length]] forHTTPHeaderField: @"Content-Length"];

    */

	//[urlRequest setTimeoutInterval: 10.0];

	NSData*   result = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: &response error: &err];
	//NSString* resultStr = nil;

	if (result == nil) {
		NSLog(@"Error when sending synchronous request of patient data");

		if (err != nil) {
			NSLog(@" with error domain %@, error code %d, and description %s", err.domain, err.code, [err.localizedDescription UTF8String]);
		}
	} else {
		//resultStr = [NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
	}

	return result;
}

- (void) sendData: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	if (CU_IS_FLAG_SET(options, WSChannelOptionAsynchronous)) {
		[self sendAsynchronousData: data withOptions: options didFailWithError: error];
	} else   {
		[self sendSynchronousData: data withOptions: options didFailWithError: error];
	}
}

- (NSData*) retrieveDataWithOptions: (NSData*) data withOptions: (WSChannelOptions) options didFailWithError: (NSError * *) error {
	NSData* result = nil;

	if (CU_IS_FLAG_SET(options, WSChannelOptionAsynchronous)) {
		[self sendAsynchronousData: data withOptions: options didFailWithError: error];
	} else   {
		result = [self sendSynchronousData: data withOptions: options didFailWithError: error];
	}

	return result;
}

@end