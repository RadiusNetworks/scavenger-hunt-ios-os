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
#import "SHAppDelegate.h"

@interface SHTargetCollectionViewController : UICollectionViewController
-(void)simulateNotification:(NSString *) message;
@property SHTargetItemViewController *itemViewController;
@property SHAppDelegate *appDelegate;
@end
