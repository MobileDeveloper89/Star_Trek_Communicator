//
//  GlowButton.m
//  SpaceRadio
//
//  Created by Ashutosh on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlowButton.h"

@implementation GlowButton

@synthesize glowImage;

// only one glow button can be pressed at a time
static GlowButton * glowButtonPressed = nil;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (glowButtonPressed != nil) {
        return;
    }

    glowButtonPressed = self;
    [super touchesBegan:touches withEvent:event];

    self.glowImage.hidden = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (glowButtonPressed != self) {
        return;
    }

    [super touchesMoved:touches withEvent:event];

    if (self.highlighted) {
        self.glowImage.hidden = NO;
    } else {
        self.glowImage.hidden = YES;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (glowButtonPressed != self) {
        return;
    }
    
    [super touchesCancelled:touches withEvent:event];
    
    self.glowImage.hidden = YES;
    glowButtonPressed = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (glowButtonPressed != self) {
        return;
    }

    [super touchesEnded:touches withEvent:event];

    self.glowImage.hidden = YES;
    glowButtonPressed = nil;
}

@end
