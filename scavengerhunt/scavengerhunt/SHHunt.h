/*
 * SHHunt.h
 * ScavengerHunt
 * Created by David G. Young on 8/29/13.
 * Copyright (c) 2013,2014 RadiusNetworks. All rights reserved.
 * http://www.radiusnetworks.com
 *
 * @author David G. Young
 *
 * Licensed to the Attribution Assurance License (AAL)
 * (adapted from the original BSD license) See the LICENSE file
 * distributed with this work for additional information
 * regarding copyright ownership.
 *
 */

#import <Foundation/Foundation.h>
#import "SHTargetItem.h"

@interface SHHunt : NSObject <NSURLConnectionDelegate>
+ (SHHunt *)sharedHunt;
-(void)setTriggerDistance:(double)triggerDistance;
-(void) reset;
-(void) start;
-(long) elapsedTime;
-(int) foundCount;
-(BOOL) everythingFound;
-(double) triggerDistance;
-(void) find: (SHTargetItem *) target;
-(void)resize: (int) size;

@property (strong, nonatomic) NSArray *targetList;
@property (strong, nonatomic) NSString *deviceId;
@end
