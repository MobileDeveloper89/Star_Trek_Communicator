//
//  SoundManager.h
//  SpaceRadio
//
//  Created by Poonam on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundManager : NSObject <AVAudioPlayerDelegate> {
    NSMutableArray *soundsUnlocked;
    AVAudioPlayer *audioPlayer;
    NSMutableDictionary * soundToPackMap; // sound name to pack name
}

+(SoundManager *)manager;
+(void)copyDefaultSoundFiles;

-(void)load;
-(void)save;
-(void)unassignSoundAtIndex:(NSUInteger)soundIndex;
-(void)assignSoundAtIndex:(NSUInteger)soundIndex toButton:(NSString *)toButton;
-(NSUInteger)getNextSoundIndex:(NSUInteger)curIndex forButton:(NSString *)button;
-(NSString *)getButtonForSoundAtIndex:(NSUInteger)soundIndex;
-(void)unlockSoundsForPurchaseID:(NSString *)purchaseID;
-(void)playSound:(NSURL *)soundURL;
-(NSString *)packNameForSound:(NSString *)soundName;
-(NSArray *)getUnlockedSounds;
-(void)moveSoundFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
