//
//  PhoneViewController.m
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhoneViewController.h"
#import "SpaceRadioAppDelegate.h"
#import "UIButtonStated.h"
#import "Flurry.h"

@implementation PhoneViewController

@synthesize lcdView, deleteButton, addressBookButton;

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    self.addressBookButton = nil;
    self.deleteButton = nil;
    self.lcdView = nil;
    
    [formatter release];
    formatter = nil;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    formatter = [[PhoneNumberFormatter alloc] initWithLocale:[NSLocale currentLocale]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.addressBookButton.userInteractionEnabled = YES;

    [Flurry logEvent:@"Phone Screen" timed:YES];
    
    SpaceRadioAppDelegate * appDelegate = (SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.savedPhoneNumber != nil) {
        self.lcdView.number = [formatter stringForObjectValue:appDelegate.savedPhoneNumber];
    } else {
        self.lcdView.number = @"";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.addressBookButton.userInteractionEnabled = NO;

    [Flurry endTimedEvent:@"Phone Screen" withParameters:nil];
}

-(void) dealloc {
    if (player != nil) {
        [player stop];
        [player release];
        player = nil;
    }

    self.addressBookButton = nil;
    self.deleteButton = nil;
    self.lcdView = nil;
    [formatter release];
    formatter = nil;
    
    [super dealloc];
}


- (void) startPlayback : (NSString *) path
{
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path]; 
	
    // stop an already playing sound
    if (player != nil) {
        [player stop];
        [player release];
        player = nil;
    }
    
    // play new sound
    player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil]; 
	[player prepareToPlay]; 
	[player play];
    
    [fileURL release];
}

-(IBAction) numberButtonPressed:(id) sender
{
	NSInteger number = ((UIButton *)sender).tag;
    
    // play button sound
    NSString *soundName = [NSString stringWithFormat:@"%d", number];
    NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
    [self startPlayback:path];
	
	if(number > 0 && number < 10)
    {
		self.lcdView.number = [formatter stringForObjectValue:[NSString stringWithFormat:@"%@%d", self.lcdView.number, number]];
    }
	else if(number == 10)
	{
		unichar sym = '*';
		self.lcdView.number = [formatter stringForObjectValue:[NSString stringWithFormat:@"%@%C", self.lcdView.number, sym]];
	}
	else if(number == 11)
    {
		self.lcdView.number = [formatter stringForObjectValue:[NSString stringWithFormat:@"%@%d", self.lcdView.number, 0]];
    }
	else if(number == 12)
	{
		unichar sym = '#';
		self.lcdView.number = [formatter stringForObjectValue:[NSString stringWithFormat:@"%@%C", self.lcdView.number, sym]];
	}
	
}

-(IBAction) deleteButtonTouchDown
{
    // take one digit off first
    [self delButtonPressed];

    // start timer that keeps taking the last digit off
    deleteButtonTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2
                                                          target:self
                                                        selector:@selector(delButtonPressed)
                                                        userInfo:nil
                                                         repeats:YES] retain];
}

-(IBAction) deleteButtonTouchUp
{
    // stop timer that keeps taking the last digit off
    if (deleteButtonTimer != nil) {
        [deleteButtonTimer invalidate];
        [deleteButtonTimer release];
        deleteButtonTimer = nil;
    }
}

-(void) delButtonPressed
{
	if(self.deleteButton.highlighted && [self.lcdView.number length] > 0) {
        // remove last digit from number
		self.lcdView.number = [formatter stringForObjectValue:[self.lcdView.number substringToIndex:[self.lcdView.number length] - 1]];

        // play button sound
        NSString *path = [[NSBundle mainBundle] pathForResource:@"delete-button" ofType:@"mp3"];
        [self startPlayback:path];
    }
}

-(void)runPhone
{
    [Flurry logEvent:@"Phone Call"];
	SpaceRadioAppDelegate *appDelegate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isPhoneEndedApp = YES;

    // use "telprompt" url by default since it can handle all numbers dialed.
    // but if we know that number is more than 3 digits and does not contain * and #, then the number 
    // can be dialed directly and we can use the "tel" url.
    NSString * urlPrefix = @"telprompt";
    if (([self.lcdView.number length] >= 3) && ([self.lcdView.number rangeOfString:@"*"].location == NSNotFound) && ([self.lcdView.number rangeOfString:@"#"].location == NSNotFound)) {
        urlPrefix = @"tel";
    }

	NSString *strPhone = [NSString stringWithFormat:@"%@:%@", urlPrefix, self.lcdView.number];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
}

-(IBAction) callButtonPressed:(id)sender{
	if([self.lcdView.number length] < 1)
		return;
	
    // play button sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    [self startPlayback:path];
    
    [self performSelector:@selector(runPhone) withObject:sender];
}

-(void) showAddressPicker
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

-(IBAction) addressBookButtonPressed
{
    // only one click at a time. will be enabled again in viewWillAppear
    self.addressBookButton.userInteractionEnabled = NO;

    // play sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"accessingfiles" ofType:@"mp3"];
    [self startPlayback:path];

    [self performSelector:@selector(showAddressPicker) withObject:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

/*
 * Called when a contact is selected from contact list.
 */
- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
	NSString * phoneNumber;
	if (ABMultiValueGetCount(multi) != 0) {
        // When there are more than 1 numbers associated with a contact, show the detailed view for that contact.
		if (ABMultiValueGetCount(multi) > 1)
		{
			ABPersonViewController * personController = [[ABPersonViewController alloc] init];
			[personController setDisplayedPerson:person];
			[personController setPersonViewDelegate:self];
			[personController setAllowsEditing:NO];
			//personController.addressBook = ABAddressBookCreate();
			personController.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
            CFRelease(multi);
			return YES;
		}
		else {
            // If there is only number associated with a contact, select that number.
			phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(multi, 0);
            
			self.lcdView.number = [formatter stringForObjectValue:phoneNumber];
			[self dismissModalViewControllerAnimated:YES];
            [phoneNumber autorelease];
            CFRelease(multi);
			return NO;
		}		
	}
	else {
		self.lcdView.number = @"";
		[self dismissModalViewControllerAnimated:YES];
        CFRelease(multi);
		return NO;
	}		
}



- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue{
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

/* 
 * This method is called when there are more than one numbers associated with the selected contact.
 */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
	if (property == kABPersonPhoneProperty){
		ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex index = ABMultiValueGetIndexForIdentifier(multi, identifier);
		NSString * phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(multi, index);
		self.lcdView.number = [formatter stringForObjectValue:phoneNumber];
		[self dismissModalViewControllerAnimated:YES];
        [phoneNumber autorelease];
        CFRelease(multi);
	}
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark - navigation button methods

-(IBAction) exitButtonPressed:(id)sender
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToMainView:kCATransitionFromLeft];
}

- (IBAction) settingsButtonPressed:(id) sender
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToSettingsView:kCATransitionFromRight];
}

- (IBAction) infoButtonPressed:(id)sender
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToInfoView:kCATransitionFromRight];
}

@end
