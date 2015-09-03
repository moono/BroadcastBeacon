//
//  HTTPCommunicationViewController.m
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "HTTPCommunicationViewController.h"


// add import for Estimote SDK
#import <EstimoteSDK/EstimoteSDK.h>

// add import for application data
#import "ApplicationData.h"

// add import for HTTP service
#import "MooHTTPCommunication.h"


#define SEND_EVERY_5_SECONDS 0

@interface HTTPCommunicationViewController () <ESTBeaconManagerDelegate>

// Propeties that will be sent to other views
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *regionIdentifier;
@property (nonatomic, strong) NSString *deviceUniqueId;

// properties for Estimote beacon
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *beaconsInRange;   // these are array of NSDictionary

// for posting
@property (nonatomic) BOOL isSending;
@property (nonatomic, strong) NSURL *url;
#if SEND_EVERY_5_SECONDS
@property (nonatomic, strong) NSMutableArray *beaconsToPost;
#endif

@end

@implementation HTTPCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // initialize strings
    ApplicationData *appData = [ApplicationData defaultInstance];
    _uuid = [appData uuid];
    _regionIdentifier = [appData regionIdentifier];
    _deviceUniqueId = [appData uniqueId];
    [_receivedResponseTextView setText:@""];
    
    // initialize beacon properties
    _beaconsInRange = [[NSMutableArray alloc] init];
    _beaconManager = [[ESTBeaconManager alloc] init];
    _beaconManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:_uuid];         // Estimote beacon's UUID are the same on factory settings
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:_regionIdentifier];
    
    // for posting
    _isSending = NO;
    _url = [NSURL URLWithString:@"http://192.168.0.2:3000/"];
    [_urlTextField setText:[_url absoluteString]];
#if SEND_EVERY_5_SECONDS
    _beaconsToPost = [[NSMutableArray alloc] init];
#endif
    
    // add event listner
    [_urlTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"HTTP-viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"HTTP-viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextField
- (void)textFieldDidChange:(UITextField *)textField {
    _url = [NSURL URLWithString:textField.text];
}

#pragma mark - ESTBeaconManager delegate
- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    // remove all list
    [_beaconsInRange removeAllObjects];
    
    ApplicationData *appData = [ApplicationData defaultInstance];
    
    for (CLBeacon *beacon in beacons) {
        // extract information & save as array of NSDictionary
        NSString *proximity = [appData convertProximityToString:beacon.proximity];
        NSString *time = [appData getCurrentTimeString];
        
        [_beaconsInRange addObject:@{kDeviceID : _deviceUniqueId,
                                     kMajor : beacon.major,
                                     kMinor : beacon.minor,
                                     kAccuracy : @(beacon.accuracy),
                                     kProximity : proximity,
                                     kRssi : @(beacon.rssi),
                                     kTime : time}];
    }
    
    // send trajectory to url
    if (_isSending == TRUE) {
#if SEND_EVERY_5_SECONDS
        // add beacon list to the end of _beaconsToPost
        [_beaconsToPost addObjectsFromArray:_beaconsInRange];
#else
        if ([_beaconsInRange count] > 0) {
            // prepare for HTTP communication
            MooHTTPCommunication *http = [[MooHTTPCommunication alloc] init];
            
            [http postURL:_url params:_beaconsInRange successBlock:^(NSData *response)
             {
                 [self setTextViewString:response];
             }];
        }
#endif
    }
}

#pragma mark - my methods
- (void)setTextViewString:(NSData *)data {
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    if (data) {
        if(json && !error) {
            NSString *jsonString = [NSString stringWithFormat:@"%@", json];
            NSLog(@"%@", jsonString);
            [_receivedResponseTextView setText:jsonString];
        }
        else {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
            [_receivedResponseTextView setText:responseString];
        }
    }
    else {
        NSLog(@"No response!!");
        [_receivedResponseTextView setText:[NSString stringWithFormat:@"No response!!"]];
    }
}

#if SEND_EVERY_5_SECONDS
- (void)postingMethod {
    if (_isSending) {
        if ([_beaconsToPost count] > 0) {
            // prepare for HTTP communication
            MooHTTPCommunication *http = [[MooHTTPCommunication alloc] init];
            
            [http postURL:_url params:_beaconsToPost successBlock:^(NSData *response)
             {
                 [self setTextViewString:response];
                 
                 // clear contents
                 [_beaconsToPost removeAllObjects];
             }];
        }
        
        
        [self performSelector:@selector(postingMethod) withObject:self afterDelay:5.0];
    }
}
#endif

#pragma mark - action events
- (IBAction)postOnce:(id)sender {
    if ([_beaconsInRange count] > 0) {
        // prepare for HTTP communication
        MooHTTPCommunication *http = [[MooHTTPCommunication alloc] init];
        
        [http postURL:_url params:_beaconsInRange successBlock:^(NSData *response)
         {
             [self setTextViewString:response];
         }];
    }
}

- (IBAction)keepPosting:(id)sender {
    _isSending = !_isSending;
    
    // set UI & post data if needed
    if (_isSending) {
        [_keepPostButton setTitle:@"Stop posting!!" forState:UIControlStateNormal];
#if SEND_EVERY_5_SECONDS
        [self postingMethod];
#endif
    }
    else {
        [_keepPostButton setTitle:@"Post data!!" forState:UIControlStateNormal];
    }
}
@end
