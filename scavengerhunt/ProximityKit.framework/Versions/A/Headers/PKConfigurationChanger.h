//
//  PKConfigurationChanger.h
//  ProximityKit
//
//  Created by David G. Young on 2/6/14.
//  Copyright (c) 2014 Radius Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKManager.h"

@interface PKConfigurationChanger : NSObject
-(void)syncManager: (PKManager *) manager withCode: (NSString * )code;
@end
