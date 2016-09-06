//
//  LCDView.h
//  SpaceRadio
//
//  Created by Ashutosh on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCDView : UIView {
    NSString * _number;
}

@property (nonatomic, copy) NSString * number;

@end
