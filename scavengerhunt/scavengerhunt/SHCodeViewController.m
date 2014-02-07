//
//  SHCodeViewController.m
//  scavengerhunt
//
//  Created by David G. Young on 2/7/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHCodeViewController.h"
#import "SHAppDelegate.h"

@interface SHCodeViewController ()

@end

@implementation SHCodeViewController {
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
    _appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"code view is: %@", self.enterCodeView);
    
    self.codeTextField.text = [self getLastValidCode];
    [self.codeSpinner setHidden: YES];
    [self.okButton setHidden: NO];
    [self.codeTextField setEnabled: YES];
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"codeView will appear");
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"codeView didReceiveMemoryWarning");
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
    const int movementDistance = 160;
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



- (void) codeValidationFailedWithError: (NSError *) error {
    // Display an error dialog based on the error code
    NSString *title = @"Network error";
    NSString *message = [NSString stringWithFormat:@"Please check your internet connection and try again.  Code: %d", error.code ];
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
    NSLog(@"**** codeValidated called.  showing download images");
    [self saveValidCode:self.codeTextField.text];
    
    [self.navigationController pushViewController:_appDelegate.loadingViewController animated:YES];
}

- (IBAction)okTapped:(id)sender {
    
    self.okButton.hidden = YES;
    self.codeSpinner.hidden = NO;
    self.codeTextField.enabled = NO;
    NSLog(@"ok tapped code view is: %@", self.enterCodeView);
    
    [_appDelegate startPKWithCode:self.codeTextField.text];
}

- (void) saveValidCode: (NSString *) code {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:code forKey:@"sh_code"];
    [userDefaults synchronize];
}

- (NSString *) getLastValidCode {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString * code = [currentDefaults stringForKey:@"sh_code"];
    if (code == Nil) {
        code = @"";
    }
    return code;
}
@end
