/*
 * SHAppDelegate.m
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
#import "SHAppDelegate.h"
#import "SHHunt.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SHStartedViewController.h"
#import <ProximityKit/ProximityKit.h>
#import <ProximityKit/PKKit.h>
#import <ProximityKit/PKIBeacon.h>
//#import <ProximityKit/PKConfigurationChanger.h>
#import <objc/runtime.h>

/*
 
 TODO:
 1. Test on iPad
 2. Test on Retina and non-Retina
 3. Update license
 */


@implementation SHAppDelegate {
    CBPeripheralManager *_peripheralManager;
    SHViewController *_mainViewController;
    NSDate * _lastEntryTime;
    NSDate * _lastExitTime;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize a Bluetooth Peripheral Manager so we can warn user about various states of availability or bluetooth being turned off
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    // Set distance for detecting targets, in this case 10 meters
    [[SHHunt sharedHunt] setTriggerDistance: 10.0];

    // Pick the right storyboard for either iPad or iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        self.storyboard = [UIStoryboard storyboardWithName:@"ScavengerHunt_iPad" bundle:nil];
    } else {
        self.storyboard = [UIStoryboard storyboardWithName:@"ScavengerHunt_iPhone" bundle:nil];
    }

    // Initialize the remote asset cache, used for downloading the badge images from a web server
    self.remoteAssetCache = [[SHRemoteAssetCache alloc] init];
    self.remoteAssetCache.delegate = self;

    // Initialize ProximityKit
    self.manager = [PKManager managerWithDelegate:self];
    
    // Show loading screen
    UIViewController *loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
    self.window.rootViewController = loadingViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


    
    // After startup, the loading screen will be displayed until the Proximity Kit proximityKitDidSync callback is received, which will kick off downloading badge images
    // Once everything is loaded, the dependenciesFullyLoaded method below is called, which will trigger displaying the opening screen.
    
    return YES;
}

-(void)startPK {
    [self.manager start];
    NSLog(@"started Proximity Kit.  Waiting for callback from sync");
}

-(void)startPKWithCode: (NSString * ) code {
    //PKConfigurationChanger *configChanger = [[PKConfigurationChanger alloc] init];
    //[configChanger syncManager:self.manager withCode: code];
    NSLog(@"started Proximity Kit with code %@.  Waiting for callback from sync", code);
}



/*
 
 Called after all badge images are either downloaded from the web, or failed to download due to network problems.

 */
-(void)dependencyLoadFinished {

    NSString *fatalError = Nil;
    
    if (![self validateRequiredImagesPresent]) {
        fatalError = @"Cannot download image files. Please verify your network connection and tap OK to try again.";
    }
    else if ([SHHunt sharedHunt].targetList.count == 0) {
        fatalError = @"Cannot download target list.  Please verify your network connection and tap OK to try again.";
    }
    
    
    if (fatalError != Nil) {
        NSLog(@"Cannot start up because I could not download the necessary badge images.  Telling user to try again later.");

            // wait for one sec in the future to do this.  if we don't wait, then the dialog may come up
            // to quickly, and then the build-in iOS permission dialog might appear and suppress this dialog
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                                message:fatalError
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:Nil];
                [alert show];

            });
        
    }
    else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             _mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: _mainViewController];
             
             [self.window.rootViewController presentViewController: navController
                                                          animated:YES completion: Nil ];
         }];
    }
    
}


/*
 This method gets called when the user taps OK on the warning dialog about the app not being able to
 start up*/
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Tell Proximity Kit to sync data again.  This will start the loading of everything all over again.
    NSLog(@"Kicking off another sync");
    [self.manager sync];
}

// Callback from SHRemoteAssetCache if it gets everything it needs
-(void)remoteAssetLoadSuccess {
    [self dependencyLoadFinished];
}

