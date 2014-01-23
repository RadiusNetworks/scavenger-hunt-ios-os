//
//  PKLocationManagerDelegate.h
//  ProximityKit
//
//  Created by Christopher Sexton on 9/23/13.
//  Copyright (c) 2013 Radius Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, PKRegionType) {
    PKCircleType,
    PKIBeaconType,
};

typedef NS_ENUM(NSInteger, PKRegionState) {
    PKRegionStateUnknown,
    PKRegionStateInside,
    PKRegionStateOutside
};

@class PKManager;
@class PKRegion;

/*
 *  Protocol PKManagerDelegate
 */
@protocol PKManagerDelegate <NSObject>
@required
@optional

/*
 *  proximityKitDidSync
 *
 *  Discussion:
 *    Invoked when kit has synced with the server and data is loaded and avaliable.
 *
 */
- (void)proximityKitDidSync:(PKManager *)manager;

/*
 *  proximityKit:didEnter:
 *
 *  Discussion:
 *    Invoked when new entering new region. Regions can be Geofence or iBeacons.
 *
 */
- (void)proximityKit:(PKManager *)manager
            didEnter:(PKRegion *)region;

/*
 *  proximityKit:didEnter:
 *
 *  Discussion:
 *    Invoked when new entering new region. Regions can be Geofence or iBeacons.
 *
 */
- (void)proximityKit:(PKManager *)manager
             didExit:(PKRegion *)region;

/*
 *  proximityKit:didDetermineState:forRegion:
 *
 *  Discussion:
 *    Invoked when new changing state for a region.
 *
 */
- (void) proximityKit:(PKManager *)manager
    didDetermineState:(PKRegionState)state
            forRegion:(PKRegion *)region;

/*
 *  proximityKit:didRangeBeacons:inRegion
 *
 *  Discussion:
 *    Invoked when a new set of beacons are available in the specified region.
 *
 *    Beacons is an array of CLBeacon objects.
 *
 *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
 *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
 *    by the device.
 *
 */
- (void)proximityKit:(PKManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(PKRegion *)region;

/*
 *  proximityKit:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred.
 */
- (void)proximityKit:(PKManager *)manager
    didFailWithError:(NSError *)error;
@end
