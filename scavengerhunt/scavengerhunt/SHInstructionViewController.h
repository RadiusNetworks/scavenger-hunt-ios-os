//
//  SHInstructionViewController.h
//  scavengerhunt
//
//  Created by Francis Nguyen on 7/3/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHTargetCollectionViewController.h"

@interface SHInstructionViewController : UIViewController
@property (strong, nonatomic) SHTargetCollectionViewController *collectionViewController;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *_instructionsImage;

@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)startTapped:(id)sender;

@end
