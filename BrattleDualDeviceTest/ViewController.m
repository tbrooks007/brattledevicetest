//
//  ViewController.m
//  BrattleDualDeviceTest
//
//  Created by Teresa Brooks on 5/14/12.
//  Copyright (c) 2012 Quarks and Bits. All rights reserved.
//

#import "ViewController.h"
#import "RobotKit/RobotKit.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize meditationStatData;
@synthesize attentionStatData;
@synthesize blinkStatData;
@synthesize poorSignalStatData;
@synthesize currentSpheroColor;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //start the input stream for the mindwave headset and create new thread
    //to update UI
    [self startHeadsetInputStreamAndCreateUIUpdateThread];
    
    //register lifecycle notifications so we can connect and disconnect to sphero
    [self registerAppLifeCycleNotificationsForSphero];
}

- (void)viewDidUnload
{
    [self setMeditationStatData:nil];
    [self setAttentionStatData:nil];
    [self setBlinkStatData:nil];
    [self setPoorSignalStatData:nil];
    [self setCurrentSpheroColor:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

- (void)dealloc 
{
    [meditationStatData release];
    [attentionStatData release];
    [blinkStatData release];
    [poorSignalStatData release];
    [currentSpheroColor release];
    [super dealloc];
}

#pragma mark-
#pragma Sphero Related methods (Start Here)

-(void)registerAppLifeCycleNotificationsForSphero
{
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;
}

-(void)appWillResignActive:(NSNotification*)notification 
{
    NSLog(@"Zombie bot is going offline...closing connection.");
    /*When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

-(void)appDidBecomeActive:(NSNotification*)notification
{
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}

- (void)handleRobotOnline 
{
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) 
    {
        NSLog(@"Zombie bot is online!");
        
        /*Only start the blinking loop once*/
        [self toggleLED];
    }
    robotOnline = YES;
}

- (void)toggleLED 
{
    NSLog(@"Toggle Zombie Bot led...");
    
    /*Toggle the LED on and off*/
    if (ledON) 
    {
        ledON = NO;
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
        self.currentSpheroColor.text = @"green";
    } 
    else 
    {
        ledON = YES;
        [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
        self.currentSpheroColor.text = @"red";
    }
    
    [self performSelector:@selector(toggleLED) withObject:nil afterDelay:0.5];
}

-(void)setupRobotConnection 
{
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) 
    {
        NSLog(@"Opening robot connection...");
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];        
    }      
}

#pragma mark-
#pragma MindWave HeadSet Related methods (Start Here)

-(void)startHeadsetInputStreamAndCreateUIUpdateThread
{
    //start the input stream
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil)
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
    //create new thread that will handle updating the UI
    if(updateThread == nil) 
    {
        //target is the object defining the specified selector
        updateThread = [[NSThread alloc] initWithTarget:self selector:@selector(updateStats) object:nil];
        [updateThread start];
    }
}

-(void)updateStats
{
    while(1) 
    {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
        //update UI labels but in main thread, we must do this as the only time the UI is updated is when
        //controll is returned to the main thread.
        [self performSelectorOnMainThread:@selector(updateMindWaveStatsUI) withObject:nil waitUntilDone:NO];
        [pool drain];
        [NSThread sleepForTimeInterval:0.15];
    }
}

-(void)updateMindWaveStatsUI
{
    NSString *strAttentionValue = [NSString stringWithFormat:@"%d", eSenseValues.attention];
    NSString *strMeditationValue = [NSString stringWithFormat:@"%d", eSenseValues.meditation];
    NSString *strBlinkStrengthValue = [NSString stringWithFormat:@"%d", blinkStrength];
    NSString *strPoorSignalValue = [NSString stringWithFormat:@"%d", poorSignalValue];
    
    NSLog(@"Updating UI...");
    NSLog(@"Attention: %@", strAttentionValue);
    NSLog(@"Meditation: %@", strMeditationValue);
    NSLog(@"Blink strength: %@", strBlinkStrengthValue);
    NSLog(@"Poor signal value: %@", strPoorSignalValue);
    
    self.attentionStatData.text = strAttentionValue;
    self.meditationStatData.text = strMeditationValue;
    self.blinkStatData.text = strBlinkStrengthValue;
    self.poorSignalStatData.text = strPoorSignalValue;
}

