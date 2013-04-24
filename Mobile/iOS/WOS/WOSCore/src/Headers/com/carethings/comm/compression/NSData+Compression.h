//
//  NSData+Compression.h
//  carePATHFramework
//
//  Created by Larry Suarez on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface NSData (Compression)

- (NSData*)compressedData;
- (NSData*)decompressedData;

@end
