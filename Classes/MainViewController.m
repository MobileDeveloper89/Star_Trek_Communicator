//
//  MainViewController.m
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "SpaceRadioAppDelegate.h"
#import "PhoneViewController.h"
#import "TouchableImageView.h"
#import "UIButtonStated.h"
#import "SoundList.h"
#import "FlipsideViewController.h"
#import "PurchaseViewController.h"
#import "Flurry.h"

#define COVER_ANIMATION_DURATION 0.5
#define COVER_CLOSE_SOUND_DELAY 0.0

#define kAccelerometerFrequency			25 //Hz
#define kAccelerationThreshold         0.25
#define kFilteringFactor               0.16
NSTimeInterval sSensorTimeGap = 1;

#define SOUND_COVER_OPEN 1
#define SOUND_AUTOHAIL_BUTTON 2
#define SOUND_COVER_CLOSE 3
#define SOUND_AUTOHAIL_CALLBACK 4
#define SOUND_PHONE 5
#define SOUND_IPOD 6
#define SOUND_NEXT_LEFT_BUTTON 7
#define SOUND_NEXT_RIGHT_BUTTON 8

@interface MainViewController (priv)
-(void) loadAccelerometer;
-(void) stopAccelerometer;
-(void) fadeToggleNavigationBar;
-(void) turnOnBlueLED;
-(void) turnOffBlueLED;
-(void) turnOnRedLED;
-(void) turnOffRedLED;
-(void) turnOnYellowLED;
-(void) turnOffYellowLED;
-(BOOL) isAutoHailEnabled;
-(void) stopLEDBlinkingTimer;
-(void) hideNavigationBar;
-(void) loadCoverAnimationImages;
-(void) playAutoHailSound;
-(void) openCoverFinished;
-(void) stopPlayback;
-(void) stopAutoHail;
-(void) startBlinkingBlueLED;
-(void) startBlinkingYellowLED;
@end


@implementation MainViewController

@synthesize magicDisk1, magicDisk2, leftButton, rightButton, yellowLED, redLED, blueLED, backgroundImageView, navbar, hailButton;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    lastTime = 0;
    [Flurry logEvent:@"Main Screen" timed:YES];
    [self loadAccelerometer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"Main Screen" withParameters:nil];
    [self stopPlayback];
    [self stopAccelerometer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self spinButton];
}

- (void)viewDidLoad
{
    SpaceRadioAppDelegate *appDelegate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];

	player = nil;
	coverIsOpened = NO;
    currentlyPlaying = -1;
    soundList = [[SoundList alloc] init];
    [self hideNavigationBar];
    [self turnOffRedLED];
    [self turnOffYellowLED];
    [self turnOffBlueLED];
    isIPhone = [appDelegate isIPhone];

    [self.navbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main nav bar.png"]]];
    self.backgroundImageView.delegate = self;

    // create animation view for cover
	animationView = [[TouchableImageView alloc] initWithImage:[UIImage imageNamed:@"lid-1.png"]];
    [self.view addSubview:animationView];

    // load cover animation image files
	[self loadCoverAnimationImages];

    // if the app was ended when user dialed a number from the phone screen, then
    // when the user comes back into the app the cover should be open
	if(appDelegate.isPhoneEndedApp) {
		coverIsOpened = YES;
	}
	appDelegate.isPhoneEndedApp = NO;

    // set cover state
    if (coverIsOpened) {
        [self openCoverFinished];
    } else {
        // the images don't load fast enough and the first time the animation is supposed
        // to play, the user ends up seeing nothing. so we force it here by hiding the view &
        // playing the animation once. animation is played fast so we can get the load out of the way.
        // at the end of the animation the user should see the closed cover state.
        animationView.hidden = YES;
        animationView.animationDuration = 0.1;
        animationView.animationRepeatCount = 1;
        animationView.animationImages = closeImages;
        [animationView startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(closeCoverFinished) userInfo:nil repeats:NO];
    }
}

- (void)spinButton
{
    [CATransaction begin];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0];
	animation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.duration = 120.0;
    animation.repeatCount = HUGE_VALF;
	[magicDisk1.layer addAnimation:animation forKey:@"rotationAnimation"];
    
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0];
	animation.toValue = [NSNumber numberWithFloat:-2.0 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.duration = 60.0;
    animation.repeatCount = HUGE_VALF;
	[magicDisk2.layer addAnimation:animation forKey:@"rotationAnimation"];
    
	[CATransaction commit];
}

- (void)dealloc
{
    self.navbar = nil;
	[openImages release];
	[closeImages release];
    [super dealloc];
}

