//
//  SoundList.m
//  iDea
//
//  Created by Asya on 9/28/09.
//  Copyright 2009 OptixSoft. All rights reserved.
//

#import "SoundList.h"
#import "SoundManager.h"

@implementation SoundList


-(id) init{

	if((self = [super init]))
	{
		leftIndex = -1;
		rightIndex = -1;
	}
	return self;
}

-(NSString *) getNextLeftSoundName
{
    leftIndex = [[SoundManager manager] getNextSoundIndex:leftIndex forButton:@"left"];
    if (leftIndex != -1) {
        NSString * soundName = [[[[SoundManager manager] getUnlockedSounds] objectAtIndex:leftIndex] objectForKey:@"sound"];
        NSString *soundlistPath = [[NSBundle mainBundle] pathForResource:@"soundlist" ofType:@"plist"];
        NSArray *soundlist = [NSDictionary dictionaryWithContentsOfFile:soundlistPath];
        NSDictionary *sound = [soundlist valueForKey:soundName];
        return [sound valueForKey:@"File"];
    }
    return nil;
}

-(NSString *) getNextRightSoundName
{
    rightIndex = [[SoundManager manager] getNextSoundIndex:rightIndex forButton:@"right"];
    if (rightIndex != -1) {
        NSString * soundName = [[[[SoundManager manager] getUnlockedSounds] objectAtIndex:rightIndex] objectForKey:@"sound"];
        NSString *soundlistPath = [[NSBundle mainBundle] pathForResource:@"soundlist" ofType:@"plist"];
        NSArray *soundlist = [NSDictionary dictionaryWithContentsOfFile:soundlistPath];
        NSDictionary *sound = [soundlist valueForKey:soundName];
        return [sound valueForKey:@"File"];
    }
    return nil;
}

@end
