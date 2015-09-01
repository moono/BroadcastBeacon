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


@interface HTTPCommunicationViewController () <ESTBeaconManagerDelegate>

// Propeties that will be sent to other views
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *regionIdentifier;

// properties for Estimote beacon
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *beaconsInRange;   // these are array of NSDictionary

@end

@implementation HTTPCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // initialize strings
    ApplicationData *appData = [ApplicationData defaultInstance];
    _uuid = [appData uuid];
    _regionIdentifier = [appData regionIdentifier];
    
    // initialize beacon properties
    _beaconsInRange = [[NSMutableArray alloc] init];
    _beaconManager = [[ESTBeaconManager alloc] init];
    _beaconManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:_uuid];         // Estimote beacon's UUID are the same on factory settings
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:_regionIdentifier];
    
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

@end
