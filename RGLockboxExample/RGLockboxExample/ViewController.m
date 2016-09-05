//
//  ViewController.m
//  RGLockboxExample
//
//  Created by Ryan Dignard on 9/5/16.
//  Copyright © 2016 Ryan Dignard. All rights reserved.
//

@import RGLockboxIOS;

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField* keyField;
@property (nonatomic, weak) IBOutlet UITextField* valueField;

@end

@implementation ViewController

- (IBAction)pressedRead {
//    RGLockbox* manager = [RGLockbox manager];
//    self.valueField.text = [[NSString alloc] initWithData:[manager dataForKey:self.keyField.text] encoding:NSUTF8StringEncoding];
}

- (IBAction)pressedSet {
//    RGLockbox* manager = [RGLockbox manager];
//    [manager setData:[self.valueField.text dataUsingEncoding:NSUTF8StringEncoding] forKey:self.keyField.text];
}

@end
