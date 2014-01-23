//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLCircularRegion.h>
#import "PKRegion.h"

@interface PKCircle : PKRegion

@property (readonly) float latitude;
@property (readonly) float longitude;
@property (readonly) float radius;

- (id)initWith:(NSDictionary *)dict;
- (CLRegion *)region;

@end
