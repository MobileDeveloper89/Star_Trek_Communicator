//
//  PhoneNumberFormatter.m
//  SpaceRadio
//
//  Created by Ashutosh on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhoneNumberFormatter.h"

@implementation PhoneNumberFormatter


- (id)initWithLocale:(NSLocale *)locale
{
    self = [super init];
    if (self) {
        _locale = [locale retain];
        NSMutableCharacterSet * workingSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
        [workingSet addCharactersInString:@"*#"];
        _filterCharSet = [[workingSet invertedSet] retain];
        [workingSet release];
    }
    
    return self;
}

- (void)dealloc
{
    [_locale release];
    [_filterCharSet release];
    [super dealloc];
}

- (NSString *)stringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString * inputString = (NSString *) anObject;

    // Keep only decimal digits and * and # in the string.
    NSRange ra = [inputString rangeOfCharacterFromSet:_filterCharSet];
    while (ra.location != NSNotFound) {
        inputString = [inputString stringByReplacingCharactersInRange:ra withString:@""];
        ra = [inputString rangeOfCharacterFromSet:_filterCharSet];
    }

    NSUInteger inputStringLength = [inputString length];
    
    // If locale is neither US nor CA, then return inputString.
    if (![[_locale localeIdentifier] isEqualToString:@"en_US"] && ![[_locale localeIdentifier] isEqualToString:@"en_CA"])
    {
        return inputString;
    }
    
    // If inputString has "*" or "#" return inputString
    if ([inputString rangeOfString:@"*"].location != NSNotFound || [inputString rangeOfString:@"#"].location != NSNotFound) {
        return inputString;
    }

    // If inputString length is greater than 11 return inputString
    if (inputStringLength > 11) {
        return inputString;
    }

    BOOL isUSCountryCode = [inputString hasPrefix:@"1"];
    // If inputString length is greater than 10 and first char is not 1 then return inputString
    if (inputStringLength > 10 && !isUSCountryCode) {
        return inputString;
    }

    // else format the string
    NSMutableString * resultString = [[[NSMutableString alloc] init] autorelease];
    // Handle Country Code
    if (isUSCountryCode) {
        [resultString appendString:@"1"];
        inputString = [inputString substringFromIndex:1];
        inputStringLength--;
        if (inputStringLength > 0) {
            [resultString appendString:@"-"];
        }
    }

    // Handle Area Code
    NSString * tempString = [inputString substringWithRange:NSMakeRange(0, MIN(3, inputStringLength))];
    [resultString appendString:tempString];
    inputString = [inputString substringFromIndex:[tempString length]];
    inputStringLength = inputStringLength - [tempString length];
    if (inputStringLength > 0) {
        [resultString appendString:@"-"];
    }

    // Handle Part 2
    tempString = [inputString substringWithRange:NSMakeRange(0, MIN(3, inputStringLength))];
    [resultString appendString:tempString];
    inputString = [inputString substringFromIndex:[tempString length]];
    inputStringLength = inputStringLength - [tempString length];
    if (inputStringLength > 0) {
        [resultString appendString:@"-"];
    }

    // Handle Part 3
    [resultString appendString:inputString];

    return [NSString stringWithString:resultString];

}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString * *)error
{
    return YES;
}

@end