//
//  SpaceRadioAppDelegate.m
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#include <sys/types.h>
#include <sys/sysctl.h>
#import "SpaceRadioAppDelegate.h"
#import "MainViewController.h"
#import "PhoneViewController.h"
#import "FlipsideViewController.h"
#import "PurchaseViewController.h"
#import "SoundManager.h"
#import "MKStoreManager.h"
#import "Flurry.h"
#import "KeychainManager.h"

#ifdef VERSION_LITE
#import "AdManager.h"
#endif

@implementation SpaceRadioAppDelegate

@synthesize window, mainViewController, navController, isPhoneEndedApp, customModalView, savedPhoneNumber;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *purchases = [dictionary objectForKey:@"Purchases"];
    soundPackPurchaseIds = [[NSMutableArray alloc] init];
    int count = [purchases count];
    int i;
    for (i = 0; i < count; i++)
    {
        NSDictionary* purchaseInfo = [purchases objectAtIndex:i];
        NSString * purchaseID = [purchaseInfo valueForKey:@"PurchaseID"];
        if (purchaseID != nil && [purchaseID length] > 0)
        {
            [soundPackPurchaseIds addObject:purchaseID];
        }
    }

    // refresh product prices EVERY TIME the application starts.
    // why? because that's what the requirements are.
    [MKStoreManager setDelegate:self];
    [[MKStoreManager sharedManager] requestProductData];

    [self loadUserDefaults];

#ifdef VERSION_LITE
    [Flurry startSession:@"D262YMSVMJT52N773R79"];
#else
    [Flurry startSession:@"6CP9TK1W6EMZ7UKJ9S5T"];
#endif
    //NSLog(@"deviceID: %@", [[KeychainManager manager] getDeviceID]);
    [Flurry setUserID:[[KeychainManager manager] getDeviceID]];

    // copy default unlocked sound files (call does nothing after the first time)
    [SoundManager copyDefaultSoundFiles];

    [window addSubview:navController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // refresh product prices EVERY TIME the application enters foreground.
    // why? because that's what the requirements are.
    [MKStoreManager setDelegate:self];
    [[MKStoreManager sharedManager] requestProductData];

    //start animation when the app enters foreground again
    if ([navController.topViewController isKindOfClass:[MainViewController class]]) {
        [self.mainViewController spinButton];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveUserDefaults];
}

- (void)loadUserDefaults
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];

    // getting an NSInteger
    isPhoneEndedApp = [[prefs objectForKey:@"phoneEndedApp"] boolValue];
}

- (void)saveUserDefaults
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];

    // saving an NSInteger
    [prefs setBool:isPhoneEndedApp forKey:@"phoneEndedApp"];

    [prefs synchronize];
}

- (void)dealloc
{
    [window release];
    [super dealloc];
}

#pragma mark - navigation methods

- (void)playSoundInBackground:(NSString *)fileName
{
    // autorelease pool since this is in a background thread and the main thread's pool is not applicable
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    if (avPlayer != nil) {
        if (avPlayer.playing) {
            [avPlayer stop];
        }
        [avPlayer release];
        avPlayer = nil;
    }

    NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    }
    NSURL * fileURL = [[[NSURL alloc] initFileURLWithPath:path] autorelease];    
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                                    error:nil];
    
    [player prepareToPlay];
    [player play];
    avPlayer = player;

    // release autorelease pool
    [pool release];
}

