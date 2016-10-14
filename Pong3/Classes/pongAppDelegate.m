/*
//
//  pongAppDelegate.m
//	Pong
//
//  Created by Ken Maskrey on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
*/


#import "pongAppDelegate.h"
#import "pongViewController.h"

@implementation pongAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize paddlePosition;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
