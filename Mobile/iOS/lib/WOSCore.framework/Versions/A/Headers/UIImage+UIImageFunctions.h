//
// Created by lsuarez on 12/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (UIImageFunctions)
- (UIImage *) scaleToSize: (CGSize)size;
- (UIImage *) scaleProportionalToSize: (CGSize)size;
@end