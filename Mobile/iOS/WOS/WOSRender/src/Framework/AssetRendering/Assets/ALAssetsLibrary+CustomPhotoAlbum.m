//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AVFoundation/AVAsset.h>


@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveAudio:(NSURL*)audioPathURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    AVURLAsset*  assetURL = [[AVURLAsset alloc] initWithURL:audioPathURL options:nil];
		
	//add the asset to the custom photo album
	[self addAssetURL: assetURL.URL 
			  toAlbum:albumName 
	  withCompletionBlock:completionBlock];
}

-(void)saveVideo:(NSURL*)videoPathURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    [self writeVideoAtPathToSavedPhotosAlbum:videoPathURL completionBlock:^(NSURL* assetURL, NSError* error) {
		
		//error handling
		if (error!=nil) {
			completionBlock(nil, error);
			return;
		}
		
		//add the asset to the custom photo album
		[self addAssetURL: assetURL 
				  toAlbum:albumName 
	  withCompletionBlock:completionBlock];
		
	}];
}

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName metadata:(NSDictionary*)metadata withCompletionBlock:(SaveImageCompletion)completionBlock {
    [self writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:^(NSURL* assetURL, NSError* error) {
                              
                          //error handling
                          if (error!=nil) {
                              completionBlock(nil, error);
                              return;
                          }

                          //add the asset to the custom photo album
                          [self addAssetURL: assetURL 
                                    toAlbum:albumName 
                        withCompletionBlock:completionBlock];
                          
                      }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum 
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL 
                                      resultBlock:^(ALAsset *asset) {
                                                  
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(assetURL, nil);
                                          
                                      } failureBlock: nil];

                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                ALAssetsLibrary* weakSelf = self;

                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName 
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                  
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL 
                                                                        resultBlock:^(ALAsset *asset) {

                                                                            //add photo to the newly created album
                                                                            [group addAsset: asset];
                                                                            
                                                                            //call the completion block
                                                                            completionBlock(assetURL, nil);

                                                                        } failureBlock: nil];
                                                          
                                                      } failureBlock: nil];

                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: nil];
    
}

@end
