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
#import "SHTargetCollectionViewController.h"
#import <ProximityKit/ProximityKit.h>
#import <ProximityKit/PKKit.h>
#import <ProximityKit/PKIBeacon.h>
#import <objc/runtime.h>
#import "SHFinishViewController.h"

@implementation SHAppDelegate {
    CBPeripheralManager *_peripheralManager;
    NSDate * _lastNotificationTime;
    BOOL _validatingCode;
    NSDate *_loadingDisplayedTime;
    BOOL _pkStarted;
    BOOL _hitFatalError;
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
    
    BOOL resumed = NO;
    // If the user has already started the hunt, resume from where he left off
    if ([SHHunt sharedHunt].elapsedTime > 0) {
        UINavigationController *navController;
        
        if ([SHHunt sharedHunt].everythingFound) {
            // if it is complete, show the finish view
            SHFinishViewController *finishViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishViewController"];
            navController = [[UINavigationController alloc] initWithRootViewController: finishViewController];
            resumed = YES;
        }
        else {
            // if it is not complete, show the collection view
            PKConfigurationChanger *configChanger = [[PKConfigurationChanger alloc] init];
            if ([configChanger isConfigStored]) {
                [configChanger syncWithStoredConfigForManager:self.manager];
                self.collectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TargetCollectionViewController"];
                navController = [[UINavigationController alloc] initWithRootViewController: self.collectionViewController];
                resumed = YES;
            }
        }
        if (resumed) {
            self.window.rootViewController = navController;
            [self.window makeKeyAndVisible];
        }
        
    }
    
    if (!resumed){
        //show instructions and start button
        [self setupInitialView];
    }
    
    return YES;
}

-(void)setupInitialView {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self.mainViewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
}

-(void)startPK {
    if (_pkStarted) {
        [self.manager sync];
        NSLog(@"calling sync on Proximity Kit.  Waiting for callback from sync");
    }
    else {
        [self.manager start];
        _pkStarted = YES;
        NSLog(@"started Proximity Kit.  Waiting for callback from sync");
    }
}

-(void)startPKWithCode: (NSString * ) code {
    // clear out all remote assets in case the new hunt code has conflicts with them
    [self.remoteAssetCache clear];
    [[SHHunt sharedHunt] reset];
    
    _validatingCode = YES;
    _pkStarted = YES;
    PKConfigurationChanger *configChanger = [[PKConfigurationChanger alloc] init];
    [configChanger syncManager:self.manager withCode: code];
    NSLog(@"started Proximity Kit with code %@.  Waiting for callback from sync", code);
    
}

// called when the user gestures to start over
-(void)resetHunt {
    [[SHHunt sharedHunt] reset];
    [self setupInitialView];
}



// Called after all badge images are either downloaded from the web, or failed to download due to network problems.
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
        _hitFatalError = YES;
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
        // Uncomment the line below to simulate one target at a time being found, a few seconds apart.
        // This is useful for testing in the simulator
        //[self simulateTargetsBeingFound];
        
        NSLog(@"Ready to show collection view controller");
        
        NSDate *now = [NSDate date];
        long timeSince = [now timeIntervalSinceDate:_loadingDisplayedTime];
        long delay = 2000-timeSince;
        if (delay < 0) {
            delay = 0;
        }
        _collectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TargetCollectionViewController"];
        
        [[SHHunt sharedHunt] start];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * delay),dispatch_get_main_queue(), ^{
            [self.mainViewController.navigationController pushViewController:_collectionViewController animated:YES];
            //[self simulateTargetsBeingFound];
        });
        
    }
    
}




// This method gets called when the user taps OK on the warning dialog about the app not being able to start up
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_hitFatalError == YES){
        //close loading screen and start over
        _hitFatalError = NO;
        [self resetHunt];
        
    }else {
        // Tell Proximity Kit to sync data again.  This will start the loading of everything all over again.
        NSLog(@"Kicking off another sync");
        [self.manager sync];
    }
}

// Callback from SHRemoteAssetCache if it gets everything it needs
-(void)remoteAssetLoadSuccess {
    [self dependencyLoadFinished];
}

