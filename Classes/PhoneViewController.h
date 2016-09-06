//
//  PhoneViewController.h
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LCDView.h"
#import "PhoneNumberFormatter.h"

@interface PhoneViewController : UIViewController<AVAudioPlayerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate> {

	AVAudioPlayer * player;
    NSTimer * deleteButtonTimer;
    int screenNo;
    PhoneNumberFormatter * formatter;
}

@property(nonatomic,retain) IBOutlet UIButton * deleteButton;
@property(nonatomic,retain) IBOutlet UIButton * addressBookButton;
@property(nonatomic,retain) IBOutlet LCDView * lcdView;

-(IBAction) numberButtonPressed:(id) sender;
-(IBAction) callButtonPressed:(id)sender;
-(IBAction) exitButtonPressed:(id) sender;
-(IBAction) deleteButtonTouchDown;
-(IBAction) deleteButtonTouchUp;
-(IBAction) addressBookButtonPressed;
-(IBAction) infoButtonPressed: (id) sender;
-(void) runPhone;
- (IBAction) settingsButtonPressed:(id) sender;

@end
