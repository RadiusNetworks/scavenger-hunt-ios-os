//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import "PKMap.h"
#import "PKRegion.h"
#import "PKIBeacon.h"

@interface PKKit : NSObject

@property NSString *url;
@property NSInteger id;
@property NSString *name;
@property NSArray *iBeaconRegions;
@property PKMap *map;
@property NSDictionary *json;

- (id)initWith:(NSDictionary *)dict;
- (PKRegion *)getRegionForIdentifier:(NSString *)identifier;
- (PKIBeacon *)getIBeaconForCLBeacon: (CLBeacon *)clBeacon;
- (void)enumerateIBeaconsUsingBlock:(void (^)(PKIBeacon *iBeacon, NSUInteger idx, BOOL *stop))block;



@end
