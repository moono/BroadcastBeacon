//
//  IDViewController.m
//  BroadcastBeacon
//
//  Created by mookyung song on 9/1/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "IDViewController.h"

#import "ApplicationData.h"


@interface IDViewController ()

@end

@implementation IDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_idTextField setText: [[ApplicationData defaultInstance] uniqueId]];
    _idTextField.enabled = NO;
    _idTextField.userInteractionEnabled = YES;
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

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
