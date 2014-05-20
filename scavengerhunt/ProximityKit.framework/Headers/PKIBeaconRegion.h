//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PKRegion.h"

@interface PKIBeaconRegion : PKRegion

@property (readonly) NSUUID *uuid;
@property (readonly) NSInteger major;
@property (readonly) NSInteger minor;

- (id)initWith:(NSDictionary *)dict;
- (CLBeaconRegion *)region;

@end
