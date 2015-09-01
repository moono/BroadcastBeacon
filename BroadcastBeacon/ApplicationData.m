//
//  ApplicationData.m
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "ApplicationData.h"

@implementation ApplicationData

+ (ApplicationData *) defaultInstance
{
    static ApplicationData *singleton = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
                  {
                      singleton = [[super alloc] init];
                  });
    
    return singleton;
}

// override init
- (instancetype)init {
    self = [super init];
    
    // set strings
    _uuid = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    _regionIdentifier = @"rangedRegion";
    
    return self;
}

#pragma mark - my methods
- (NSString *)convertProximityToString:(CLProximity)proximity {
    NSString *returnString = nil;
    switch (proximity) {
        case CLProximityUnknown:
            returnString = @"Unknown";
            break;
        case CLProximityImmediate:
            returnString = @"Immediate";
            break;
        case CLProximityNear:
            returnString = @"Near";
            break;
        case CLProximityFar:
            returnString = @"Far";
            break;
        default:
            returnString = @"Unknown";
            break;
    }
    
    return returnString;
}

- (NSString *)getCurrentTimeString {
    // get current date/time
    long long timeInMs = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *now = [@(timeInMs) stringValue];
    
    return now;
}
@end
