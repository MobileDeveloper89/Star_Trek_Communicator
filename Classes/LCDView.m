//
//  LCDView.m
//  SpaceRadio
//
//  Created by Ashutosh on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LCDView.h"
#import "SpaceRadioAppDelegate.h"

@implementation LCDView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) dealloc
{
    [_number release];
    _number = nil;
    
    [super dealloc];
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextClearRect(context, rect);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGImageRef lcdImage = [UIImage imageNamed:@"dialer lcd.png"].CGImage;
    CGFloat charWidth = CGImageGetWidth(lcdImage) / 14.0; // there are 14 characters in the image
    CGFloat displayCharWidth = rect.size.width / 14.0; // there are 14 characters in the image
    CGImageRef img;
    CGRect rect1;

    // number is right justified. & overflows off to the left side.

    NSInteger length = [_number length];
    NSInteger startIndex = MAX(0, (length - 14));
    for (int i = startIndex; i < length; i++) {
        img = nil;
        NSString * character = [_number substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"*"]) {
            img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(12*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
        } else if ([character isEqualToString:@"#"]) {
            img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(13*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
        } else if ([character isEqualToString:@"-"]) {
            img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(10*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
        } else if ([character isEqualToString:@"+"]) {
            img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(11*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
        } else {
            NSInteger number = [character integerValue];
            if (number > 0 && number < 10) {
                number -= 1;
                img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(number*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
            } else if (number == 0) {
                img = CGImageCreateWithImageInRect(lcdImage, CGRectMake(9*charWidth, 0, charWidth, CGImageGetHeight(lcdImage)));
            }
        }

        rect1 = CGRectMake(rect.size.width - (length-i)*displayCharWidth, 0, displayCharWidth, rect.size.height);
        if (img != nil) {
            CGContextDrawImage(context, rect1, img);
            CGImageRelease(img);
        }
    }
}

- (NSString *)number
{
    return _number;
}

- (void)setNumber:(NSString *)number
{
    [_number release];
    _number = [number copy];
    
    SpaceRadioAppDelegate * appDelegate = (SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate;            
    appDelegate.savedPhoneNumber = _number;
    
    [self setNeedsDisplay];
}

@end
