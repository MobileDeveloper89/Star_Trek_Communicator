//
//  UIButtonStated.m
//  SpaceRadio
//
//  Created by Asya Maryenkova on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIButtonStated.h"


@implementation UIButtonStated

@synthesize isSelected;

-(void)setIsSelected:(BOOL)sel{
	
	isSelected = sel;
	if(isSelected) {
        self.hidden = NO;
    }
	else {
        self.hidden = YES;
    }		
}
@end
