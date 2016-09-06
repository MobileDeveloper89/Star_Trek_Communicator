//
//  PhoneNumberFormatter.h
//  SpaceRadio
//
//  Created by Ashutosh on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNumberFormatter : NSFormatter
{
    NSLocale * _locale;
    NSCharacterSet * _filterCharSet;
}

- (id)initWithLocale:(NSLocale *)locale;

@end