//
//  SHLoadingViewController.h
//  scavengerhunt
//
//  Created by David G. Young on 2/6/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHLoadingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *downloadingImagesView;
- (IBAction)tappedAttribution:(id)sender;
@end