// Callback from SHRemoteAssetCache if it doesn't get everything it needs
-(void)remoteAssetLoadFail {
    [self dependencyLoadFinished];
}

// determines the variant url of the badge image based on the screen size/density and whether the
// found/not found variant id desired
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
        if (retina) {
            suffix = [NSString stringWithFormat:@"%@_312", suffix];
        }
        else {
            suffix = [NSString stringWithFormat:@"%@_624", suffix];
            
        }
    }
    else {
        if (retina) {
            suffix = [NSString stringWithFormat:@"%@_260", suffix];
        }
    }
    return [NSString stringWithFormat:@"%@%@%@",prefix,suffix,extension];
}
- (void)processKit: (PKKit *) kit {
    if (_validatingCode) {
        _validatingCode = NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [self.mainViewController codeValidated];
             _loadingDisplayedTime = [[NSDate alloc] init];
         }];
    }
    __block int targetCount = 0;
    __block BOOL targetsChanged = false;
    __block BOOL isTablet = ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad);
    __block BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                             ([UIScreen mainScreen].scale == 2.0));
    NSMutableDictionary *targetImageUrls = [[NSMutableDictionary alloc] init];
    
    NSLog(@"Processing kit with %ld iBeacons", (unsigned long)kit.iBeaconRegions.count);
    [kit enumerateIBeaconsUsingBlock:^(PKIBeacon *iBeacon, NSUInteger idx, BOOL *stop) {
        //int idx = 0;
        //for (PKIBeacon *iBeacon in kit.iBeaconRegions) {
        NSString* huntId = [iBeacon.attributes objectForKey:@"hunt_id"];
        NSString* imageUrlString = [iBeacon.attributes objectForKey:@"image_url"];
        


        NSLog(@"Processing first beacon with huntId %@ and imageUrl %@", huntId, imageUrlString);
        if (huntId != Nil) {
            NSLog(@"Hunt id is %@", huntId);
            NSString *existingHuntId = Nil;
            if (idx < [SHHunt sharedHunt].targetList.count ) {
                existingHuntId = [SHHunt sharedHunt].targetList[idx];
            }
            if (![huntId isEqualToString:existingHuntId]) {
                targetsChanged = YES;
            }
            if (imageUrlString == nil) {
                NSLog(@"ERROR: No image_url specified in ProximityKit for item with hunt_id=%@", huntId);
            }
            else {
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
            
            
            
            //custom splash screen and instructions screen metadata
            NSString* instruction_background_color = [iBeacon.attributes objectForKey:@"instruction_background_color"];
            NSString* instruction_image_url = [iBeacon.attributes objectForKey:@"instruction_image_url"];
            NSString* instruction_start_button_name = [iBeacon.attributes objectForKey:@"instruction_start_button_name"];
            NSString* instruction_text_1 = [iBeacon.attributes objectForKey:@"instruction_text_1"];
            NSString* instruction_text_2 = [iBeacon.attributes objectForKey:@"instruction_text_2"];
            NSString* instruction_title = [iBeacon.attributes objectForKey:@"instruction_title"];
            NSString* splash_url = [iBeacon.attributes objectForKey:@"splash_url"];
            NSString* title = [iBeacon.attributes objectForKey:@"title"];
            
            if (instruction_background_color != Nil){
                //save custom splash screen and instructions screen for later use
                
                //saving images
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory

                NSData * instruction_image_url_Data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: instruction_image_url]];
                NSString *instruction_image_filename = [documentsPath stringByAppendingPathComponent:@"instruction_image.png"]; //Add the file name
                [instruction_image_url_Data writeToFile:instruction_image_filename atomically:YES]; //Write the file
                
                NSData * splash_url_Data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: splash_url]];
                NSString *splash_filename = [documentsPath stringByAppendingPathComponent:@"splash.png"]; //Add the file name
                [splash_url_Data writeToFile:splash_filename atomically:YES]; //Write the file
                

                //saving all data (including filenames for saved images)
                NSDictionary* customData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            instruction_background_color, @"instruction_background_color",
                                            instruction_image_url, @"instruction_image_url",
                                            instruction_start_button_name, @"instruction_start_button_name",
                                            instruction_text_1, @"instruction_text_1",
                                            instruction_text_2, @"instruction_text_2",
                                            instruction_title, @"instruction_title",
                                            splash_url, @"splash_url",
                                            title, @"title",
                                            instruction_image_filename, @"instruction_image",
                                            splash_filename, @"splash",
                                            nil];
                [[SHHunt sharedHunt] setCustomStartScreenData: customData];
                
                NSLog(@"customStartScreenData: %@",[[SHHunt sharedHunt] customStartScreenData]);
            }
            
        }
        else {
            NSLog(@"No hunt_id for the item in proximity kit");
        }
        
    }];
    
    
    if ([SHHunt sharedHunt].targetList.count != targetCount) {
        targetsChanged = true;
    }
    
    if (targetsChanged) {
        NSLog(@"The kit says the targets have changed.   New count is %d items from %lu items.  Restarting hunt from scratch.", targetCount, (unsigned long)[SHHunt sharedHunt].targetList.count);
        [[SHHunt sharedHunt]resize:targetCount];
    }
    
    NSLog(@"Target count is %d", targetCount);
    self.remoteAssetCache.retinaFallbackEnabled = YES; // If we can't download the @2x versions, fallback to the non-@2x versions
    [self.remoteAssetCache downloadAssets:targetImageUrls];
    [self.manager startRangingIBeacons];
    
}


