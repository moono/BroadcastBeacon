//
//  OpenFileViewController.m
//  BroadcastBeacon
//
//  Created by mookyung song on 9/1/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "OpenFileViewController.h"

//// add import for segue
//#import "FileViewController.h"


@interface OpenFileViewController ()

@end

@implementation OpenFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_textView setText:@""];
    [self setTextViewContents:_fileName];
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

#pragma mark - my methods
- (void)setTextViewContents:(NSString *)fileName {
    // get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    // open file and set text to textView
    NSString *file = [documentsPath stringByAppendingPathComponent:fileName];
    
    [_textView setText:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
}

#pragma mark - action events
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
