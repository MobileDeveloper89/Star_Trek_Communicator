//
//  PurchaseViewController.m
//  SpaceRadio
//
//  Created by Poonam on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PurchaseViewController.h"
#import "PurchaseTableCell.h"
#import "SoundManager.h"
#import "PurchaseTableDelegate.h"
#import "SoundSettingsTableDelegate.h"
#import "SpaceRadioAppDelegate.h"
#import "Flurry.h"

#ifdef VERSION_LITE
#import "AdManager.h"
#endif

@interface PurchaseViewController(priv)
-(void) selectRowAtIndexPath:(NSIndexPath * ) indexPath;
@end

@implementation PurchaseViewController

@synthesize purchaseTable, backgroundImageView, soundPacksButton, settingsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [purchaseTableDelegate release];
    [soundSettingsTableDelegate release];
    
    purchaseTableDelegate = nil;
    soundSettingsTableDelegate = nil;
    
    self.purchaseTable = nil;
    self.backgroundImageView = nil;
    self.soundPacksButton = nil;
    self.settingsButton = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentScreen = @"Sound Packs Screen";
    purchaseTableDelegate = [[PurchaseTableDelegate alloc] initWithController:self];
    soundSettingsTableDelegate = [[SoundSettingsTableDelegate alloc] initWithController:self];

    // set up table and its scroll bar
    self.purchaseTable.dataSource = purchaseTableDelegate;
    self.purchaseTable.delegate = purchaseTableDelegate;
    self.soundPacksButton.enabled = NO;
    self.settingsButton.enabled = YES;
}

- (void) viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [Flurry logEvent:currentScreen timed:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [Flurry endTimedEvent:currentScreen withParameters:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(refreshPurchaseTable:) name:@"refreshTable" object:nil];

    if ([[UIDevice currentDevice].systemVersion compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending) {
        [notificationCenter addObserver:self selector:@selector(applicationBackgrounded:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [soundSettingsTableDelegate stopSounds];

    NSNotificationCenter * notificationCenter =[NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"refreshTable" object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [purchaseTableDelegate release];
    [soundSettingsTableDelegate release];
    purchaseTableDelegate = nil;
    soundSettingsTableDelegate = nil;
    
    self.purchaseTable = nil;
    self.backgroundImageView = nil;
    self.soundPacksButton = nil;
    self.settingsButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - navigation button methods

-(IBAction) mainScreenButtonPressed: (id)sender
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToMainView:kCATransitionFromLeft];
}

-(IBAction) dialerScreenButtonPressed:(id)sender
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToPhoneView:kCATransitionFromLeft];
}

- (IBAction) infoButtonClicked:(id)sender {
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToInfoView:kCATransitionFromRight];
}

-(IBAction) soundPacksButtonPressed: (id)sender
{
    [soundSettingsTableDelegate stopSounds];
    [purchaseTableDelegate reset];
    
    [Flurry endTimedEvent:currentScreen withParameters:nil];
    currentScreen = @"Sound Packs Screen";
    
    [Flurry logEvent:currentScreen timed:YES];
    
    self.backgroundImageView.image = [UIImage imageNamed:@"sound pack background.png"];
    self.soundPacksButton.enabled = NO;
    self.settingsButton.enabled = YES;
    self.purchaseTable.dataSource = purchaseTableDelegate;
    self.purchaseTable.delegate = purchaseTableDelegate;
    [self.purchaseTable reloadData];

    self.purchaseTable.editing = NO;
    self.purchaseTable.allowsSelectionDuringEditing = NO;

#ifdef VERSION_LITE
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

-(IBAction) soundSettingsButtonPressed: (id)sender
{
    [soundSettingsTableDelegate loadSounds];
    
    [Flurry endTimedEvent:currentScreen withParameters:nil];
    currentScreen = @"Sound Settings Screen";
    
    [Flurry logEvent:currentScreen timed:YES];
    
    self.backgroundImageView.image = [UIImage imageNamed:@"sound settings background.png"];
    self.soundPacksButton.enabled = YES;
    self.settingsButton.enabled = NO;
    self.purchaseTable.dataSource = soundSettingsTableDelegate;
    self.purchaseTable.delegate = soundSettingsTableDelegate;
    [self.purchaseTable reloadData];
    
    self.purchaseTable.editing = YES;
    self.purchaseTable.allowsSelectionDuringEditing = YES;

#ifdef VERSION_LITE
    [[AdManager manager] checkAndShowInterstitialAd];
#endif
}

- (void) refreshPurchaseTable:(NSNotification *) notification
{
    if (self.purchaseTable.delegate == purchaseTableDelegate) {
        NSIndexPath * lastSelectedRow = [self.purchaseTable indexPathForSelectedRow];
        [self.purchaseTable reloadData];
        if (lastSelectedRow != nil)
        {
            [self.purchaseTable selectRowAtIndexPath:lastSelectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void) applicationBackgrounded:(NSNotification *)notification
{
    [soundSettingsTableDelegate stopSounds];
}

@end
