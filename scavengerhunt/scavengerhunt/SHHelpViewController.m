//
//  SHHelpViewController.m
//  scavengerhunt
//
//  Created by David G. Young on 2/12/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHHelpViewController.h"

@interface SHHelpViewController ()

@end

@implementation SHHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Scavenger Hunt Help";
    NSString *fullURL = @"http://developer.radiusnetworks.com/scavenger_hunt/help.html";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.spinner startAnimating];
    [self.spinner setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
