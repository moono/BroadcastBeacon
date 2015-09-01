//
//  OpenFileViewController.h
//  BroadcastBeacon
//
//  Created by mookyung song on 9/1/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenFileViewController : UIViewController

//@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *fileName;

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)closeView:(id)sender;

@end
