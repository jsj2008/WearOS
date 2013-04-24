//
// Created by lsuarez on 12/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <UIKit/UIKit.h>
#import "UIImage+UIImageFunctions.h"


@implementation UIImage (UIImageFunctions)

- (UIImage *) scaleToSize: (CGSize)size {
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef    context    = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));

    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    }

    CGImageRef scaledImage=CGBitmapContextCreateImage(context);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    UIImage *image = [UIImage imageWithCGImage: scaledImage];

    CGImageRelease(scaledImage);

    return image;
}

- (UIImage *) scaleProportionalToSize: (CGSize)size {
    float widthRatio = size.width/self.size.width;
    float heightRatio = size.height/self.size.height;

    if (widthRatio > heightRatio) {
        size=CGSizeMake(self.size.width*heightRatio,self.size.height*heightRatio);
    } else {
        size=CGSizeMake(self.size.width*widthRatio,self.size.height*widthRatio);
    }

    return [self scaleToSize:size];
}

@end