// Callback from SHRemoteAssetCache if it gets everything it needs
-(void)remoteAssetLoadFail {
    [self dependencyLoadFinished];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 Downloads all assets and saves them locally in the Documents directory by the normalized asset filename
 // target1.png
 // target1~ipad.png
 // target1@2x.png
 // target1@2x~ipad.png
 // target1_found.png
 // target1_found~ipad.png
 // target1_found@2x.png
 // target1_found@2x~ipad.png
 */
- (NSString *)variantTargetImageUrlForBaseUrlString: (NSString *) baseUrlString found:(BOOL)found tablet:(BOOL)tablet retina:(BOOL)retina {
    unsigned long extensionIndex = [baseUrlString rangeOfString:@"." options:NSBackwardsSearch].location;
    if (extensionIndex == NSNotFound) {
        return Nil;
    }
    NSLog(@"Extension Index of %@ is %ld", baseUrlString, extensionIndex);
    
    NSString *extension = [baseUrlString substringFromIndex:extensionIndex];
    NSString *prefix = [baseUrlString substringToIndex:extensionIndex];
    NSString *suffix;
    if (found) {
        suffix = @"_found";
    }
    else {
        suffix = @"";
    }
    if (tablet) {
        suffix = [NSString stringWithFormat:@"%@~ipad", suffix];
    }
    if (retina) {
        suffix = [NSString stringWithFormat:@"%@@2x", suffix];
    }
    return [NSString stringWithFormat:@"%@%@%@",prefix,suffix,extension];
}

- (void)proximityKitDidSync:(PKManager *)manager {
    NSLog(@"proximityKitDidSync");
    PKKit *kit = manager.kit;
    if (kit == Nil) {
        //TODO: figure out if this should be nil
        NSLog(@"Proximity Kit is nil after sync.  We may be offline.");
        NSLog(@"Manager kit is %@", self.manager.kit);
        [self dependencyLoadFinished];
    }
    else {
        int targetCount = 0;
        NSMutableDictionary *targetImageUrls = [[NSMutableDictionary alloc] init];
        for (PKRegion *region in kit.iBeacons) {
            NSString* huntId = [region.attributes objectForKey:@"hunt_id"];
            NSString* imageUrlString = [region.attributes objectForKey:@"image_url"];
            
            if (huntId != Nil) {
                if (imageUrlString == nil) {
                    NSLog(@"ERROR: No image_url specified in ProximityKit for item with hunt_id=%@", huntId);
                }
                else {
                    BOOL isTablet = ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad);
                    BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                                     ([UIScreen mainScreen].scale == 2.0));
                    
                    NSURL *notFoundUrl = [[NSURL alloc] initWithString:[self variantTargetImageUrlForBaseUrlString:imageUrlString found:false tablet:isTablet retina:isRetina]];
                    NSURL *foundUrl = [[NSURL alloc] initWithString:[self variantTargetImageUrlForBaseUrlString:imageUrlString found:true tablet:isTablet retina:isRetina]];
                    if (notFoundUrl != Nil) {
                        [targetImageUrls setObject:foundUrl forKey: [NSString stringWithFormat:@"target%@_found", huntId]];
                    }
                    else {
                        NSLog(@"Error: cannot convert target image url %@ to a not found variant for this platform.  Does the file at the end of the URL contain an extension?", imageUrlString);
                    }
                    if (foundUrl != Nil) {
                        [targetImageUrls setObject:notFoundUrl forKey: [NSString stringWithFormat:@"target%@", huntId]];
                    }
                    else {
                        NSLog(@"Error: cannot convert target image url %@ to a found variant for this platform.  Does the file at the end of the URL contain an extension?", imageUrlString);
                    }
                }
                targetCount++;
            }
        }
        
        if ([SHHunt sharedHunt].targetList.count != targetCount) {
            NSLog(@"The kit says the target count has changed to %d items from %lu items.  Restarting hunt from scratch.", targetCount, (unsigned long)[SHHunt sharedHunt].targetList.count);
            [[SHHunt sharedHunt]resize:targetCount];
        }
        NSLog(@"Target count is %d", targetCount);
        self.remoteAssetCache.retinaFallbackEnabled = YES; // If we can't download the @2x versions, fallback to the non-@2x versions
        [self.remoteAssetCache downloadAssets:targetImageUrls];
        [self.manager startRangingIBeacons];
    }

}

/*
 Validates that there is a target image downloaded for both the found and not found target state for this platform (tablet/phone, pixeel density)
 */
- (BOOL)validateRequiredImagesPresent {
    BOOL missing = NO;
    unsigned long targetCount = [SHHunt sharedHunt].targetList.count;
    for (int i = 0; i < targetCount; i++) {
        if ([self.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d_found", i+1]] == Nil) {
            NSLog(@"Error: required image target%d_found has not been downloaded", i+1);
            missing = YES;
        }
        if ([self.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d", i+1]] == Nil) {
            NSLog(@"Error: required image target%d  has not been downloaded", i+1);
            missing = YES;
        }
    }
    
    return !missing;
}

- (void)proximityKit:(PKManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"PK didFailWithError: %@", error.description);
}


- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion*)region {
    NSLog(@"PK didEnter Region %@ (%@)", region.name, region.identifier);
}

- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region {
    NSLog(@"PK didExit Region %@ (%@)", region.name, region.identifier);
}

