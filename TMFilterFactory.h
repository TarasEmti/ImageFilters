//
//  TMFilterFactory.h
//  SkillApp
//
//  Created by Тарас on 15.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMFilterFactory : NSObject

+ (UIImage*) applyMonochromeFilterOnImage:(UIImage*)image;

+ (UIImage*) rotateImage:(UIImage*)image byDegrees:(int)degrees;

+ (UIImage*) mirrorImage:(UIImage*)image;

+ (UIImage*) invertColors:(UIImage*)image;

+ (UIImage*) mirrorLeftHalf:(UIImage*)image;

@end

