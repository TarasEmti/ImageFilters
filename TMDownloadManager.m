//
//  TMDownloadManager.m
//  SkillApp
//
//  Created by Тарас on 15.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMDownloadManager.h"

@implementation TMDownloadManager

@synthesize delegate;

- (void)downloadImageFromURL:(NSString*)url {
    
    NSURL* urlLink = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlLink];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (connection) {
        NSLog(@"Connection - OK");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    
    self.imageData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.imageData appendData:data];
    self.receivedBytes += data.length;
    
    float progress = self.receivedBytes / (float)self.totalBytes;
    [delegate progressChanged:progress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    UIImage* image = [UIImage imageWithData:self.imageData];
    [delegate imageDidLoad:image];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"Something went wrong in image download");
    [delegate handleError];
}

@end
