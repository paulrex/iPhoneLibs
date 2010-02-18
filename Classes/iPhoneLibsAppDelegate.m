//
//  iPhoneLibsAppDelegate.m
//  iPhoneLibs
//
//  Created by Mahipal Raythattha on 2/18/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iPhoneLibsAppDelegate.h"

@implementation iPhoneLibsAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
