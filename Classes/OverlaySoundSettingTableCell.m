//
//  OverlaySoundSettingTableCell.m
//  SpaceRadio
//
//  Created by Poonam on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlaySoundSettingTableCell.h"
#import "SoundManager.h"

@implementation OverlaySoundSettingTableCell

@synthesize backgroundImage, soundPackLabel, titleLabel, currentButton, leftButton, rightButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsTableSoundPlayed:) name:@"settingsTableSoundPlayed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsTableSoundStopped:) name:@"settingsTableSoundStopped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsTableSoundPlayed:) name:@"settingsTableSoundDragged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsTableSoundStopped:) name:@"settingsTableSoundDropped" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.backgroundImage = nil;
    self.soundPackLabel = nil;
    self.titleLabel = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.currentButton = nil;
    
    [super dealloc];
}

- (void)settingsTableSoundPlayed:(NSNotification *)notification
{
    if (((NSNumber *)notification.object).integerValue == self.tag) {
        self.backgroundImage.image = [UIImage imageNamed:@"setting table cell background highlighted.png"];
    }
}

- (void)settingsTableSoundStopped:(NSNotification *)notification
{
    self.backgroundImage.image = [UIImage imageNamed:@"setting table cell background.png"];
}

-(void)previewButtonPressed
{
    NSString *soundlistPath = [[NSBundle mainBundle] pathForResource:@"soundlist" ofType:@"plist"];    
    NSArray *soundlist = [NSDictionary dictionaryWithContentsOfFile:soundlistPath];
    
    NSDictionary *sound = [soundlist valueForKey:soundName];
    
  	NSString *path = [[NSBundle mainBundle] pathForResource:[sound valueForKey:@"File"] ofType:@"mp3"];
    
  	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath: path] autorelease];
    
    [[SoundManager manager] playSound:fileURL];
}

-(void) setUpDataForSound:(NSString *)sndName atIndex:(NSUInteger)index cellHighlighted:(BOOL)cellHighlighted
{
    soundName = sndName;
    soundIndex = index;
    NSString * packName = [[SoundManager manager] packNameForSound:sndName];
    
    // set sound & pack titles
    [self.titleLabel setText:[sndName uppercaseString]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Enterprise" size:10]];      
    [self.soundPackLabel setText:[NSString stringWithFormat:@"%@ Pack", packName]];
    [self.soundPackLabel setFont:[UIFont fontWithName:@"Enterprise" size:9]];
    
    // set hilighted button
    NSString * button = [[SoundManager manager] getButtonForSoundAtIndex:index];
    if (button != nil && [button isEqualToString:@"left"] == YES) {
        [self highlightLeftButton];
        [self unhilightRightButton];
    } else if (button != nil && [button isEqualToString:@"right"] == YES) {
        [self highlightRightButton];
        [self unhilightLeftButton];
    } else {
        [self unhilightLeftButton];
        [self unhilightRightButton];
    }
    
    if (cellHighlighted) {
        self.backgroundImage.image = [UIImage imageNamed:@"setting table cell background highlighted.png"];
    } else {
        self.backgroundImage.image = [UIImage imageNamed:@"setting table cell background.png"];
    }
}

-(void)highlightLeftButton
{
    [self.leftButton setImage:[UIImage imageNamed:@"setting table cell left highlight.png"] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"setting table cell left highlight.png"] forState:UIControlStateHighlighted];
}

-(void)highlightRightButton
{
    [self.rightButton setImage:[UIImage imageNamed:@"setting table cell right highlight.png"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"setting table cell right highlight.png"] forState:UIControlStateHighlighted];
}

-(void)unhilightLeftButton
{
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"setting table cell left highlight.png"] forState:UIControlStateHighlighted];
}

-(void)unhilightRightButton
{
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"setting table cell right highlight.png"] forState:UIControlStateHighlighted];
}

-(IBAction) leftButtonClicked:(id)sender
{
    // unassign from right
    [self unhilightRightButton];

    // assign to left
    NSString * button = [[SoundManager manager] getButtonForSoundAtIndex:soundIndex];
    if (button != nil && [button isEqualToString:@"left"])
    {
        [[SoundManager manager] unassignSoundAtIndex:soundIndex];
        [self unhilightLeftButton];
    }
    else
    {
        [[SoundManager manager] assignSoundAtIndex:soundIndex toButton:@"left"];
        [self highlightLeftButton];
    }
    
    [[SoundManager manager] save];
}

-(IBAction) rightButtonClicked:(id)sender
{
    // unassign from left
    [self unhilightLeftButton];

    // assign to right
    NSString * button = [[SoundManager manager] getButtonForSoundAtIndex:soundIndex];
    if (button != nil && [button isEqualToString:@"right"])
    {
        [[SoundManager manager] unassignSoundAtIndex:soundIndex];
        [self unhilightRightButton];
    }
    else
    {
        [[SoundManager manager] assignSoundAtIndex:soundIndex toButton:@"right"];
        [self highlightRightButton];
    }
    
    [[SoundManager manager] save];
}

@end
