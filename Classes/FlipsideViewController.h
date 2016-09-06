//
//  FlipsideViewController.h
//  Untitled
//
//  Created by Mike Ziuzin on 11/4/09.
//  Copyright OptixSoft 2009. All rights reserved.
//

#import "CustomScrollBar.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController<UIScrollViewDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
    UITextView * textView1;
    UITextView * textView2;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet CustomScrollBar *scrollBar;
@property(nonatomic, retain) IBOutlet UIImageView *topBlackShader;
@property(nonatomic, retain) IBOutlet UIButton * eulaButton;
@property(nonatomic, retain) IBOutlet UIButton * privacyButton;
@property(nonatomic, retain) IBOutlet UIScrollView * scrollView;

-(IBAction) mainScreenButtonPressed;
-(IBAction) restorePurchaseButtonPressed;
-(IBAction) soundButtonPressed;
-(IBAction) phoneButtonPressed;
-(IBAction) onEulaClicked:(id)sender;
-(IBAction) onPrivacyPolicyClicked:(id)sender;

@end

