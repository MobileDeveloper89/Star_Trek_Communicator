//
//  PurchaseTableCell.h
//  SpaceRadio
//
//  Created by Poonam on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseTableDelegate.h"


@interface PurchaseTableCell : UITableViewCell {
    NSDictionary *purchaseData;
    BOOL buttonClickedOnce;
    BOOL currentStateDetailView;
    UITextView * descriptionText;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImage;
@property (nonatomic, assign) PurchaseTableDelegate *delegate;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) IBOutlet UIButton * highlightButton;
@property (nonatomic, retain) IBOutlet UIImageView * backgroundImageView;

- (void)loadPurchaseData:(NSDictionary *)purchaseData font:(UIFont *) font;
- (IBAction)buyButtonPressed;
- (void)showData;
- (void)hideData;

- (IBAction)highlightButtonClick;

@end
