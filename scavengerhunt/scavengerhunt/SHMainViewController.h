//
//  SHMainViewController.h
//  scavengerhunt
//
//  Created by David G. Young on 2/12/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIView *codeDialog;
@property (weak, nonatomic) IBOutlet UIView *loadingDialog;
@property (weak, nonatomic) IBOutlet UIView *validatingCodeDialog;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *instructionsView;
- (IBAction)tappedAttribution:(id)sender;
- (IBAction)codeEditingDidBegin:(id)sender;
- (IBAction)codeEditingDidEnd:(id)sender;
- (IBAction)startTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
- (IBAction)tappedHelp:(id)sender;
- (IBAction)okTapped:(id)sender;
- (void)codeValidated;
- (void) codeValidationFailedWithError: (NSError *) error;
@end