-(void) loadCoverAnimationImages
{
    openImages = [[NSMutableArray alloc] init];
	closeImages = [[NSMutableArray alloc] init];
	NSInteger i;
    for(i = 1; i <= 7; i++) {
		NSString *cname = [NSString stringWithFormat:@"lid-%d.png", i];
		UIImage *img = [UIImage imageNamed:cname];
		if (img) [openImages addObject:img];
	}
    for(i = 7; i >= 1; i--) {
		NSString *cname = [NSString stringWithFormat:@"lid-%d.png", i];
		UIImage *img = [UIImage imageNamed:cname];
		if (img) [closeImages addObject:img];
	}
}

#pragma mark - audio playback methods

- (void) startPlayback : (NSInteger) i
{
	currentlyPlaying = i;
	NSString *soundName;
	NSString *path = nil;

	if(player!= nil) {
        if (player.playing) {
            [player stop];
        }
        [player release];
        player = nil;
    }

	switch (i) {
		case SOUND_COVER_OPEN:
			soundName = @"open2"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_AUTOHAIL_BUTTON:
			soundName = @"button8"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_COVER_CLOSE:
			soundName = @"close2"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_AUTOHAIL_CALLBACK:
			soundName = @"callback"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_PHONE:
			soundName = @"button5"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_IPOD:
			soundName = @"ipod-touch"; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
			break;
		case SOUND_NEXT_LEFT_BUTTON:
			soundName = [soundList getNextLeftSoundName]; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
			break;
		case SOUND_NEXT_RIGHT_BUTTON:
			soundName = [soundList getNextRightSoundName]; 
			path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
			break;
		default:
			break;
	}

	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
	AVAudioPlayer *newPlayer = 
	[[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
										   error: nil];
	[fileURL release];
	player = newPlayer; 
	[player prepareToPlay]; 
	[player setDelegate: self];
	[player play];
}

-(void) stopPlayback
{
	currentlyPlaying = -1;
	[player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if ((currentlyPlaying == SOUND_AUTOHAIL_CALLBACK) && (!coverIsOpened))
		[self startPlayback:currentlyPlaying];
}

-(void) playCoverCloseSound
{
    [self startPlayback:SOUND_COVER_CLOSE];
}

#pragma mark - cover open/close methods

-(void) checkAndOpenCover
{
	if(coverIsOpened)
		return;

	[self animateOpenCloseCover:YES];
}

-(void) checkAndCloseCover
{
	if(!coverIsOpened)
		return;

	[self animateOpenCloseCover:NO];
}

-(void) openCover {
    coverIsOpened = YES;
    [self stopPlayback];

    // stop autohail if it was enabled
    if([self isAutoHailEnabled])
    {
        [self stopAutoHail];
    }

    // Begin the animation
	animationView.hidden = NO;
	animationView.animationRepeatCount = 1;
	animationView.animationDuration = COVER_ANIMATION_DURATION;
	animationView.animationImages = openImages;
    animationView.image = [animationView.animationImages lastObject];
	[animationView startAnimating];
    [self startPlayback:SOUND_COVER_OPEN];
	[NSTimer scheduledTimerWithTimeInterval:COVER_ANIMATION_DURATION target:self selector:@selector(openCoverFinished) userInfo:nil repeats:NO];
}

-(void) openCoverFinished
{
    leftButton.enabled = YES;
    rightButton.enabled = YES;
    self.hailButton.userInteractionEnabled = YES;

    animationView.hidden = YES;
    coverIsOpened = YES;
}

-(void) closeCover {
    coverIsOpened = NO;

    // enable autohail if required
    if([self isAutoHailEnabled]) {
        [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(playAutoHailSound) userInfo:nil repeats:NO];
    }
    self.hailButton.userInteractionEnabled = NO;

    // play sound for cover close
    [NSTimer scheduledTimerWithTimeInterval:COVER_CLOSE_SOUND_DELAY target:self selector:@selector(playCoverCloseSound) userInfo:nil repeats:NO];

    // Begin the animation
	animationView.hidden = NO;
	animationView.animationRepeatCount = 1;
	animationView.animationDuration = COVER_ANIMATION_DURATION;
	animationView.animationImages = closeImages;
    animationView.image = [animationView.animationImages lastObject];
	[animationView startAnimating];
	[NSTimer scheduledTimerWithTimeInterval:COVER_ANIMATION_DURATION target:self selector:@selector(closeCoverFinished) userInfo:nil repeats:NO];
}

-(void) closeCoverFinished
{
    // stop yellow led timer
    [self stopLEDBlinkingTimer];

    leftButton.enabled = NO;
    rightButton.enabled = NO;
    self.hailButton.userInteractionEnabled = NO;
    [self turnOffBlueLED];
    [self turnOffYellowLED];

    [animationView stopAnimating];
    animationView.hidden = NO;
    animationView.image = [closeImages lastObject];
    coverIsOpened = NO;
}

-(void) animateOpenCloseCover:(BOOL) open
{
	if(animationView.isAnimating)
		return;

	if (open == coverIsOpened) {
		return;
	}

    // hide nav bar when closing
    if (!open) {
        [self hideNavigationBar];
    }

	if(coverIsOpened) {
		[self closeCover];
	} else {
		[self openCover];
	}
}

#pragma mark - autohail methods

-(BOOL) isAutoHailEnabled
{
    return (redBlinkingTimer != nil);
}

-(void) redBlinkProcess
{
	if(redLED.isSelected == NO)
		[self turnOnRedLED];
	else
        [self turnOffRedLED];
}

-(void) playAutoHailSound
{
	if(!coverIsOpened)
	{
		[self startPlayback:SOUND_AUTOHAIL_CALLBACK];
	}
}

-(void)startAutoHail
{
    // start red led blinking
    [self turnOnRedLED];
    redBlinkingTimer = [[NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                        target: self
                                                      selector: @selector(redBlinkProcess)
                                                      userInfo: nil
                                                       repeats: YES] retain];
    
    // stop yellow & blue leds
    [self turnOffYellowLED];
    if (yellowBlinkingTimer != nil) {
        [yellowBlinkingTimer invalidate];
        [yellowBlinkingTimer release];
        yellowBlinkingTimer = nil;
    }
    [self turnOffBlueLED];
    if (blueBlinkingTimer != nil) {
        [blueBlinkingTimer invalidate];
        [blueBlinkingTimer release];
        blueBlinkingTimer = nil;
    }
}

-(void)stopAutoHail
{
    // stop red led blinking
    [self turnOffRedLED];
    if ([redBlinkingTimer isValid]) {
        [redBlinkingTimer invalidate];
        [redBlinkingTimer release];
        redBlinkingTimer = nil;
    }
}

-(IBAction)autoHailButtonPressed
{
	if(!coverIsOpened)
		return;

    // hide nav bar
    if (navBarVisible) {
        [self fadeToggleNavigationBar];
    }

	if([self isAutoHailEnabled]) {
        [self stopAutoHail];
	} else {
		[self startAutoHail];
	}
	[self startPlayback:SOUND_AUTOHAIL_BUTTON];	
}

#pragma mark - navbar methods

- (void)navBarAnimationComplete
{
    if (navBarVisible) {
        self.navbar.userInteractionEnabled = YES;
    } 
    else {
        self.navbar.userInteractionEnabled = NO;
    }
}

-(void)hideNavigationBar
{
    self.navbar.alpha = 0.0;
    navBarVisible = NO;
    self.navbar.userInteractionEnabled = NO;
}

-(void)fadeToggleNavigationBar
{
    // when cover is open, toggle navigation bar
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelegate:self];
    if (navBarVisible) {
        [UIView setAnimationDidStopSelector:@selector(navBarAnimationComplete)];
        self.navbar.alpha = 0.0;
    } else {
        [UIView setAnimationDidStopSelector:@selector(navBarAnimationComplete)];
        self.navbar.alpha = 1.0;    
    }
    [UIView commitAnimations];
    
    navBarVisible = !navBarVisible;
}

-(void)onClickEvent 
{
    if(coverIsOpened) {
        [self fadeToggleNavigationBar];
    } else {
        // when cover is close, open cover
        [self animateOpenCloseCover:YES];
    }
}

#pragma mark - led methods

-(void) turnOnBlueLED
{
    if (![self isAutoHailEnabled])
        blueLED.isSelected = YES;
}

-(void) turnOffBlueLED
{
    blueLED.isSelected = NO;
}

-(void) turnOnYellowLED
{
    if (![self isAutoHailEnabled])
        yellowLED.isSelected = YES;
}

-(void) turnOffYellowLED
{
    yellowLED.isSelected = NO;
}

-(void) turnOnRedLED
{
    redLED.isSelected = YES;
}

-(void) turnOffRedLED
{
    redLED.isSelected = NO;
}

-(void) stopLEDBlinkingTimer
{
    [self turnOffYellowLED];
    [yellowBlinkingTimer invalidate];
    [yellowBlinkingTimer release];
    yellowBlinkingTimer = nil;
    
    [self turnOffBlueLED];
    [blueBlinkingTimer invalidate];
    [blueBlinkingTimer release];
    blueBlinkingTimer = nil;
}

#pragma mark - ui button press methods

-(IBAction)rightPlayButtonPressed
{
	if(!coverIsOpened)
		return;
    
    // hide nav bar
    if (navBarVisible) {
        [self fadeToggleNavigationBar];
    }

    [Flurry logEvent:@"Right Button Press"];

	[self startPlayback:SOUND_NEXT_RIGHT_BUTTON];
    
    [self stopLEDBlinkingTimer];
    [self stopAutoHail];
    
    [self startBlinkingBlueLED];
}

- (void) startBlinkingBlueLED
{
    blueLEDCount = 1;
    [self turnOnBlueLED];
	blueBlinkingTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.5f
                                                          target: self
                                                        selector: @selector(stateChangeBlueLED)
                                                        userInfo: nil
                                                         repeats: YES] retain];
    
}

