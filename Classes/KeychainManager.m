//
//  KeychainManager.m
//  SpaceRadio
//
//  Created by Ashutosh on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeychainManager.h"

@interface KeychainManager (KeychainManager_priv)
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
- (void)writeToKeychain;
- (id)initSingleton;
@end

@implementation KeychainManager

static KeychainManager * singletonObject = nil;

/*
   Factory method to get KeychainManager singleton.
 */
+ (KeychainManager *)manager
{
    if (singletonObject == nil) {
        singletonObject = [[KeychainManager alloc] initSingleton];
    }

    return singletonObject;
}

/*
   Try to load user data from keychain when this object is instantiated. If we don't find anything
   in the keychain, then initialize empty userData.
 */
- (id)initSingleton
{
    if ((self = [super init])) {
        // Create search query to look for entry in keychain
        keychainSearchQuery = [[NSMutableDictionary alloc] init];
        [keychainSearchQuery setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];
        [keychainSearchQuery setObject:@"SpaceRadioUserData" forKey:(id)kSecAttrGeneric];
        [keychainSearchQuery setObject:@"SpaceRadioUserData" forKey:(id)kSecAttrAccount];

        // Use the proper search constants, return only the attributes of the first match.
        [keychainSearchQuery setObject:(id) kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [keychainSearchQuery setObject:(id) kCFBooleanTrue forKey:(id)kSecReturnAttributes];

        NSDictionary * tempQuery = [NSDictionary dictionaryWithDictionary:keychainSearchQuery];
        NSMutableDictionary * outDictionary = nil;

        // if we got data in the keychain, load it in
        if (SecItemCopyMatching((CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr) {
            userData = [[self secItemFormatToDictionary:outDictionary] retain];
        }
        // otherwise stick some defaults in it
        else {
            userData = [[NSMutableDictionary alloc] init];
        }

        [outDictionary release];
    }

    return self;
}

/*
   Cleanup.
 */
- (void)dealloc
{
    [keychainSearchQuery release];
    [userData release];

    [super dealloc];
}

/*
   Returns deviceID saved in keychain (from local cache).
 */
- (NSString *)getDeviceID
{
    NSString * deviceID = [userData objectForKey:@"deviceID"];
    if (deviceID == nil) {
        // generate deviceID
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        deviceID = (__bridge NSString *)CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);

        // save deviceID in keychain
        [userData setObject:deviceID forKey:@"deviceID"];
        [self writeToKeychain];

        [deviceID autorelease];
    }

    return deviceID;
}

/*
   Add/Update user data from cache to the keychain.
 */
- (void)writeToKeychain
{
    NSDictionary * attributes = NULL;
    OSStatus result;

    if (SecItemCopyMatching((CFDictionaryRef)keychainSearchQuery, (CFTypeRef *)&attributes) == noErr) {
        // Update previously existing item
        NSMutableDictionary * updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
        [updateItem setObject:[keychainSearchQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];
        [updateItem setObject:@"SpaceRadioUserData" forKey:(id)kSecAttrAccount];

        NSMutableDictionary * dataDict = [self dictionaryToSecItemFormat:userData];
        [dataDict removeObjectForKey:(id)kSecClass];

        result = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)dataDict);
        NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    }
    else {
        // No previous item found; add the new one.
        result = SecItemAdd((CFDictionaryRef)[self dictionaryToSecItemFormat: userData], NULL);
        NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    }
}

/*
   Converts user data from local dictionary to keychain format.
 */
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary * returnDictionary = [NSMutableDictionary dictionary];

    // Add the Generic Password keychain item class attribute.
    [returnDictionary setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];
    [returnDictionary setObject:@"SpaceRadioUserData" forKey:(id)kSecAttrGeneric];
    [returnDictionary setObject:@"SpaceRadioUserData" forKey:(id)kSecAttrAccount];

    // Convert the NSDictionary to NSData to meet the requirements for the value type kSecValueData.
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver * archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeObject:dictionaryToConvert forKey:@"SpaceRadioUserData"];
    [archiver finishEncoding];

    // This is where to store sensitive data that should be encrypted.
    [returnDictionary setObject:data forKey:(id)kSecValueData];

    return returnDictionary;
}

/*
   Converts data from keychain format to local user dictionary format.
 */
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary * searchDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the proper search key and class attribute.
    [searchDictionary setObject:(id) kCFBooleanTrue forKey:(id)kSecReturnData];
    [searchDictionary setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];

    // Acquire the archived data from the attributes.
    NSData * archivedUserData = nil;
    NSMutableDictionary * unarchivedDictionary = nil;
    if (SecItemCopyMatching((CFDictionaryRef)searchDictionary, (CFTypeRef *)&archivedUserData) == noErr) {
        // Add the user data to the dictionary (converting from NSData to NSDictionary).
        NSKeyedUnarchiver * unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:archivedUserData] autorelease];
        unarchivedDictionary = [unarchiver decodeObjectForKey:@"SpaceRadioUserData"];
        [unarchiver finishDecoding];
    }
    else {
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }

    [archivedUserData release];

    return unarchivedDictionary;
}

@end