- (void)proximityKitDidSync:(PKManager *)manager {
    NSLog(@"proximityKitDidSync");
    PKKit *kit = manager.kit;
    
    if (kit == Nil) {
        [self proximityKit:manager didFailWithError:Nil];
        return;
    }
    else {
        [self processKit: kit];
    }
    
}

- (void)proximityKit:(PKManager *)manager didFailWithError:(NSError *)error
{
    
    NSLog(@"PK didFailWithError: %@", error);
    if (_validatingCode) {
        NSLog(@"Code validation failed");
        _validatingCode = NO;
        [self.mainViewController codeValidationFailedWithError:error];
        return;
    }
    else {
        NSLog(@"Manager kit is %@", self.manager.kit);
        if (self.manager.kit == Nil) {
            [self dependencyLoadFinished];
        }
        else {
            [self processKit: self.manager.kit];
        }
        
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
    NSLog(@"PK didDetermineState %d forRegion %@ (%@)", (int) state, region.name, region.identifier);
    NSLog(@"Did determine State for region: %@ from manager %@ with state %d, where the inside state is %ld", region.identifier, manager, (int)state, (long)CLRegionStateInside);
    
}

// call this method to run a simulation of all targets being found, one every four seconds
-(void)simulateTargetsBeingFound {
    // run the following every 2 seconds;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4.0),dispatch_get_main_queue(), ^{
        __block BOOL anyFound = NO;
        [[SHHunt sharedHunt].targetList enumerateObjectsUsingBlock:^(id targetObj, NSUInteger targetIdx, BOOL *targetStop) {
            SHTargetItem *target = (SHTargetItem *) targetObj;
            if (!target.found && !anyFound) {
                NSLog(@"**** simulating finding target %@", target.huntId);
                target.found = YES;
                anyFound = YES;
                
                [_collectionViewController.collectionView reloadData];
                [_collectionViewController showFoundForTarget: target];
                if ([[SHHunt sharedHunt] everythingFound]) {
                    // switch to the main controller to tell the player he has won
                    if (_collectionViewController) {
                        SHFinishViewController *finishViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishViewController"];
                        NSLog(@"Finish view controller is %@", finishViewController);
                        [_collectionViewController.navigationController
                         pushViewController:finishViewController animated:YES];
                    }
                }
            }
        }];
        if (!([[SHHunt sharedHunt] everythingFound]) ) {
            // set up to call again in a bit
            [self simulateTargetsBeingFound];
        }
    });
    
}