- (void) stateChangeBlueLED
{
    if (blueLED.isSelected) {
        [self turnOffBlueLED];
        if (blueLEDCount == 3) {
            [blueBlinkingTimer invalidate];
            [blueBlinkingTimer release];
            blueBlinkingTimer = nil;
        }
    }
    else {
        blueLEDCount++;
        [self turnOnBlueLED];
    }
}

- (void) startBlinkingYellowLED
{
    yellowLEDCount = 1;
    [self turnOnYellowLED];
	yellowBlinkingTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.5f
                                                            target: self
                                                          selector: @selector(stateChangeYellowLED)
                                                          userInfo: nil
                                                           repeats: YES] retain];
    
}

- (void) stateChangeYellowLED
{
    if (yellowLED.isSelected) {
        [self turnOffYellowLED];
        if (yellowLEDCount == 3) {
            [yellowBlinkingTimer invalidate];
            [yellowBlinkingTimer release];
            yellowBlinkingTimer = nil;
        }
    }
    else {
        yellowLEDCount++;
        [self turnOnYellowLED];
    }
}

-(IBAction) leftPlayButtonPressed
{
	if(!coverIsOpened)
		return;
    
    // hide nav bar
    if (navBarVisible) {
        [self fadeToggleNavigationBar];
    }
    
    [Flurry logEvent:@"Left Button Press"];
	[self startPlayback:SOUND_NEXT_LEFT_BUTTON];
    
    [self stopLEDBlinkingTimer];
    [self stopAutoHail];
    
    [self startBlinkingYellowLED];
}