- (void)proximityKit:(PKManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(PKRegion *)region
{
    NSLog(@"PK didRangeBeacons in Region %@ (%@)", region.name, region.identifier);
    [self tellHuntAboutRangedBeacons: beacons inRegion: region];
}

- (void)proximityKit:(PKManager *)manager didDetermineState:(PKRegionState)state forRegion:(PKRegion *)region
{
    NSLog(@"PK didDetermineState %ld forRegion %@ (%@)", state, region.name, region.identifier);
    NSLog(@"Did determine State for region: %@ from manager %@ with state %ld, where the inside state is %ld", region.identifier, manager, state, (long)CLRegionStateInside);
    [self tellHuntAboutMonitoredBeacons: state];
}

-(void)tellHuntAboutMonitoredBeacons:(int)state {
    
    NSDate * now = [[NSDate alloc] init];
    if(state == CLRegionStateInside) {
        NSTimeInterval secondsSinceLastNotification = [now timeIntervalSinceDate: _lastEntryTime];
        NSTimeInterval secondsSinceLastExit = [now timeIntervalSinceDate: _lastExitTime];
        
        if (_lastExitTime != nil && secondsSinceLastExit < 60) {
            NSLog(@"Ignoring entry into this region because we just exited %.1f seconds ago.", secondsSinceLastExit);
            return;
        }
        else if (_lastEntryTime != nil && secondsSinceLastNotification < 60 ) {
            NSLog(@"Ignoring entry into this region because we just entered %.1f seconds ago.", secondsSinceLastNotification);
            return;
        }
        else {
            NSLog(@"We just saw a target.  The last notification time was %.1f seconds ago.", secondsSinceLastNotification);
            
            NSLog(@"Sending a notification that a beacon is nearby");
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = [NSString stringWithFormat:@"A scavenger hunt location is nearby."];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            _lastEntryTime = now;
            
        }
    }
    else if (state == CLRegionStateOutside) {
        _lastExitTime = now;
    }
    
}

-(void)tellHuntAboutRangedBeacons:(NSArray*) beacons inRegion: (PKRegion*) region {
    
    [beacons enumerateObjectsUsingBlock:^(id beaconObj, NSUInteger beaconIdx, BOOL *beaconStop) {
        
        NSString *huntId = [region.attributes objectForKey:@"hunt_id"]; // set in ProximityKit (e.g. 1, 2, 3, etc.)
        NSNumber *distanceObj = [beaconObj valueForKey:@"accuracy"];
        NSLog(@"processing beacon with targetId: %@ and distance %@", huntId, distanceObj);
        float distance = [distanceObj floatValue];
        
        [[SHHunt sharedHunt].targetList enumerateObjectsUsingBlock:^(id targetObj, NSUInteger targetIdx, BOOL *targetStop) {
            SHTargetItem *target = (SHTargetItem *)targetObj;
            if ([huntId isEqualToString:target.huntId]) {
                BOOL justFound = NO;
                target.distance = distance;
                if (target.distance < 0) {
                    NSLog(@"range unknown");
                }
                else {
                    justFound = (target.distance < [SHHunt sharedHunt].triggerDistance && target.found == NO &&[SHHunt sharedHunt].elapsedTime > 0);
                    
                    [target sawIt];
                    
                    if ([_mainViewController.collectionViewController.itemViewController.item.huntId isEqualToString: target.huntId]) {
                        [_mainViewController.collectionViewController.itemViewController showRange];
                    }
                    
                    if (justFound) {
                        
                        [[SHHunt sharedHunt] find:target];
                        NSLog(@"****************** FOUND ONE");
                        
                        if (_mainViewController && _mainViewController.collectionViewController) {
                            NSLog(@"refreshing collection");
                            [_mainViewController.collectionViewController.collectionView reloadData];
                            [_mainViewController.collectionViewController simulateNotification: [NSString stringWithFormat:@"You've received badge %d of %lu", [[SHHunt sharedHunt] foundCount], (unsigned long)[[SHHunt sharedHunt] targetList].count]];
                            NSLog(@"Back from notification");
                        }
                        else {
                            NSLog(@"CAn't refresh colleciton because it is null: %@, %@", _mainViewController, _mainViewController.collectionViewController);
                        }
                        if ([[SHHunt sharedHunt] everythingFound]) {
                            // switch to the main controller to tell the player he has won
                            if (_mainViewController && _mainViewController.collectionViewController) {
                                [_mainViewController.collectionViewController.navigationController
                                 popToViewController:_mainViewController animated:YES];
                            }
                        }
                        
                        
                        
                        
                    }
                }
                
            }
            else {
                NSLog(@"no match to hunt target %@",target.huntId);
            }
        }];
    }];
    
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"peripheralManagerDidUpdateState called with %@",peripheral);
    _peripheralManager = peripheral;
    [self complainIfBluetoothNotAvailable];
}

- (Boolean)complainIfBluetoothNotAvailable {
    if (_peripheralManager != nil) {
        if(_peripheralManager.state==CBCentralManagerStatePoweredOn)
        {
            NSLog(@"Core Bluetooth is on.");
            return NO;
        }
        else if(_peripheralManager.state==CBCentralManagerStatePoweredOff) {
            NSLog(@"bluetooth is off");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth is Off"
                                                                 message:@"Please enable bluetooth to play the Scavenger Hunt"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }];
            return YES;
        }
        else if(_peripheralManager.state==CBCentralManagerStateUnsupported) {
            NSLog(@"bluetooth is unsupported");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth LE Not Available"
                                                                 message:@"Sorry, Bluetooth LE is not Available on this device"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }];
            
            return YES;
        }
        else if(_peripheralManager.state==CBCentralManagerStateUnauthorized) {
            NSLog(@"bluetooth is unauthorized");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Not Authorized"
                                                                 message:@"Sorry, you cannot use Bluetooth LE on this device"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }];
            
            return YES;
        }
        else if(_peripheralManager.state==CBCentralManagerStateUnknown) {
            NSLog(@"Known Unknown bluetooth state");
            //This indicates it is still powering on...
        }
        else {
            NSLog(@"Unknown Unknown bluetooth state");
            return YES;
        }
    }
    else {
        NSLog(@"peripheral manager is nil");
    }
    return YES;
}


@end
