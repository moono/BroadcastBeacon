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

// add import for application data
#import "ApplicationData.h"

// add import for other views
#import "FileViewController.h"
#import "HTTPCommunicationViewController.h"


@interface MonitoringHomeTableViewController () <ESTBeaconManagerDelegate, UITabBarControllerDelegate>

// Propeties that will be sent to other views
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *regionIdentifier;

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
    
    // request authorization
    [_beaconManager requestAlwaysAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"Home-viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"Home-viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ESTBeaconManager delegate
- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    // remove all list
    [_beaconsInRange removeAllObjects];
    
    ApplicationData *appData = [ApplicationData defaultInstance];
    
    for (CLBeacon *beacon in beacons) {
        // extract information & save as array of NSDictionary
        NSString *proximity = [appData convertProximityToString:beacon.proximity];
        
        [_beaconsInRange addObject:@{kMajor : beacon.major,
                                     kAccuracy : @(beacon.accuracy),
                                     kProximity : proximity}];
    }
    
    // update UI
    [self.tableView reloadData];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *destination = [segue destinationViewController];
    
    if([segue.identifier isEqualToString:@"displayIdSegue"]) {
        destination = [segue.destinationViewController topViewController];
    }
}


@end
