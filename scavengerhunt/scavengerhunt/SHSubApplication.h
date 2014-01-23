//
//  SHAppDelegateAdditions.h
//  ScavengerHunt
//
//  Created by David G. Young on 11/8/13.
//  Copyright (c) 2013 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SHSubApplication : NSObject <CLLocationManagerDelegate, CBPeripheralManagerDelegate>
-(NSString *) checkIncompatibility;
-(void)start: (UINavigationController *) navigationController;
@end
