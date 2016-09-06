//
//  TouchableImageView.m
//  PushButton
//
//  Created by Asya Maryenkova on 3/7/09.
//  Copyright 2009 OptixSoft. All rights reserved.
//

#import "TouchableImageView.h"
#import "SpaceRadioAppDelegate.h"
#import "MainViewController.h"

@implementation TouchableImageView

@synthesize delegate;

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	SpaceRadioAppDelegate *appDelagate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelagate.mainViewController animateOpenCloseCover];
//}

#define VERT_SWIPE_DRAG_MIN  12 
#define HORIZ_SWIPE_DRAG_MAX    4 


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject]; 
    // startTouchPosition is an instance variable 
    startTouchPosition = [touch locationInView:self];
    coverAnimation = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject]; 
    CGPoint currentTouchPosition = [touch locationInView:self]; 
    // To be a swipe, direction of touch must be horizontal and long enough. 
    if (fabsf(startTouchPosition.y - currentTouchPosition.y) >= 
		VERT_SWIPE_DRAG_MIN && 
        fabsf(startTouchPosition.x - currentTouchPosition.x) <= 
		HORIZ_SWIPE_DRAG_MAX) 
    { 
		SpaceRadioAppDelegate *appDelagate = (SpaceRadioAppDelegate *)[[UIApplication sharedApplication] delegate];
		
        if (startTouchPosition.y > currentTouchPosition.y) {
            [appDelagate.mainViewController checkAndOpenCover];
        }
        else {
            [appDelagate.mainViewController checkAndCloseCover];
        }
        coverAnimation = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	startTouchPosition = CGPointMake(0,0);
    if (!coverAnimation) {
        [self.delegate onClickEvent];
    }
}

- (void)dealloc {
	
    [super dealloc];
}

@end
