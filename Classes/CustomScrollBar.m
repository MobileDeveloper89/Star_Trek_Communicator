//
//  CustomScrollBar.m
//  SpaceRadio
//
//  Created by Poonam on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomScrollBar.h"


@implementation CustomScrollBar

static int SCROLLBAR_HANDLE_TAG = 1;

@synthesize scrollBarHandle, scrollView;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *uiviews = [[NSBundle mainBundle] loadNibNamed:@"CustomScrollBar" owner:self options:nil];
        
        UIView *scrollbar = [uiviews objectAtIndex:0];
        CGRect rect = scrollbar.frame;
        rect.size.height = self.frame.size.height;
        scrollbar.frame = rect;
        [self addSubview:scrollbar];
        
        self.scrollBarHandle = (UIButton *)[self viewWithTag:SCROLLBAR_HANDLE_TAG];
        [self.scrollBarHandle addTarget:self action:@selector(handleDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    }
    return self;
}

- (void)dealloc
{
    self.scrollBarHandle = nil;
    
    [super dealloc];
}

-(void)refreshHandlePosition
{
    // update scroll bar handle location based on scroll view offset
    if (self.scrollView != nil)
    {
        CGFloat scrollViewHeight = self.scrollView.bounds.size.height;
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        if (scrollViewContentHeight < scrollViewHeight)
        {
            // don't scroll if we don't have enough content
            return;
        }
        CGFloat scrollableHeight = scrollViewHeight - scrollViewContentHeight;
        CGFloat ratio = -self.scrollView.contentOffset.y / scrollableHeight;
        ratio = MIN(MAX(ratio, 0), 1);
        
        CGRect rect = self.scrollBarHandle.bounds;
        rect.origin.y = (self.bounds.size.height - rect.size.height) * ratio;
        self.scrollBarHandle.frame = rect;
    }
}

- (void)handleDragged:(UIControl *)control withEvent:(UIEvent *)event
{
    UITouch *touch = (UITouch *)[[event touchesForView:control] anyObject];
    CGPoint point = [touch locationInView:self];
    
    // update scroll bar handle location
    CGRect rect = self.scrollBarHandle.bounds;
    CGFloat halfHeight = rect.size.height*0.5f;
    rect.origin.y = MIN(MAX(point.y, halfHeight), self.bounds.size.height-halfHeight) - halfHeight;
    
    // update offset of scroll view
    if (self.scrollView != nil)
    {
        CGFloat ratio = rect.origin.y / (self.bounds.size.height - rect.size.height);
        
        CGFloat scrollViewHeight = self.scrollView.bounds.size.height;
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        if (scrollViewContentHeight < scrollViewHeight)
        {
            // don't scroll if we don't have enough content
            return;
        }
        CGFloat scrollableHeight = scrollViewHeight - scrollViewContentHeight;
        CGFloat offset = scrollableHeight * ratio;
        self.scrollBarHandle.frame = rect;
        self.scrollView.contentOffset = CGPointMake(0, -offset);
    }
}

@end
