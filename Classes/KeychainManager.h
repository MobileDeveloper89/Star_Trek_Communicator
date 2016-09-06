//
//  KeychainManager.h
//  SpaceRadio
//
//  Created by Ashutosh on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject {
    NSMutableDictionary *keychainSearchQuery;
    NSMutableDictionary *userData;
}

+ (KeychainManager *)manager;
- (NSString *) getDeviceID;

@end
