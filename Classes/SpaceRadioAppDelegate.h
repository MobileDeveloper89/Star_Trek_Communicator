//
//  SpaceRadioAppDelegate.h
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MKStoreManager.h"

@class MainViewController;

@interface SpaceRadioAppDelegate : NSObject<UIApplicationDelegate, MKStoreKitDelegate, UIAlertViewDelegate> {
    UIWindow * window;
    IBOutlet MainViewController * mainViewController;
    IBOutlet UINavigationController * navController;
    AVAudioPlayer * avPlayer;
    NSMutableArray * soundPackPurchaseIds;

    BOOL isPhoneEndedApp;
}
@property (nonatomic) BOOL isPhoneEndedApp;
@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet MainViewController * mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationController * navController;
@property (nonatomic, retain) UIView * customModalView;
@property (nonatomic, copy) NSString * savedPhoneNumber;

- (void)loadUserDefaults;
- (void)saveUserDefaults;
- (BOOL)isIPhone;
- (void)goToMainView:(NSString *) animation;
- (void)goToPhoneView:(NSString *) animation;
- (void)goToInfoView:(NSString *) animation;
- (void)goToSettingsView:(NSString *) animation;
+ (void)showModalView:(UIView *)modalView;
+ (void)hideModalView;
@end
