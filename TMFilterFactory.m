//
//  TMFilterFactory.m
//  SkillApp
//
//  Created by Тарас on 15.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMFilterFactory.h"

@implementation TMFilterFactory

+ (UIImage*) applyMonochromeFilterOnImage:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:ciimg forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    CIContext   *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) rotateImage:(UIImage*)image byDegrees:(int)degrees {
    
    float rotationAngle = degrees * M_PI/180;
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
    [rotate setValue:ciimg forKey:kCIInputImageKey];
    
    CGAffineTransform t = CGAffineTransformMakeRotation(rotationAngle);
    [rotate setValue:[NSValue valueWithBytes:&t
                                    objCType:@encode(CGAffineTransform)]
              forKey:@"inputTransform"];
    
    CIImage *result = [rotate outputImage];
    CIContext   *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) mirrorImage:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
    [rotate setValue:ciimg forKey:kCIInputImageKey];
    
    CGAffineTransform t = CGAffineTransformMakeScale(-1, 1);
    
    [rotate setValue:[NSValue valueWithBytes:&t
                                    objCType:@encode(CGAffineTransform)]
              forKey:@"inputTransform"];
    
    CIImage *result = [rotate outputImage];
    CIContext   *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];

    return resultImg;
}

+ (UIImage*) invertColors:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:ciimg forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    CIContext   *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

@end
