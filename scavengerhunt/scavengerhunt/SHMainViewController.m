//
//  SHMainViewController.m
//  scavengerhunt
//
//  Created by David G. Young on 2/12/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHMainViewController.h"
#import "SHAppDelegate.h"
#import "SHHelpViewController.h"

@interface SHMainViewController ()

@end

@implementation SHMainViewController {
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
    self.title = @"Scavenger Hunt";
    self.codeTextField.text = [self getLastValidCode];
    [self showDialog: nil];
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"mainView will appear");
    [super viewWillAppear:animated];
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
    //[self animateTextField: self.codeTextField up: YES];
}

- (IBAction)codeEditingDidEnd:(id)sender {
    //[self animateTextField: self.codeTextField up: NO];
}

- (IBAction)startTapped:(id)sender {
    NSLog(@"Start tapped");
    if ([self pkPlistPath] == Nil) {
        NSLog(@"No proximityKit.plist present.  Asking user for code.");
        [self showDialog: self.codeDialog];
    }
    else {
        NSLog(@"ProximityKit.plist present.  Not asking user for code.");
        [self showDialog: self.loadingDialog];
        [_appDelegate startPK];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.codeDialog.frame = CGRectOffset(self.codeDialog.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)tappedHelp:(id)sender {
    SHHelpViewController *helpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    NSLog(@"Pushing help view controller: %@", helpViewController);
    [self.navigationController pushViewController:helpViewController animated:YES];
}



- (void) codeValidationFailedWithError: (NSError *) error {
    
    // Display an error dialog based on the error code
    NSString *title = @"Network error";
    NSString *message = [NSString stringWithFormat:@"Please check your internet connection and try again.  Code: %ld", (long)error.code ];
    if (error.code >= 300 && error.code <= 500) {
        title = @"Invalid Code";
        message = @"Please verify your code and try again.";
    }
    NSLog(@"**** codeValidationFailedWithError called.  Code: %ld", (long)error.code);

    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self saveValidCode:self.codeTextField.text];
         [self showDialog: self.codeDialog];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     }];
}

- (IBAction)tappedAwayFromCodeInput:(id)sender {
    NSLog(@"Tapped outside of text field");
    [self.codeTextField endEditing:YES];
    [self.codeTextField resignFirstResponder];
    
}

- (void) codeValidated {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         // The delegate will have already started PK when it calls this
         NSLog(@"**** codeValidated called.  showing download images");
         [self saveValidCode:self.codeTextField.text];
         [self showDialog: self.loadingDialog];

     }];
}

- (IBAction)okTapped:(id)sender {
    NSLog(@"OK tapped with code %@", self.codeTextField.text);

    [self.codeTextField endEditing:YES];
    [self showDialog: self.validatingCodeDialog];
    
    NSString *normalizedCode = @"";
    
    // strip all non number characters from code so user can enter "00-00-00-00" or " 00 00 00 00"
    for (int i = 0; i < self.codeTextField.text.length; i++) {
        char c = [self.codeTextField.text characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            normalizedCode = [NSString stringWithFormat:@"%@%c", normalizedCode, c];
        }
    }
    
    [_appDelegate startPKWithCode:normalizedCode];
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

- (void) showDialog: (UIView *)view {
    if (view == Nil) {
        [self.instructionsView setAlpha: 1];
        [self.startButton setEnabled: YES];
    }
    else {
        [self.instructionsView setAlpha: 0.5];
        [self.startButton setEnabled: NO];
    }
    
    [self.validatingCodeDialog setHidden: YES];
    [self.loadingDialog setHidden: YES];
    [self.codeDialog setHidden: YES];
    
    if (view == self.codeDialog) {
        [self.codeTextField setEnabled: YES];
        [self.codeDialog setHidden: NO];
    }
    if (view == self.validatingCodeDialog) {
        [self.validatingCodeDialog setHidden: NO];
    }
    if (view == self.loadingDialog) {
        [self.loadingDialog setHidden: NO];
    }
}

- (NSString *)pkPlistPath {
    NSString *mainPath = [[NSBundle mainBundle] pathForResource:@"ProximityKit" ofType:@"plist"];
    if (mainPath) {
        return mainPath;
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [bundle pathForResource:@"ProximityKit" ofType:@"plist"];
    }
}
@end
