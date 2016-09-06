//
//  FlipsideViewController.m
//  Untitled
//
//  Created by Mike Ziuzin on 11/4/09.
//  Copyright OptixSoft 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MKStoreManager.h"
#import "SpaceRadioAppDelegate.h"
#import "SpaceRadioAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "Flurry.h"

@interface FlipsideViewController (priv)
- (void) arrangeScollViewContents;
@end


@implementation FlipsideViewController

@synthesize delegate;
@synthesize scrollBar, topBlackShader, eulaButton, privacyButton, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];

    textView1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 0)];
    textView1.editable = NO;
    textView1.textColor = [UIColor whiteColor];
    textView1.backgroundColor = [UIColor clearColor];
    textView1.font = [UIFont fontWithName:@"Helvetica" size:11];
    textView2 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 0)];
    textView2.editable = NO;
    textView2.textColor = [UIColor whiteColor];
    textView2.backgroundColor = [UIColor clearColor];
    textView2.font = [UIFont fontWithName:@"Helvetica" size:11];
    [textView1 setText:NSLocalizedStringFromTable(@"info_text_part1", @"STComm", nil)];
    [textView2 setText:NSLocalizedStringFromTable(@"info_text_part2", @"STComm", nil)];
    [self.scrollView addSubview:textView1];
    [self.scrollView addSubview:textView2];

    NSString * text1 = textView1.text;
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    textView1.text = [text1 stringByReplacingOccurrencesOfString:@"{$version}" withString:appVersion];

    [self arrangeScollViewContents];
    self.scrollView.delegate = self;
    self.scrollBar.scrollView = self.scrollView;

    self.topBlackShader.alpha = 0.3;
    
	self.navigationController.navigationBarHidden = YES;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Flurry endTimedEvent:@"Info Screen" withParameters:nil];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"Info Screen" timed:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    textView1.layer.shadowColor = [[UIColor blackColor] CGColor];
    textView1.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    textView1.layer.shadowOpacity = 1.0f;
    textView1.layer.shadowRadius = 0.0f;
    textView2.layer.shadowColor = [[UIColor blackColor] CGColor];
    textView2.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    textView2.layer.shadowOpacity = 1.0f;
    textView2.layer.shadowRadius = 0.0f;
    
    UIColor * color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [self.eulaButton setBackgroundImage:[self imageWithColor:color] forState:UIControlStateHighlighted];
    [self.privacyButton setBackgroundImage:[self imageWithColor:color] forState:UIControlStateHighlighted];
    
    [self.scrollBar refreshHandlePosition];
}

- (IBAction)restorePurchaseButtonPressed
{
    //get previous transactions
    [[MKStoreManager sharedManager] restorePreviousTransactions];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
    
    self.scrollBar = nil;
    [textView1 release];
    textView1 = nil;
    [textView2 release];
    textView2 = nil;
    self.eulaButton = nil;
    self.privacyButton = nil;
    self.scrollView = nil;
}


- (void)dealloc {
    self.scrollBar = nil;
    [textView1 release];
    textView1 = nil;
    [textView2 release];
    textView2 = nil;
    self.eulaButton = nil;
    self.privacyButton = nil;
    self.scrollView = nil;
    [super dealloc];
}

- (void)arrangeScollViewContents
{
    // resize and position scroll view contents to arrange themselves vertically
    CGRect frame = textView1.frame;
    frame.size.height = textView1.contentSize.height;
    textView1.frame = frame;
    
    frame = self.eulaButton.frame;
    frame.origin.y = textView1.frame.size.height;
    frame.size.width = self.eulaButton.titleLabel.frame.size.width;
    frame.size.height = self.eulaButton.titleLabel.frame.size.height;
    self.eulaButton.frame = frame;
    
    frame = self.privacyButton.frame;
    frame.origin.y = self.eulaButton.frame.origin.y + self.eulaButton.frame.size.height + 3;
    frame.size.width = self.privacyButton.titleLabel.frame.size.width;  
    frame.size.height = self.privacyButton.titleLabel.frame.size.height;        
    self.privacyButton.frame = frame;
    
    frame = textView2.frame;
    frame.origin.y = self.privacyButton.frame.origin.y + self.privacyButton.frame.size.height + 3;
    frame.size.height = textView2.contentSize.height;
    textView2.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(frame.size.width, frame.origin.y + frame.size.height);
}

#pragma mark - button handlers

- (IBAction)onEulaClicked:(id)sender
{
    WebViewController * webViewController = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
    webViewController.title = @"E.U.L.A.";
    webViewController.url = [NSURL URLWithString:@"http://cbsitou.custhelp.com/app/answers/detail/a_id/1320"];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:webViewController animated:NO];
    [UIView commitAnimations];
}

- (IBAction)onPrivacyPolicyClicked:(id)sender
{
    WebViewController * webViewController = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
    webViewController.title = @"Privacy Policy";
    webViewController.url = [NSURL URLWithString:@"http://cbsiprivacy.custhelp.com/app/answers/detail/a_id/1265"];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:webViewController animated:NO];
    [UIView commitAnimations];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (sView.contentOffset.y > 0) {
        [UIView beginAnimations:nil context:NULL]; 
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        self.topBlackShader.alpha = 1.0;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:NULL]; 
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        self.topBlackShader.alpha = 0.3;
        [UIView commitAnimations];
    }
    
    [self.scrollBar refreshHandlePosition];
}

#pragma mark - navigation button methods

- (IBAction)mainScreenButtonPressed
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToMainView:kCATransitionFromLeft];
}

-(IBAction) soundButtonPressed
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToSettingsView:kCATransitionFromLeft];
}

-(IBAction) phoneButtonPressed
{
    [((SpaceRadioAppDelegate *)[UIApplication sharedApplication].delegate) goToPhoneView:kCATransitionFromLeft];
}

@end
