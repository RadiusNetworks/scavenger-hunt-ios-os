/*
 * SHViewController.h
 * ScavengerHunt
 *
 * Created by David G. Young on 8/28/13.
 * Copyright (c) 2013,2014 RadiusNetworks. All rights reserved.
 * http://www.radiusnetworks.com
 *
 * @author David G. Young
 *
 * Licensed to the Attribution Assurance License (AAL)
 * (adapted from the original BSD license) See the LICENSE file
 * distributed with this work for additional information
 * regarding copyright ownership.
 *
 */

#import <UIKit/UIKit.h>
#import "SHTargetCollectionViewController.h"
#import "SHSubApplication.h"

@interface SHViewController : UIViewController <UIAlertViewDelegate>
@property SHTargetCollectionViewController *collectionViewController;
@property SHSubApplication *subApplication;
@property (weak, nonatomic) IBOutlet UIView *finishedView;
@property (weak, nonatomic) IBOutlet UIView *redeemView;
@property (weak, nonatomic) IBOutlet UIView *startedView;
@property (weak, nonatomic) IBOutlet UIView *unstartedView;
@property (weak, nonatomic) IBOutlet UIView *startedViewLandscape;
@property (weak, nonatomic) IBOutlet UIView *unstartedViewLandscape;
@property (weak, nonatomic) IBOutlet UILabel *huntProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *redemptionLabel;
- (IBAction)startHunt:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)redeem:(id)sender;
@end
