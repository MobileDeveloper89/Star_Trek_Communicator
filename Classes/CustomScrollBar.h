//
//  CustomScrollBar.h
//  SpaceRadio
//
//  Created by Poonam on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomScrollBar : UIView {
    
}

@property (nonatomic, retain) IBOutlet UIButton *scrollBarHandle;
@property (nonatomic, assign) UIScrollView *scrollView;

-(void)refreshHandlePosition;

@end
