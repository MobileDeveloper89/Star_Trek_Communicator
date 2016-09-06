//
//  SoundSettingsTableDelegate.h
//  SpaceRadio
//
//  Created by Ashutosh on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PurchaseViewController.h"

@interface SoundSettingsTableDelegate : NSObject <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {
    PurchaseViewController * purchaseController;
    NSMutableArray * sounds;
    NSInteger audioPlayIndex;
    AVAudioPlayer *player;
}

- (id)initWithController:(PurchaseViewController *)c;
- (void)loadSounds;
- (void)stopSounds;

@end
