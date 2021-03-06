//
//  TMDownloadManager.m
//  SkillApp
//
//  Created by Тарас on 15.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMDownloadManager.h"

@interface TMDownloadManager ()

@property (strong, nonatomic) NSURL* url;

@end

@implementation TMDownloadManager

@synthesize delegate;



- (void)downloadImageFromURL:(NSString*)url {
    
    NSURL* urlLink = [NSURL URLWithString:url];
    _url = urlLink;
    NSURLRequest *request = [NSURLRequest requestWithURL:urlLink];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (connection == nil) {
        [delegate handleError];
    }
}

#pragma mark - NSURLConnectionDelegate

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
    [delegate imageDidLoad:image fromURL:_url];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [delegate handleError];
}

@end
