//
//  SoundList.h
//  iDea
//
//  Created by Asya on 9/28/09.
//  Copyright 2009 OptixSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundList : NSObject {
    
	NSInteger leftIndex;
	NSInteger rightIndex;
}

-(NSString *) getNextLeftSoundName;
-(NSString *) getNextRightSoundName;

@end
