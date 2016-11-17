//
//  TMExifInfo.h
//  SkillApp
//
//  Created by Тарас on 16.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TMExifInfoDelegate;

@interface TMExifInfo : NSObject

@property (assign, nonatomic) id delegate;

- (void)collectEXIFdata:(NSURL*)assetURL;

//+ (void)modifyEXIFdata:(NSDictionary*)exifData;

+ (NSDictionary*)getExifDataFromURL:(NSURL*)fileURL;

@end

@protocol TMExifInfoDelegate <NSObject>

- (void)dataCollected:(NSDictionary*)exifData;

@end
