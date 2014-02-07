//
//  SHCodeViewController.h
//  scavengerhunt
//
//  Created by David G. Young on 2/7/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHCodeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *enterCodeView;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
- (IBAction)tappedAttribution:(id)sender;
- (IBAction)codeEditingDidBegin:(id)sender;
- (IBAction)codeEditingDidEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
- (IBAction)tappedHelp:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *codeSpinner;
- (IBAction)okTapped:(id)sender;
- (void)codeValidated;
- (void) codeValidationFailedWithError: (NSError *) error;

@end
