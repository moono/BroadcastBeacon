//
//  FileViewController.m
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "FileViewController.h"


// add import for Estimote SDK
#import <EstimoteSDK/EstimoteSDK.h>

// add import for application data
#import "ApplicationData.h"

@interface FileViewController () <ESTBeaconManagerDelegate>

// Propeties that will be sent to other views
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *regionIdentifier;

// properties for Estimote beacon
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *beaconsInRange;   // these are array of NSDictionary

// properties for saving as file
@property (nonatomic) BOOL isTrajectorySaving;
@property (nonatomic, strong) NSString *currentDirectory;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSMutableString *contents;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _currentDirectory = [paths objectAtIndex:0];
    
    // initialize file name
    _fileName = @"moo_trajectory_save.txt";
    _isTrajectorySaving = FALSE;
    _contents = [[NSMutableString alloc] init];
    
    // initialize strings
    ApplicationData *appData = [ApplicationData defaultInstance];
    _uuid = [appData uuid];
    _regionIdentifier = [appData regionIdentifier];
    [_textView setText:@""];
    
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
    NSLog(@"File-viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"File-viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my methods
- (NSString *)getBeaconStatusString:(NSArray *)beacons {
    // check the size
    if ([beacons count] == 0) {
        return nil;
    }
    
    // convert to string for writing to file stream
    NSMutableString *content = [NSMutableString new];
    for (NSDictionary *data in beacons) {
        [content appendString:[[NSString alloc] initWithFormat:@"%@, %@, %@, %@, %@\n",
                               [data[kMajor] stringValue],
                               [data[kMinor] stringValue],
                               data[kTime],
                               [data[kAccuracy] stringValue],
                               [data[kRssi] stringValue] ]];
    }
    
    return content;
}

- (void)customObjectViewSetting {
    if (_isTrajectorySaving == TRUE) {
        [_saveButton setTitle:@"Stop Saving" forState:UIControlStateNormal];
    }
    else {
        [_saveButton setTitle:@"Save Trajectory" forState:UIControlStateNormal];
    }
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
        
        [_beaconsInRange addObject:@{kMajor : beacon.major,
                                     kMinor : beacon.minor,
                                     kAccuracy : @(beacon.accuracy),
                                     kProximity : proximity,
                                     kRssi : @(beacon.rssi),
                                     kTime : time}];
    }
    
    // save trajectory if specified
    if (_isTrajectorySaving == TRUE) {
        // get becon status string
        NSString *beaconStatusString = [self getBeaconStatusString:_beaconsInRange];
        
        // check the string
        if (beaconStatusString != nil) {
            // append string
            [_contents appendString:beaconStatusString];
            
            // display contents to text view
            [_textView setText:_contents];
        }
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destination = [segue destinationViewController];
    
    if([segue.identifier isEqualToString:@"viewFileSegue"]) {
        destination = [segue.destinationViewController topViewController];
    }
    
    [destination setValue:_fileName forKey:@"fileName"];
}


#pragma mark - action events
- (IBAction)startStopSaving:(id)sender {
    _isTrajectorySaving = !_isTrajectorySaving;
    
    // start saving
    if (_isTrajectorySaving) {
        // clear contents for new string saving
        _contents = [NSMutableString stringWithString:@""];
    }
    // stop saving(really save it as a file)
    else {
        // make a file name to write the data to using the documents directory:
        NSString *fullName = [_currentDirectory stringByAppendingPathComponent:_fileName];
        
        // check if the file exists
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:fullName]) {
            // create new one and write data
            [_contents writeToFile:fullName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else {
            // append data
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fullName];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[_contents dataUsingEncoding:NSUTF8StringEncoding]];
        }

    }
    
    [self customObjectViewSetting];
}

- (IBAction)clearFileContents:(id)sender {
    // find file and remove
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fullName = [_currentDirectory stringByAppendingPathComponent:_fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fullName error:&error];
    if (success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Removing Done" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    else
    {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Removing Failed" message:@"Fail to remove" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
@end