-(void)tellHuntAboutRangedBeacons:(NSArray*) beacons inRegion: (PKRegion*) region {
    
    [beacons enumerateObjectsUsingBlock:^(id beaconObj, NSUInteger beaconIdx, BOOL *beaconStop) {
        
        PKIBeacon *beacon = (PKIBeacon *) beaconObj;
        
        NSLog(@"beacon=%@, beacon.attributes=%@", beacon, beacon.attributes);
        
        NSString *huntId = [beacon.attributes objectForKey:@"hunt_id"]; // set in ProximityKit (e.g. 1, 2, 3, etc.)
        double triggerDistance = [SHHunt sharedHunt].triggerDistance;
        if ([beacon.attributes objectForKey:@"trigger_distance"]) {
            triggerDistance = [[beacon.attributes objectForKey:@"trigger_distance"] doubleValue];
        }
        NSNumber *distanceObj = [NSNumber numberWithDouble: beacon.clBeacon.accuracy];
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
                    justFound = (target.distance < triggerDistance && target.found == NO &&[SHHunt sharedHunt].elapsedTime > 0);
                    if (!justFound) {
                        NSLog(@"not just found %f %f %d %ld", target.distance, [SHHunt sharedHunt].triggerDistance, target.found, [SHHunt sharedHunt].elapsedTime );
                    }
                    
                    
                    if ([_collectionViewController.itemViewController.item.huntId isEqualToString: target.huntId]) {
                        [_collectionViewController.itemViewController showRange];
                    }
                    
                    
                    if (justFound) {
                        
                        [[SHHunt sharedHunt] find:target];
                        NSLog(@"****************** FOUND ONE");
                        
                        if ( _collectionViewController) {
                            NSLog(@"refreshing collection");
                            [_collectionViewController.collectionView reloadData];
                            [_collectionViewController showFoundForTarget: target];
                            NSLog(@"Back from notification");
                        }
                        else {
                            NSLog(@"CAn't refresh colleciton because it is null: %@, ", _collectionViewController);
                        }
                        if ([[SHHunt sharedHunt] everythingFound]) {
                            // switch to the main controller to tell the player he has won
                            if (_collectionViewController) {
                                SHFinishViewController *finishViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishViewController"];
                                NSLog(@"Finish view controller is %@", finishViewController);
                                [_collectionViewController.navigationController
                                 pushViewController:finishViewController animated:YES];
                            }
                        }
                    }
                    else {
                        
                        // send notification to user that a target is nearby, if this target has not already been found and we haven't done so recently
                        NSDate * now = [[NSDate alloc] init];
                        NSTimeInterval secondsSinceLastNotification;
                        NSTimeInterval secondsSinceLastSeen;
                        secondsSinceLastSeen = now.timeIntervalSince1970 - target.lastSeenAt;
                        if (_lastNotificationTime == nil) {
                            secondsSinceLastNotification = 1000000;  // really big number
                        }
                        else {
                            secondsSinceLastNotification = [now timeIntervalSinceDate: _lastNotificationTime];
                        }
                        // only send notifications if the hunt has started and this target is not found
                        if(secondsSinceLastSeen > 300 && target.found == NO &&[SHHunt sharedHunt].elapsedTime > 0) {
                            
                            
                            if (secondsSinceLastNotification < 60 ) {
                                NSLog(@"Not sending notification because we just did %.1f seconds ago.", secondsSinceLastNotification);
                                return;
                            }
                            else {
                                NSLog(@"We just saw a target we have not found yet.  The last notification time was %.1f seconds ago.", secondsSinceLastNotification);
                                
                                NSLog(@"Sending a notification that a beacon is nearby");
                                UILocalNotification *notification = [[UILocalNotification alloc] init];
                                notification.alertBody = [NSString stringWithFormat:@"A scavenger hunt location is nearby."];
                                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                                _lastNotificationTime = now;
                                
                            }
                        }
                        else {
                            NSLog(@"Not sending notification because  target %@ found is %d and was last seen %f seconds ago, elapsed time is %ld and seconds since last notification is %f", target.huntId, target.found,  secondsSinceLastSeen, [SHHunt sharedHunt].elapsedTime, secondsSinceLastNotification);
                        }
                    }
                }
                NSLog(@"Calling sawit on target %@", target.huntId);
                [target sawIt];
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
