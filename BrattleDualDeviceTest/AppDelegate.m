//
//  AppDelegate.m
//  BrattleDualDeviceTest
//
//  Created by Teresa Brooks on 5/14/12.
//  Copyright (c) 2012 Quarks and Bits. All rights reserved.
//

#import "AppDelegate.h"
#import "TGAccessoryManager.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } 
    else 
    {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    
    //do mindwave set up
    [self doMindWaveAccessorySetUp];
    
    //set the viewController to the root view controller of the app window.
    self.window.rootViewController = self.viewController;
    
    //make window the key window and make it visible
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)doMindWaveAccessorySetUp
{
    NSLog(@"Doing mind wave accessory setup...");
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    TGAccessoryType accessoryType = (TGAccessoryType)[defaults integerForKey:@"accessory_type_preference"];
    BOOL rawEnabled = [defaults boolForKey:@"raw_enabled"];
    
    if(rawEnabled) 
    {
        // setup the TGAccessoryManager to dispatch dataReceived notifications every 0.05s (20 times per second)
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.05 forAccessoryType:accessoryType];
    } 
    else 
    {
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.2 forAccessoryType:accessoryType];
    }
    
    // set the root UIViewController as the delegate object.
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:self.viewController];
    [[TGAccessoryManager sharedTGAccessoryManager] setRawEnabled:rawEnabled];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
