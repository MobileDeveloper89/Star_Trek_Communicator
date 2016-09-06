//
//  UIUnderlineButton.m
//  SpaceRadio
//
//  Created by Ashutosh on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIUnderlinedButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIUnderlinedButton

+ (UIUnderlinedButton*) underlinedButton {
    UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
    
    return [button autorelease];
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same shadow as text

    UIColor * shadowColor = self.currentTitleShadowColor;
    CGSize offset = self.titleLabel.shadowOffset;
    
    CGContextMoveToPoint(contextRef, textRect.origin.x + offset.width, textRect.origin.y + textRect.size.height + descender + self.titleLabel.shadowOffset.height + offset.height);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width + offset.width, textRect.origin.y + textRect.size.height + descender + self.titleLabel.shadowOffset.height + offset.height);    
    
    CGContextSetStrokeColorWithColor(contextRef, shadowColor.CGColor);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);   
    
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender + self.titleLabel.shadowOffset.height);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender + self.titleLabel.shadowOffset.height);

    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}


@end
