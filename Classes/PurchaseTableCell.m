//
//  PurchaseTableCell.m
//  SpaceRadio
//
//  Created by Poonam on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PurchaseTableCell.h"
#import "MKStoreManager.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"


@implementation PurchaseTableCell

@synthesize nameLabel, buyButton, image, arrowImage, delegate, highlightButton, indexPath, backgroundImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)updateBuyButton
{
    NSString *purchaseID = [purchaseData objectForKey:@"PurchaseID"];
    NSString * price = [[MKStoreManager sharedManager] getProductPrice:purchaseID];

    if (purchaseID == nil || [purchaseID length] == 0 || [MKStoreManager isFeaturePurchased:purchaseID] == YES)
    {
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"sound pack button yellow.png"] forState:UIControlStateNormal];
        [self.buyButton setTitle:@"VIEW" forState:UIControlStateNormal];
    }
    else if (buttonClickedOnce || price == nil)
    {
        buttonClickedOnce = YES; // set it to true in case price was nil
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"sound pack button blue.png"] forState:UIControlStateNormal];
        [self.buyButton setTitle:@"BUY" forState:UIControlStateNormal];
    }
    else
    {
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"sound pack button red.png"] forState:UIControlStateNormal];
        [self.buyButton setTitle:price forState:UIControlStateNormal];
    }
}

- (void)showData
{
    currentStateDetailView = YES;
    
    if (descriptionText == nil) {
        descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(30, 45, 240, 105)];
        descriptionText.backgroundColor = [UIColor clearColor];
        descriptionText.font = [UIFont fontWithName:@"Helvetica" size:11];
        descriptionText.textColor = [UIColor whiteColor];
        descriptionText.layer.shadowColor = [[UIColor blackColor] CGColor];
        descriptionText.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        descriptionText.layer.shadowOpacity = 1.0f;
        descriptionText.layer.shadowRadius = 0.0f;
        descriptionText.alpha = 0;
        descriptionText.editable = NO;
        descriptionText.userInteractionEnabled = NO;
        [self addSubview:descriptionText];
    }
    [descriptionText setText:[purchaseData objectForKey:@"Description"]];

    NSString * productExpanded = [purchaseData objectForKey:@"PurchaseID"];
    if (productExpanded == nil || [productExpanded isEqualToString:@""]) {
        productExpanded = [purchaseData objectForKey:@"Name"];
    }
    [Flurry logEvent:@"Sound Pack View" withParameters:[NSDictionary dictionaryWithObject:productExpanded forKey:@"ProductId"]];

    [self.arrowImage setImage:[UIImage imageNamed:@"sound pack up arrow.png"]];
    
    [self.backgroundImageView setImage:[UIImage imageNamed:@"sound pack cell background expanded.png"]];
    CGRect newBounds = self.backgroundImageView.frame;
    newBounds.size.height = 150;
    
    // fade in when showing info
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    descriptionText.alpha = 1;
    self.backgroundImageView.frame = newBounds;
    [UIView commitAnimations];
}

- (void)hideData
{
    [self.arrowImage setImage:[UIImage imageNamed:@"sound pack down arrow.png"]];
    
    // no fade when hiding info
    descriptionText.alpha = 0;
    
    CGRect newBounds = self.backgroundImageView.frame;
    newBounds.size.height = 46;
    
    if (self.highlightButton.userInteractionEnabled == NO) {
        // fade in when showing info
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        self.backgroundImageView.frame = newBounds;
        [UIView commitAnimations];
    } else {
        self.backgroundImageView.frame = newBounds;        
    }
    
    [self.backgroundImageView setImage:[UIImage imageNamed:@"sound pack cell background.png"]];
    currentStateDetailView = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        if (!currentStateDetailView) {
            [self showData];
            self.highlightButton.userInteractionEnabled = NO;
        }
    }
    else
    {
        [self hideData];
        self.highlightButton.userInteractionEnabled = YES;
    }
}

- (void)dealloc
{
    self.nameLabel = nil;
    self.buyButton = nil;
    [descriptionText release];
    descriptionText = nil;
    self.image = nil;
    self.arrowImage = nil;
    self.highlightButton = nil;
    self.indexPath = nil;
    [purchaseData release];
    purchaseData = nil;
    self.backgroundImageView = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)loadPurchaseData:(NSDictionary *)data font:(UIFont *) font
{
    purchaseData = [data retain];
    buttonClickedOnce = NO;
    currentStateDetailView = NO;

    [self.nameLabel setText:[[purchaseData objectForKey:@"Name"] uppercaseString]];
    [self.nameLabel setFont:font];
    [self.image setImage:[UIImage imageNamed:[purchaseData objectForKey:@"Image"]]];
    [self.buyButton.titleLabel setFont:font];
    [self updateBuyButton];
}

- (IBAction)buyButtonPressed
{
    NSString *purchaseID = [purchaseData objectForKey:@"PurchaseID"];
    
    if (purchaseID != nil && [purchaseID length] != 0 && [MKStoreManager isFeaturePurchased:purchaseID] == NO)
    {
        if (buttonClickedOnce == NO) {
            // first click switches to "buy" option
            buttonClickedOnce = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buyClickedOnce" object:self];
            [self updateBuyButton];
            return;
        } else {
            // purchase package
            [[MKStoreManager sharedManager] buyFeature:purchaseID];
        }
    }
    else
    {
        //already purchased package. open up soundsettings page.
        [self.delegate installedButtonClicked:self.nameLabel.text];
    }
}

- (void)buyClickedOnce:(NSNotification *) notification
{
    if (notification.object != self) {
        buttonClickedOnce = NO;
        [self updateBuyButton];
    }
}

- (IBAction)highlightButtonClick {
    [self.delegate cellHighlightButtonClicked:self.indexPath];
}

@end
