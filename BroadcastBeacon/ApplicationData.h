//
//  ApplicationData.h
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


// add defines for easy NSDictionary access
#define kMajor @"major"             // number
#define kMinor @"minor"             // number
#define kAccuracy @"accuracy"       // number
#define kRssi @"rssi"               // number
#define kProximity @"proximity"     // string
#define kTime  @"time"              // string
#define kDeviceID @"ID"             // string

@interface ApplicationData : NSObject

// propeties
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *regionIdentifier;

// initiating method
+ (ApplicationData *)defaultInstance;


// class method
- (NSString *)convertProximityToString:(CLProximity)proximity;
- (NSString *)getCurrentTimeString;

@end
