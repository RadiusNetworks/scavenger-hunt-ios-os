//  Copyright (c) 2013 Radius Networks. All rights reserved.

#import <Foundation/Foundation.h>

@interface PKRegion : NSObject {
    @protected
    NSString *_name;
    NSString *_identifier;
    NSDictionary *_attributes;
}

@property (readonly) NSString *name;
@property (readonly) NSString *identifier;
@property (readonly) NSDictionary *attributes;

@end
