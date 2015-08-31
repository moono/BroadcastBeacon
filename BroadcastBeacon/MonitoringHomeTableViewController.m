//
//  MonitoringHomeTableViewController.m
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "MonitoringHomeTableViewController.h"

// add import for Estimote SDK
#import <EstimoteSDK/EstimoteSDK.h>


// add defines for easy NSDictionary access
#define kMajor @"major"             // number
#define kMinor @"minor"             // number
#define kAccuracy @"accuracy"       // number
#define kRssi @"rssi"               // number
#define kProximity @"proximity"     // string
#define kTime  @"time"              // string


@interface MonitoringHomeTableViewController () <ESTBeaconManagerDelegate>

// properties for Estimote beacon
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *beaconsInRange;   // these are array of NSDictionary

@end

@implementation MonitoringHomeTableViewController

#pragma mark - Table view protocols
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // initialize beacon properties
    _beaconsInRange = [[NSMutableArray alloc] init];
    _beaconManager = [[ESTBeaconManager alloc] init];
    _beaconManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];         // Estimote beacon's UUID are the same on factory settings
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"ranged region"];
    
    // request authorization
    [_beaconManager requestAlwaysAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController *destination = [segue destinationViewController];
//    
//    if ([segue.identifier isEqualToString:@"viewFileSegue"]) {
//        destination = [segue.destinationViewController topViewController];
//    }
//    
//    [destination setValue:self forKey:@"delegate"];
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

#pragma mark - ESTBeaconManager delegate
- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    // remove all list
    [_beaconsInRange removeAllObjects];
    
    for (CLBeacon *beacon in beacons) {
        // extract information & save as array of NSDictionary
        NSString *proximity = [self convertProximityToString:beacon.proximity];
        NSString *time = [self getCurrentTimeString];
        
        [_beaconsInRange addObject:@{kMajor : beacon.major,
                                     kMinor : beacon.minor,
                                     kAccuracy : @(beacon.accuracy),
                                     kProximity : proximity,
                                     kRssi : @(beacon.rssi),
                                     kTime : time}];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_beaconsInRange count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beaconDisplayCell"];
    
    // retrieve data
    NSDictionary *data = _beaconsInRange[indexPath.row];
    
    // show only distance on table view
    if (data != nil) {
        NSString *major = [data[kMajor] stringValue];
        
        NSString *description = [[NSString alloc] initWithFormat:@"%@: %@", data[kProximity], [data[kAccuracy] stringValue]];
        cell.textLabel.text = description;
        if ([major isEqualToString:@"100"]) {
            cell.textLabel.textColor = [UIColor blueColor];
        }
        else if ([major isEqualToString:@"200"]) {
            cell.textLabel.textColor = [UIColor cyanColor];
        }
        else if ([major isEqualToString:@"300"]) {
            cell.textLabel.textColor = [UIColor greenColor];
        }
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
