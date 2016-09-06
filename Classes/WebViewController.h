//
//  WebViewController.h
//  SpaceRadio
//
//  Created by Ashutosh on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSURL * url;
@property (nonatomic, retain) IBOutlet UIWebView * webView;

@end
