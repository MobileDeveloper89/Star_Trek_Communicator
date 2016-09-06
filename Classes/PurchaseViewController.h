//
//  PurchaseViewController.h
//  SpaceRadio
//
//  Created by Poonam on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlowButton.h"

@class PurchaseTableDelegate;
@class SoundSettingsTableDelegate;

@interface PurchaseViewController : UIViewController {
    PurchaseTableDelegate * purchaseTableDelegate;
    SoundSettingsTableDelegate * soundSettingsTableDelegate;
    NSString * currentScreen;
}

@property (nonatomic, retain) IBOutlet UIImageView * backgroundImageView;
@property (nonatomic, retain) IBOutlet UITableView * purchaseTable;
@property (nonatomic, retain) IBOutlet GlowButton * soundPacksButton;
@property (nonatomic, retain) IBOutlet GlowButton * settingsButton;

-(IBAction) mainScreenButtonPressed: (id)sender;
-(IBAction) dialerScreenButtonPressed: (id)sender;
-(IBAction) infoButtonClicked: (id)sender;
-(IBAction) soundPacksButtonPressed: (id)sender;
-(IBAction) soundSettingsButtonPressed: (id)sender;
-(void) refreshPurchaseTable:(NSNotification *) notification;
@end
