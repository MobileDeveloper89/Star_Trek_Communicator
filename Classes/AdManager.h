//
//  AdManager.h
//  SpaceRadio
//
//  Created by Ashutosh on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdMarvelView.h"
#import "AdMarvelInterstitialDelegate.h"

@interface AdManager : NSObject {
    AdMarvelView * adMarvelInterstitialView;
    AdMarvelInterstitialDelegate * adMarvelInterstitialDelegate;
    NSInteger count;
    NSMutableArray * soundPackPurchaseIds;
}

+ (AdManager *)manager;
- (AdMarvelView *)getAdMarvelInterstitialView;
- (void)checkAndShowInterstitialAd;
- (BOOL)shouldShowAds;

@end
