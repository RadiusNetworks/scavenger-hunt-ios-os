//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PKManagerDelegate.h"
#import "PKRegion.h"
#import "PKKit.h"

/*
 * Type PKFetchCompletionHandler
 *
 * Same signature as UIKit's performFetchWithCompletionHandler's block
 */
typedef void(^PKFetchCompletionHandler)(UIBackgroundFetchResult);


/*
 *  Class PKManager
 *
 *  Discussion:
 *      This is the main class for used for interacting with the Proximity
 *      Kit SDK.
 *
 *  More information can be found at http://proximitykit.com
 *
 */
@interface PKManager : NSObject <CLLocationManagerDelegate>

/*
 *  getVersion
 *
 *  Discussion:
 *      Get the version string for the Proximity Kit Framework
 *
 */
+ (NSString *)getVersion;

/*
 *  managerWithDelegate
 *
 *  Discussion:
 *      Creates the manager, assignes the delegate.
 *
 */
+ (PKManager *)managerWithDelegate:(id <PKManagerDelegate>)delegate;

/*
 *  start
 *
 *  Discussion:
 *      Sets up the manager and syncs data with the server.
 *
 */
- (void)start;

/*
 *  sync
 *
 *  Discussion:
 *      Force a sync with the server. This is not normally required.
 *
 */
- (void)sync;

/*
 *  syncWithCompletionHandler
 *
 *  Discussion:
 *      Same as `-sync`, but accepts a block for the sync callbacks. This is
 *      particularly useful for updating the ProximityKit data when the
 *      application in in the background.
 *
 *      To take advantage of this you need to implement
 *      `application:performFetchWithCompletionHandler:` on your in your
 *      application delegate. Then Within that method you can simply call
 *      `syncWithCompletionHandler` and pass it the compleation block:
 *
 *       - (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 *       {
 *           // ...
 *           [pkManager syncWithCompletionHandler: completionHandler];
 *       }
 *
 *     Be sure to set the fetch interval in your didFinishLaunching method:
 *
 *       - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 *       {
 *           // ...
 *           [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
 *           return YES;
 *       }
 *
 *    Finally make sure you add `UIBackgroundModes` to your info plist with a string set to 'fetch'
 *
 *
 */
- (void)syncWithCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler;

/*
 *  delegate
 *
 *  Discussion:
 *      Primary delegate for the PKManager.
 */
@property (assign) id <PKManagerDelegate> delegate;

/*
 *  locationManager
 *
 *  Discussion:
 *      The instance of CLLocation manager that PKManager wraps and maintains.
 *
 */
@property (readonly) CLLocationManager *locationManager;

/*
 *  locationManagerDelegate
 *
 *  Discussion:
 *      Proxy for all of the CLLocationManager delgate methods. All of the
 *      non-deprecated methods from CLLocationManagerDelegate will be called
 *      on this object.
 *
 *      This is useful for accessing the underlying core location functionality
 *      while using the same locationManager instance that Proximity Kit wraps
 *      and maintains.
 *
 */
@property (assign) id <CLLocationManagerDelegate> locationManagerDelegate;

/*
 *  kit
 *
 *  Discussion:
 *      The representation of the Kit as defined in the Proximity Kit service.
 *      This contains lists of iBeacons and Geofences.
 *
 */
@property (readonly) PKKit *kit;

/*
 * getRegionForIdentifier
 *
 *  Discussion:
 *      Lookup the PKRegion for a given identifier.
 *
 *      Returns nil if no region found.
 *
 */
- (PKRegion *)getRegionForIdentifier:(NSString *)identifier;

/*
 * startRangingIBeacons
 *
 *  Discussion:
 *      Start calculating ranges for iBeacons.
 *
 */
- (void)startRangingIBeacons;

/*
 * stopRangingIBeacons
 *
 *  Discussion:
 *      Stop calculating ranges for iBeacons.
 *
 */
- (void)stopRangingIBeacons;

@end
