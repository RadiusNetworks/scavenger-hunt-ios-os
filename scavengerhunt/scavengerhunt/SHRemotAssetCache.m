/*
 * SHRemoteAssetCache.m
 * scavengerhunt
 *
 * Created by David G. Young on 1/22/14.
 *
 * SHTargetCollectionViewController.h
 * ScavengerHunt
 *
 * Created by David G. Young on 9/4/13.
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

#import <UIKit/UIKit.h>
#import "SHRemoteAssetCache.h"

@implementation SHRemoteAssetCache {
    
}


- (void)downloadAssets:(NSDictionary *) assetUrls {
    __block long assetsToDownload = assetUrls.count;
    __block int failureCount = 0;
    
    NSLog(@"downloadAssets called with count of %lu", (unsigned long)assetUrls.count);
    
    for (NSString *standardizedFilename in [assetUrls allKeys]) {
        NSURL *assetUrl = [assetUrls objectForKey:standardizedFilename];
        NSLog(@"Trying to download asset at %@", assetUrl);
        [self downloadAssetWithURL: assetUrl completionBlock: ^(BOOL succeeded, NSData *data){
            if (succeeded) {
                NSLog(@"Successfully downloaded %@", assetUrl);
                [self saveFileWithName: standardizedFilename data: data];
                assetsToDownload--;
            }
            else {
                NSLog(@"Failed to load %@", assetUrl);
                BOOL retrying = NO;
                    if (self.retinaFallbackEnabled) {
                        
                        //finding which extension has been added to the file name
                        NSString* extension;
                        if ([[assetUrl absoluteString] rangeOfString:@"_260" options:(NSCaseInsensitiveSearch)].location != NSNotFound)
                        {
                            extension = @"_260";
                        } else if ([[assetUrl absoluteString] rangeOfString:@"_312" options:(NSCaseInsensitiveSearch)].location != NSNotFound)
                        {
                            extension = @"_312";
                        } else if ([[assetUrl absoluteString] rangeOfString:@"_624" options:(NSCaseInsensitiveSearch)].location != NSNotFound)
                        {
                            extension = @"_624";
                        } else                         {
                            extension = @"@2x";
                        }
                        
                        long location = [[assetUrl absoluteString] rangeOfString:extension].location;
                        
                        if (location != NSNotFound) {
                            NSLog(@"Cannot download image url with a standard version.  Trying to get standard version.");
                            retrying = YES;
                            
                            //attempting to download filename without extension
                            NSString *nonRetinaAssetUrlString = [[assetUrl absoluteString] stringByReplacingOccurrencesOfString:extension withString:@""];
                            NSURL *nonRetinaAssetUrl = [NSURL URLWithString:nonRetinaAssetUrlString];
                            NSLog(@"Attempting image download from standard URL of %@", nonRetinaAssetUrl);
                            [self downloadAssetWithURL: nonRetinaAssetUrl completionBlock: ^(BOOL succeeded, NSData *data){
                                if (succeeded) {
                                    NSLog(@"Successfully downloaded %@", nonRetinaAssetUrl);
                                    [self saveFileWithName: standardizedFilename data: data];
                                    assetsToDownload--;
                                }
                                else {
                                    
                                    assetsToDownload--;
                                    failureCount++;
                                }
                                if (assetsToDownload == 0) {
                                    if (failureCount == 0) {
                                        [self.delegate remoteAssetLoadSuccess];
                                    }
                                    else {
                                        [self.delegate remoteAssetLoadFail];
                                    }
                                    
                                }

                            }];
                        }
                    }
                if (!retrying) {
                    assetsToDownload--;
                    failureCount++;
                }
            }
            if (assetsToDownload == 0) {
                if (failureCount == 0) {
                    [self.delegate remoteAssetLoadSuccess];
                }
                else {
                    [self.delegate remoteAssetLoadFail];
                }

            }

        }];
        
    }
    
}

- (void)saveFileWithName: (NSString *) filename data: (NSData *) data {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedAssetPath = [documentsDirectory stringByAppendingPathComponent:filename];
    [data writeToFile:savedAssetPath atomically:NO];
    NSLog(@"Saved file to %@", filename);
}

- (UIImage *)getImageByName: (NSString *) name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    NSLog(@"Image %@ has width: %f and heigh: %f", name, img.size.width, img.size.height);
    return img;
}

- (void)downloadAssetWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
                                   if ([httpResponse statusCode] == 200) {
                                       completionBlock(YES,data);
                                   }
                                   else {
                                       NSLog(@"got a %ld status code from request", (long)[httpResponse statusCode]);
                                       completionBlock(NO,data);
                                   }
                                   
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)clear {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                NSLog(@"Cannot remove file %@", fullPath);
            }
            else {
                NSLog(@"Removed image file %@", fullPath);
            }
        }
    } else {
        NSLog(@"Cannot read directory %@", documentsDirectory);
    }
}

@end
