//
//  MainViewController.h
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <AVFoundation/AVFoundation.h>
#import "FlipsideViewController.h"
#import "TouchableImageView.h"

@class UIButtonStated;
@class SoundList;

@interface MainViewController : UIViewController<AVAudioPlayerDelegate, TouchableImageViewDelegate, UIAccelerometerDelegate> {
	
	TouchableImageView *animationView;
	IBOutlet TouchableImageView *backgroundImageView;
	BOOL coverIsOpened;
	IBOutlet UIButton *leftButton;
	IBOutlet UIButton *rightButton;
	NSTimer *yellowBlinkingTimer;
	NSTimer *redBlinkingTimer;
	NSTimer *blueBlinkingTimer;
	NSTimer *closeCallbackTimer;
	NSTimer *isAnimatingTimer;

	IBOutlet UIButtonStated *yellowLED;
	IBOutlet UIButtonStated *redLED;
	IBOutlet UIButtonStated *blueLED;
	AVAudioPlayer *player;
	NSInteger currentlyPlaying;
	bool isIPhone;
	SoundList * soundList;
	
	NSMutableArray * openImages;
	NSMutableArray * closeImages;
    BOOL navBarVisible;
    CFTimeInterval		lastTime;
    UIAccelerationValue	myAccelerometer[3];
	double previousSensorZ;
    
    int yellowLEDCount;
    int blueLEDCount;
}
@property(nonatomic, retain) IBOutlet UIImageView *magicDisk1;
@property(nonatomic, retain) IBOutlet UIImageView *magicDisk2;
@property(nonatomic, retain) IBOutlet UIButton *leftButton;
@property(nonatomic, retain) IBOutlet UIButton *rightButton;
@property(nonatomic, retain) IBOutlet UIButton *hailButton;
@property(nonatomic, retain) IBOutlet UIButtonStated *yellowLED;
@property(nonatomic, retain) IBOutlet UIButtonStated *redLED;
@property(nonatomic, retain) IBOutlet UIButtonStated *blueLED;
@property(nonatomic, retain) IBOutlet TouchableImageView *backgroundImageView;
@property(nonatomic, retain) IBOutlet UIView * navbar;

- (void) startPlayback : (NSInteger) i;
-(void) animateOpenCloseCover:(BOOL) open;
- (void)spinButton;

-(IBAction)leftPlayButtonPressed;
-(IBAction)rightPlayButtonPressed;
-(IBAction)phoneButtonPressed;
-(IBAction)autoHailButtonPressed;
-(void) checkAndOpenCover;
-(void) checkAndCloseCover;
-(IBAction) infoButtonPressed;
-(IBAction) soundButtonPressed;

@end
