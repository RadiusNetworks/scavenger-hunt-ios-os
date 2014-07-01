//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>

@interface PKMap : NSObject {
    NSMutableArray *_overlays;
}

- (NSArray *)overlays;
- (id)initWith:(NSDictionary *)dict;

@end
