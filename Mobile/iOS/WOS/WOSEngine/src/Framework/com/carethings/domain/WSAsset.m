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

#import "WSAsset.h"
#import "OpenPATHEngine.h"
#import "WOSCore/OpenPATHCore.h"

@implementation WSAsset

- (id)initWithXML: (__unused NSString*)xml {
		self = [super init];

		if (self) {
		}

		return self;
}

- (id) initWithAsset: (Asset*) asset {
		self = [super init];

		if (self) {
				asset_ = asset;
		}

		return self;
}

- (NSString*) generateJson {
    NSMutableString* asset = [[NSMutableString alloc] initWithString: @"         {\n"];
  
  	if ([WSStringUtils isNotEmpty: asset_.assetID]) {
  		[asset appendString: @"          \"assetID\" : \""];
  		[asset appendString: asset_.assetID];
  		[asset appendString: @"\",\n"];
  	}
	
	if ([WSStringUtils isNotEmpty: asset_.objectID]) {
  		[asset appendString: @"          \"objectID\" : \""];
  		[asset appendString: asset_.objectID];
  		[asset appendString: @"\",\n"];
  	}
  
    if ([WSStringUtils isNotEmpty: asset_.timeLength]) {
  		[asset appendString: @"          \"timeLength\" : \""];
  		[asset appendString: asset_.timeLength];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.fileSize]) {
  		[asset appendString: @"          \"fileSize\" : \""];
  		[asset appendString: asset_.fileSize];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.relatedID]) {
  		[asset appendString: @"          \"relatedID\" : \""];
  		[asset appendString: asset_.relatedID];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.originator]) {
  		[asset appendString: @"          \"originator\" : \""];
  		[asset appendString: asset_.originator];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.location]) {
  		[asset appendString: @"          \"location\" : \""];
  		[asset appendString: asset_.location];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.locationCode]) {
  		[asset appendString: @"          \"locationCode\" : \""];
  		[asset appendString: asset_.locationCode];
  		[asset appendString: @"\",\n"];
  	}

    if ([WSStringUtils isNotEmpty: asset_.patientID]) {
  		[asset appendString: @"          \"patientID\" : \""];
  		[asset appendString: asset_.patientID];
  		[asset appendString: @"\",\n"];
  	}

    [asset appendString: @"	      \"assetType\" : \""];


    if (asset_.assetType == AssetTypeUnknown) {
        [asset appendString:@"Unknown"];
    } else if (asset_.assetType == AssetTypePhoto) {
        [asset appendString:@"Photo"];
    } else if (asset_.assetType ==AssetTypeVideo) {
        [asset appendString:@"Video"];
    } else if (asset_.assetType ==AssetTypeAudio) {
        [asset appendString:@"Audio"];
    } else if (asset_.assetType ==AssetTypeDateTime) {
        [asset appendString:@"Timestamp"];
    } else if (asset_.assetType ==AssetTypeText) {
        [asset appendString:@"Log"];
    }

    [asset appendString: @"\",\n"];

  	[asset appendString: @"	      \"creationTime\" : \""];
  	[asset appendString:[NSString stringWithFormat: @"%@", [DateFormatter localizedStringFromUSDateString:asset_.creationTime]]];
  	[asset appendString: @"\"\n"];
  	[asset appendString: @"         }\n"];
  
  	return asset;
}

- (NSString*) generateGalleryAlbumJson {
    NSMutableString* asset = [[NSMutableString alloc] initWithString: @"         {\n"];

    [asset appendString: @"          \"type\" : \"album\"\n"];

    if ([WSStringUtils isNotEmpty: asset_.container]) {
   		[asset appendString: @",         \"name\" : \""];
   		[asset appendString: asset_.container];
   		[asset appendString: @"\"\n"];
   	}

  	if ([WSStringUtils isNotEmpty: asset_.assetID]) {
  		[asset appendString: @",         \"title\" : \""];
  		[asset appendString: asset_.assetID];
  		[asset appendString: @"\"\n"];
  	}

  	[asset appendString: @"         }\n"];

  	return asset;
}

- (NSString*) generateGalleryPhotoJson {
    NSMutableString* asset = [[NSMutableString alloc] initWithString: @"         {\n"];

    [asset appendString: @"          \"type\" : \"photo\"\n"];

    if ([WSStringUtils isNotEmpty: asset_.container]) {
   		[asset appendString: @",         \"name\" : \""];
   		[asset appendString: asset_.container];
   		[asset appendString: @"\"\n"];
   	}

  	if ([WSStringUtils isNotEmpty: asset_.assetID]) {
  		[asset appendString: @",         \"title\" : \""];
  		[asset appendString: asset_.assetID];
  		[asset appendString: @"\"\n"];
  	}

  	[asset appendString: @"         }\n"];

  	return asset;
}

/*
NSData *imageData =
        UIImageJPEGRepresentation(
                self.image,
                GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5);
NSString *imageName =
        [@"Mobile_" stringByAppendingString:[NSString stringWithFormat:@"%d",
                                             GlobalSettings.uploadCounter++]];
NSString *imageCaption =
        ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
NSDictionary *metaData =
        [NSDictionary dictionaryWithObjectsAndKeys:
         imageName, @"name",
         (imageCaption == nil) ? @""              :imageCaption, @"description",
         @"photo", @"type",
         nil];



NSError *error = nil;
id <RKParser> parser = [RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
NSString *metaDataString = [parser stringFromObject:metaData error:&error];

[postParams setValue:metaDataString forParam:@"entity"];
[postParams setData:imageData MIMEType:@"application/octet-stream" forParam:@"file"];

NSString *resourcePath = [@"/rest/item/" stringByAppendingString:self.albumID];

[client post:resourcePath params:postParams delegate:self];

*/








@end