#pragma mark -
#pragma mark TGAccessoryDelegate protocol methods

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is connected.
- (void)accessoryDidConnect:(EAAccessory *)accessory {
    // toss up a UIAlertView when an accessory connects
    /*UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Accessory Connected" 
     message:[NSString stringWithFormat:@"A ThinkGear accessory called %@ was connected to this device.", [accessory name]]
     delegate:nil 
     cancelButtonTitle:@"Okay" 
     otherButtonTitles:nil];
     [a show];
     [a release];
     */
    
    // start the data stream to the accessory
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
}

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is disconnected.
- (void)accessoryDidDisconnect {
    // toss up a UIAlertView when an accessory disconnects
    /*UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Accessory Disconnected" 
     message:@"The ThinkGear accessory was disconnected from this device." 
     delegate:nil 
     cancelButtonTitle:@"Okay" 
     otherButtonTitles:nil];
     [a show];
     [a release];
     */
    
    //stop stream
    [[TGAccessoryManager sharedTGAccessoryManager] stopStream];
}

//  This method gets called by the TGAccessoryManager when data is received from the
//  ThinkGear-enabled device.
- (void)dataReceived:(NSDictionary *)data {
    //[data retain];
    
    NSLog(@"Data received...");
    
    NSString * temp = [[NSString alloc] init];
    
    NSDate * date = [NSDate date];
    rawValue = [[data valueForKey:@"raw"] shortValue];
    temp = [temp stringByAppendingFormat:@"%f: Raw: %d\n", [date timeIntervalSince1970], rawValue];
    
    if([data valueForKey:@"blinkStrength"])
        blinkStrength = [[data valueForKey:@"blinkStrength"] intValue];
    
    // check to see whether the eSense values are there. if so, we assume that
    // all of the other data (aside from raw) is there. this is not necessarily
    // a safe assumption.
    if([data valueForKey:@"eSenseAttention"]){
        poorSignalValue = [[data valueForKey:@"poorSignal"] intValue];
        //temp = [NSString stringWithFormat:@"poorsignal: %02x\n", poorSignalValue];
        temp = [temp stringByAppendingFormat:@"%f: Poor Signal: %d\n", [date timeIntervalSince1970], poorSignalValue];
        
        eSenseValues.attention =    [[data valueForKey:@"eSenseAttention"] intValue];        
        eSenseValues.meditation =   [[data valueForKey:@"eSenseMeditation"] intValue];
        temp = [temp stringByAppendingFormat:@"%f: Attention: %d\n", [date timeIntervalSince1970], eSenseValues.attention];
        temp = [temp stringByAppendingFormat:@"%f: Meditation: %d\n", [date timeIntervalSince1970], eSenseValues.meditation];
          
        eegValues.delta =       [[data valueForKey:@"eegDelta"] intValue];
        eegValues.theta =       [[data valueForKey:@"eegTheta"] intValue];
        eegValues.lowAlpha =    [[data valueForKey:@"eegLowAlpha"] intValue];
        eegValues.highAlpha =   [[data valueForKey:@"eegHighAlpha"] intValue];
        eegValues.lowBeta =     [[data valueForKey:@"eegLowBeta"] intValue];
        eegValues.highBeta =    [[data valueForKey:@"eegHighBeta"] intValue];
        eegValues.lowGamma =    [[data valueForKey:@"eegLowGamma"] intValue];
        eegValues.highGamma =   [[data valueForKey:@"eegHighGamma"] intValue];
        
        NSLog(@"Data Received: %@", temp);
        
        rawCount = [[data valueForKey:@"rawCount"] intValue];
    }
    
    [temp release];    
    
    // release the parameter
    [data release];
}
@end
