//
//  PhoneNumberFormatterTests.m
//  SpaceRadio
//
//  Created by Ashutosh on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhoneNumberFormatterTests.h"
#import "PhoneNumberFormatter.h"

@implementation PhoneNumberFormatterTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testNonUSLocaleDoesNotFormat
{
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
    PhoneNumberFormatter * formatter = [[PhoneNumberFormatter alloc] initWithLocale:locale];

    NSString * inputString = @"1234";
    NSString * returnString = [formatter stringForObjectValue:inputString];
    STAssertEqualObjects(inputString, returnString, nil);

    inputString = @"12-34";
    returnString = [formatter stringForObjectValue:inputString];
    STAssertEqualObjects(@"1234", returnString, nil);

    inputString = @"12-3*4";
    returnString = [formatter stringForObjectValue:inputString];
    STAssertEqualObjects(@"123*4", returnString, nil);

    inputString = @"12-3*4#";
    returnString = [formatter stringForObjectValue:inputString];
    STAssertEqualObjects(@"123*4#", returnString, nil);
}

- (void)testUSCALocaleWithCountryCode
{
    NSArray * localeIdentifiers = [NSArray arrayWithObjects:@"en_US", @"en_CA", nil];

    for (NSString * localeID in localeIdentifiers) {

        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
        PhoneNumberFormatter * formatter = [[PhoneNumberFormatter alloc] initWithLocale:locale];

        NSString * inputString = @"1";
        NSString * returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(inputString, returnString, nil);

        inputString = @"12";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-2", returnString, nil);

        inputString = @"123";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-23", returnString, nil);

        inputString = @"1234";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234", returnString, nil);

        inputString = @"12345";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-5", returnString, nil);

        inputString = @"123456";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-56", returnString, nil);

        inputString = @"1234567";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-567", returnString, nil);

        inputString = @"12345678";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-567-8", returnString, nil);

        inputString = @"123456789";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-567-89", returnString, nil);

        inputString = @"1234567890";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-567-890", returnString, nil);

        inputString = @"12345678901";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"1-234-567-8901", returnString, nil);

        inputString = @"123456789012";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"123456789012", returnString, nil);
    }
}

- (void)testUSCALocaleWithoutCountryCode
{
    NSArray * localeIdentifiers = [NSArray arrayWithObjects:@"en_US", @"en_CA", nil];

    for (NSString * localeID in localeIdentifiers) {

        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
        PhoneNumberFormatter * formatter = [[PhoneNumberFormatter alloc] initWithLocale:locale];

        NSString * inputString = @"2";
        NSString * returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(inputString, returnString, nil);

        inputString = @"23";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"23", returnString, nil);

        inputString = @"234";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234", returnString, nil);

        inputString = @"2345";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-5", returnString, nil);

        inputString = @"23456";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-56", returnString, nil);

        inputString = @"234567";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-567", returnString, nil);

        inputString = @"2345678";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-567-8", returnString, nil);

        inputString = @"23456789";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-567-89", returnString, nil);

        inputString = @"234567890";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-567-890", returnString, nil);

        inputString = @"2345678901";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"234-567-8901", returnString, nil);

        inputString = @"23456789012";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"23456789012", returnString, nil);
    }
}

- (void)testUSCALocalWithSigns
{
    NSArray * localeIdentifiers = [NSArray arrayWithObjects:@"en_US", @"en_CA", nil];

    for (NSString * localeID in localeIdentifiers) {

        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
        PhoneNumberFormatter * formatter = [[PhoneNumberFormatter alloc] initWithLocale:locale];

        NSString * inputString = @"2*234";
        NSString * returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"2*234", returnString, nil);

        inputString = @"2*23-4";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"2*234", returnString, nil);

        inputString = @"2#23-4";
        returnString = [formatter stringForObjectValue:inputString];
        STAssertEqualObjects(@"2#234", returnString, nil);
    }
}


@end