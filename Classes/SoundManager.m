//
//  SoundManager.m
//  SpaceRadio
//
//  Created by Poonam on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"


@interface SoundManager (SoundManager_priv)
-(NSMutableArray *)getMutableSoundsForButton:(NSString *)button;
-(void)filterSounds:(NSMutableArray *)sounds byPackage:(NSString *)packageName;
@end


@implementation SoundManager

static SoundManager *singletonManager;

+(SoundManager *)manager
{
    if (singletonManager == nil)
    {
        singletonManager = [[SoundManager alloc] init];
        [singletonManager load];
    }
    return singletonManager;
}

+(void)copyDefaultSoundFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSMutableArray *unlockedSoundsList = [NSMutableArray array];

    // create unlocked file in documents folder
    NSString *unlockedpath = [documentsDirectory stringByAppendingPathComponent:@"sounds_unlocked.plist"];
	if ([fileManager fileExistsAtPath:unlockedpath] == NO)
    {
        // copy sounds from purchases with purchaseID not present
        NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
        NSDictionary *purchasesPlistData = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *purchases = [purchasesPlistData valueForKey:@"Purchases"];
        path = [[NSBundle mainBundle] pathForResource:@"soundlist" ofType:@"plist"];
        NSDictionary *soundsListData = [NSDictionary dictionaryWithContentsOfFile:path];

        for (int i=0; i<[purchases count]; i++)
        {
            NSDictionary *purchaseData = [purchases objectAtIndex:i];
            NSString *purchaseID = [purchaseData objectForKey:@"PurchaseID"];
            if (purchaseID == nil || [purchaseID length] == 0)
            {
                // add sounds for this purchase to unlocked list
                NSArray *soundList = [purchaseData objectForKey:@"Sounds"];
                for (NSString *sound in soundList)
                {
                    NSDictionary *soundData = [soundsListData objectForKey:sound];
                    NSString *defaultButton = [soundData objectForKey:@"DefaultButton"];
                    [unlockedSoundsList addObject:[NSDictionary dictionaryWithObjectsAndKeys:sound, @"sound", defaultButton, @"button", nil]];
                }
            }
        }

        NSDictionary *defaultDict = [NSDictionary dictionaryWithObjectsAndKeys:unlockedSoundsList, @"sounds", nil];
        [defaultDict writeToFile:unlockedpath atomically:YES];
    }
}

-(void)dealloc
{
    [soundsUnlocked release];
    
    [super dealloc];
}

-(void)load
{
    // release current data before (re)loading
    [soundsUnlocked release];
    [soundToPackMap release];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // load unlocked sounds
    NSString *unlockedpath = [documentsDirectory stringByAppendingPathComponent:@"sounds_unlocked.plist"];
    NSDictionary *unlockedPlistData = [NSDictionary dictionaryWithContentsOfFile:unlockedpath];
    
    soundsUnlocked = [[NSMutableArray arrayWithArray:[unlockedPlistData valueForKey:@"sounds"]] retain];
    
    // make sound to pack map
    NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
    NSDictionary *purchasesPlistData = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *purchases = [purchasesPlistData valueForKey:@"Purchases"];
    soundToPackMap = [[NSMutableDictionary dictionary] retain];
    for (int i=0; i<[purchases count]; i++)
    {
        NSDictionary *purchaseData = [purchases objectAtIndex:i];
        NSString *packName = (NSString *) [purchaseData objectForKey:@"Name"];
        NSArray *soundList = [purchaseData objectForKey:@"Sounds"];
        for (int j = 0; j < [soundList count]; j++) {
            [soundToPackMap setObject:packName forKey:[soundList objectAtIndex:j]];
        }
    }
}

-(void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // save unlocked sounds
    NSString *unlockedpath = [documentsDirectory stringByAppendingPathComponent:@"sounds_unlocked.plist"];
    NSMutableDictionary *unlockeddictionary = [[NSMutableDictionary alloc] init];
    [unlockeddictionary setObject:soundsUnlocked forKey:@"sounds"];
    [unlockeddictionary writeToFile:unlockedpath atomically:YES];
    [unlockeddictionary release];
}

-(void)unassignSoundAtIndex:(NSUInteger)soundIndex
{
    [self assignSoundAtIndex:soundIndex toButton:@""];
}

-(void)assignSoundAtIndex:(NSUInteger)soundIndex toButton:(NSString *)toButton
{
    [[soundsUnlocked objectAtIndex:soundIndex] setObject:toButton forKey:@"button"];
}

-(NSString *)getButtonForSoundAtIndex:(NSUInteger)soundIndex
{
    return [[soundsUnlocked objectAtIndex:soundIndex] objectForKey:@"button"];
}

-(NSUInteger)getNextSoundIndex:(NSUInteger)curIndex forButton:(NSString *)button
{
    int i = curIndex;
    int count = 0;
    int numSounds = [soundsUnlocked count];
    while (count < numSounds) {
        i = (i+1) % numSounds;
        count++;
        if ([[[soundsUnlocked objectAtIndex:i] objectForKey:@"button"] isEqualToString:button]) {
            return i;
        }
    }
    return -1;
}

-(void)moveSoundFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSObject * sound = [[soundsUnlocked objectAtIndex:fromIndex] retain];
    [soundsUnlocked removeObjectAtIndex:fromIndex];
    [soundsUnlocked insertObject:sound atIndex:toIndex];
    [sound release];
}

-(void)unlockSoundsForPurchaseID:(NSString *)purchaseID
{
    // add sounds from this purchase package to the list of unlocked sounds
    NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
    NSDictionary *purchasesPlistData = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *purchases = [purchasesPlistData valueForKey:@"Purchases"];
    
    for (int i=0; i<[purchases count]; i++)
    {
        NSDictionary *purchaseData = [purchases objectAtIndex:i];
        if ([(NSString *)[purchaseData objectForKey:@"PurchaseID"] compare:purchaseID] == NSOrderedSame)
        {
            // add sounds for this purchase to unlocked list
            NSArray *soundList = [purchaseData objectForKey:@"Sounds"];
            for (NSString *soundName in soundList)
            {
                [soundsUnlocked addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:soundName, @"sound", @"", @"button", nil]];
            }
            
            // save sounds file
            [self save];
            
            break;
        }
    }
}

-(NSString *)packNameForSound:(NSString *)soundName
{
    return [soundToPackMap objectForKey:soundName];
}

-(NSArray *)getUnlockedSounds
{
    return soundsUnlocked;
}

-(void)playSound:(NSURL *)soundURL
{
    if (audioPlayer != nil)
    {
        if ([audioPlayer isPlaying])
        {
            [audioPlayer stop];
        }
        [audioPlayer release];
    }

    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error: nil]; 

	[audioPlayer prepareToPlay]; 
	[audioPlayer setDelegate: self];

	[audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [audioPlayer release];
    audioPlayer = nil;
}

@end
