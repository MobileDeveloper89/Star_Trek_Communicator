//
//  PurchaseTableDelegate.h
//  SpaceRadio
//
//  Created by Ashutosh on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PurchaseViewController.h"

@interface PurchaseTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
    NSArray *purchases;
    CGRect lastSelectedRowRect;
    NSInteger lastSelectedRow;
    PurchaseViewController * purchaseController;
    UIFont * font;
}

-(id) initWithController:(PurchaseViewController *)c;
-(void) reset;
-(void) installedButtonClicked: (NSString *) soundPackName;
-(void) cellHighlightButtonClicked: (NSIndexPath *) indexPath;

@end
