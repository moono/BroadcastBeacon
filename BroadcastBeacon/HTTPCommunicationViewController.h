//
//  HTTPCommunicationViewController.h
//  BroadcastBeacon
//
//  Created by mookyung song on 8/31/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTTPCommunicationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *postOnceButton;
@property (weak, nonatomic) IBOutlet UIButton *keepPostButton;
@property (weak, nonatomic) IBOutlet UITextView *receivedResponseTextView;


- (IBAction)postOnce:(id)sender;
- (IBAction)keepPosting:(id)sender;
@end
