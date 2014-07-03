/*
 * SHAppDelegate.h
 * scavengerhunt
 *
 * Created by David G. Young on 1/17/14.
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
#import <ProximityKit/ProximityKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SHRemoteAssetCache.h"
#import "SHMainViewController.h"
#import "SHTargetCollectionViewController.h"
#import "SHInstructionViewController.h"

@interface SHAppDelegate : UIResponder <UIApplicationDelegate, PKManagerDelegate, CBPeripheralManagerDelegate, SHRemoteAssetCacheDelegate>
-(void)startPK;
-(void)startPKWithCode: (NSString * ) code;
-(void)resetHunt;
-(void)startTargetCollection;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PKManager *manager;
@property (strong, nonatomic) SHRemoteAssetCache *remoteAssetCache;
@property (strong, nonatomic) UIStoryboard *storyboard;
@property (strong, nonatomic) SHMainViewController *mainViewController;
@property (strong, nonatomic) SHTargetCollectionViewController *collectionViewController;
@property (strong, nonatomic) SHInstructionViewController *instructionViewController;
@end
