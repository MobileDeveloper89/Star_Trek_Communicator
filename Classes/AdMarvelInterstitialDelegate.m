//
//  AdMarvelInterstitialDelegate.m
//  SpaceRadio
//
//  Created by Poonam on 1/18/13.
//
//

#import "AdMarvelInterstitialDelegate.h"
#import "SpaceRadioAppDelegate.h"
#import "AdManager.h"

@implementation AdMarvelInterstitialDelegate

- (NSString *)partnerId
{
#ifdef VERSION_DEBUG
    return @"9ebd827a07c8ff04";//@"8aa4839dd3f57f21";
#elif VERSION_RELEASE
    return @"9ebd827a07c8ff04";
#else
    // unknown build variant. check project settings and make sure preprocessor macro is defined for this build variant.
    DONOTCOMPILE
#endif
}

- (NSString *)siteId
{
#ifdef VERSION_DEBUG
    return @"39969";//@"40971";
#elif VERSION_RELEASE
    return @"39969";
#else
    // unknown build variant. check project settings and make sure preprocessor macro is defined for this build variant.
    DONOTCOMPILE
#endif
}

- (BOOL) testingEnabled
{
    return NO;
}

- (UIViewController *) applicationUIViewController
{
    return ((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate).navController;
}

- (NSDictionary*) targetingParameters
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"ScreenChange", TARGETING_PARAM_INT_TYPE, nil];
}

- (void) getAdSucceeded
{
    NSLog(@"INTERSTITIAL: getAdSucceeded");
}

- (void) getAdFailed
{
    NSLog(@"INTERSTITIAL: getAdFailed");
}

- (void) getInterstitialAdSucceeded
{
    NSLog(@"INTERSTITIAL: getInerstitialAdSucceeded");
}

- (void) getInterstitialAdFailed
{
    NSLog(@"INTERSTITIAL: getInterstititalAdFailed");
}

- (void) interstitialActivated
{
    NSLog(@"INTERSTITIAL: interstitialActivated");
}

- (void) interstitialClosed
{
    NSLog(@"INTERSTITIAL: interstitialClosed");
    // get next ad as soon as this ad closes
    [[[AdManager manager] getAdMarvelInterstitialView] getInterstitialAd];
}

@end