#pragma mark - navigation button methods

-(IBAction)phoneButtonPressed
{
    [self stopAutoHail];
    [self stopLEDBlinkingTimer];
    
	[self stopPlayback];
	[((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToPhoneView:kCATransitionFromRight];
}

-(IBAction) infoButtonPressed
{
    [self stopAutoHail];
    [self stopLEDBlinkingTimer];
    
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToInfoView:kCATransitionFromRight];
}

-(IBAction) soundButtonPressed
{
    [self stopAutoHail];
    [self stopLEDBlinkingTimer];
    
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToSettingsView:kCATransitionFromRight];
}

#pragma mark - accelerometer methods

-(void) loadAccelerometer{
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(2.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
}
-(void) stopAccelerometer{
	
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
}
- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration 
{
    
	if(lastTime == 0) {
		lastTime = acceleration.timestamp - sSensorTimeGap;
		previousSensorZ = acceleration.z;
		return;
	}
	
    double filteredZ = acceleration.z * kFilteringFactor + previousSensorZ * (1.0f - kFilteringFactor);
    double diffZ = filteredZ - previousSensorZ;
    
    previousSensorZ = acceleration.z;
    //NSLog(@"previousSensorZ = %f, acceleration=%f, diffZ=%f", previousSensorZ, acceleration.z, diffZ);
    
    if ((acceleration.timestamp - lastTime) < sSensorTimeGap) {
        return;
    }
    
    if (diffZ > kAccelerationThreshold) {
        //NSLog(@"greater than %f, filteredZ=%f, acceleration.z=%f", diffZ, filteredZ, acceleration.z);
        [self animateOpenCloseCover:NO];
        lastTime = acceleration.timestamp;
    }
    else if (diffZ < -kAccelerationThreshold) {
        //NSLog(@"less than %f, filteretdZ=%f, acceleration.z=%f", diffZ, filteredZ, acceleration.z);
        [self animateOpenCloseCover:YES];
        lastTime = acceleration.timestamp;
    }
}

@end
