//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PKRegion.h"

@interface PKIBeacon : PKRegion

@property (readonly) NSUUID *uuid;
@property (readonly) NSInteger major;
@property (readonly) NSInteger minor;
@property (readonly) NSInteger rssi;
@property (readonly) CLBeacon *clBeacon;

- (id)initWith:(NSDictionary *)dict;
- (id)initWithBeacon:(CLBeacon *)beacon attributes:(NSDictionary *) attrs;
@end
