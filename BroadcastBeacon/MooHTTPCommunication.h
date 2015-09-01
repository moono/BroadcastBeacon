//
//  MooHTTPCommunication.h
//  BeaconDistance
//
//  Created by mookyung song on 8/17/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MooHTTPCommunication : NSObject <NSURLSessionDownloadDelegate>

- (void)postURL:(NSURL *)url params:(id)params successBlock:(void (^)(NSData *))successBlock;
@end
