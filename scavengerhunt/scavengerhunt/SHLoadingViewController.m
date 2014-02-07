//
//  SHLoadingViewController.m
//  scavengerhunt
//
//  Created by David G. Young on 2/6/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHLoadingViewController.h"
#import "SHAppDelegate.h"

@interface SHLoadingViewController ()

@end

@implementation SHLoadingViewController {
    SHAppDelegate *_appDelegate;
}

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
    NSLog(@"Loading view controller didLoad");
    _appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedAttribution:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://developer.radiusnetworks.com/scavenger_hunt/index.html"]];
}

@end
