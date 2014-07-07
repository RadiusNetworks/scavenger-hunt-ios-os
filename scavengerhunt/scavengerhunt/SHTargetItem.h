/*
 * SHTargetItem.h
 * ScavengerHunt
 *
 * Created by David G. Young on 8/28/13.
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

@interface SHTargetItem : NSObject
@property NSString *huntId;
@property float distance;
@property int proximity;
@property BOOL found;
@property long lastSeenAt;
@property NSString *title;
@property NSString *description;
@property double triggerDistance;

-(SHTargetItem *) initWithId: (NSString*) huntId;
-(void) sawIt;
-(void) reset;
-(BOOL) hasItDisappeared;
@end
