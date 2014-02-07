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
    SHAppDelegate *appDelegate;
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
    appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Check to see if ProximityKit.plist exists.  If so, we start right up.
    // Otherwise, we ask the user for a code to start
    if ([self plistPath] != Nil) {
        [appDelegate startPK];
        [self showDownloadingImagesView];
    }
    else {
        [self showEnterCodeView];
    }
}

- (void) showDownloadingImagesView {
    self.enterCodeView.hidden = YES;
    self.downloadingImagesView.hidden = NO;
}

- (void) showEnterCodeView {
    self.enterCodeView.hidden = NO;
    self.downloadingImagesView.hidden = YES;
    self.codeSpinner.hidden = YES;
    self.okButton.hidden = NO;
    self.codeTextField.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedAttribution:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://developer.radiusnetworks.com/scavenger_hunt/index.html"]];
}

- (IBAction)codeEditingDidBegin:(id)sender {
    [self animateTextField: self.codeTextField up: YES];
}

- (IBAction)codeEditingDidEnd:(id)sender {
    [self animateTextField: self.codeTextField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)tappedHelp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://developer.radiusnetworks.com/scavenger_hunt/help.html"]];
}

- (NSString *)plistPath {
    NSString *mainPath = [[NSBundle mainBundle] pathForResource:@"ProximityKit" ofType:@"plist"];
    if (mainPath) {
        return mainPath;
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [bundle pathForResource:@"ProximityKit" ofType:@"plist"];
    }
}

- (void) codeValidationFailedWithError: (NSError *) error {
    // Display an error dialog based on the error code
    NSString *title = @"Network error";
    NSString *message = [NSString stringWithFormat:@"Please check your internet connection and try again.  Code: %ld", error.code ];
    if (error.code >= 300 && error.code < 500) {
        title = @"Invalid Code";
        message = @"Please verify your code and try again.";        
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     }];
}

- (void) codeValidated {
    // The delegate will have already started PK when it calls this
    [self showDownloadingImagesView];
}

- (IBAction)okTapped:(id)sender {
    self.okButton.hidden = YES;
    self.codeSpinner.hidden = NO;
    self.codeTextField.enabled = NO;
    
}

@end
