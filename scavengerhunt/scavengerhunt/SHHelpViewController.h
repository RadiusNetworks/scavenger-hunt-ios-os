//
//  SHHelpViewController.h
//  scavengerhunt
//
//  Created by David G. Young on 2/12/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHHelpViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
