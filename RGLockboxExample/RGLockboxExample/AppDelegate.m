//
//  AppDelegate.m
//  RGLockboxExample
//
//  Created by Ryan Dignard on 9/5/16.
//  Copyright © 2016 Ryan Dignard. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate
@synthesize window = _window;

- (BOOL) application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [ViewController new];
    return YES;
}

@end