- (void)goToMainView:(NSString *) animation
{
    [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"4"];
    
    [self.navController popToRootViewControllerAnimated:YES];

#ifdef VERSION_LITE
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

- (void)goToPhoneView:(NSString *) animation
{
    if ([self isIPhone]) {
#ifdef VERSION_LITE
        // In the lite version, users cannot access the phone screen unless they
        // have at least one pack purchased
        if ([MKStoreManager anyFeaturePurchased:soundPackPurchaseIds] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dialer Disabled"
                                                            message:@"Purchase any Sound Pack to turn off ads and access this feature!"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Purchase", @"Cancel", nil];
            [alert show];
            [alert release];
            
            [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"garbled-radio-short"];
            
            return;
        }
#endif
        CATransition* transition = [CATransition animation];
        transition.duration = 0;
        transition.type = kCATransitionPush;
        transition.subtype = animation;
        
        [self.navController.view.layer 
         addAnimation:transition forKey:kCATransition];
        
        [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"5"];

        // if we are top, push it. otherwise replace the outermost one.
        PhoneViewController * controller = [[[PhoneViewController alloc] initWithNibName:@"PhoneView" bundle:nil] autorelease];
        if ([self.navController.viewControllers count] == 1) {
            [self.navController pushViewController:controller animated:NO];
        }
        else {
            NSMutableArray * controllers = [NSMutableArray arrayWithArray:self.navController.viewControllers];
            [controllers removeLastObject];
            [controllers addObject:controller];
            [self.navController setViewControllers:controllers animated:NO];
        }
#ifdef VERSION_LITE
        [[AdManager manager] checkAndShowInterstitialAd];
#endif
    }
    else {
        [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"garbled-radio-short"];
    }
}

- (void)goToInfoView:(NSString *) animation
{
    [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"6"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionPush;
    transition.subtype = animation;
    
    [self.navController.view.layer 
     addAnimation:transition forKey:kCATransition];
    
    // if we are top, push it. otherwise replace the outermost one.
    FlipsideViewController * controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil] autorelease];
    if ([self.navController.viewControllers count] == 1) {
        [self.navController pushViewController:controller animated:NO];
    }
    else {
        NSMutableArray * controllers = [NSMutableArray arrayWithArray:self.navController.viewControllers];
        [controllers removeLastObject];
        [controllers addObject:controller];
        [self.navController setViewControllers:controllers animated:NO];
    }
    //Start Animation
    [UIView commitAnimations];

#ifdef VERSION_LITE
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

- (void)goToSettingsView:(NSString *) animation
{
    [self performSelectorInBackground:@selector(playSoundInBackground:) withObject:@"7"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionPush;
    transition.subtype = animation;
    
    [self.navController.view.layer 
     addAnimation:transition forKey:kCATransition];
    
    // if we are top, push it. otherwise replace the outermost one.
    PurchaseViewController * controller = [[[PurchaseViewController alloc] initWithNibName:@"PurchaseView" bundle:nil] autorelease];
    if ([self.navController.viewControllers count] == 1) {
        [self.navController pushViewController:controller animated:NO];
    }
    else {
        NSMutableArray * controllers = [NSMutableArray arrayWithArray:self.navController.viewControllers];
        [controllers removeLastObject];
        [controllers addObject:controller];
        [self.navController setViewControllers:controllers animated:NO];
    }

#ifdef VERSION_LITE
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

#pragma mark - custom modal view methods

+ (void)showModalView:(UIView *)modalView
{
    SpaceRadioAppDelegate * appDelegate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];

    // show controller in center
    [appDelegate.window addSubview:modalView];
    modalView.center = appDelegate.window.center;

    appDelegate.customModalView = modalView;
}

+ (void)hideModalView
{
    SpaceRadioAppDelegate * appDelegate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.customModalView removeFromSuperview];

    appDelegate.customModalView = nil;
}

#pragma mark - alertview delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#ifdef VERSION_LITE
    if (buttonIndex == 0) { // purchase button
        UIViewController * controller = [self.navController topViewController];
        if ([controller isKindOfClass:[MainViewController class]]) {
            [self goToSettingsView:kCATransitionFromRight];
        } else if ([controller isKindOfClass:[FlipsideViewController class]]) {
            [self goToSettingsView:kCATransitionFromLeft];
        } else if ([controller isKindOfClass:[PurchaseViewController class]]) {
            [((PurchaseViewController *)controller) soundPacksButtonPressed:nil];
            // switching to sound packs will already check and show interstitial so we can exit here
            return;
        }
    }
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

#pragma mark - device model detection methods

- (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char * machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * platform = [NSString stringWithUTF8String:machine]; //[NSString stringWithCString:machine];
    free(machine);
    return platform;
}

- (BOOL)isIPhone
{
    NSString * platform = [self platform];
    NSRange range = [platform rangeOfString:@"iPhone"];
    if (range.location == NSNotFound)
        return NO;
    return YES;

}

# pragma mark - MKStoreDelegate methods

- (void)productFetchComplete
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter postNotificationName:@"refreshTable" object:self];
}

- (void)productPurchased:(NSString *)productId
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter postNotificationName:@"refreshTable" object:self];
}

- (void)transactionCanceled
{}

@end