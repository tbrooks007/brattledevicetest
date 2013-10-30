//
//  ViewController.h
//  BrattleDualDeviceTest
//
//  Created by Teresa Brooks on 5/14/12.
//  Copyright (c) 2012 Quarks and Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TGAccessoryManager.h"
#import "TGAccessoryDelegate.h"

// the eSense values
typedef struct {
    int attention;
    int meditation;
} ESenseValues;

// the EEG power bands
typedef struct {
    int delta;
    int theta;
    int lowAlpha;
    int highAlpha;
    int lowBeta;
    int highBeta;
    int lowGamma;
    int highGamma;
} EEGValues;

@interface ViewController : UIViewController <TGAccessoryDelegate> 
{
    //Sphero related fields
    BOOL ledON;
    BOOL robotOnline;
    
    //TGAccessory / MindWave Headset related fields
    short rawValue;
    int rawCount;
    int blinkStrength;
    int poorSignalValue;
    
    ESenseValues eSenseValues;
    EEGValues eegValues;
    NSThread * updateThread;
}
@property (retain, nonatomic) IBOutlet UILabel *meditationStatData;
@property (retain, nonatomic) IBOutlet UILabel *attentionStatData;
@property (retain, nonatomic) IBOutlet UILabel *blinkStatData;
@property (retain, nonatomic) IBOutlet UILabel *poorSignalStatData;
@property (retain, nonatomic) IBOutlet UILabel *currentSpheroColor;

// TGAccessoryDelegate protocol methods
- (void)accessoryDidConnect:(EAAccessory *)accessory;
- (void)accessoryDidDisconnect;
- (void)dataReceived:(NSDictionary *)data;

// Sphero methods
-(void)setupRobotConnection;
-(void)handleRobotOnline;
-(void)toggleLED;

@end
