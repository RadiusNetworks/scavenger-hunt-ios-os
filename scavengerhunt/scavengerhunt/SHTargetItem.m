/*
 * SHTargetItem.m
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

#import "SHTargetItem.h"

@implementation SHTargetItem
{
    float _distance;
    BOOL _found;
    int _iBeaconMinor;
    long _lastSeenAt;
}

-(SHTargetItem *) init {
    self = [super init];
    [self reset];
    return self;
}

-(void)reset {
    self.found = false;
    self.proximity = -1;
    self.distance = -1;
    self.lastSeenAt = 0;
}

-(SHTargetItem *) initWithId: (NSString*) huntId  {
    self = [super init];
    self.huntId = huntId;
    self.found = false;
    self.distance = -1;
    self.proximity = -1;
    self.lastSeenAt = 0;
    return self;
}
-(void) sawIt {
  _lastSeenAt = (long)[[NSDate date] timeIntervalSince1970];
}
-(BOOL) hasItDisappeared {
    // if we have not seen the beacon recently, then adjust its distance to 0
    long now = (long)[[NSDate date] timeIntervalSince1970];
    if (_lastSeenAt > 0) {
        long secondsSinceSeen = now - _lastSeenAt;
        NSLog(@"it has been %ld seconds since we last saw target %@", secondsSinceSeen, self.huntId);
        if (secondsSinceSeen > 15) {
            self.distance = 0;
            return YES;
        }
    }
    return NO;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.huntId = [decoder decodeObjectForKey:@"hunt_id"];
    self.found = [decoder decodeBoolForKey:@"found"];
    self.proximity = -1;
    self.distance = -1;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.huntId forKey:@"hunt_id"];
    [encoder encodeBool:self.found forKey:@"found"];
}


@end
