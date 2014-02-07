/*
 * SHTargetImageCache.h
 * scavengerhunt
 *
 * Created by David G. Young on 1/22/14.
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

@protocol SHRemoteAssetCacheDelegate
- (void) remoteAssetLoadSuccess;
- (void) remoteAssetLoadFail;
@end

@interface SHRemoteAssetCache : NSObject
- (void)downloadAssets:(NSDictionary *) assetUrls;
- (UIImage *)getImageByName: (NSString *) name;
- (void)clear;
@property (strong, nonatomic) id <SHRemoteAssetCacheDelegate> delegate;
@property BOOL retinaFallbackEnabled;
@end
