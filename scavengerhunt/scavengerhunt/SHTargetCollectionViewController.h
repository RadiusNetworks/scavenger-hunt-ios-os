/*
 * SHTargetCollectionViewController.h
 * ScavengerHunt
 *
 * Created by David G. Young on 9/4/13.
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
#import "SHTargetItemViewController.h"

@interface SHTargetCollectionViewController : UICollectionViewController
-(void)simulateNotification:(NSString *) message;
- (IBAction)tappedStartOver:(id)sender;
-(void) showFoundForTarget: (SHTargetItem *) target;
@property (weak, nonatomic) IBOutlet UIView *foundTargetDialog;
@property (weak, nonatomic) IBOutlet UIImageView *foundTargetImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startOverButton;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property SHTargetItemViewController *itemViewController;
@end
