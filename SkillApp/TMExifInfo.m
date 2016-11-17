//
//  TMExifInfo.m
//  SkillApp
//
//  Created by Тарас on 16.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMExifInfo.h"

#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation TMExifInfo

@synthesize delegate;

- (void)collectEXIFdata:(NSURL*)assetURL {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL
             resultBlock:^(ALAsset *asset) {
                 
                 ALAssetRepresentation *img_representation = [asset defaultRepresentation];
                 
                 uint8_t *buffer = (Byte*)malloc(img_representation.size);
                 NSUInteger length = [img_representation getBytes:buffer
                                                       fromOffset:0.0
                                                           length:img_representation.size
                                                            error:nil];
                 
                 if (length != 0) {
                     
                     NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:img_representation.size freeWhenDone:YES];
                     
                     NSDictionary *sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[img_representation UTI], kCGImageSourceTypeIdentifierHint, nil];
                     
                     CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef) sourceOptionsDict);
                     
                     CFDictionaryRef imagePropDict;
                     imagePropDict = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL);
                     
                     CFDictionaryRef exif = (CFDictionaryRef)CFDictionaryGetValue(imagePropDict, kCGImagePropertyExifDictionary);
                     
                     NSDictionary *exifDict = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary*)exif];
                     NSLog(@"Data collected - OK");
                     [delegate dataCollected:exifDict];
                     
                 } else {
                     NSLog(@"Asset length = 0");
                 }
             }
            failureBlock:^(NSError *error) {
                NSLog(@"Could not get asset!");
            }];
}

+ (NSDictionary*)getExifDataFromURL:(NSURL*)fileURL {
    
    CGImageSourceRef fileSourceRef = CGImageSourceCreateWithURL((CFURLRef)fileURL, NULL);
    
    NSDictionary *fileMetaData = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(fileSourceRef, 0, NULL));
    
    NSDictionary *exifDict = [fileMetaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    
    return exifDict;
}
/*
+ (void)modifyEXIFdata:(NSDictionary*)exifData {
    
    
}
*/
@end
