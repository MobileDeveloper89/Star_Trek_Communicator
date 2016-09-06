//
//  AdManager.m
//  SpaceRadio
//
//  Created by Ashutosh on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdManager.h"
#import "SpaceRadioAppDelegate.h"

@implementation AdManager

static AdManager * singletonObject = nil;

+ (AdManager *)manager
{
    if (singletonObject == nil) {
        singletonObject = [[AdManager alloc] initSingleton];
    }
    return singletonObject;
}

- (id)initSingleton
{
    self = [super init];
    if (self) {
        count = 0;

        NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *purchases = [dictionary objectForKey:@"Purchases"];
        soundPackPurchaseIds = [[NSMutableArray alloc] init];
        int numPurchases = [purchases count];
        int i;
        for (i = 0; i < numPurchases; i++) {
            NSDictionary* purchaseInfo = [purchases objectAtIndex:i];
            NSString * purchaseID = [purchaseInfo valueForKey:@"PurchaseID"];
            if (purchaseID != nil && [purchaseID length] > 0) {
                [soundPackPurchaseIds addObject:purchaseID];
            }
        }

        // one ad view for interstitials and one ad view for banners
        adMarvelInterstitialDelegate = [[AdMarvelInterstitialDelegate alloc] init];
        adMarvelInterstitialView = [[AdMarvelView createAdMarvelViewWithDelegate:adMarvelInterstitialDelegate] retain];

        NSLog(@"AdMarvel SDK Version = %@", [adMarvelInterstitialView getSDKVersion]);

        // no need to fetch ads if any purchase has been made already
        if ([MKStoreManager anyFeaturePurchased:soundPackPurchaseIds] == NO) {
            //[adMarvelBannerView getAdWithNotification];
            [adMarvelInterstitialView getInterstitialAd];
        }
    }
    return self;
}

- (AdMarvelView *)getAdMarvelInterstitialView
{
    return adMarvelInterstitialView;
}

- (void)checkAndShowInterstitialAd
{
    // if any packs have been purchased, we do not need to show any ads
    if ([self shouldShowAds] == NO) {
        return;
    }

    count += 1;
    if (count % 3 == 0) {
        // display ad if we have one. otherwise request for an ad.
        if ([adMarvelInterstitialView isInterstitialReady]) {
            [adMarvelInterstitialView displayInterstitial];
            NSLog(@"displayInterstitial called!");
        } else {
            NSLog(@"checkAndShowInterstitialAd called when interstitial is not ready!");
            [adMarvelInterstitialView getInterstitialAd];
        }
    }
}

- (BOOL)shouldShowAds
{
    // if any packs have been purchased, we do not need to show any ads
    return ![MKStoreManager anyFeaturePurchased:soundPackPurchaseIds];
}

@end
