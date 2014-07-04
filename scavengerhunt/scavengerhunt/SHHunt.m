/*
 * SHHunt.m
 * ScavengerHunt
 *
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

#import "SHHunt.h"
#import "SHTargetItem.h"

@implementation SHHunt
{
    long _timeStarted;
    long _timeCompleted;
    double _triggerDistance;
    int _targetCount;
    NSDictionary* _customStartScreenData;
    BOOL _instructionDisplayed;
}


+ (SHHunt *)sharedHunt {
        static id instance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[self alloc] init];
        });
        
        return instance;
}


- (void)setTriggerDistance:(double)triggerDistance {
    _triggerDistance = triggerDistance;
}

- (double) triggerDistance {
    return _triggerDistance;
}

- (void)setCustomStartScreenData:(NSDictionary*)customStartScreenData {
    _customStartScreenData = customStartScreenData;
}

- (NSDictionary*) customStartScreenData {
    return _customStartScreenData;
}


- (id)init {
    self = [super init];
    if(self)
    {
        _targetCount = 0;
        _triggerDistance = 10.0;
        _instructionDisplayed = false;
        [self loadFromUserDefaults];
        if (_deviceId == Nil) {
            self.deviceId = [[NSUUID UUID] UUIDString];
        }
        if (_targetList == Nil) {
            [self resize: _targetCount];
        }
    }
    return self;
}

-(void)resize: (int) size {
    _targetCount = size;
    _targetList = [self createTargetListOfSize:_targetCount];
    NSLog(@"initialized target list with %lu items", (unsigned long)_targetList.count);
    
    _timeStarted = 0;
    _timeCompleted = 0;
    _instructionDisplayed = false;
    [self saveToUserDefaults];
}

-(void)clear {
    [self resize: 0];
    _timeStarted = 0;
    _instructionDisplayed = false;
    [self saveToUserDefaults];
    
}
-(void)reset {
    _timeStarted = 0;
    [_targetList enumerateObjectsUsingBlock:^(id targetObj, NSUInteger targetIdx, BOOL *targetStop) {
        SHTargetItem *item = (SHTargetItem *) targetObj;
        item.found = NO;
    }];
   
    [self saveToUserDefaults];
}

-(NSArray *)createTargetListOfSize: (int) numTargets {
    NSMutableArray *targetList = [[NSMutableArray alloc]init];
    for (int i = 0; i < numTargets; i++) {
        [targetList addObject: [[SHTargetItem alloc] initWithId:[NSString stringWithFormat:@"%d",i+1]]];
    }
    return targetList;
}

-(void) start {
    if (_timeStarted == 0) {
        _timeStarted = (long)[[NSDate date] timeIntervalSince1970];
        [self saveToUserDefaults];
    }
}

-(long) elapsedTime {
    if (_timeStarted > 0) {
        long now = (long)[[NSDate date] timeIntervalSince1970];
        return now-_timeStarted;
    }
    return 0;
}

-(BOOL) everythingFound {
    if (_timeCompleted > 0) {
        return true;
    }
    if ([self foundCount] == _targetList.count && _timeCompleted == 0) {
        _timeCompleted = (long)[[NSDate date] timeIntervalSince1970];
        [self saveToUserDefaults];
        return true;
    }
    return false;
}

-(BOOL) instructionScreenDisplayed {
    return _instructionDisplayed;
}

- (int)foundCount {
    __block int count = 0;
    [_targetList enumerateObjectsUsingBlock:^(id targetObj, NSUInteger targetIdx, BOOL *targetStop) {
        SHTargetItem *item = (SHTargetItem *) targetObj;
        if (item.found) {
            count++;
        }
    }];
    return count;
}


- (void) find:(SHTargetItem *) target {
    target.found = YES;
    [self saveToUserDefaults];
}

- (void) saveToUserDefaults{
    NSLog(@"saving to user defaults");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.targetList] forKey:@"sh_target_list"];
    [userDefaults setDouble:_timeStarted forKey:@"sh_time_started"];
    [userDefaults setDouble:_timeCompleted forKey:@"sh_time_completed"];
    [userDefaults setBool:_instructionDisplayed forKey:@"sh_splash_displayed"];
    [userDefaults setObject:self.deviceId forKey:@"sh_device_uuid"];
    [userDefaults setObject:self.customStartScreenData forKey:@"sh_custom_start_screen_data"];
    NSLog(@"begin synchronizing user defaults");
    [userDefaults synchronize];
    NSLog(@"end synchronizing user defaults");
}

- (void) loadFromUserDefaults {
    NSLog(@"loading from defaults");
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    self.targetList = [NSKeyedUnarchiver unarchiveObjectWithData:[currentDefaults objectForKey:@"sh_target_list"]];
    _timeStarted = [currentDefaults doubleForKey:@"sh_time_started"];
    NSLog(@"loaded started time from defaults %ld", _timeStarted);
    _timeCompleted = [currentDefaults doubleForKey:@"sh_time_completed"];
    _instructionDisplayed = [currentDefaults boolForKey:@"sh_splash_displayed"];
    self.deviceId = [currentDefaults stringForKey:@"sh_device_uuid"];
    self.customStartScreenData = [currentDefaults dictionaryForKey:@"sh_custom_start_screen_data"];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //_responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Metric sent successfully");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Metric send FAILED");

}


@end
