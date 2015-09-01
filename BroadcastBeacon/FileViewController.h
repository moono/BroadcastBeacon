//
//  FileViewController.h
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)startStopSaving:(id)sender;
- (IBAction)clearFileContents:(id)sender;
@end
