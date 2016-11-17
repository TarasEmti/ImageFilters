//
//  TMDownloadManager.h
//  SkillApp
//
//  Created by Тарас on 15.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TMDownloadManagerDelegate;

@interface TMDownloadManager : NSObject <NSURLConnectionDataDelegate> 

@property (nonatomic, assign) id  delegate;

@property (nonatomic) NSMutableData *imageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;

- (void)downloadImageFromURL:(NSString*)url;

@end

@protocol TMDownloadManagerDelegate <NSObject>

- (void) imageDidLoad:(UIImage*)image fromURL:(NSURL*)url;
- (void) progressChanged:(float)progress;
- (void) handleError;

@end
