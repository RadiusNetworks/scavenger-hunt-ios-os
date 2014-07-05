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
#import "SHTargetItem.h"

@interface SHTargetItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *distanceProgress;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (readonly) SHTargetItem *item;
-(void) showItem:(SHTargetItem *) item;
-(void) showRange;

@end
