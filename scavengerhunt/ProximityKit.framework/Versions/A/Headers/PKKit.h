//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>
#import "PKMap.h"
#import "PKRegion.h"

@interface PKKit : NSObject

@property NSString *url;
@property NSInteger id;
@property NSString *name;
@property NSArray *iBeacons;
@property PKMap *map;

- (id)initWith:(NSDictionary *)dict;
- (PKRegion *)getRegionForIdentifier:(NSString *)identifier;

@end
