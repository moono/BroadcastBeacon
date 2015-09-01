//
//  MooHTTPCommunication.m
//  BeaconDistance
//
//  Created by mookyung song on 8/17/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "MooHTTPCommunication.h"

@interface MooHTTPCommunication ()
@property (nonatomic, copy) void(^successBlock)(NSData *);
@end

@implementation MooHTTPCommunication

#pragma mark - my methods
- (void)postURL:(NSURL *)url params:(id)params successBlock:(void (^)(NSData *))successBlock {
    _successBlock = successBlock;
    
    
    // set JSON parameter for post
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Sending %@", jsonString);
    }
    
    // set request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:jsonData];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    
    [task resume];
}

#pragma mark - NSURLSessionDownloadDelgate protocol

- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"URLSession:downloadTask:didFinishDownloadingToURL()");
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       _successBlock(data);
                   });
}

@end
