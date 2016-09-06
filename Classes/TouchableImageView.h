//
//  TouchableImageView.h
//  PushButton
//
//  Created by Asya Maryenkova on 3/7/09.
//  Copyright 2009 OptixSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TouchableImageViewDelegate <NSObject>

-(void)onClickEvent;
@end

@interface TouchableImageView : UIImageView {
	
	CGPoint startTouchPosition;
    BOOL coverAnimation;
}

@property(nonatomic, retain) id<TouchableImageViewDelegate> delegate;

@end

